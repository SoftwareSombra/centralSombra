import 'package:flutter_bloc/flutter_bloc.dart';
import 'elevated_button_bloc_event.dart';
import 'elevated_button_bloc_state.dart';

class ElevatedButtonBloc
    extends Bloc<ElevatedButtonBlocEvent, ElevatedButtonBlocState> {
  ElevatedButtonBloc() : super(ElevatedButtonBlocInitial()) {
    on<ElevatedButtonPressed>((event, emit) {
      emit(ElevatedButtonBlocLoading());
    });
    on<ElevatedButtonActionCompleted>((event, emit) {
      emit(ElevatedButtonBlocLoaded());
    });
     on<ElevatedButtonReset>((event, emit) {
      emit(ElevatedButtonBlocInitial());
    });
  }
}
