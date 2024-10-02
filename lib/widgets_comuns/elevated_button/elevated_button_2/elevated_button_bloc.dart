import 'package:flutter_bloc/flutter_bloc.dart';
import 'elevated_button_bloc_event.dart';
import 'elevated_button_bloc_state.dart';

class ElevatedButtonBloc2
    extends Bloc<ElevatedButtonBloc2Event, ElevatedButtonBloc2State> {
  ElevatedButtonBloc2() : super(ElevatedButtonBloc2Initial()) {
    on<ElevatedButton2Pressed>((event, emit) {
      emit(ElevatedButtonBloc2Loading());
    });
    on<ElevatedButton2ActionCompleted>((event, emit) {
      emit(ElevatedButtonBloc2Loaded());
    });
     on<ElevatedButton2Reset>((event, emit) {
      emit(ElevatedButtonBloc2Initial());
    });
  }
}
