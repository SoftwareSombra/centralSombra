part of 'notificacao_foto_bloc.dart';

sealed class NotificacaoFotoEvent {}

final class BuscarNotificacao extends NotificacaoFotoEvent {
  String uid;
  String missaoId;
  BuscarNotificacao({required this.uid, required this.missaoId});
}
