// // ============================================
// // FILE: lib/data/repositories/auth_repository.dart
// // ============================================

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthRepository {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   // Get current user
//   User? get currentUser => _auth.currentUser;

//   // Auth state changes
//   Stream<User?> get authStateChanges => _auth.authStateChanges();

//   // Sign in with phone number (SMS)
//   Future<void> signInWithPhoneNumber(
//     String phoneNumber,
//     Function(PhoneAuthCredential) onVerificationCompleted,
//     Function(FirebaseAuthException) onVerificationFailed,
//     Function(String, int?) onCodeSent,
//   ) async {
//     await _auth.verifyPhoneNumber(
//       phoneNumber: phoneNumber,
//       verificationCompleted: onVerificationCompleted,
//       verificationFailed: onVerificationFailed,
//       codeSent: onCodeSent,
//       codeAutoRetrievalTimeout: (String verificationId) {},
//       timeout: const Duration(seconds: 60),
//     );
//   }

//   // Verify OTP
//   Future<UserCredential> verifyOTP(String verificationId, String otp) async {
//     final credential = PhoneAuthProvider.credential(
//       verificationId: verificationId,
//       smsCode: otp,
//     );
//     return await _auth.signInWithCredential(credential);
//   }

//   // Sign in with Google
//   Future<UserCredential> signInWithGoogle() async {
//     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
//     if (googleUser == null) {
//       throw Exception('Google sign in cancelled');
//     }

//     final GoogleSignInAuthentication googleAuth = 
//         await googleUser.authentication;

//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     return await _auth.signInWithCredential(credential);
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await Future.wait([
//       _auth.signOut(),
//       _googleSignIn.signOut(),
//     ]);
//   }

//   // Delete account
//   Future<void> deleteAccount() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       await user.delete();
//     }
//   }
// }


//2-WEB

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: kIsWeb
        ? '330079705329-abcd1234.apps.googleusercontent.com' // Web client ID
        : null,
  );

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Phone sign-in (not available on web)
  Future<void> signInWithPhoneNumber(
    String phoneNumber,
    Function(PhoneAuthCredential) onVerificationCompleted,
    Function(FirebaseAuthException) onVerificationFailed,
    Function(String, int?) onCodeSent,
  ) async {
    if (kIsWeb) {
      throw Exception('Phone authentication not available on web');
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Google sign in cancelled');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}

