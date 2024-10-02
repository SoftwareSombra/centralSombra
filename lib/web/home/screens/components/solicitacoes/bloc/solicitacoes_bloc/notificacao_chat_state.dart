part of 'notificacao_chat_bloc.dart';

@immutable
sealed class MissoesSolicitadasStreamState {}

final class MissoesSolicitadasStreamInitial extends MissoesSolicitadasStreamState {}

final class MissoesSolicitadasStreamLoading extends MissoesSolicitadasStreamState {}

final class MissoesSolicitadasStreamLoaded extends MissoesSolicitadasStreamState {
  final List<MissaoSolicitada> missoesSolicitadas;

  MissoesSolicitadasStreamLoaded(this.missoesSolicitadas);
}

final class MissoesSolicitadasStreamError extends MissoesSolicitadasStreamState {}
