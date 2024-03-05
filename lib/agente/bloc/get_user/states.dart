import '../../model/agente_model.dart';

abstract class AgenteState {}

class AgenteInitial extends AgenteState {}

class AgenteLoading extends AgenteState {}

class AgenteLoaded extends AgenteState {
  final Agente agente;
  AgenteLoaded(this.agente);
}

class EmAnalise extends AgenteState {}

class AgenteNotExist extends AgenteState {}

class AgenteInfosRejected extends AgenteState {
  final Map<String, dynamic> dados;
  final Map<String, dynamic> dadosAceitos;
  final String? nomeAceito;
  //final String? enderecoAceito;
  final String? logradouroAceito;
  final String? numeroAceito;
  final String? bairroAceito;
  final String? cidadeAceito;
  final String? estadoAceito;
  final String? complementoAceito;
  final String? cepAceito;
  final String? celularAceito;
  final String? rgAceito;
  final String? cpfAceito;
  final String? rgFrenteAceito;
  final String? rgVersoAceito;
  final String? compResidAceito;
  AgenteInfosRejected(
      this.dados,
      this.dadosAceitos,
      this.nomeAceito,
      //this.enderecoAceito,
      this.logradouroAceito,
      this.numeroAceito,
      this.bairroAceito,
      this.cidadeAceito,
      this.estadoAceito,
      this.complementoAceito,
      this.cepAceito,
      this.celularAceito,
      this.rgAceito,
      this.cpfAceito,
      this.rgFrenteAceito,
      this.rgVersoAceito,
      this.compResidAceito);
}

class AgenteError extends AgenteState {
  final String message;
  AgenteError(this.message);
}
