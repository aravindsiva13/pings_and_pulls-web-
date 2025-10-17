
// ============================================
// FILE: lib/data/repositories/ping_repository.dart
// ============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pings_and_pulls/core/constants/app_constants.dart';
import '../models/ping_model.dart';
import '../models/conversation_model.dart';
import '../../core/constants/firebase_constants.dart';

class PingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send ping
  Future<String> sendPing(PingModel ping) async {
    final docRef = await _firestore
        .collection(FirebaseConstants.pingsCollection)
        .add(ping.toFirestore());

    // Update or create conversation
    await _updateConversation(ping);

    return docRef.id;
  }

  // Get ping by ID
  Future<PingModel?> getPingById(String pingId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.pingsCollection)
        .doc(pingId)
        .get();

    if (doc.exists) {
      return PingModel.fromFirestore(doc);
    }
    return null;
  }

  // Get pending pings for user
  Stream<List<PingModel>> getPendingPings(String userId) {
    return _firestore
        .collection(FirebaseConstants.pingsCollection)
        .where(FirebaseConstants.receiverId, isEqualTo: userId)
        .where(FirebaseConstants.status, isEqualTo: 'pending')
        .orderBy(FirebaseConstants.sentAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PingModel.fromFirestore(doc))
            .toList());
  }

  // Pull ping (mark as pulled)
  Future<void> pullPing(String pingId) async {
    await _firestore
        .collection(FirebaseConstants.pingsCollection)
        .doc(pingId)
        .update({
      FirebaseConstants.status: 'pulled',
      FirebaseConstants.pulledAt: FieldValue.serverTimestamp(),
      FirebaseConstants.sharedMoment: true,
    });
  }

  // Mark ping as read
  Future<void> markAsRead(String pingId) async {
    await _firestore
        .collection(FirebaseConstants.pingsCollection)
        .doc(pingId)
        .update({
      FirebaseConstants.status: 'read',
      FirebaseConstants.readAt: FieldValue.serverTimestamp(),
    });
  }

  // Get conversation pings
  Stream<List<PingModel>> getConversationPings(
      String userId, String otherUserId) {
    return _firestore
        .collection(FirebaseConstants.pingsCollection)
        .where(FirebaseConstants.senderId, whereIn: [userId, otherUserId])
        .orderBy(FirebaseConstants.sentAt, descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PingModel.fromFirestore(doc))
          .where((ping) =>
              (ping.senderId == userId && ping.receiverId == otherUserId) ||
              (ping.senderId == otherUserId && ping.receiverId == userId))
          .toList();
    });
  }

  // Get all conversations for user
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _firestore
        .collection(FirebaseConstants.conversationsCollection)
        .where(FirebaseConstants.participantIds, arrayContains: userId)
        .orderBy(FirebaseConstants.lastMessageAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc))
            .toList());
  }

  // Update conversation after sending ping
  Future<void> _updateConversation(PingModel ping) async {
    final conversationId = _getConversationId(ping.senderId, ping.receiverId);
    
    final docRef = _firestore
        .collection(FirebaseConstants.conversationsCollection)
        .doc(conversationId);

    final doc = await docRef.get();

    if (doc.exists) {
      // Update existing conversation
      final conversation = ConversationModel.fromFirestore(doc);
      final newUnreadCount = Map<String, int>.from(conversation.unreadCount);
      newUnreadCount[ping.receiverId] = (newUnreadCount[ping.receiverId] ?? 0) + 1;

      await docRef.update({
        FirebaseConstants.lastMessage: ping.message,
        FirebaseConstants.lastMessageAt: FieldValue.serverTimestamp(),
        FirebaseConstants.unreadCount: newUnreadCount,
      });
    } else {
      // Create new conversation
      final newConversation = ConversationModel(
        id: conversationId,
        participantIds: [ping.senderId, ping.receiverId],
        lastMessage: ping.message,
        lastMessageAt: ping.sentAt,
        unreadCount: {
          ping.senderId: 0,
          ping.receiverId: 1,
        },
      );

      await docRef.set(newConversation.toFirestore());
    }
  }

  // Reset unread count
  Future<void> resetUnreadCount(String conversationId, String userId) async {
    await _firestore
        .collection(FirebaseConstants.conversationsCollection)
        .doc(conversationId)
        .update({
      'unreadCount.$userId': 0,
    });
  }

  // Helper: Generate conversation ID
  String _getConversationId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Stream ping
  Stream<PingModel?> streamPing(String pingId) {
    return _firestore
        .collection(FirebaseConstants.pingsCollection)
        .doc(pingId)
        .snapshots()
        .map((doc) => doc.exists ? PingModel.fromFirestore(doc) : null);
  }
}