// ============================================
// FILE: lib/features/pull/bloc/pull_bloc.dart
// ============================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/ping_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/ping_repository.dart';
import '../../../data/repositories/user_repository.dart';

// Events
abstract class PullEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPingDetails extends PullEvent {
  final String pingId;
  LoadPingDetails(this.pingId);
  @override
  List<Object?> get props => [pingId];
}

class PullPingNow extends PullEvent {
  final String pingId;
  PullPingNow(this.pingId);
  @override
  List<Object?> get props => [pingId];
}

class MarkPingAsRead extends PullEvent {
  final String pingId;
  MarkPingAsRead(this.pingId);
  @override
  List<Object?> get props => [pingId];
}

// States
abstract class PullState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PullInitial extends PullState {}

class PullLoading extends PullState {}

class PullDetailsLoaded extends PullState {
  final PingModel ping;
  final UserModel sender;

  PullDetailsLoaded({required this.ping, required this.sender});

  @override
  List<Object?> get props => [ping, sender];
}

class PullPulling extends PullState {}

class PullPulled extends PullState {
  final PingModel ping;
  final UserModel sender;

  PullPulled({required this.ping, required this.sender});

  @override
  List<Object?> get props => [ping, sender];
}

class PullMarkedAsRead extends PullState {}

class PullError extends PullState {
  final String message;
  PullError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class PullBloc extends Bloc<PullEvent, PullState> {
  final PingRepository pingRepository = PingRepository();
  final UserRepository userRepository = UserRepository();

  PullBloc() : super(PullInitial()) {
    on<LoadPingDetails>(_onLoadPingDetails);
    on<PullPingNow>(_onPullPingNow);
    on<MarkPingAsRead>(_onMarkPingAsRead);
  }

  Future<void> _onLoadPingDetails(
      LoadPingDetails event, Emitter<PullState> emit) async {
    emit(PullLoading());

    try {
      final ping = await pingRepository.getPingById(event.pingId);
      if (ping == null) {
        emit(PullError('Ping not found'));
        return;
      }

      final sender = await userRepository.getUserById(ping.senderId);
      if (sender == null) {
        emit(PullError('Sender not found'));
        return;
      }

      emit(PullDetailsLoaded(ping: ping, sender: sender));
    } catch (e) {
      emit(PullError(e.toString()));
    }
  }

  Future<void> _onPullPingNow(
      PullPingNow event, Emitter<PullState> emit) async {
    if (state is PullDetailsLoaded) {
      final currentState = state as PullDetailsLoaded;
      emit(PullPulling());

      try {
        await pingRepository.pullPing(event.pingId);
        
        // Get updated ping
        final updatedPing = await pingRepository.getPingById(event.pingId);
        if (updatedPing != null) {
          emit(PullPulled(ping: updatedPing, sender: currentState.sender));
        } else {
          emit(PullError('Failed to load updated ping'));
        }
      } catch (e) {
        emit(PullError('Failed to pull ping: ${e.toString()}'));
      }
    }
  }

  Future<void> _onMarkPingAsRead(
      MarkPingAsRead event, Emitter<PullState> emit) async {
    try {
      await pingRepository.markAsRead(event.pingId);
      emit(PullMarkedAsRead());
    } catch (e) {
      emit(PullError('Failed to mark as read: ${e.toString()}'));
    }
  }
}
