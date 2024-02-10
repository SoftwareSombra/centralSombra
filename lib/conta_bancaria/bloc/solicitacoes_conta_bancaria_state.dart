import '../model/conta_bancaria_model.dart';

abstract class SolicitacoesContaBancariaState {}

class SolicitacoesContaBancariaLoading extends SolicitacoesContaBancariaState {}

class SolicitacoesContaBancariaLoaded extends SolicitacoesContaBancariaState {
  final List<ContaBancaria> conta;

  SolicitacoesContaBancariaLoaded(this.conta);
}

class SolicitacoesContaBancariaError extends SolicitacoesContaBancariaState {
  final String message;

  SolicitacoesContaBancariaError(this.message);
}

class SolicitacoesContaBancariaNotFound extends SolicitacoesContaBancariaState {}