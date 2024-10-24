sealed class AttsHomeState {}

final class AttsHomeInitial extends AttsHomeState {}

final class AttsHomeLoading extends AttsHomeState {}

final class AttsHomeLoaded extends AttsHomeState {
  final bool att;

  AttsHomeLoaded(this.att);
}

final class AttsHomeError extends AttsHomeState {
  final String message;

  AttsHomeError(this.message);
}

final class AttsHomeEmpty extends AttsHomeState {}
