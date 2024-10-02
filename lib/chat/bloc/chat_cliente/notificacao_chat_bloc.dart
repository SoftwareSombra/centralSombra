import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/chat_services.dart';
part 'notificacao_chat_event.dart';
part 'notificacao_chat_state.dart';

class NotificacaoChatClienteBloc
    extends Bloc<NotificacaoChatClienteEvent, NotificacaoChatClienteState> {
  NotificacaoChatClienteBloc() : super(NotificacaoChatClienteInitial()) {
    ChatServices chatServices = ChatServices();
    on<BuscarNotificacaoChatCliente>(
      (event, emit) async {
        emit(NotificacaoChatClienteLoading());
        try {
          debugPrint('Buscando notificacoes com bloc...');
          await for (final hasNotification in chatServices.notificacaoChatCliente()) {
            debugPrint(hasNotification.toString());
            if (!isClosed) {
              emit(NotificacaoChatClienteLoaded(hasNotification));
            }
          }
        } catch (e) {
          if (!isClosed) {
            emit(NotificacaoChatClienteError());
          }
        }
      },
    );
  }
}
