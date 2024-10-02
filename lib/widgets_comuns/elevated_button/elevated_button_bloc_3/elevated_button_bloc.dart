import 'package:flutter_bloc/flutter_bloc.dart';
import 'elevated_button_bloc_event.dart';
import 'elevated_button_bloc_state.dart';

class ElevatedButtonBloc3
    extends Bloc<ElevatedButtonBloc3Event, ElevatedButtonBloc3State> {
  ElevatedButtonBloc3() : super(ElevatedButtonBloc3Initial()) {
    on<ElevatedButton3Pressed>((event, emit) {
      emit(ElevatedButtonBloc3Loading());
    });
    on<ElevatedButton3ActionCompleted>((event, emit) {
      emit(ElevatedButtonBloc3Loaded());
    });
     on<ElevatedButton3Reset>((event, emit) {
      emit(ElevatedButtonBloc3Initial());
    });
  }
}
