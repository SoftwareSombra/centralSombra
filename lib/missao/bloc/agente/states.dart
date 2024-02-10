import 'package:geolocator/geolocator.dart';
import '../../model/missao_model.dart';

abstract class AgentState {}

class LoadingAgentState extends AgentState {}

class Available extends AgentState {}

class MissaoNaoIniciada extends AgentState {
  final String uid;
  final String missaoId;
  final Position currentLocation;
  final String local;
  final String? placaCavalo;
  final String? placaCarreta;
  final String? motorista;
  final String? corVeiculo;
  final String? tipo;
  MissaoNaoIniciada(
      this.uid,
      this.missaoId,
      this.currentLocation,
      this.local,
      this.placaCavalo,
      this.placaCarreta,
      this.motorista,
      this.corVeiculo,
      this.tipo);
}

class OnMission extends AgentState {
  final Missao missionDetails;
  OnMission(this.missionDetails);
}

class FetchMissionLoading extends AgentState {
  final String uid;
  FetchMissionLoading(this.uid);
}

class ReportPending extends AgentState {
  final Missao? missao;
  final String uid;
  final String nome;
  ReportPending(this.missao, this.uid, this.nome);
}
