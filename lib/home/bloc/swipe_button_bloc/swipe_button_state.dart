
sealed class SwipeButtonState {}

final class SwipeButtonInitial extends SwipeButtonState {}

final class SwipeButtonLoadind extends SwipeButtonState {}

final class SwipeButtonLoaded extends SwipeButtonState {
  final bool status;

  SwipeButtonLoaded(this.status);
}

final class SwipeButtonError extends SwipeButtonState {
  final String message;

  SwipeButtonError(this.message);
}

