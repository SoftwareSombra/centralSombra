
import '../../model/missao_solicitada.dart';

sealed class MissoesPendentesState {}

final class MissoesPendentesInitial extends MissoesPendentesState {}

final class MissoesPendentesLoading extends MissoesPendentesState {}

final class MissoesPendentesLoaded extends MissoesPendentesState {
  final List<MissaoSolicitada> missoes;

  MissoesPendentesLoaded(this.missoes);
}

final class MissoesPendentesEmpty extends MissoesPendentesState {}

final class MissoesPendentesError extends MissoesPendentesState {
  final String error;

  MissoesPendentesError(this.error);
}
