part of 'notificacao_foto_bloc.dart';

@immutable
sealed class NotificacaoFotoState {}

final class NotificacaoFotoInitial extends NotificacaoFotoState {}

final class NotificacaoFotoLoading extends NotificacaoFotoState {}

final class NotificacaoFotoLoaded extends NotificacaoFotoState {
  final bool hasNotification;

  NotificacaoFotoLoaded(this.hasNotification);
}

final class NotificacaoFotoError extends NotificacaoFotoState {}
