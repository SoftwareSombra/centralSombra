import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/conta_bancaria_model.dart';
import '../services/conta_bancaria_services.dart';
import 'solicitacoes_conta_bancaria_event.dart';
import 'solicitacoes_conta_bancaria_state.dart';

class SolicitacoesContaBancariaBloc extends Bloc<SolicitacoesContaBancariaEvent,
    SolicitacoesContaBancariaState> {
  SolicitacoesContaBancariaBloc() : super(SolicitacoesContaBancariaLoading()) {
    on<FetchSolicitacoesContaBancaria>((event, emit) async {
      ContaBancariaServices contaBancariaServices = ContaBancariaServices();

      emit(SolicitacoesContaBancariaLoading());
      try {
        List<ContaBancaria> contas =
            await contaBancariaServices.getSolicitacoesContaBancaria();

        if (contas.isEmpty) {
          emit(SolicitacoesContaBancariaNotFound());
          return;
        }

        emit(SolicitacoesContaBancariaLoaded(contas));
      } catch (e) {
        emit(SolicitacoesContaBancariaError(e.toString()));
      }
    });
  }
}
