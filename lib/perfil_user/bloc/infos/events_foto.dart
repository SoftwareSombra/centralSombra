abstract class SelectFotoEvent {}

class FotoSelected extends SelectFotoEvent {
  final String tipo;
  
  FotoSelected({required this.tipo});
}
