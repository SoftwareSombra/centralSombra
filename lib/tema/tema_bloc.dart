import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_bloc.dart';
import 'state_bloc.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(DarkMode()) {
    on<ToggleTheme>((event, emit) {
      if (state is LightMode) {
        emit(DarkMode());
      } else {
        emit(LightMode());
      }
    });
  }
}
