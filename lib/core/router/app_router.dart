
// ============================================
// FILE: lib/core/router/app_router.dart
// ============================================

import 'package:flutter/material.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/compose/screens/compose_screen.dart';
import '../../features/pull/screens/ping_details_screen.dart';
import '../../features/pull/screens/pull_experience_screen.dart';
import '../../features/conversation/screens/conversation_list_screen.dart';
import '../../features/conversation/screens/conversation_detail_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

class AppRouter {
  static const String welcome = '/';
  static const String signup = '/signup';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String compose = '/compose';
  static const String pingDetails = '/ping-details';
  static const String pullExperience = '/pull-experience';
  static const String conversationList = '/conversations';
  static const String conversationDetail = '/conversation-detail';
  static const String settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      
      case profileSetup:
        return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
      
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case compose:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ComposeScreen(receiverId: args?['receiverId']),
        );
      
      case pingDetails:
        final pingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PingDetailsScreen(pingId: pingId),
        );
      
      case pullExperience:
        final pingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PullExperienceScreen(pingId: pingId),
        );
      
      case conversationList:
        return MaterialPageRoute(builder: (_) => const ConversationListScreen());
      
      case conversationDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ConversationDetailScreen(
            conversationId: args['conversationId'],
            otherUserId: args['otherUserId'],
          ),
        );
      
      case AppRouter.settings: 
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}