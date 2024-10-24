import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../notificacoess.dart';
import 'qtd_missoes_pendentes_event.dart';
import 'qtd_missoes_pendentes_state.dart';

class AttsHomeBloc extends Bloc<AttsHomeEvent, AttsHomeState> {
  final NotificationService notServices = NotificationService();

  AttsHomeBloc() : super(AttsHomeInitial()) {
    on<BuscarAttsHome>((event, emit) async {
      debugPrint('buscando notificacao');
      emit(AttsHomeLoading());
      try {
        // Escuta a stream e usa await for para processar cada evento da stream
        await for (final bool newAtt in notServices.notificacoesCentral()) {
          debugPrint('escutando stream');
          if (state is AttsHomeLoaded) {
            if (!emit.isDone) {
              emit(AttsHomeLoaded(newAtt));
            }
          } else {
            // Se for o primeiro documento, emitimos diretamente
            if (!emit.isDone) {
              emit(AttsHomeLoaded(newAtt));
            }
          }
        }
      } catch (e) {
        // Captura e emite o erro caso aconteça algum problema
        if (!emit.isDone) {
          emit(AttsHomeError(e.toString()));
        }
      }
    });
  }

  @override
  Future<void> close() {
    debugPrint("AttsHomeBloc - Fechado");
    return super.close();
  }
}
