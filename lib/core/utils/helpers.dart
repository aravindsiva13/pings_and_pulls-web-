
// ============================================
// FILE: lib/core/utils/helpers.dart
// ============================================

import 'package:intl/intl.dart';

class Helpers {
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  static String formatTime(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  static String getUrgencyEmoji(String urgency) {
    switch (urgency) {
      case 'gentle':
        return '🌱';
      case 'normal':
        return '💙';
      case 'sometime':
        return '⏰';
      default:
        return '💙';
    }
  }

  static String getUrgencyLabel(String urgency) {
    switch (urgency) {
      case 'gentle':
        return 'Gentle';
      case 'normal':
        return 'Normal';
      case 'sometime':
        return 'Sometime';
      default:
        return 'Normal';
    }
  }

  static String getAvailabilityLabel(String availability) {
    switch (availability) {
      case 'available':
        return 'Available';
      case 'busy':
        return 'Busy';
      case 'do-not-disturb':
        return 'Do Not Disturb';
      default:
        return 'Available';
    }
  }
}
