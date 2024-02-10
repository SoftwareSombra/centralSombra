import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import '../../../missao/model/missao_model.dart';
import 'events.dart';
import 'states.dart';

class GetMissaoBloc extends Bloc<GetMissaoEvent, GetMissaoState> {
  final MissaoServices missaoServices;

  GetMissaoBloc({required this.missaoServices}) : super(GetMissaoLoading()) {
    on<LoadMissao>((event, emit) async {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final uid = firebaseAuth.currentUser!.uid;
      final nome = firebaseAuth.currentUser!.displayName;
      emit(GetMissaoLoading());
      try {
        bool emMissao = await missaoServices.emMissao(uid);
        if (emMissao) {
          emit(EmMissao());
        } else {
          bool aguradandoResposta = await missaoServices.aguardandoresposta();
          debugPrint('Aguardando resposta: $aguradandoResposta');
          if (aguradandoResposta) {
            final missaoAguardadaId = await missaoServices.missaoAguardada(uid);
            //ir para o evento AceitarChamado
            add(AceitarChamado(missaoAguardadaId, nome!));
          } else {
            await for (var missao
                in missaoServices.getMissaoStream(event.uid)) {
              debugPrint('=================');
              if (missao != null) {
                debugPrint('=====${missao.placaCarreta}=======');
                debugPrint('=====${missao.motorista}======');
                emit(GetMissaoLoaded(missao));
              } else {
                final emMissao2 = await missaoServices.emMissao(uid);
                emMissao2
                    ? emit(EmMissao())
                    : emit(SemMissao('Sem missões no momento'));
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Erro ao buscar missões: $e');
        emit(GetMissaoError('Erro ao buscar missões: $e'));
      }
    });
    on<LoadSavedMission>(
      (event, emit) {
        debugPrint('=================');
        emit(
          GetMissaoLoaded(
            Missao(
              cnpj: event.missao.cnpj,
              nomeDaEmpresa: event.missao.nomeDaEmpresa,
              placaCavalo: event.missao.placaCavalo,
              placaCarreta: event.missao.placaCarreta,
              motorista: event.missao.motorista,
              corVeiculo: event.missao.corVeiculo,
              observacao: event.missao.observacao,
              tipo: event.missao.tipo,
              missaoId: event.missao.missaoId,
              missaoLatitude: event.missao.missaoLatitude,
              missaoLongitude: event.missao.missaoLongitude,
              local: event.missao.local,
              uid: event.missao.uid,
              userLatitude: event.missao.userLatitude,
              userLongitude: event.missao.userLongitude,
            ),
          ),
        );
      },
    );

    on<AceitarChamado>((event, emit) async {
      emit(AceitarChamadoLoading());
      final completer = Completer();
      try {
        missaoServices.buscarResposta().listen((resposta) async {
          if (!completer.isCompleted) {
            if (resposta != null) {
              if (resposta) {
                emit(
                    ConfirmacaoMissaoSuccess('Missão confirmada pela central'));
              } else {
                emit(ConfirmacaoMissaoFailed('Missão recusada pela central'));
              }
            } else {
              Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high);
              final latitude = position.latitude;
              final longitude = position.longitude;
              await missaoServices.aceitarSolicitacao(
                  event.missaoId, event.nome, latitude, longitude);
              emit(AceitarChamadoLoaded());
            }
            completer.complete();
          }
        });

        // Aguardando a conclusão do Stream.listen
        await completer.future;
      } catch (e) {
        if (!completer.isCompleted) {
          emit(ChamadoError('Erro ao aceitar chamado: $e'));
        }
      }
    });

    // adicionar mais manipuladores conforme necessário...
  }
}

//     debugPrint("GetMissaoBloc inicializado");
//     on<LoadMissao>(_onLoadMissao);
//   }

//   Stream<GetMissaoState> _onLoadMissao(
//       LoadMissao event, Emitter<GetMissaoState> emit) async* {
//     debugPrint("Evento LoadMissao recebido");
//     try {
//       emit(GetMissaoLoading());
//       await for (var missao in missaoServices.getMissaoStream(event.uid)) {
//         if (missao != null) {
//           debugPrint("Missão recebida: ${missao.toString()}");
//           emit(GetMissaoLoaded(missao));
//         } else {
//           debugPrint("Sem missões");
//           emit(GetMissaoError('Sem missões no momento'));
//         }
//       }
//     } catch (e) {
//       debugPrint("Erro ao carregar missão: $e");
//       emit(GetMissaoError(e.toString()));
//     }
//   }
// }
