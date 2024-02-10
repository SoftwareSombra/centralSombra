import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/agentes_list_services.dart';
import 'agentes_list_event.dart';
import 'agentes_list_state.dart';

class AgentesListBloc extends Bloc<AgentesListEvent, AgentesListState> {
  AgentesListBloc() : super(AgentesListInitial()) {
    on<FetchAgentesList>(
      (event, emit) async {
        emit(AgentesListLoading());
        try {
          final agentes = await AgentesListServices().getAllAgentes();
          if (agentes != null) {
            emit(AgentesListLoaded(agentes));
          } else {
            emit(AgentesListEmpty());
          }
        } catch (e) {
          emit(AgentesListError('Erro ao carregar agentes'));
        }
      },
    );
  }
}
