import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../missao/services/missao_services.dart';
part 'notificacao_chat_event.dart';
part 'notificacao_foto_state.dart';

class NotificacaoFotoBloc
    extends Bloc<NotificacaoFotoEvent, NotificacaoFotoState> {
  NotificacaoFotoBloc() : super(NotificacaoFotoInitial()) {
    MissaoServices missaoServices = MissaoServices();
    on<BuscarNotificacao>((event, emit) async {
      emit(NotificacaoFotoLoading());
      try {
        debugPrint('Buscando notificacoes com bloc...');
        await for (final hasNotification
            in missaoServices.notificacaoFoto(event.uid, event.missaoId)) {
          debugPrint(hasNotification.toString());
          if (!isClosed) {
            emit(NotificacaoFotoLoaded(hasNotification));
          }
        }
      } catch (e) {
        if (!isClosed) {
          emit(NotificacaoFotoError());
        }
      }
    });
  }
}
