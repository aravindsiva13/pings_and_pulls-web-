
// ============================================
// FILE: lib/features/home/screens/widgets/pending_pings_section.dart
// ============================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/ping_model.dart';

class PendingPingsSection extends StatelessWidget {
  final List<PingModel> pings;

  const PendingPingsSection({Key? key, required this.pings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending Pings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (pings.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${pings.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (pings.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.noPendingPings,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.pullWhenReady,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pings.length,
            itemBuilder: (context, index) {
              final ping = pings[index];
              return _PingCard(ping: ping);
            },
          ),
      ],
    );
  }
}

class _PingCard extends StatelessWidget {
  final PingModel ping;

  const _PingCard({required this.ping});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.pingDetails,
            arguments: ping.id,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Urgency Indicator
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getUrgencyColor(ping.urgency).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Helpers.getUrgencyEmoji(ping.urgency),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sender ID: ${ping.senderId.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helpers.formatTimestamp(ping.sentAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.chevron_right,
                color: AppConstants.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case AppConstants.urgencyGentle:
        return AppConstants.gentleGreen;
      case AppConstants.urgencyNormal:
        return AppConstants.normalBlue;
      case AppConstants.urgencySometime:
        return AppConstants.sometimeOrange;
      default:
        return AppConstants.normalBlue;
    }
  }
}
