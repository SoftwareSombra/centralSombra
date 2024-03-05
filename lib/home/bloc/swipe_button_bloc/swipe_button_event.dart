
sealed class SwipeButtonEvent {}

final class SwipeButtonLoad extends SwipeButtonEvent {}

final class SwipeButtonChange extends SwipeButtonEvent {
  final bool isSwitched;

  SwipeButtonChange(this.isSwitched);
}
