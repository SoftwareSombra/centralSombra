import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../../agente/services/agente_services.dart';
import '../../../sqfLite/missao/services/db_helper.dart';
import '../../model/missao_model.dart';
import '../../services/missao_services.dart';
import 'events.dart';
import 'states.dart';

class AgentMissionBloc extends Bloc<AgentEvent, AgentState> {
  AgentMissionBloc() : super(LoadingAgentState()) {
    //ChatServices chatServices = ChatServices();
    AgenteServices agenteServices = AgenteServices();
    final MissaoServices missaoServices = MissaoServices();

    on<FetchMission>(
      (event, emit) async {
        //pegar localização atual
        FirebaseAuth firebaseAuth = FirebaseAuth.instance;
        final uid = firebaseAuth.currentUser!.uid;
        debugPrint('======uid: $uid=======');

        final isAgent = await agenteServices.isAgent(uid);

        if (!isAgent) {
          emit(IsNotAgent());
          return;
        }

        final currentLocation = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        emit(FetchMissionLoading(uid));

        //verificar se ha conexao com a internet
        final hasConnection = await InternetConnection().hasInternetAccess;

        if (!hasConnection) {
          debugPrint('sem conexao');
          final missaoEmCache =
              await MissionDatabaseHelper.instance.verificarMissaoIniciada();
          debugPrint('missao em cache: ${missaoEmCache.toString()}');
          if (missaoEmCache) {
            final mission = await MissionDatabaseHelper.instance
                .buscarValoresMissaoIniciada();
            final Missao missionDetails = Missao(
              cnpj: '1',
              nomeDaEmpresa: 'a',
              placaCavalo: mission['placaCavalo'],
              placaCarreta: mission['placaCarreta'],
              motorista: mission['motorista'],
              corVeiculo: mission['corVeiculo'],
              observacao: 'a',
              tipo: mission['tipo'],
              missaoId: mission['missaoId'],
              uid: mission['uid'],
              userLatitude: 0,
              userLongitude: 0,
              userFinalLatitude: 0,
              userFinalLongitude: 0,
              missaoLatitude: mission['missaoLatitude'],
              missaoLongitude: mission['missaoLongitude'],
              local: mission['local'],
              inicio: null,
              fim: null,
            );
            emit(OnMission(missionDetails));
            return;
          } else {
            emit(Available());
            return;
          }
        } else {
          final emMissaoResult = await missaoServices.emMissao(uid);
          if (emMissaoResult) {
            final missionDetails = await missaoServices.fetchMissionData(uid);
            final missaoIniciada =
                await missaoServices.verificarMissaoIniciada(uid);
            if (missaoIniciada) {
              //só prosseguir quando missionDetails for diferente de null, ficar aguardando
              while (missionDetails == null) {
                await Future.delayed(const Duration(seconds: 3));
              }
              emit(
                OnMission(missionDetails),
              );
              final missaoEmCache = await MissionDatabaseHelper.instance
                  .verificarMissaoIniciada();
              debugPrint('missao em cache: ${missaoEmCache.toString()}');
              if (missaoEmCache) {
                await missaoServices.excluirMissaoIniciadaCache();
              }
              await missaoServices.iniciarMissaoCache(
                  missionDetails.uid,
                  missionDetails.missaoId,
                  missionDetails.missaoLatitude,
                  missionDetails.missaoLongitude,
                  missionDetails.local,
                  missionDetails.placaCavalo,
                  missionDetails.placaCarreta,
                  missionDetails.motorista,
                  missionDetails.corVeiculo,
                  missionDetails.tipo);
              // final chatEmCache = await chatServices
              //     .verificarChatMissaoCache(missionDetails.missaoId);
              // debugPrint('chat em cache: ${chatEmCache.toString()}');
              // if (chatEmCache) {
              //   await chatServices
              //       .deleteChatMissaoCache(missionDetails.missaoId);
              // }
              // final chatMessages = await FirebaseFirestore.instance
              //     .collection('Chat missão')
              //     .doc(missionDetails.missaoId)
              //     .collection('Mensagens')
              //     .orderBy('Timestamp', descending: false)
              //     .get();
              // //usando for
              // for (var element in chatMessages.docs) {
              //   final Timestamp timestamp = element['Timestamp'];
              //   final DateTime dateTime = timestamp.toDate();
              //   final String iso8601 = dateTime.toIso8601String();

              //   await chatServices.insertChatMissaoCache(
              //     element['User uid'],
              //     element['Mensagem'] ?? '',
              //     element['Imagem'] ?? '',
              //     iso8601,
              //     missionDetails.missaoId,
              //     element['Autor'],
              //     element['FotoUrl'],
              //   );
              // }
              // //debugPrint das mensagens armazenadas no cache
              // final chatMessagesCache = await chatServices
              //     .getChatMissaoCache(missionDetails.missaoId);
              // debugPrint('chatMessagesCache: ${chatMessagesCache.toString()}');
            } else {
              emit(
                MissaoNaoIniciada(
                    uid,
                    missionDetails!.missaoId,
                    currentLocation,
                    missionDetails.local,
                    missionDetails.placaCavalo,
                    missionDetails.placaCarreta,
                    missionDetails.motorista,
                    missionDetails.corVeiculo,
                    missionDetails.tipo),
              );
            }
          } else {
            emit(Available());
          }
        }
      },
    );

    on<FinishMission>(
      (event, emit) {
        emit(Available());
      },
    );
  }
}
