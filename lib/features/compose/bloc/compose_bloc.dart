// ============================================
// FILE: lib/features/compose/bloc/compose_bloc.dart
// ============================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/ping_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/ping_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../services/storage_service.dart';

// Events
abstract class ComposeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadContacts extends ComposeEvent {}

class SendPing extends ComposeEvent {
  final String receiverId;
  final String message;
  final String urgency;

  SendPing({
    required this.receiverId,
    required this.message,
    required this.urgency,
  });

  @override
  List<Object?> get props => [receiverId, message, urgency];
}

// States
abstract class ComposeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ComposeInitial extends ComposeState {}

class ComposeLoading extends ComposeState {}

class ComposeContactsLoaded extends ComposeState {
  final List<UserModel> contacts;

  ComposeContactsLoaded(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class ComposeSending extends ComposeState {}

class ComposeSent extends ComposeState {
  final String pingId;

  ComposeSent(this.pingId);

  @override
  List<Object?> get props => [pingId];
}

class ComposeError extends ComposeState {
  final String message;

  ComposeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ComposeBloc extends Bloc<ComposeEvent, ComposeState> {
  final UserRepository userRepository = UserRepository();
  final PingRepository pingRepository = PingRepository();

  ComposeBloc() : super(ComposeInitial()) {
    on<LoadContacts>(_onLoadContacts);
    on<SendPing>(_onSendPing);
  }

  Future<void> _onLoadContacts(
      LoadContacts event, Emitter<ComposeState> emit) async {
    emit(ComposeLoading());

    try {
      final userId = StorageService.getUserId();
      if (userId == null) {
        emit(ComposeError('User not found'));
        return;
      }

      final allUsers = await userRepository.getAllUsers();
      final contacts = allUsers.where((user) => user.id != userId).toList();

      emit(ComposeContactsLoaded(contacts));
    } catch (e) {
      emit(ComposeError(e.toString()));
    }
  }

  Future<void> _onSendPing(SendPing event, Emitter<ComposeState> emit) async {
    emit(ComposeSending());

    try {
      final userId = StorageService.getUserId();
      if (userId == null) {
        emit(ComposeError('User not found'));
        return;
      }

      final ping = PingModel(
        id: '', // Will be set by Firestore
        senderId: userId,
        receiverId: event.receiverId,
        message: event.message,
        urgency: event.urgency,
        status: 'pending',
        sentAt: DateTime.now(),
      );

      final pingId = await pingRepository.sendPing(ping);

      emit(ComposeSent(pingId));
    } catch (e) {
      emit(ComposeError('Failed to send ping: ${e.toString()}'));
    }
  }
}
