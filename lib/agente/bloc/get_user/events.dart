abstract class AgenteEvent {}

class FetchAgenteInfo extends AgenteEvent {
  final String uid;
  FetchAgenteInfo(this.uid);
}
