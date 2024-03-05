import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/missao_services.dart';
import 'missoes_pendentes_event.dart';
import 'missoes_pendentes_state.dart';

class MissoesPendentesBloc
    extends Bloc<MissoesPendentesEvent, MissoesPendentesState> {
  MissoesPendentesBloc() : super(MissoesPendentesInitial()) {
    final MissaoServices missaoServices = MissaoServices();

    on<MissoesPendentesEvent>(
      (event, emit) {},
    );
    on<BuscarMissoesPendentes>(
      (event, emit) async {
        emit(MissoesPendentesLoading());
        try {
          final missoes = await missaoServices.buscarMissoesPendentes();
          if (missoes.isEmpty) {
            emit(MissoesPendentesEmpty());
            return;
          }
          emit(MissoesPendentesLoaded(missoes));
        } catch (e) {
          emit(MissoesPendentesError(e.toString()));
        }
      },
    );
  }
}
