import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../conta_bancaria/model/conta_bancaria_model.dart';
import '../../../conta_bancaria/services/conta_bancaria_services.dart';
import 'events.dart';
import 'states.dart';

class ContaBancariaBloc extends Bloc<ContaBancariaEvent, ContaBancariaState> {
  final ContaBancariaServices contaBancariaServices = ContaBancariaServices();
  ContaBancariaBloc() : super(ContaBancariaInitial()) {
    on<FetchContaBancariaInfo>((event, emit) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      emit(ContaBancariaLoading());
      try {
        DocumentSnapshot isAgent =
            await firestore.collection('User infos').doc(event.uid).get();
        if (isAgent.exists) {
          final aguardandoAprovacao = await contaBancariaServices
              .existeDocDoAgenteAguardandoAprovacao(event.uid);

          if (aguardandoAprovacao) {
            emit(ContaBancariaAguardandoAprovacao());
            return;
          }

          ContaBancaria? contaBancaria =
              await contaBancariaServices.getConta(event.uid);

          if (contaBancaria == null) {
            final dadosRejeitados =
                await contaBancariaServices.getDadosRejeitados(event.uid);
            final dadosAceitos = await contaBancariaServices
                .getDadosAguardandoAprovacao(event.uid);
            final String? titularAceito;
            if (dadosAceitos.containsKey('titular')) {
              titularAceito = dadosAceitos['titular'];
            } else {
              titularAceito = null;
            }
            final String? numeroAceito;
            if (dadosAceitos.containsKey('numero')) {
              numeroAceito = dadosAceitos['numero'];
            } else {
              numeroAceito = null;
            }
            final String? agenciaAceita;
            if (dadosAceitos.containsKey('agencia')) {
              agenciaAceita = dadosAceitos['agencia'];
            } else {
              agenciaAceita = null;
            }
            final String? chavePixAceita;
            if (dadosAceitos.containsKey('chavePix')) {
              chavePixAceita = dadosAceitos['chavePix'];
            } else {
              chavePixAceita = null;
            }
            if (dadosRejeitados.isNotEmpty) {
              emit(ContaBancariaInfosRejected(dadosRejeitados, dadosAceitos,
                  titularAceito, numeroAceito, agenciaAceita, chavePixAceita));
              return;
            }
            emit(ContaBancariaNotExist());
          } else {
            emit(ContaBancariaLoaded(contaBancaria));
          }
        } else {
          emit(AgenteSemCadastro());
        }
      } catch (e) {
        emit(ContaBancariaError(e.toString()));
      }
    });
  }
}
