import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/missao_services.dart';
import 'qtd_missoes_pendentes_event.dart';
import 'qtd_missoes_pendentes_state.dart';

class QtdMissoesPendentesBloc
    extends Bloc<QtdMissoesPendentesEvent, QtdMissoesPendentesState> {
  //StreamSubscription? _subscription;

  QtdMissoesPendentesBloc(MissaoServices missaoServices)
      : super(QtdMissoesPendentesInitial()) {
    on<BuscarQtdMissoesPendentes>(
      (event, emit) async {
        emit(QtdMissoesPendentesLoading());
        try {
          // Primeiro, ouça a stream
          await for (final qtd
              in missaoServices.quantidadeDeMissoesPendentesStream2()) {
            // Verifique se o Bloc ainda está ativo antes de emitir o próximo estado
            if (!isClosed) {
              emit(
                QtdMissoesPendentesLoaded(qtd),
              );
            }
          }
        } catch (e) {
          // Trate erros de stream aqui
          if (!isClosed) {
            emit(QtdMissoesPendentesError(e.toString()));
          }
        }
      },
    );
  }

  // @override
  // Future<void> close() {
  //   _subscription
  //       ?.cancel(); // Não esqueça de cancelar a assinatura ao fechar o Bloc
  //   return super.close();
  // }
}
