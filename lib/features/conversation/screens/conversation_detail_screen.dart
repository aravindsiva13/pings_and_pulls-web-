
// ============================================
// FILE: lib/features/conversation/screens/conversation_detail_screen.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/helpers.dart';
import '../../../services/storage_service.dart';
import '../bloc/conversation_bloc.dart';

class ConversationDetailScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserId;

  const ConversationDetailScreen({
    Key? key,
    required this.conversationId,
    required this.otherUserId,
  }) : super(key: key);

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationBloc>().add(
          LoadConversationDetail(
            conversationId: widget.conversationId,
            otherUserId: widget.otherUserId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ConversationBloc, ConversationState>(
          builder: (context, state) {
            if (state is ConversationDetailLoaded) {
              return Text(state.otherUser.displayName);
            }
            return const Text('Conversation');
          },
        ),
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          if (state is ConversationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ConversationBloc>().add(
                            LoadConversationDetail(
                              conversationId: widget.conversationId,
                              otherUserId: widget.otherUserId,
                            ),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ConversationDetailLoaded) {
            if (state.pings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.noMessagesYet,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppConstants.textSecondary,
                          ),
                    ),
                  ],
                ),
              );
            }

            final currentUserId = StorageService.getUserId();

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.pings.length,
                    itemBuilder: (context, index) {
                      final ping = state.pings[index];
                      final isSentByMe = ping.senderId == currentUserId;

                      return _MessageBubble(
                        ping: ping,
                        isSentByMe: isSentByMe,
                        otherUser: state.otherUser,
                      );
                    },
                  ),
                ),
                _buildComposeBar(context, state.otherUser.id),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildComposeBar(BuildContext context, String receiverId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.compose,
                  arguments: {'receiverId': receiverId},
                );
              },
              icon: const Icon(Icons.create),
              label: const Text('Send Ping'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic ping;
  final bool isSentByMe;
  final dynamic otherUser;

  const _MessageBubble({
    required this.ping,
    required this.isSentByMe,
    required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSentByMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppConstants.primaryColor.withOpacity(0.2),
              backgroundImage: otherUser.photoUrl != null
                  ? NetworkImage(otherUser.photoUrl!)
                  : null,
              child: otherUser.photoUrl == null
                  ? Text(
                      otherUser.displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? AppConstants.primaryColor
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ping.message,
                    style: TextStyle(
                      color: isSentByMe ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Helpers.getUrgencyEmoji(ping.urgency),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Helpers.formatTimestamp(ping.sentAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSentByMe
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}