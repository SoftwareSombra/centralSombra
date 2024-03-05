import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/agente/services/agente_services.dart';
import '../../model/agente_model.dart';
import 'events.dart';
import 'states.dart';

class AgenteBloc extends Bloc<AgenteEvent, AgenteState> {
  final AgenteServices agenteServices = AgenteServices();
  AgenteBloc() : super(AgenteInitial()) {
    on<FetchAgenteInfo>((event, emit) async {
      emit(AgenteLoading());
      try {
        Agente? agente = await agenteServices.getAgenteInfos(event.uid);
        final emAnalise = await agenteServices.emAnalise(event.uid);
        if (emAnalise) {
          emit(EmAnalise());
          return;
        }
        if (agente == null) {
          debugPrint('chegou aqui, agente == null');
          final dadosRejeitados =
              await agenteServices.getDadosRejeitados(event.uid);
          final dadosAceitos =
              await agenteServices.getDadosAguardandoAprovacao(event.uid);
          debugPrint('passou aqui');
          final String? nomeAceito;
          if (dadosAceitos.containsKey('Nome')) {
            nomeAceito = dadosAceitos['Nome'];
          } else {
            nomeAceito = null;
          }
          // final String? enderecoAceito;
          // if (dadosAceitos.containsKey('Endereço')) {
          //   enderecoAceito = dadosAceitos['Endereço'];
          // } else {
          //   enderecoAceito = null;
          // }
          final String? logradouroAceito;
          if (dadosAceitos.containsKey('logradouro')) {
            logradouroAceito = dadosAceitos['logradouro'];
          } else {
            logradouroAceito = null;
          }
          final String? numeroAceito;
          if (dadosAceitos.containsKey('numero')) {
            numeroAceito = dadosAceitos['numero'];
          } else {
            numeroAceito = null;
          }
          final String? bairroAceito;
          if (dadosAceitos.containsKey('bairro')) {
            bairroAceito = dadosAceitos['bairro'];
          } else {
            bairroAceito = null;
          }
          final String? cidadeAceito;
          if (dadosAceitos.containsKey('cidade')) {
            cidadeAceito = dadosAceitos['cidade'];
          } else {
            cidadeAceito = null;
          }
          final String? estadoAceito;
          if (dadosAceitos.containsKey('estado')) {
            estadoAceito = dadosAceitos['estado'];
          } else {
            estadoAceito = null;
          }
          final String? complementoAceito;
          if (dadosAceitos.containsKey('complemento')) {
            complementoAceito = dadosAceitos['complemento'];
          } else {
            complementoAceito = null;
          }
          final String? cepAceito;
          if (dadosAceitos.containsKey('Cep')) {
            cepAceito = dadosAceitos['Cep'];
          } else {
            cepAceito = null;
          }
          final String? celularAceito;
          if (dadosAceitos.containsKey('Celular')) {
            celularAceito = dadosAceitos['Celular'];
          } else {
            celularAceito = null;
          }
          final String? rgAceito;
          if (dadosAceitos.containsKey('RG')) {
            rgAceito = dadosAceitos['RG'];
          } else {
            rgAceito = null;
          }
          final String? cpfAceito;
          if (dadosAceitos.containsKey('CPF')) {
            cpfAceito = dadosAceitos['CPF'];
          } else {
            cpfAceito = null;
          }
          final String? rgFrenteAceito;
          if (dadosAceitos.containsKey('RG frente')) {
            rgFrenteAceito = dadosAceitos['RG frente'];
          } else {
            rgFrenteAceito = null;
          }
          final String? rgVersoAceito;
          if (dadosAceitos.containsKey('RG verso')) {
            rgVersoAceito = dadosAceitos['RG verso'];
          } else {
            rgVersoAceito = null;
          }
          final String? compResidAceito;
          if (dadosAceitos.containsKey('Comprovante de residência')) {
            compResidAceito = dadosAceitos['Comprovante de residência'];
          } else {
            compResidAceito = null;
          }
          debugPrint('valor ${dadosRejeitados.toString()}');
          debugPrint(event.uid);
          if (dadosRejeitados.isNotEmpty) {
            emit(AgenteInfosRejected(
                dadosRejeitados,
                dadosAceitos,
                nomeAceito,
                //enderecoAceito,
                logradouroAceito,
                numeroAceito,
                bairroAceito,
                cidadeAceito,
                estadoAceito,
                complementoAceito,
                cepAceito,
                celularAceito,
                rgAceito,
                cpfAceito,
                rgFrenteAceito,
                rgVersoAceito,
                compResidAceito));
            return;
          }
          emit(AgenteNotExist());
        } else {
          emit(AgenteLoaded(agente));
        }
      } catch (e) {
        emit(AgenteError(e.toString()));
      }
    });
  }
}
