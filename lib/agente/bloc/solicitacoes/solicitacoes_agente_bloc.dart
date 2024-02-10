import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/agente_model.dart';
import 'events.dart';
import 'states.dart';

class AgenteSolicitacaoBloc
    extends Bloc<AgenteSolicitacaoEvent, AgenteSolicitacaoState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AgenteSolicitacaoBloc() : super(AgenteSolicitacaoLoading()) {
    on<FetchAgenteSolicitacaos>((event, emit) async {
      emit(AgenteSolicitacaoLoading());
      try {
        List<Agente> agentes = [];
        final agentesSnapshot =
            await _firestore.collection('Aprovação de user infos').get();

        for (var agenteDoc in agentesSnapshot.docs) {
          agentes.add(Agente.fromFirestore(agenteDoc.data(), agenteDoc.id));
        }

        if (agentes.isEmpty) {
          emit(AgenteSolicitacaoNotFound());
          return;
        }

        emit(AgenteSolicitacaoLoaded(agentes));
      } catch (e) {
        emit(AgenteSolicitacaoError(e.toString()));
      }
    });
  }
}
