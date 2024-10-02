import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../missao/services/missao_services.dart';
part 'respostas_chamado_event.dart';
part 'respostas_chamado_state.dart';

class RespostasChamadoBloc
    extends Bloc<RespostasChamadoEvent, RespostasChamadoState> {
  RespostasChamadoBloc() : super(RespostasChamadoInitial()) {
    MissaoServices missaoServices = MissaoServices();
    on<BuscarRespostasChamado>((event, emit) async {
      emit(RespostasChamadoLoading());
      try {
        debugPrint('Buscando respostas de chamado com bloc...');
        await for (final hasNotification in missaoServices.buscarMissoesSolicitadasStream()) {
          debugPrint(hasNotification.toString());
          if (!isClosed) {
            emit(RespostasChamadoLoaded(true));
          }
        }
      } catch (e) {
        if (!isClosed) {
          emit(RespostasChamadoError());
        }
      }
    });
  }
}
