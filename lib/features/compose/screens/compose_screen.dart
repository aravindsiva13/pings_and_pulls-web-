
// ============================================
// FILE: lib/features/compose/screens/compose_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/user_model.dart';
import '../bloc/compose_bloc.dart';

class ComposeScreen extends StatefulWidget {
  final String? receiverId;

  const ComposeScreen({Key? key, this.receiverId}) : super(key: key);

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  
  UserModel? _selectedReceiver;
  String _selectedUrgency = AppConstants.urgencyNormal;

  @override
  void initState() {
    super.initState();
    context.read<ComposeBloc>().add(LoadContacts());
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendPing() {
    if (_formKey.currentState!.validate() && _selectedReceiver != null) {
      context.read<ComposeBloc>().add(
            SendPing(
              receiverId: _selectedReceiver!.id,
              message: _messageController.text.trim(),
              urgency: _selectedUrgency,
            ),
          );
    } else if (_selectedReceiver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recipient')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose Ping'),
      ),
      body: BlocConsumer<ComposeBloc, ComposeState>(
        listener: (context, state) {
          if (state is ComposeSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ping sent successfully!')),
            );
            Navigator.pop(context);
          } else if (state is ComposeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ComposeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isSending = state is ComposeSending;
          final contacts = state is ComposeContactsLoaded ? state.contacts : <UserModel>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Recipient Selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<UserModel>(
                            value: _selectedReceiver,
                            decoration: const InputDecoration(
                              hintText: 'Select a recipient',
                              prefixIcon: Icon(Icons.person),
                            ),
                            items: contacts.map((contact) {
                              return DropdownMenuItem<UserModel>(
                                value: contact,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppConstants.primaryColor
                                          .withOpacity(0.2),
                                      backgroundImage: contact.photoUrl != null
                                          ? NetworkImage(contact.photoUrl!)
                                          : null,
                                      child: contact.photoUrl == null
                                          ? Text(
                                              contact.displayName[0]
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppConstants.primaryColor,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(contact.displayName),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: isSending
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedReceiver = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Message Input
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Message:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _messageController,
                            maxLines: 5,
                            maxLength: AppConstants.maxMessageLength,
                            decoration: const InputDecoration(
                              hintText: 'Write your mindful message...',
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            validator: Validators.validateMessage,
                            enabled: !isSending,
                          ),
                          Text(
                            '${_messageController.text.length}/${AppConstants.maxMessageLength}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppConstants.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Urgency Selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Urgency Level:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _UrgencyOption(
                                  urgency: AppConstants.urgencyGentle,
                                  emoji: Helpers.getUrgencyEmoji(
                                      AppConstants.urgencyGentle),
                                  label: 'Gentle',
                                  color: AppConstants.gentleGreen,
                                  isSelected: _selectedUrgency ==
                                      AppConstants.urgencyGentle,
                                  onTap: isSending
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedUrgency =
                                                AppConstants.urgencyGentle;
                                          });
                                        },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _UrgencyOption(
                                  urgency: AppConstants.urgencyNormal,
                                  emoji: Helpers.getUrgencyEmoji(
                                      AppConstants.urgencyNormal),
                                  label: 'Normal',
                                  color: AppConstants.normalBlue,
                                  isSelected: _selectedUrgency ==
                                      AppConstants.urgencyNormal,
                                  onTap: isSending
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedUrgency =
                                                AppConstants.urgencyNormal;
                                          });
                                        },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _UrgencyOption(
                                  urgency: AppConstants.urgencySometime,
                                  emoji: Helpers.getUrgencyEmoji(
                                      AppConstants.urgencySometime),
                                  label: 'Sometime',
                                  color: AppConstants.sometimeOrange,
                                  isSelected: _selectedUrgency ==
                                      AppConstants.urgencySometime,
                                  onTap: isSending
                                      ? null
                                      : () {
                                          setState(() {
                                            _selectedUrgency =
                                                AppConstants.urgencySometime;
                                          });
                                        },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Send Button
                  ElevatedButton(
                    onPressed: isSending ? null : _sendPing,
                    child: isSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send Ping'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UrgencyOption extends StatelessWidget {
  final String urgency;
  final String emoji;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _UrgencyOption({
    required this.urgency,
    required this.emoji,
    required this.label,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}