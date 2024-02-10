sealed class RespostaSolicitacaoVeiculoEvent {}

class FetchRespostaSolicitacaoVeiculo extends RespostaSolicitacaoVeiculoEvent {
  final String uid;

  FetchRespostaSolicitacaoVeiculo(this.uid);
}