
// ============================================
// FILE: lib/features/pull/screens/pull_experience_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../bloc/pull_bloc.dart';

class PullExperienceScreen extends StatefulWidget {
  final String pingId;

  const PullExperienceScreen({Key? key, required this.pingId}) : super(key: key);

  @override
  State<PullExperienceScreen> createState() => _PullExperienceScreenState();
}

class _PullExperienceScreenState extends State<PullExperienceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    context.read<PullBloc>().add(LoadPingDetails(widget.pingId));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _showMessage = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Moment'),
      ),
      body: BlocBuilder<PullBloc, PullState>(
        builder: (context, state) {
          if (state is PullLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PullPulled || state is PullDetailsLoaded) {
            final ping = state is PullPulled
                ? state.ping
                : (state as PullDetailsLoaded).ping;
            final sender = state is PullPulled
                ? state.sender
                : (state as PullDetailsLoaded).sender;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Gift Opening Animation
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Icon(
                            Icons.card_giftcard,
                            size: 100,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Shared Moment Indicator
                  if (ping.sharedMoment)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppConstants.gentleGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppConstants.gentleGreen,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: AppConstants.gentleGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'You\'re both reading this now',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppConstants.gentleGreen,
                                ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Message Card
                  if (_showMessage)
                    AnimatedOpacity(
                      opacity: _showMessage ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: AppConstants.primaryColor
                                        .withOpacity(0.2),
                                    backgroundImage: sender.photoUrl != null
                                        ? NetworkImage(sender.photoUrl!)
                                        : null,
                                    child: sender.photoUrl == null
                                        ? Text(
                                            sender.displayName[0].toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppConstants.primaryColor,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    sender.displayName,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 16),
                              Text(
                                ping.message,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  if (_showMessage) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<PullBloc>()
                            .add(MarkPingAsRead(widget.pingId));
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.home,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Mark as Complete'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.compose,
                          arguments: {'receiverId': sender.id},
                        );
                      },
                      icon: const Icon(Icons.reply),
                      label: const Text('Reply'),
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}