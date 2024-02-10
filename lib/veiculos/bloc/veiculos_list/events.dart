abstract class VeiculoEvent {}

class FetchVeiculos extends VeiculoEvent {
  final String uid;

  FetchVeiculos(this.uid);
}
