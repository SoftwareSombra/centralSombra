import '../../../conta_bancaria/model/conta_bancaria_model.dart';

abstract class ContaBancariaState {}

class ContaBancariaInitial extends ContaBancariaState {}

class ContaBancariaLoading extends ContaBancariaState {}

class ContaBancariaLoaded extends ContaBancariaState {
  final ContaBancaria contaBancaria;
  ContaBancariaLoaded(this.contaBancaria);
}

class ContaBancariaNotExist extends ContaBancariaState {}

class ContaBancariaAguardandoAprovacao extends ContaBancariaState {}

class ContaBancariaInfosRejected extends ContaBancariaState {
  final Map<String, dynamic> dados;
  final Map<String, dynamic> dadosAceitos;
  final String? titularAceito;
  final String? numeroAceito;
  final String? agenciaAceita;
  final String? chavePixAceita;
  ContaBancariaInfosRejected(this.dados, this.dadosAceitos, this.titularAceito,
      this.numeroAceito, this.agenciaAceita, this.chavePixAceita);
}

class ContaBancariaError extends ContaBancariaState {
  final String message;
  ContaBancariaError(this.message);
}

class AgenteSemCadastro extends ContaBancariaState {}