sealed class RespostaSolicitacaoVeiculoState {}

final class RespostaSolicitacaoVeiculoInitial
    extends RespostaSolicitacaoVeiculoState {}

final class RespostaSolicitacaoVeiculoLoading
    extends RespostaSolicitacaoVeiculoState {}

final class RespostaSolicitacaoVeiculoLoaded
    extends RespostaSolicitacaoVeiculoState {
  final Map<String, dynamic> dados;
  final Map<String, dynamic> dadosAceitos;
  final String? nome;
  final String? placa;
  final String? marca;
  final String? modelo;
  final String? cor;
  final String? ano;

  RespostaSolicitacaoVeiculoLoaded(this.dados, this.dadosAceitos, this.nome,
      this.placa, this.marca, this.modelo, this.cor, this.ano);
}

final class RespostaSolicitacaoNotFound
    extends RespostaSolicitacaoVeiculoState {}

final class RespostaSolicitacaoVeiculoError
    extends RespostaSolicitacaoVeiculoState {
  final String message;

  RespostaSolicitacaoVeiculoError(this.message);
}

final class SemCadastro extends RespostaSolicitacaoVeiculoState {}
