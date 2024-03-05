
sealed class MissaoPendenteCardState {}

final class MissaoPendenteCardInitial extends MissaoPendenteCardState {}

final class MissaoPendenteCardLoading extends MissaoPendenteCardState {}

final class MissaoPendenteCardLoaded extends MissaoPendenteCardState {}

final class MissaoPendenteCardError extends MissaoPendenteCardState {
  final String error;

  MissaoPendenteCardError(this.error);
}