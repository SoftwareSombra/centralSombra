sealed class ElevatedButtonBlocState {}

final class ElevatedButtonBlocInitial extends ElevatedButtonBlocState {}

final class ElevatedButtonBlocLoading extends ElevatedButtonBlocState {}

final class ElevatedButtonBlocLoaded extends ElevatedButtonBlocState {}

final class ElevatedButtonBlocError extends ElevatedButtonBlocState {
  final String message;

  ElevatedButtonBlocError(this.message);
}
