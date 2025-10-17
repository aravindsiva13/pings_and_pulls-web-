
// ============================================
// FILE: lib/data/models/ping_model.dart
// ============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PingModel extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String urgency; // gentle, normal, sometime
  final String status; // pending, pulled, read
  final DateTime sentAt;
  final DateTime? pulledAt;
  final DateTime? readAt;
  final bool sharedMoment;

  const PingModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.urgency,
    required this.status,
    required this.sentAt,
    this.pulledAt,
    this.readAt,
    this.sharedMoment = false,
  });

  // From Firestore
  factory PingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PingModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      urgency: data['urgency'] ?? 'normal',
      status: data['status'] ?? 'pending',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      pulledAt: data['pulledAt'] != null 
          ? (data['pulledAt'] as Timestamp).toDate() 
          : null,
      readAt: data['readAt'] != null 
          ? (data['readAt'] as Timestamp).toDate() 
          : null,
      sharedMoment: data['sharedMoment'] ?? false,
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'urgency': urgency,
      'status': status,
      'sentAt': Timestamp.fromDate(sentAt),
      'pulledAt': pulledAt != null ? Timestamp.fromDate(pulledAt!) : null,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'sharedMoment': sharedMoment,
    };
  }

  // Copy with
  PingModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    String? urgency,
    String? status,
    DateTime? sentAt,
    DateTime? pulledAt,
    DateTime? readAt,
    bool? sharedMoment,
  }) {
    return PingModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      pulledAt: pulledAt ?? this.pulledAt,
      readAt: readAt ?? this.readAt,
      sharedMoment: sharedMoment ?? this.sharedMoment,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        message,
        urgency,
        status,
        sentAt,
        pulledAt,
        readAt,
        sharedMoment,
      ];
}
