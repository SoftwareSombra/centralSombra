sealed class ElevatedButtonBloc3State {}

final class ElevatedButtonBloc3Initial extends ElevatedButtonBloc3State {}

final class ElevatedButtonBloc3Loading extends ElevatedButtonBloc3State {}

final class ElevatedButtonBloc3Loaded extends ElevatedButtonBloc3State {}

final class ElevatedButtonBloc3Error extends ElevatedButtonBloc3State {
  final String message;

  ElevatedButtonBloc3Error(this.message);
}
