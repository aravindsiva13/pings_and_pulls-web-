
// ============================================
// FILE: lib/services/storage_service.dart
// ============================================

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User ID
  static Future<void> saveUserId(String userId) async {
    await _prefs.setString('userId', userId);
  }

  static String? getUserId() {
    return _prefs.getString('userId');
  }

  static Future<void> removeUserId() async {
    await _prefs.remove('userId');
  }

  // Notification Settings
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool('notifications_enabled', enabled);
  }

  static bool getNotificationsEnabled() {
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  // Quiet Hours
  static Future<void> setQuietHoursStart(String time) async {
    await _prefs.setString('quiet_hours_start', time);
  }

  static String? getQuietHoursStart() {
    return _prefs.getString('quiet_hours_start');
  }

  static Future<void> setQuietHoursEnd(String time) async {
    await _prefs.setString('quiet_hours_end', time);
  }

  static String? getQuietHoursEnd() {
    return _prefs.getString('quiet_hours_end');
  }

  // Read Receipts
  static Future<void> setReadReceiptsEnabled(bool enabled) async {
    await _prefs.setBool('read_receipts_enabled', enabled);
  }

  static bool getReadReceiptsEnabled() {
    return _prefs.getBool('read_receipts_enabled') ?? false;
  }

  // Message Preview
  static Future<void> setMessagePreviewEnabled(bool enabled) async {
    await _prefs.setBool('message_preview_enabled', enabled);
  }

  static bool getMessagePreviewEnabled() {
    return _prefs.getBool('message_preview_enabled') ?? false;
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}