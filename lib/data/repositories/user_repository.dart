
// ============================================
// FILE: lib/data/repositories/user_repository.dart
// ============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pings_and_pulls/core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../../core/constants/firebase_constants.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create user
  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.id)
        .set(user.toFirestore());
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .update(data);
  }

  // Update availability
  Future<void> updateAvailability(String userId, String availability) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .update({
      FirebaseConstants.availability: availability,
      FirebaseConstants.lastSeen: FieldValue.serverTimestamp(),
    });
  }

  // Update FCM token
  Future<void> updateFCMToken(String userId, String token) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .update({FirebaseConstants.fcmToken: token});
  }

  // Get all users (for contacts - simplified version)
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .get();

    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .delete();
  }

  // Stream user
  Stream<UserModel?> streamUser(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }
}
