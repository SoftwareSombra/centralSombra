import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import 'missoes_solicitadas_event.dart';
import 'missoes_solicitadas_state.dart';

class MissoesSolicitadasBloc
    extends Bloc<MissoesSolicitadasEvent, MissoesSolicitadasState> {
  MissoesSolicitadasBloc() : super(MissoesSolicitadasLoading()) {
    final MissaoServices missaoServices = MissaoServices();

    on<BuscarMissoes>((event, emit) async {
      emit(MissoesSolicitadasLoading());
      try {
        final missoes = await missaoServices.buscarMissoesSolicitadas();
        if (missoes.isEmpty) {
          emit(MissoesSolicitadasEmpty());
          return;
        }
        emit(MissoesSolicitadasLoaded(missoes));
      } catch (e) {
        emit(MissoesSolicitadasError(e.toString()));
      }
    });
  }
}
