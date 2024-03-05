import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/missao_services.dart';
import 'missao_solicitacao_card_event.dart';
import 'missao_solicitacao_card_state.dart';

class MissaoSolicitacaoCardBloc
    extends Bloc<MissaoSolicitacaoCardEvent, MissaoSolicitacaoCardState> {
  MissaoSolicitacaoCardBloc() : super(MissaoSolicitacaoCardInitial()) {
    MissaoServices missaoServices = MissaoServices();
    on<BuscarMissao>((event, emit) async {
      emit(MissaoSolicitacaoCardLoading());
      try {
        final chamado = await missaoServices.verificarChamado(event.missaoId);
        if (chamado) {
          emit(MissaoJaSolicitadaCard());
        } else {
          emit(MissaoNaoSolicitadaCard());
        }
      } catch (e) {
        emit(
          MissaoSolicitacaoCardError(
            e.toString(),
          ),
        );
      }
    });
  }
}
