
// ============================================
// FILE: lib/app.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/compose/bloc/compose_bloc.dart';
import 'features/pull/bloc/pull_bloc.dart';
import 'features/conversation/bloc/conversation_bloc.dart';
import 'features/settings/bloc/settings_bloc.dart';

class PingsAndPullsApp extends StatelessWidget {
  const PingsAndPullsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC - Global
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepository(),
          )..add(AppStarted()),
        ),
        
        // Home BLoC
        BlocProvider(
          create: (context) => HomeBloc(),
        ),
        
        // Compose BLoC
        BlocProvider(
          create: (context) => ComposeBloc(),
        ),
        
        // Pull BLoC
        BlocProvider(
          create: (context) => PullBloc(),
        ),
        
        // Conversation BLoC
        BlocProvider(
          create: (context) => ConversationBloc(),
        ),
        
        // Settings BLoC
        BlocProvider(
          create: (context) => SettingsBloc(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Handle auth state changes globally if needed
          // For example, navigate to home when authenticated
        },
        child: MaterialApp(
          title: 'Pings & Pulls',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

// Auth Wrapper to handle initial routing based on auth state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return const _HomeWrapper();
        }

        if (state is AuthNeedsProfile) {
          return const _ProfileSetupWrapper();
        }

        // AuthUnauthenticated or AuthError
        return const _WelcomeWrapper();
      },
    );
  }
}

// Wrapper widgets for different initial screens
class _WelcomeWrapper extends StatelessWidget {
  const _WelcomeWrapper();

  @override
  Widget build(BuildContext context) {
    // Import after all other imports
    return const Placeholder(); // Will be replaced by WelcomeScreen from router
  }
}

class _ProfileSetupWrapper extends StatelessWidget {
  const _ProfileSetupWrapper();

  @override
  Widget build(BuildContext context) {
    // Import after all other imports
    return const Placeholder(); // Will be replaced by ProfileSetupScreen from router
  }
}

class _HomeWrapper extends StatelessWidget {
  const _HomeWrapper();

  @override
  Widget build(BuildContext context) {
    // Import after all other imports
    return const Placeholder(); // Will be replaced by HomeScreen from router
  }
}

// Note: The AuthWrapper uses Placeholder temporarily.
// In production, you would directly import and use:
// - WelcomeScreen for unauthenticated
// - ProfileSetupScreen for needs profile
// - HomeScreen for authenticated

// Better implementation of AuthWrapper:
/*
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          // Navigate to home using named route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthNeedsProfile) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, AppRouter.profileSetup);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Default to welcome
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, AppRouter.welcome);
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
*/