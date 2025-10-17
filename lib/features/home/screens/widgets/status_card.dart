// ============================================
// FILE: lib/features/home/screens/widgets/status_card.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/user_model.dart';
import '../../bloc/home_bloc.dart';

class StatusCard extends StatelessWidget {
  final UserModel user;

  const StatusCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.displayName[0].toUpperCase(),
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
                        user.displayName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Helpers.getAvailabilityLabel(user.availability),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _getAvailabilityColor(user.availability),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            Text(
              'Your Availability',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            
            const SizedBox(height: 12),
            
            // Availability Buttons
            Row(
              children: [
                Expanded(
                  child: _AvailabilityChip(
                    label: 'Available',
                    isSelected: user.availability == AppConstants.availabilityAvailable,
                    color: Colors.green,
                    onTap: () {
                      context.read<HomeBloc>().add(
                            UpdateAvailability(AppConstants.availabilityAvailable),
                          );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AvailabilityChip(
                    label: 'Busy',
                    isSelected: user.availability == AppConstants.availabilityBusy,
                    color: Colors.orange,
                    onTap: () {
                      context.read<HomeBloc>().add(
                            UpdateAvailability(AppConstants.availabilityBusy),
                          );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _AvailabilityChip(
                    label: 'DND',
                    isSelected: user.availability == AppConstants.availabilityDnd,
                    color: Colors.red,
                    onTap: () {
                      context.read<HomeBloc>().add(
                            UpdateAvailability(AppConstants.availabilityDnd),
                          );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvailabilityColor(String availability) {
    switch (availability) {
      case AppConstants.availabilityAvailable:
        return Colors.green;
      case AppConstants.availabilityBusy:
        return Colors.orange;
      case AppConstants.availabilityDnd:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _AvailabilityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _AvailabilityChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
