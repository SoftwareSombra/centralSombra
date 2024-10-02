import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/chat_services.dart';
part 'notificacao_chat_event.dart';
part 'notificacao_chat_state.dart';

class NotificacaoChatBloc
    extends Bloc<NotificacaoChatEvent, NotificacaoChatState> {
  NotificacaoChatBloc() : super(NotificacaoChatInitial()) {
    ChatServices chatServices = ChatServices();
    on<BuscarNotificacao>((event, emit) async {
      emit(NotificacaoLoading());
      try {
        debugPrint('Buscando notificacoes com bloc...');
        await for (final hasNotification in chatServices.notificacaoChat()) {
          debugPrint(hasNotification.toString());
          if (!isClosed) {
            emit(NotificacaoLoaded(hasNotification));
          }
        }
      } catch (e) {
        if (!isClosed) {
          emit(NotificacaoError());
        }
      }
    });
  }
}
