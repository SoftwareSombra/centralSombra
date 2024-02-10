abstract class ContaBancariaEvent {}

class FetchContaBancariaInfo extends ContaBancariaEvent {
  final String uid;
  FetchContaBancariaInfo(this.uid);
}