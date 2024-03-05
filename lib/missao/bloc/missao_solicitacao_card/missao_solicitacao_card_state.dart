sealed class MissaoSolicitacaoCardState {}

final class MissaoSolicitacaoCardInitial extends MissaoSolicitacaoCardState {}

final class MissaoSolicitacaoCardLoading extends MissaoSolicitacaoCardState {}

final class MissaoJaSolicitadaCard extends MissaoSolicitacaoCardState {}

final class MissaoNaoSolicitadaCard extends MissaoSolicitacaoCardState {}

final class MissaoSolicitacaoCardError extends MissaoSolicitacaoCardState {
  final String message;

  MissaoSolicitacaoCardError(this.message);
}
