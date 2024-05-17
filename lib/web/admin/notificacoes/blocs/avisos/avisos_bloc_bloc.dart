import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/notificacoes_services.dart';
import 'avisos_bloc_event.dart';
import 'avisos_bloc_state.dart';

class AvisosBloc extends Bloc<AvisosBlocEvent, AvisosBlocState> {
  AvisosBloc() : super(AvisosBlocInitial()) {
    NotificacoesAdmServices notificacoesAdmServices = NotificacoesAdmServices();
    on<BuscarAvisos>(
      (event, emit) async {
        emit(AvisosBlocLoading());
        try {
          List<AvisoModel>? avisos =
              await notificacoesAdmServices.getAllAvisos();
          avisos == null
              ? emit(AvisosBlocIsEmpty())
              : emit(AvisosBlocLoaded(avisos: avisos));
        } catch (e) {
          debugPrint('Erro ao buscar avisos ${e.toString()}');
          emit(AvisosBlocError());
        }
      },
    );
  }
}
