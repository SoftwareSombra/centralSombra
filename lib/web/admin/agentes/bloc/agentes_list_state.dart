import '../model/agente_model.dart';

sealed class AgentesListState {}

final class AgentesListInitial extends AgentesListState {}

final class AgentesListLoading extends AgentesListState {}

final class AgentesListLoaded extends AgentesListState {
  final List<AgenteAdmList> agentes;

  AgentesListLoaded(this.agentes);
}

final class AgentesListEmpty extends AgentesListState {}

final class AgentesListError extends AgentesListState {
  final String message;

  AgentesListError(this.message);
}
