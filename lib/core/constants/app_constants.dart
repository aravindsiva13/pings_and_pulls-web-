// ============================================
// FILE: lib/core/constants/app_constants.dart
// ============================================

import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Pings & Pulls';
  static const String appTagline = 'Mindful messaging without anxiety';
  
  // Colors
  static const Color primaryColor = Color(0xFF6B4EFF);
  static const Color gentleGreen = Color(0xFF4CAF50);
  static const Color normalBlue = Color(0xFF2196F3);
  static const Color sometimeOrange = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  
  // Urgency Levels
  static const String urgencyGentle = 'gentle';
  static const String urgencyNormal = 'normal';
  static const String urgencySometime = 'sometime';
  
  // Ping Status
  static const String statusPending = 'pending';
  static const String statusPulled = 'pulled';
  static const String statusRead = 'read';
  
  // Availability Status
  static const String availabilityAvailable = 'available';
  static const String availabilityBusy = 'busy';
  static const String availabilityDnd = 'do-not-disturb';
  
  // Strings
  static const String noMessagesYet = 'No messages yet';
  static const String noPendingPings = 'No pending pings';
  static const String pullWhenReady = 'Pull when you\'re ready';
  
  // Limits
  static const int maxMessageLength = 500;
  static const int maxDisplayNameLength = 50;
}

// ============================================
// FILE: lib/core/constants/firebase_constants.dart
// ============================================

class FirebaseConstants {
  // Collection Names
  static const String usersCollection = 'users';
  static const String pingsCollection = 'pings';
  static const String conversationsCollection = 'conversations';
  
  // User Fields
  static const String displayName = 'displayName';
  static const String photoUrl = 'photoUrl';
  static const String phoneNumber = 'phoneNumber';
  static const String availability = 'availability';
  static const String createdAt = 'createdAt';
  static const String lastSeen = 'lastSeen';
  static const String fcmToken = 'fcmToken';
  
  // Ping Fields
  static const String senderId = 'senderId';
  static const String receiverId = 'receiverId';
  static const String message = 'message';
  static const String urgency = 'urgency';
  static const String status = 'status';
  static const String sentAt = 'sentAt';
  static const String pulledAt = 'pulledAt';
  static const String readAt = 'readAt';
  static const String sharedMoment = 'sharedMoment';
  
  // Conversation Fields
  static const String participantIds = 'participantIds';
  static const String lastMessage = 'lastMessage';
  static const String lastMessageAt = 'lastMessageAt';
  static const String unreadCount = 'unreadCount';
}
