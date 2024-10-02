part of 'notificacao_chat_bloc.dart';

@immutable
sealed class NotificacaoChatClienteState {}

final class NotificacaoChatClienteInitial extends NotificacaoChatClienteState {}

final class NotificacaoChatClienteLoading extends NotificacaoChatClienteState {}

final class NotificacaoChatClienteLoaded extends NotificacaoChatClienteState {
  final bool hasNotification;

  NotificacaoChatClienteLoaded(this.hasNotification);
}

final class NotificacaoChatClienteError extends NotificacaoChatClienteState {}
