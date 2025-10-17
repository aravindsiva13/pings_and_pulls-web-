// // ============================================
// // FILE: lib/features/auth/screens/signup_screen.dart
// // ============================================

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../core/constants/app_constants.dart';
// import '../../../core/router/app_router.dart';
// import '../bloc/auth_bloc.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({Key? key}) : super(key: key);

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _phoneController = TextEditingController();
//   final _otpController = TextEditingController();
//   String? _verificationId;
//   String? _phoneNumber;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     _otpController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//       ),
//       body: BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthCodeSent) {
//             setState(() {
//               _verificationId = state.verificationId;
//               _phoneNumber = state.phoneNumber;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('OTP sent to your phone')),
//             );
//           } else if (state is AuthNeedsProfile) {
//             Navigator.pushReplacementNamed(context, AppRouter.profileSetup);
//           } else if (state is AuthAuthenticated) {
//             Navigator.pushReplacementNamed(context, AppRouter.home);
//           } else if (state is AuthError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message)),
//             );
//           }
//         },
//         builder: (context, state) {
//           final isLoading = state is AuthLoading;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 24),
                
//                 Text(
//                   'Welcome to mindful messaging',
//                   style: Theme.of(context).textTheme.headlineMedium,
//                   textAlign: TextAlign.center,
//                 ),
                
//                 const SizedBox(height: 48),

//                 if (_verificationId == null) ...[
//                   // Phone Number Input
//                   TextField(
//                     controller: _phoneController,
//                     keyboardType: TextInputType.phone,
//                     decoration: const InputDecoration(
//                       labelText: 'Phone Number',
//                       hintText: '+1234567890',
//                       prefixIcon: Icon(Icons.phone),
//                     ),
//                     enabled: !isLoading,
//                   ),
                  
//                   const SizedBox(height: 24),
                  
//                   ElevatedButton(
//                     onPressed: isLoading
//                         ? null
//                         : () {
//                             final phone = _phoneController.text.trim();
//                             if (phone.isNotEmpty) {
//                               context.read<AuthBloc>().add(
//                                     SignInWithPhoneRequested(phone),
//                                   );
//                             }
//                           },
//                     child: isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Text('Send OTP'),
//                   ),
                  
//                   const SizedBox(height: 32),
                  
//                   const Row(
//                     children: [
//                       Expanded(child: Divider()),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Text('OR'),
//                       ),
//                       Expanded(child: Divider()),
//                     ],
//                   ),
                  
//                   const SizedBox(height: 32),
                  
//                   // Google Sign In
//                   OutlinedButton.icon(
//                     onPressed: isLoading
//                         ? null
//                         : () {
//                             context.read<AuthBloc>().add(
//                                   SignInWithGoogleRequested(),
//                                 );
//                           },
//                     icon: Image.network(
//                       'https://www.google.com/favicon.ico',
//                       height: 24,
//                     ),
//                     label: const Text('Continue with Google'),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ] else ...[
//                   // OTP Verification
//                   Text(
//                     'Enter the code sent to $_phoneNumber',
//                     style: Theme.of(context).textTheme.bodyLarge,
//                     textAlign: TextAlign.center,
//                   ),
                  
//                   const SizedBox(height: 24),
                  
//                   TextField(
//                     controller: _otpController,
//                     keyboardType: TextInputType.number,
//                     maxLength: 6,
//                     decoration: const InputDecoration(
//                       labelText: 'OTP Code',
//                       hintText: '000000',
//                       counterText: '',
//                     ),
//                     enabled: !isLoading,
//                   ),
                  
//                   const SizedBox(height: 24),
                  
//                   ElevatedButton(
//                     onPressed: isLoading
//                         ? null
//                         : () {
//                             final otp = _otpController.text.trim();
//                             if (otp.isNotEmpty && _verificationId != null) {
//                               context.read<AuthBloc>().add(
//                                     VerifyOTPRequested(_verificationId!, otp),
//                                   );
//                             }
//                           },
//                     child: isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : const Text('Verify OTP'),
//                   ),
                  
//                   const SizedBox(height: 16),
                  
//                   TextButton(
//                     onPressed: isLoading
//                         ? null
//                         : () {
//                             setState(() {
//                               _verificationId = null;
//                               _phoneNumber = null;
//                               _otpController.clear();
//                             });
//                           },
//                     child: const Text('Change Phone Number'),
//                   ),
//                 ],
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


//2-WEB



import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../bloc/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  String? _phoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthCodeSent) {
            setState(() {
              _verificationId = state.verificationId;
              _phoneNumber = state.phoneNumber;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent to your phone')),
            );
          } else if (state is AuthNeedsProfile) {
            Navigator.pushReplacementNamed(context, AppRouter.profileSetup);
          } else if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, AppRouter.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to mindful messaging',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    if (_verificationId == null && !isWeb) ...[
                      // Phone Number Input (Mobile only)
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+1234567890',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final phone = _phoneController.text.trim();
                                if (phone.isNotEmpty) {
                                  context.read<AuthBloc>().add(
                                        SignInWithPhoneRequested(phone),
                                      );
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Text('Send OTP'),
                      ),
                      const SizedBox(height: 32),
                      const Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR'),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ] else if (_verificationId == null && isWeb) ...[
                      // Web-only signup message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'On web, you can only sign in with Google. Phone authentication is available on mobile apps.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ] else if (_verificationId != null) ...[
                      // OTP Verification (Mobile only)
                      Text(
                        'Enter the code sent to $_phoneNumber',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          labelText: 'OTP Code',
                          hintText: '000000',
                          counterText: '',
                        ),
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final otp = _otpController.text.trim();
                                if (otp.isNotEmpty && _verificationId != null) {
                                  context.read<AuthBloc>().add(
                                        VerifyOTPRequested(_verificationId!, otp),
                                      );
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Text('Verify OTP'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _verificationId = null;
                                  _phoneNumber = null;
                                  _otpController.clear();
                                });
                              },
                        child: const Text('Change Phone Number'),
                      ),
                    ],
                    // Google Sign In (Web + Mobile)
                    OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(
                                    SignInWithGoogleRequested(),
                                  );
                            },
                      icon: const Icon(Icons.account_circle),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}