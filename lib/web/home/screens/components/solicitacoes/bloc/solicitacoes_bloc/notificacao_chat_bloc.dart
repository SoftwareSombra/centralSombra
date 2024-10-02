import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../missao/model/missao_solicitada.dart';
import '../../../../../../../missao/services/missao_services.dart';
part 'notificacao_chat_event.dart';
part 'notificacao_chat_state.dart';

class MissoesSolicitadasStreamBloc
    extends Bloc<MissoesSolicitadasStreamEvent, MissoesSolicitadasStreamState> {
  MissoesSolicitadasStreamBloc() : super(MissoesSolicitadasStreamInitial()) {
    MissaoServices missaoServices = MissaoServices();
    on<BuscarMissoesSolicitadasStream>((event, emit) async {
      emit(MissoesSolicitadasStreamLoading());
      try {
        debugPrint('Buscando missoes solicitadas com bloc...');
        await for (final hasNotification in missaoServices.buscarMissoesSolicitadasStream()) {
          debugPrint(hasNotification.toString());
          if (!isClosed) {
            emit(MissoesSolicitadasStreamLoaded(hasNotification));
          }
        }
      } catch (e) {
        if (!isClosed) {
          emit(MissoesSolicitadasStreamError());
        }
      }
    });
  }
}
