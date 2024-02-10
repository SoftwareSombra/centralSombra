
import '../../model/agente_model.dart';

abstract class AgenteSolicitacaoState {}

class AgenteSolicitacaoLoading extends AgenteSolicitacaoState {}

class AgenteSolicitacaoLoaded extends AgenteSolicitacaoState {
  final List<Agente> agente;

  AgenteSolicitacaoLoaded(this.agente);
}

class AgenteSolicitacaoError extends AgenteSolicitacaoState {
  final String message;

  AgenteSolicitacaoError(this.message);
}

class AgenteSolicitacaoNotFound extends AgenteSolicitacaoState {}
