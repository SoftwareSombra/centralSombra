sealed class MissaoSolicitacaoCardEvent {}

final class BuscarMissao extends MissaoSolicitacaoCardEvent {
  final String missaoId;

  BuscarMissao({required this.missaoId});
}