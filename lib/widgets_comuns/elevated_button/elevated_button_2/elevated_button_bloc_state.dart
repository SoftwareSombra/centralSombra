sealed class ElevatedButtonBloc2State {}

final class ElevatedButtonBloc2Initial extends ElevatedButtonBloc2State {}

final class ElevatedButtonBloc2Loading extends ElevatedButtonBloc2State {}

final class ElevatedButtonBloc2Loaded extends ElevatedButtonBloc2State {}

final class ElevatedButtonBloc2Error extends ElevatedButtonBloc2State {
  final String message;

  ElevatedButtonBloc2Error(this.message);
}
