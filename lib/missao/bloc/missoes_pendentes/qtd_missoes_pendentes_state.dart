sealed class QtdMissoesPendentesState {}

final class QtdMissoesPendentesInitial extends QtdMissoesPendentesState {}

final class QtdMissoesPendentesLoading extends QtdMissoesPendentesState {}

final class QtdMissoesPendentesLoaded extends QtdMissoesPendentesState {
  final int qtd;

  QtdMissoesPendentesLoaded(this.qtd);
}

final class QtdMissoesPendentesError extends QtdMissoesPendentesState {
  final String message;

  QtdMissoesPendentesError(this.message);
}

final class QtdMissoesPendentesEmpty extends QtdMissoesPendentesState {}
