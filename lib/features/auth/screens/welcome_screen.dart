
// ============================================
// FILE: lib/features/auth/screens/welcome_screen.dart
// ============================================

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo
              Icon(
                Icons.message_outlined,
                size: 100,
                color: AppConstants.primaryColor,
              ),
              
              const SizedBox(height: 24),
              
              // App Name
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                AppConstants.appTagline,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppConstants.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Philosophy Points
              _buildPhilosophyPoint(
                context,
                '🌱',
                'No forced interruptions',
              ),
              const SizedBox(height: 16),
              _buildPhilosophyPoint(
                context,
                '💙',
                'You control when to receive',
              ),
              const SizedBox(height: 16),
              _buildPhilosophyPoint(
                context,
                '✨',
                'Shared moments create connection',
              ),
              
              const Spacer(),
              
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.signup);
                  },
                  child: const Text('Get Started'),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Privacy Policy
              TextButton(
                onPressed: () {
                  // Open privacy policy
                },
                child: const Text('Privacy Policy'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhilosophyPoint(BuildContext context, String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}