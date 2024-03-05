import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/missao_services.dart';
import 'qtd_missoes_pendentes_event.dart';
import 'qtd_missoes_pendentes_state.dart';

class QtdMissoesPendentesBloc
    extends Bloc<QtdMissoesPendentesEvent, QtdMissoesPendentesState> {
  QtdMissoesPendentesBloc() : super(QtdMissoesPendentesInitial()) {
    MissaoServices missaoServices = MissaoServices();
    on<QtdMissoesPendentesEvent>(
      (event, emit) {},
    );
    on<BuscarQtdMissoesPendentes>(
      (event, emit) async {
        emit(QtdMissoesPendentesLoading());
        await missaoServices.quantidadeDeMissoesPendentes().then(
          (qtd) {
            if (qtd > 0) {
              emit(QtdMissoesPendentesLoaded(qtd));
            } else {
              emit(QtdMissoesPendentesEmpty());
            }
          },
        ).catchError(
          (e) {
            emit(QtdMissoesPendentesError(e.toString()));
          },
        );
      },
    );
  }
}
