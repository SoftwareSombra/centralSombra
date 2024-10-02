sealed class MissionDetailsEvent {}

final class FetchMissionDetails extends MissionDetailsEvent {
  final String uid;
  final String missaoId;
  //final Missao missoes;
  FetchMissionDetails(
    this.uid,
    this.missaoId,
    //this.missoes
  );
}

final class ResetMissionDetails extends MissionDetailsEvent {}