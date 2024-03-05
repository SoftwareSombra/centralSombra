import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../agente/bloc/get_user/agente_bloc.dart';
import '../../agente/bloc/get_user/events.dart';
import '../../missao/bloc/agente/agente_bloc.dart';
import '../../missao/bloc/agente/events.dart';
import '../../perfil_user/bloc/conta_bancaria/conta_bancaria_bloc.dart';
import '../../perfil_user/bloc/conta_bancaria/events.dart';
import '../../veiculos/bloc/veiculos_list/events.dart';
import '../../veiculos/bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_bloc.dart';
import '../../veiculos/bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_event.dart';
import '../../veiculos/bloc/veiculos_list/veiculo_bloc.dart';
import '../bloc/missao_bloc/events.dart';
import '../bloc/missao_bloc/get_missao_bloc.dart';
import 'bloc_events.dart';
import 'bloc_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  final BuildContext context;
  NavigationBloc(this.context) : super(HomeSelected()) {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final uid = firebaseAuth.currentUser!.uid;

    on<ChangeToHome>((event, emit) async {
      await addHomeEvents(context, uid);
      emit(HomeSelected());
    });

    on<ChangeToVeiculos>((event, emit) async {
      await addVeiculosEvents(context, uid);
      emit(VeiculosSelected());
    });

    on<ChangeToPerfil>((event, emit) async {
      await addPerfilEvents(context, uid);
      emit(PerfilSelected());
    });

    on<ChangeToMissao>((event, emit) async {
      await addMissaoEvents(context, uid);
      emit(MissaoSelected());
    });
    // Adicione mais manipuladores conforme necessário...
  }

  Future<void> addHomeEvents(BuildContext context, String uid) async {
    context.read<GetMissaoBloc>().add(LoadMissao(uid));
    context.read<AgentMissionBloc>().add(FetchMission());
  }

  Future<void> addMissaoEvents(BuildContext context, String uid) async {
    context.read<GetMissaoBloc>().add(LoadMissao(uid));
    context.read<AgentMissionBloc>().add(FetchMission());
  }

  Future<void> addVeiculosEvents(BuildContext context, String uid) async {
    context
        .read<RespostaSolicitacaoVeiculoBloc>()
        .add(FetchRespostaSolicitacaoVeiculo(uid));
    context.read<VeiculoBloc>().add(FetchVeiculos(uid));
  }

  Future<void> addPerfilEvents(BuildContext context, String uid) async {
    context.read<AgenteBloc>().add(FetchAgenteInfo(uid));
    context.read<ContaBancariaBloc>().add(FetchContaBancariaInfo(uid));
  }
}
