
// ============================================
// FILE: lib/features/pull/screens/ping_details_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/helpers.dart';
import '../bloc/pull_bloc.dart';

class PingDetailsScreen extends StatefulWidget {
  final String pingId;

  const PingDetailsScreen({Key? key, required this.pingId}) : super(key: key);

  @override
  State<PingDetailsScreen> createState() => _PingDetailsScreenState();
}

class _PingDetailsScreenState extends State<PingDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PullBloc>().add(LoadPingDetails(widget.pingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ping Details'),
      ),
      body: BlocConsumer<PullBloc, PullState>(
        listener: (context, state) {
          if (state is PullPulled) {
            // Navigate to pull experience
            Navigator.pushReplacementNamed(
              context,
              AppRouter.pullExperience,
              arguments: widget.pingId,
            );
          } else if (state is PullError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PullLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PullError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PullBloc>().add(LoadPingDetails(widget.pingId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PullDetailsLoaded) {
            final ping = state.ping;
            final sender = state.sender;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sender Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                AppConstants.primaryColor.withOpacity(0.2),
                            backgroundImage: sender.photoUrl != null
                                ? NetworkImage(sender.photoUrl!)
                                : null,
                            child: sender.photoUrl == null
                                ? Text(
                                    sender.displayName[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppConstants.primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sender.displayName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'sent you a ping',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppConstants.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ping Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    Helpers.getUrgencyEmoji(ping.urgency),
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    Helpers.getUrgencyLabel(ping.urgency),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  ping.status.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppConstants.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Sent ${Helpers.formatTimestamp(ping.sentAt)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Message Preview (if enabled in settings)
                  Card(
                    color: AppConstants.gentleGreen.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.card_giftcard,
                            size: 64,
                            color: AppConstants.gentleGreen,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'A message awaits you',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppConstants.gentleGreen,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pull when you\'re ready to read',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pull Now Button
                  ElevatedButton.icon(
                    onPressed: state is PullPulling
                        ? null
                        : () {
                            context
                                .read<PullBloc>()
                                .add(PullPingNow(widget.pingId));
                          },
                    icon: const Icon(Icons.download),
                    label: state is PullPulling
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Pull Now'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Pull Later Button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Pull Later'),
                  ),
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
