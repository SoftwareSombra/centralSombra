part of 'notificacao_chat_bloc.dart';

@immutable
sealed class NotificacaoChatState {}

final class NotificacaoChatInitial extends NotificacaoChatState {}

final class NotificacaoLoading extends NotificacaoChatState {}

final class NotificacaoLoaded extends NotificacaoChatState {
  final bool hasNotification;

  NotificacaoLoaded(this.hasNotification);
}

final class NotificacaoError extends NotificacaoChatState {}
