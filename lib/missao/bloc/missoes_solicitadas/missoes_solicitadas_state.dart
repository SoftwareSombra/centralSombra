import '../../../../missao/model/missao_solicitada.dart';

sealed class MissoesSolicitadasState {}

final class MissoesSolicitadasLoading extends MissoesSolicitadasState {}

final class MissoesSolicitadasLoaded extends MissoesSolicitadasState {
  final List<MissaoSolicitada> missoes;

  MissoesSolicitadasLoaded(this.missoes);
}

final class MissoesSolicitadasEmpty extends MissoesSolicitadasState {}

final class MissoesSolicitadasError extends MissoesSolicitadasState {
  final String error;

  MissoesSolicitadasError(this.error);
}