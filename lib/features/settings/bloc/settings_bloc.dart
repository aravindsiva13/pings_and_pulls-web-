// ============================================
// FILE: lib/features/settings/bloc/settings_bloc.dart
// ============================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../services/storage_service.dart';

// Events
abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class UpdateNotifications extends SettingsEvent {
  final bool enabled;
  UpdateNotifications(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateQuietHours extends SettingsEvent {
  final String? start;
  final String? end;
  UpdateQuietHours({this.start, this.end});
  @override
  List<Object?> get props => [start, end];
}

class UpdateReadReceipts extends SettingsEvent {
  final bool enabled;
  UpdateReadReceipts(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class UpdateMessagePreview extends SettingsEvent {
  final bool enabled;
  UpdateMessagePreview(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

// States
class SettingsState extends Equatable {
  final bool notificationsEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final bool readReceiptsEnabled;
  final bool messagePreviewEnabled;
  final bool isLoading;

  const SettingsState({
    required this.notificationsEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.readReceiptsEnabled,
    required this.messagePreviewEnabled,
    this.isLoading = false,
  });

  factory SettingsState.initial() {
    return const SettingsState(
      notificationsEnabled: true,
      readReceiptsEnabled: false,
      messagePreviewEnabled: false,
    );
  }

  SettingsState copyWith({
    bool? notificationsEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? readReceiptsEnabled,
    bool? messagePreviewEnabled,
    bool? isLoading,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      readReceiptsEnabled: readReceiptsEnabled ?? this.readReceiptsEnabled,
      messagePreviewEnabled:
          messagePreviewEnabled ?? this.messagePreviewEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        notificationsEnabled,
        quietHoursStart,
        quietHoursEnd,
        readReceiptsEnabled,
        messagePreviewEnabled,
        isLoading,
      ];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateNotifications>(_onUpdateNotifications);
    on<UpdateQuietHours>(_onUpdateQuietHours);
    on<UpdateReadReceipts>(_onUpdateReadReceipts);
    on<UpdateMessagePreview>(_onUpdateMessagePreview);
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    final notificationsEnabled = StorageService.getNotificationsEnabled();
    final quietHoursStart = StorageService.getQuietHoursStart();
    final quietHoursEnd = StorageService.getQuietHoursEnd();
    final readReceiptsEnabled = StorageService.getReadReceiptsEnabled();
    final messagePreviewEnabled = StorageService.getMessagePreviewEnabled();

    emit(state.copyWith(
      notificationsEnabled: notificationsEnabled,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
      readReceiptsEnabled: readReceiptsEnabled,
      messagePreviewEnabled: messagePreviewEnabled,
    ));
  }

  Future<void> _onUpdateNotifications(
      UpdateNotifications event, Emitter<SettingsState> emit) async {
    await StorageService.setNotificationsEnabled(event.enabled);
    emit(state.copyWith(notificationsEnabled: event.enabled));
  }

  Future<void> _onUpdateQuietHours(
      UpdateQuietHours event, Emitter<SettingsState> emit) async {
    if (event.start != null) {
      await StorageService.setQuietHoursStart(event.start!);
    }
    if (event.end != null) {
      await StorageService.setQuietHoursEnd(event.end!);
    }
    emit(state.copyWith(
      quietHoursStart: event.start ?? state.quietHoursStart,
      quietHoursEnd: event.end ?? state.quietHoursEnd,
    ));
  }

  Future<void> _onUpdateReadReceipts(
      UpdateReadReceipts event, Emitter<SettingsState> emit) async {
    await StorageService.setReadReceiptsEnabled(event.enabled);
    emit(state.copyWith(readReceiptsEnabled: event.enabled));
  }

  Future<void> _onUpdateMessagePreview(
      UpdateMessagePreview event, Emitter<SettingsState> emit) async {
    await StorageService.setMessagePreviewEnabled(event.enabled);
    emit(state.copyWith(messagePreviewEnabled: event.enabled));
  }
}
