import '../../model/veiculo_model.dart';

abstract class VeiculoSolicitacaoState {}

class VeiculoSolicitacaoLoading extends VeiculoSolicitacaoState {}

class VeiculoSolicitacaoLoaded extends VeiculoSolicitacaoState {
  final List<Veiculo> veiculo;

  VeiculoSolicitacaoLoaded(this.veiculo);
}

class VeiculoSolicitacaoError extends VeiculoSolicitacaoState {
  final String message;

  VeiculoSolicitacaoError(this.message);
}

class VeiculoSolicitacaoNotFound extends VeiculoSolicitacaoState {}
