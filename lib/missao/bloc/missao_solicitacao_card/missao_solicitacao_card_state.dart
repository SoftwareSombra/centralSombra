sealed class MissaoSolicitacaoCardState {}

final class MissaoSolicitacaoCardInitial extends MissaoSolicitacaoCardState {}

final class MissaoSolicitacaoCardLoading extends MissaoSolicitacaoCardState {}

final class MissaoJaSolicitacaoCard extends MissaoSolicitacaoCardState {}

final class MissaoNaoSolicitacaoCard extends MissaoSolicitacaoCardState {}

final class MissaoSolicitacaoCardError extends MissaoSolicitacaoCardState {
  final String message;

  MissaoSolicitacaoCardError(this.message);
}
