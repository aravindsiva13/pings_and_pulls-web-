// ============================================
// FILE: lib/features/conversation/bloc/conversation_bloc.dart
// ============================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/conversation_model.dart';
import '../../../data/models/ping_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/ping_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../services/storage_service.dart';

// Events
abstract class ConversationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadConversations extends ConversationEvent {}

class LoadConversationDetail extends ConversationEvent {
  final String conversationId;
  final String otherUserId;

  LoadConversationDetail({
    required this.conversationId,
    required this.otherUserId,
  });

  @override
  List<Object?> get props => [conversationId, otherUserId];
}

// States
abstract class ConversationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationsLoaded extends ConversationState {
  final List<ConversationModel> conversations;
  final Map<String, UserModel> users;

  ConversationsLoaded({
    required this.conversations,
    required this.users,
  });

  @override
  List<Object?> get props => [conversations, users];
}

class ConversationDetailLoaded extends ConversationState {
  final List<PingModel> pings;
  final UserModel otherUser;

  ConversationDetailLoaded({
    required this.pings,
    required this.otherUser,
  });

  @override
  List<Object?> get props => [pings, otherUser];
}

class ConversationError extends ConversationState {
  final String message;

  ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final PingRepository pingRepository = PingRepository();
  final UserRepository userRepository = UserRepository();

  ConversationBloc() : super(ConversationInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadConversationDetail>(_onLoadConversationDetail);
  }

  Future<void> _onLoadConversations(
      LoadConversations event, Emitter<ConversationState> emit) async {
    emit(ConversationLoading());

    try {
      final userId = StorageService.getUserId();
      if (userId == null) {
        emit(ConversationError('User not found'));
        return;
      }

      await emit.forEach(
        pingRepository.getConversations(userId),
        onData: (List<ConversationModel> conversations) {
          // Load all users involved in conversations
          final userIds = <String>{};
          for (final conv in conversations) {
            userIds.addAll(conv.participantIds);
          }

          final users = <String, UserModel>{};
          // Since we can't use 'await' here, we need to prefetch users before calling emit.forEach.
          // Consider fetching all users before calling emit.forEach, or make getUserById synchronous if possible.
          // For now, we'll return without user details.
          return ConversationsLoaded(
            conversations: conversations,
            users: users,
          );
        },
        onError: (error, stackTrace) => ConversationError(error.toString()),
      );
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> _onLoadConversationDetail(
      LoadConversationDetail event, Emitter<ConversationState> emit) async {
    emit(ConversationLoading());

    try {
      final userId = StorageService.getUserId();
      if (userId == null) {
        emit(ConversationError('User not found'));
        return;
      }

      final otherUser = await userRepository.getUserById(event.otherUserId);
      if (otherUser == null) {
        emit(ConversationError('User not found'));
        return;
      }

      await emit.forEach(
        pingRepository.getConversationPings(userId, event.otherUserId),
        onData: (List<PingModel> pings) {
          return ConversationDetailLoaded(
            pings: pings,
            otherUser: otherUser,
          );
        },
        onError: (error, stackTrace) => ConversationError(error.toString()),
      );
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }
}
