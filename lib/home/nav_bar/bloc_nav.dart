import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc_events.dart';
import 'bloc_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(HomeSelected()) {
    on<ChangeToHome>((event, emit) {
      emit(HomeSelected());
    });

    on<ChangeToVeiculos>((event, emit) {
      emit(VeiculosSelected());
    });

    on<ChangeToPerfil>((event, emit) {
      emit(PerfilSelected());
    });

    on<ChangeToMissao>((event, emit) {
      emit(MissaoSelected());
    });

    // Adicione mais manipuladores conforme necessário...
  }
}
