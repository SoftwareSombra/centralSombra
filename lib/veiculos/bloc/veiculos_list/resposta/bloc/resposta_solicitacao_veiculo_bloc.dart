import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/veiculos/services/veiculos_services.dart';
import 'resposta_solicitacao_veiculo_event.dart';
import 'resposta_solicitacao_veiculo_state.dart';

class RespostaSolicitacaoVeiculoBloc extends Bloc<
    RespostaSolicitacaoVeiculoEvent, RespostaSolicitacaoVeiculoState> {
  RespostaSolicitacaoVeiculoBloc()
      : super(RespostaSolicitacaoVeiculoInitial()) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    on<FetchRespostaSolicitacaoVeiculo>((event, emit) async {
      VeiculoServices veiculoServices = VeiculoServices();
      emit(RespostaSolicitacaoVeiculoLoading());
      try {
        DocumentSnapshot isAgent =
            await firestore.collection('User infos').doc(event.uid).get();
        if (isAgent.exists) {
          final aprovacaoPendente = await veiculoServices
              .existeDocDoAgenteAguardandoAprovacao(event.uid);
          debugPrint('aprovacaoPendente: $aprovacaoPendente');
          if (aprovacaoPendente) {
            emit(RespostaSolicitacaoVeiculoAguardandoAprovacao());
            debugPrint(state.toString());
            return;
          }
          final dadosRejeitados =
              await veiculoServices.getDadosRejeitados(event.uid);
          final dadosAceitos =
              await veiculoServices.getDadosAguardandoAprovacao(event.uid);

          final String? nomeAceito;
          if (dadosAceitos.containsKey('Nome')) {
            nomeAceito = dadosAceitos['Nome'];
          } else {
            nomeAceito = null;
          }
          final String? placaAceita;
          if (dadosAceitos.containsKey('Placa')) {
            placaAceita = dadosAceitos['Placa'];
          } else {
            placaAceita = null;
          }
          final String? marcaAceita;
          if (dadosAceitos.containsKey('Marca')) {
            marcaAceita = dadosAceitos['Marca'];
          } else {
            marcaAceita = null;
          }
          final String? modeloAceito;
          if (dadosAceitos.containsKey('Modelo')) {
            modeloAceito = dadosAceitos['Modelo'];
          } else {
            modeloAceito = null;
          }
          final String? corAceita;
          if (dadosAceitos.containsKey('Cor')) {
            corAceita = dadosAceitos['Cor'];
          } else {
            corAceita = null;
          }
          final String? anoAceito;
          if (dadosAceitos.containsKey('Ano')) {
            anoAceito = dadosAceitos['Ano'];
          } else {
            anoAceito = null;
          }
          if (dadosRejeitados.isNotEmpty) {
            emit(RespostaSolicitacaoVeiculoLoaded(
                dadosRejeitados,
                dadosAceitos,
                nomeAceito,
                placaAceita,
                marcaAceita,
                modeloAceito,
                corAceita,
                anoAceito));
          } else {
            emit(RespostaSolicitacaoNotFound());
          }
        } else {
          emit(SemCadastro());
        }
      } catch (e) {
        emit(RespostaSolicitacaoVeiculoError(e.toString()));
      }
    });
  }
}
