
// ============================================
// FILE: lib/features/settings/screens/settings_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../bloc/settings_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              _buildSection(
                context,
                'Notifications',
                [
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive gentle pings'),
                    value: state.notificationsEnabled,
                    onChanged: (value) {
                      context
                          .read<SettingsBloc>()
                          .add(UpdateNotifications(value));
                    },
                  ),
                  ListTile(
                    title: const Text('Quiet Hours'),
                    subtitle: Text(
                      state.quietHoursStart != null &&
                              state.quietHoursEnd != null
                          ? '${state.quietHoursStart} - ${state.quietHoursEnd}'
                          : 'Not set',
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () => _showQuietHoursPicker(context, state),
                  ),
                ],
              ),
              const Divider(),
              _buildSection(
                context,
                'Privacy',
                [
                  SwitchListTile(
                    title: const Text('Read Receipts'),
                    subtitle:
                        const Text('Let senders know when you read messages'),
                    value: state.readReceiptsEnabled,
                    onChanged: (value) {
                      context
                          .read<SettingsBloc>()
                          .add(UpdateReadReceipts(value));
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Message Preview'),
                    subtitle: const Text('Show message preview in details'),
                    value: state.messagePreviewEnabled,
                    onChanged: (value) {
                      context
                          .read<SettingsBloc>()
                          .add(UpdateMessagePreview(value));
                    },
                  ),
                ],
              ),
              const Divider(),
              _buildSection(
                context,
                'Account',
                [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.orange),
                    title: const Text('Sign Out'),
                    onTap: () => _showSignOutDialog(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Delete Account'),
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
              const Divider(),
              _buildSection(
                context,
                'About',
                [
                  ListTile(
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0 (Phase 1)'),
                  ),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // Open privacy policy
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy policy coming soon'),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () {
                      // Open terms
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms of service coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  void _showQuietHoursPicker(BuildContext context, SettingsState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Quiet Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(state.quietHoursStart ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  final timeString = time.format(context);
                  context
                      .read<SettingsBloc>()
                      .add(UpdateQuietHours(start: timeString));
                }
              },
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(state.quietHoursEnd ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  final timeString = time.format(context);
                  context
                      .read<SettingsBloc>()
                      .add(UpdateQuietHours(end: timeString));
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.welcome,
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(DeleteAccountRequested());
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.welcome,
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}