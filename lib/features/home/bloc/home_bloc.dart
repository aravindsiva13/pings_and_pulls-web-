// ============================================
// FILE: lib/features/home/bloc/home_bloc.dart
// ============================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/ping_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/ping_repository.dart';
import '../../../services/storage_service.dart';

// Events
abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {}

class UpdateAvailability extends HomeEvent {
  final String availability;
  UpdateAvailability(this.availability);
  @override
  List<Object?> get props => [availability];
}

class RefreshPendingPings extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserModel user;
  final List<PingModel> pendingPings;
  final List<UserModel> contacts;

  HomeLoaded({
    required this.user,
    required this.pendingPings,
    required this.contacts,
  });

  HomeLoaded copyWith({
    UserModel? user,
    List<PingModel>? pendingPings,
    List<UserModel>? contacts,
  }) {
    return HomeLoaded(
      user: user ?? this.user,
      pendingPings: pendingPings ?? this.pendingPings,
      contacts: contacts ?? this.contacts,
    );
  }

  @override
  List<Object?> get props => [user, pendingPings, contacts];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository = UserRepository();
  final PingRepository pingRepository = PingRepository();

  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<UpdateAvailability>(_onUpdateAvailability);
    on<RefreshPendingPings>(_onRefreshPendingPings);
  }

Future<void> _onLoadHomeData(
    LoadHomeData event, Emitter<HomeState> emit) async {
  emit(HomeLoading());

  try {
    final userId = StorageService.getUserId();
    if (userId == null) {
      emit(HomeError('User not found'));
      return;
    }

    final user = await userRepository.getUserById(userId);
    if (user == null) {
      emit(HomeError('User data not found'));
      return;
    }

    // Get contacts once
    final allContacts = await userRepository.getAllUsers();
    final contacts = allContacts
        .where((contact) => contact.id != userId)
        .take(5)
        .toList();

    // Listen to pending pings
    await emit.forEach(
      pingRepository.getPendingPings(userId),
      onData: (List<PingModel> pings) {
        return HomeLoaded(
          user: user,
          pendingPings: pings,
          contacts: contacts,
        );
      },
      onError: (error, stackTrace) => HomeError(error.toString()),
    );
  } catch (e) {
    emit(HomeError(e.toString()));
  }
}
 
 
 
 
  Future<void> _onUpdateAvailability(
      UpdateAvailability event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      
      try {
        await userRepository.updateAvailability(
          currentState.user.id,
          event.availability,
        );

        final updatedUser = currentState.user.copyWith(
          availability: event.availability,
        );

        emit(currentState.copyWith(user: updatedUser));
      } catch (e) {
        emit(HomeError('Failed to update availability'));
      }
    }
  }

  Future<void> _onRefreshPendingPings(
      RefreshPendingPings event, Emitter<HomeState> emit) async {
    // The stream will automatically update
  }
}
