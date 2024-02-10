import '../../model/veiculo_model.dart';

abstract class VeiculoState {}

class VeiculoLoading extends VeiculoState {}

class VeiculoLoaded extends VeiculoState {
  final List<Veiculo> veiculos;

  VeiculoLoaded(this.veiculos);
}

class VeiculoError extends VeiculoState {
  final String message;

  VeiculoError(this.message);
}

class VeiculoNotFound extends VeiculoState {}
