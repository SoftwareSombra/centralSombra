import 'states.dart';

abstract class LocationEvent {}

class StartLocationTracking extends LocationEvent {
  final MissionType missionType;
  final String missaoId;

  StartLocationTracking(this.missionType, this.missaoId);
}

class StopLocationTracking extends LocationEvent {}
