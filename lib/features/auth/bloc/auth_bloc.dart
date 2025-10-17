// ============================================
// FILE: lib/features/auth/bloc/auth_bloc.dart
// ============================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../services/storage_service.dart';
import '../../../services/firebase_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInWithPhoneRequested extends AuthEvent {
  final String phoneNumber;
  SignInWithPhoneRequested(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOTPRequested extends AuthEvent {
  final String verificationId;
  final String otp;
  VerifyOTPRequested(this.verificationId, this.otp);
  @override
  List<Object?> get props => [verificationId, otp];
}

class SignInWithGoogleRequested extends AuthEvent {}

class CompleteProfileRequested extends AuthEvent {
  final String displayName;
  final String? photoUrl;
  CompleteProfileRequested(this.displayName, this.photoUrl);
  @override
  List<Object?> get props => [displayName, photoUrl];
}

class SignOutRequested extends AuthEvent {}

class DeleteAccountRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthCodeSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  AuthCodeSent(this.verificationId, this.phoneNumber);
  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

class AuthNeedsProfile extends AuthState {
  final String userId;
  AuthNeedsProfile(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository = UserRepository();

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInWithPhoneRequested>(_onSignInWithPhone);
    on<VerifyOTPRequested>(_onVerifyOTP);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<CompleteProfileRequested>(_onCompleteProfile);
    on<SignOutRequested>(_onSignOut);
    on<DeleteAccountRequested>(_onDeleteAccount);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    await StorageService.initialize();
    
    final user = authRepository.currentUser;
    if (user != null) {
      final userModel = await userRepository.getUserById(user.uid);
      if (userModel != null) {
        await StorageService.saveUserId(user.uid);
        emit(AuthAuthenticated(userModel));
      } else {
        emit(AuthNeedsProfile(user.uid));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithPhone(
      SignInWithPhoneRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await authRepository.signInWithPhoneNumber(
        event.phoneNumber,
        (credential) async {
          // Auto verification
          final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
          final userModel = await userRepository.getUserById(userCred.user!.uid);
          
          if (userModel != null) {
            emit(AuthAuthenticated(userModel));
          } else {
            emit(AuthNeedsProfile(userCred.user!.uid));
          }
        },
        (error) {
          emit(AuthError(error.message ?? 'Phone verification failed'));
        },
        (verificationId, resendToken) {
          emit(AuthCodeSent(verificationId, event.phoneNumber));
        },
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOTP(
      VerifyOTPRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final userCredential = await authRepository.verifyOTP(
        event.verificationId,
        event.otp,
      );

      final userModel = await userRepository.getUserById(userCredential.user!.uid);
      
      if (userModel != null) {
        await StorageService.saveUserId(userCredential.user!.uid);
        emit(AuthAuthenticated(userModel));
      } else {
        emit(AuthNeedsProfile(userCredential.user!.uid));
      }
    } catch (e) {
      emit(AuthError('Invalid OTP. Please try again.'));
    }
  }

  Future<void> _onSignInWithGoogle(
      SignInWithGoogleRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final userCredential = await authRepository.signInWithGoogle();
      final userModel = await userRepository.getUserById(userCredential.user!.uid);
      
      if (userModel != null) {
        await StorageService.saveUserId(userCredential.user!.uid);
        emit(AuthAuthenticated(userModel));
      } else {
        emit(AuthNeedsProfile(userCredential.user!.uid));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCompleteProfile(
      CompleteProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final currentUser = authRepository.currentUser;
      if (currentUser == null) {
        emit(AuthError('No user found'));
        return;
      }

      // Get FCM token
      final fcmToken = await FirebaseService.getFCMToken();

      final userModel = UserModel(
        id: currentUser.uid,
        displayName: event.displayName,
        photoUrl: event.photoUrl ?? currentUser.photoURL,
        phoneNumber: currentUser.phoneNumber,
        availability: 'available',
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
        fcmToken: fcmToken,
      );

      await userRepository.createUser(userModel);
      await StorageService.saveUserId(currentUser.uid);
      
      emit(AuthAuthenticated(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      await authRepository.signOut();
      await StorageService.clearAll();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
      DeleteAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    try {
      final userId = authRepository.currentUser?.uid;
      if (userId != null) {
        await userRepository.deleteUser(userId);
        await authRepository.deleteAccount();
        await StorageService.clearAll();
      }
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
