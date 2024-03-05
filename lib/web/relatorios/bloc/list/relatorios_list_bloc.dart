import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../missao/model/missao_model.dart';
import '../../services/relatorio_services.dart';
import 'relatorios_list_event.dart';
import 'relatorios_list_state.dart';

class RelatoriosListBloc
    extends Bloc<RelatoriosListEvent, RelatoriosListState> {
  RelatoriosListBloc() : super(RelatoriosListInitial()) {
    RelatorioServices relatorioServices = RelatorioServices();

    on<RelatoriosListEvent>((event, emit) {});
    on<BuscarRelatoriosEvent>(
      (event, emit) async {
        emit(RelatoriosListLoading());
        try {
          List<MissaoRelatorio?> relatorios =
              await relatorioServices.buscarTodosRelatorios();
          if (relatorios.isEmpty) {
            emit(RelatoriosListEmpty());
          } else {
            emit(
              RelatoriosListLoaded(relatorios: relatorios),
            );
          }
        } catch (e) {
          emit(
            RelatoriosListError(
              message: e.toString(),
            ),
          );
        }
      },
    );
  }
}
