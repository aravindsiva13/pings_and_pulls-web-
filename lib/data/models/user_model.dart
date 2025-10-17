// ============================================
// FILE: lib/data/models/user_model.dart
// ============================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final String availability;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.displayName,
    this.photoUrl,
    this.phoneNumber,
    required this.availability,
    required this.createdAt,
    this.lastSeen,
    this.fcmToken,
  });

  // From Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      availability: data['availability'] ?? 'available',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSeen: data['lastSeen'] != null 
          ? (data['lastSeen'] as Timestamp).toDate() 
          : null,
      fcmToken: data['fcmToken'],
    );
  }

  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'availability': availability,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'fcmToken': fcmToken,
    };
  }

  // Copy with
  UserModel copyWith({
    String? id,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? availability,
    DateTime? createdAt,
    DateTime? lastSeen,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      availability: availability ?? this.availability,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        photoUrl,
        phoneNumber,
        availability,
        createdAt,
        lastSeen,
        fcmToken,
      ];
}
