import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:js_interop';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import '../../agente/model/agente_model.dart';
import '../../agente/services/agente_services.dart';
import '../../chat/services/chat_services.dart';
import '../../notificacoes/fcm.dart';
import '../../notificacoes/notificacoess.dart';
import '../../sqfLite/missao/model/missao_db_model.dart';
import '../../sqfLite/missao/services/db_helper.dart';
import '../../web/home/screens/mapa_teste.dart';
import '../model/missao_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../model/missao_solicitada.dart';

class MissaoServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  //final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<String?> criarChamado(
      cnpj,
      nomeDaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      missaoId,
      uid,
      tipo,
      userLatitude,
      userLongitude,
      missaoLatitude,
      missaoLongitude,
      local) async {
    final timestamp = FieldValue.serverTimestamp();

    try {
      await firestore.collection('Convites missões').doc(uid).set({
        'cnpj': cnpj,
        'nome da empresa': nomeDaEmpresa,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
        'tipo de missao': tipo,
        'missaoID': missaoId,
        'userUid': uid,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'local': local,
        'timestamp': timestamp,
      });
      await firestore.collection('Chamado gerado').doc(missaoId).set({
        'Chamado gerado': true,
      });
      // await firestore
      //     .collection('Missões')
      //     .doc(missaoId)
      //     .set({'missaoID': missaoId, 'emAndamento': false});
      // await firestore.collection('Empresa').doc(cnpj)
      //.collection('Missões ativas').doc(missaoId).set(
      //     {'missaoID': missaoId, 'emAndamento': false, 'criadaEm': timestamp});
      //await firestore.collection('Missões solicitadas').doc(missaoId).delete();
      return 'Chamado criado com sucesso';
    } catch (e) {
      return 'Erro ao criar chamado';
    }
  }

  Future<String> criarSolicitacao(
      cnpj,
      nomeDaEmpresa,
      tipo,
      missaoLatitude,
      missaoLongitude,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      {local}) async {
    const uuid = Uuid();
    final missaoId = uuid.v1();
    //final uid = user!.uid;
    final timestamp = FieldValue.serverTimestamp();

    try {
      local ??= await getAddressFromLatLng(missaoLatitude, missaoLongitude);

      await firestore
          .collection('Missões solicitadas')
          .doc(cnpj)
          .set({'sinc': 'sinc'});
      await firestore
          .collection('Missões solicitadas')
          .doc(cnpj)
          .collection('Missao')
          .doc(missaoId)
          .set({
        'cnpj': cnpj,
        'nome da empresa': nomeDaEmpresa,
        'missaoId': missaoId,
        'tipo de missao': tipo,
        'timestamp': timestamp,
        'userUid': uid,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'local': local,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
      });
      return 'Agente solicitado com sucesso';
    } catch (e) {
      return 'Erro ao solicitar agente';
    }
  }

  Future<String?> getAddressFromLatLng(
      double latitude, double longitude) async {
    const String apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
    const String baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

    try {
      var response = await Dio().get(baseUrl, queryParameters: {
        'latlng': '$latitude,$longitude',
        'key': apiKey,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.toString());

        // Verifica se obteve alguma resposta
        if (data['results'].isNotEmpty) {
          // Retorna o endereço formatado
          return data['results'][0]['formatted_address'];
        } else {
          debugPrint('Nenhum endereço encontrado.');
          return null;
        }
      } else {
        debugPrint('Erro ao obter o endereço: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao fazer a requisição: $e');
      return null;
    }
  }

  Future<bool> criarMissaoPendente(
      cnpj,
      nomeDaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      missaoId,
      uid,
      tipo,
      userLatitude,
      userLongitude,
      missaoLatitude,
      missaoLongitude,
      local) async {
    try {
      await firestore.collection('Missões pendentes').doc(cnpj).set({
        'sinc': 'sinc',
      });
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Missões pendentes')
          .doc(cnpj)
          .collection('Missao')
          .doc(missaoId)
          .set({
        'cnpj': cnpj,
        'nome da empresa': nomeDaEmpresa,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
        'tipo de missao': tipo,
        'missaoId': missaoId,
        'userUid': uid,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'local': local,
        'timestamp': timestamp,
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao criar missão pendente: $e');
      return false;
    }
  }

  Future<void> rejeitarSolicitacao(
      String missaoId, String cnpj, String local, timestamp) async {
    try {
      await firestore
          .collection('Missões solicitadas')
          .doc(cnpj)
          .collection('Missao')
          .doc(missaoId)
          .delete();

      await checkMissaoSolicitadaIdAndDelete(missaoId, cnpj);

      await firestore
          .collection('Solicitacoes rejeitadas')
          .doc(cnpj)
          .set({'sinc': 'sinc'});

      await firestore
          .collection('Solicitacoes rejeitadas')
          .doc(cnpj)
          .collection('Solicitacao')
          .doc(missaoId)
          .set({
        'missaoId': missaoId,
        'cnpj': cnpj,
        'local': local,
        'solicitadaEm': timestamp,
        'rejeitadaPor': uid,
        'rejeitadaEm': FieldValue.serverTimestamp()
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejeitarSolicitacaoPendente(
      String missaoId, String cnpj, String local, timestamp) async {
    try {
      await firestore
          .collection('Missões pendentes')
          .doc(cnpj)
          .collection('Missao')
          .doc(missaoId)
          .delete();

      await checkMissaoSolicitadaIdAndDelete(missaoId, cnpj);

      await firestore
          .collection('Solicitacoes rejeitadas')
          .doc(cnpj)
          .set({'sinc': 'sinc'});

      await firestore
          .collection('Solicitacoes rejeitadas')
          .doc(cnpj)
          .collection('Solicitacao')
          .doc(missaoId)
          .set({
        'missaoId': missaoId,
        'cnpj': cnpj,
        'local': local,
        'solicitadaEm': timestamp,
        'rejeitadaPor': uid,
        'rejeitadaEm': FieldValue.serverTimestamp()
      });
      await checkMissaoIdAndDelete(missaoId);
      await firestore.collection('Chamado gerado').doc(missaoId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkMissaoIdAndDelete(String missaoId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Convites missões')
          .where('missaoID', isEqualTo: missaoId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        debugPrint('Existem documentos com o missaoID $missaoId');
        // Iterar sobre os documentos se precisar
        for (var doc in querySnapshot.docs) {
          await firestore.collection('Convites missões').doc(doc.id).delete();
        }
      } else {
        debugPrint('Não existem documentos com o missaoID $missaoId');
      }
    } catch (e) {
      debugPrint('Erro ao verificar missaoID: $e');
    }
  }

  Future<void> checkMissaoSolicitadaIdAndDelete(
      String missaoId, String cnpj) async {
    final firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Missões solicitadas')
          .doc(cnpj)
          .collection('Missao')
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('Não xistem documentos com o cnpj: $cnpj');
        await firestore.collection('Missões solicitadas').doc(cnpj).delete();
      } else {
        debugPrint('Não existem documentos com o missaoID $missaoId');
      }
    } catch (e) {
      debugPrint('Erro ao verificar missaoID: $e');
    }
  }

  Future<bool?> verificarSeAgenteRejeitou(uid, missaoId) async {
    debugPrint('verificando se agente ja rejeitou missao !!!!');
    debugPrint(uid);
    debugPrint(missaoId);
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await firestore
          .collection('Missões recusadas')
          .doc(missaoId)
          .collection('Agente')
          .doc(uid)
          .get();

      debugPrint('!!!!!!!! já?: ${doc.exists.toString()}');
      return doc.exists;
    } catch (e) {
      debugPrint('Erro ao tentar verificar recusa de missao: ${e.toString()}');
      rethrow;
    }
  }

  Stream<bool> verificarSeAlgumAgenteAceitou(String missaoId) {
    try {
      return FirebaseFirestore.instance
          .collection('Respostas dos agentes')
          .doc(missaoId)
          .snapshots()
          .map((snapshot) {
        if (snapshot.data() != null) {
          var data = snapshot.data()!;
          return data['notificacao'] is bool ? data['notificacao'] : false;
        }
        return false;
      });
    } catch (e) {
      debugPrint("Erro ao buscar as missões solicitadas: $e");
      return Stream.value(false);
    }
  }

  Stream<bool> existeSolicitacaoPendente() {
    try {
      return firestore
          .collection('Missões solicitadas')
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty);
    } catch (e) {
      debugPrint("Erro ao buscar os missoes solicitadas: $e");
      return Stream.value(false);
    }
  }

  Stream<List<MissaoSolicitada>> buscarMissoesSolicitadasStream() {
    return FirebaseFirestore.instance
        .collection('Missões solicitadas')
        .snapshots()
        .switchMap((missoesSnapshot) {
      List<Stream<List<MissaoSolicitada>>> empresaStreams = [];

      for (var missaoDoc in missoesSnapshot.docs) {
        String cnpj = missaoDoc.id;

        var empresaStream = FirebaseFirestore.instance
            .collection('Missões solicitadas')
            .doc(cnpj)
            .collection('Missao')
            .snapshots()
            .map((empresasSnapshot) {
          List<MissaoSolicitada> missoes = [];
          debugPrint(empresasSnapshot.docs.length.toString());

          for (var empresaDoc in empresasSnapshot.docs) {
            MissaoSolicitada missao = MissaoSolicitada.fromFirestore(
                cnpj, empresaDoc.data() as Map<String, dynamic>);
            debugPrint(missao.toString());
            missoes.add(missao);
          }

          return missoes;
        });

        empresaStreams.add(empresaStream);
      }

      if (empresaStreams.isEmpty) {
        // Caso não haja sub-coleções, retorne um stream vazio
        return Stream.value([]);
      }

      // Combine todos os streams em um único stream
      return CombineLatestStream(empresaStreams,
          (List<List<MissaoSolicitada>> missoesList) {
        List<MissaoSolicitada> allMissoes = [];

        for (var missoes in missoesList) {
          allMissoes.addAll(missoes);
        }

        // Ordena as missões por data
        allMissoes.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return allMissoes;
      });
    });
  }

  Future<int> quantidadeDeMissoesPendentes() async {
    final qtd = await firestore.collection('Missões pendentes').get();
    return qtd.docs.length;
  }

  //quantidade de missões pendentes stream
  Stream<int> quantidadeDeMissoesPendentesStream() {
    return firestore.collection('Missões pendentes').snapshots().map((event) {
      return event.docs.length;
    });
  }

  Stream<int> quantidadeDeMissoesPendentesStream2() {
    final missaoPendentesRef =
        FirebaseFirestore.instance.collection('Missões pendentes');

    return missaoPendentesRef.snapshots().switchMap((snapshot) {
      final subCollectionsStreams = snapshot.docs.map((doc) {
        final missaoRef = missaoPendentesRef.doc(doc.id).collection('Missao');
        return missaoRef
            .snapshots()
            .map((subSnapshot) => subSnapshot.docs.length);
      });

      return Rx.combineLatest(subCollectionsStreams, (List<int> counts) {
        return counts.reduce((a, b) => a + b);
      });
    });
  }

  //excluir missao pendente
  Future<bool> excluirMissaoPendente(String missaoId, String cnpj) async {
    try {
      await firestore
          .collection('Missões pendentes')
          .doc(cnpj)
          .collection('Missao')
          .doc(missaoId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> recusadoPelaCentral(uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('Resposta do chamado')
          .doc(uid)
          .set({'aguardando': false});
      await firestore.collection('Convites missões').doc(uid).delete();
      return 'Enviado com sucesso';
    } catch (e) {
      return 'Erro ao enviar resposta';
    }
  }

  Future<String?> aceitarSolicitacao(
      missaoId, nome, userLatitude, userLongitude) async {
    try {
      final uid = firebaseAuth.currentUser!.uid;
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Solicitações aceitas')
          .doc(missaoId)
          .collection('Agente')
          .doc(uid)
          .set({
        'missaoID': missaoId,
        'userUid': uid,
        'timestamp': timestamp,
        'nome': nome,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
      });
      await FirebaseFirestore.instance
          .collection('Resposta do chamado')
          .doc(uid)
          .set({'sinalizado': true});
    } catch (e) {
      return 'Erro ao aceitar missão';
    }
    return 'Erro ao aceitar missão';
  }

  Future<List<Map<String, dynamic>>> buscarAgentesQueAceitaram(
      String missaoId) async {
    List<Map<String, dynamic>> agentes = [];

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Solicitações aceitas')
          .doc(missaoId)
          .collection('Agente')
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        agentes.add({
          'userUid': data['userUid'],
          'nome': data['nome'],
          'userLatitude': data['userLatitude'],
          'userLongitude': data['userLongitude'],
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar agentes: $e');
      // Tratar o erro conforme necessário
    }

    return agentes;
  }

  Future<bool> criarMissao(
      cnpj,
      nomedaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      uid,
      userLatitude,
      userLongitude,
      missaoLatitude,
      missaoLongitude,
      local,
      tipo,
      missaoId,
      nome) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore.collection('Missões aceitas').doc(uid).set({
        'cnpj': cnpj,
        'nome da empresa': nomedaEmpresa,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
        'tipo de missao': tipo,
        'missaoID': missaoId,
        'userUid': uid,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'local': local,
        'inicio': timestamp,
        'agente': nome,
      });
      await firestore.collection('Missões').doc(missaoId).set({
        'cnpj': cnpj,
        'nome da empresa': nomedaEmpresa,
        'missaoID': missaoId,
        'emAndamento': true,
        'timestamp': timestamp,
        'agenteUid': uid
      });
      await firestore
          .collection('Empresa')
          .doc(cnpj)
          .collection('Missões ativas')
          .doc(missaoId)
          .set({
        'cnpj': cnpj,
        'nome da empresa': nomedaEmpresa,
        'missaoID': missaoId,
        'emAndamento': true,
        'timestamp': timestamp,
        'agenteUid': uid,
        'nome': nome,
        'tipo': tipo,
        'criadaEm': timestamp,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'local': local,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
      });
      await firestore
          .collection('Missões solicitadas')
          .doc(cnpj)
          .collection('Missao')
          .doc(missaoId)
          .delete();
      await firestore.collection('Convites missões').doc(uid).delete();
      await firestore.collection('Chamado gerado').doc(missaoId).delete();
      await FirebaseFirestore.instance
          .collection('Resposta do chamado')
          .doc(uid)
          .delete();
      await firestore
          .collection('Solicitações aceitas')
          .doc(missaoId)
          .collection('Agente')
          .doc(uid)
          .delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> emMissao(String uid) async {
    final DocumentSnapshot result =
        await firestore.collection('Missões aceitas').doc(uid).get();

    return result.exists;
  }

  Future<bool> iniciarMissao(uid, missaoId, Position currentLocation) async {
    final timestamp = FieldValue.serverTimestamp();
    final missiontimestamp = DateTime.now();
    try {
      await firestore.collection('Missão iniciada').doc(uid).set({
        'userUid': uid,
        'inicio': timestamp,
      });
      await firestore
          .collection('Rotas')
          .doc(missaoId)
          .collection('Rota')
          .doc()
          .set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'uid': uid,
        'timestamp': missiontimestamp,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> iniciarMissaoCache(
    uid,
    missaoId,
    missaoLatitude,
    missaoLongitude,
    local,
    String? placaCavalo,
    String? placaCarreta,
    String? motorista,
    String? corVeiculo,
    String? tipo,
  ) async {
    try {
      debugPrint('iniciando missao cache...');
      final db = MissionDatabaseHelper.instance.database;
      db.then((db) async {
        await db.insert(MissaoIniciadaTable.tableName, {
          MissaoIniciadaTable.columnUid: uid,
          MissaoIniciadaTable.columnMissaoId: missaoId,
          MissaoIniciadaTable.columnMissaoLatitude: missaoLatitude,
          MissaoIniciadaTable.columnMissaoLongitude: missaoLongitude,
          MissaoIniciadaTable.columnLocal: local,
          MissaoIniciadaTable.columnPlacaCavalo: placaCavalo,
          MissaoIniciadaTable.columnPlacaCarreta: placaCarreta,
          MissaoIniciadaTable.columnMotorista: motorista,
          MissaoIniciadaTable.columnCorVeiculo: corVeiculo,
          MissaoIniciadaTable.columnTipo: tipo,
        });
        //debugPrint de cada campo adicionado
        List<Map> missao = await db.query(MissaoIniciadaTable.tableName);
        debugPrint('missao: $missao');
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //excluir missao iniciada do cache
  Future<bool> excluirMissaoIniciadaCache() async {
    try {
      debugPrint('excluindo missao cache...');
      final db = MissionDatabaseHelper.instance.database;
      db.then((db) async {
        await db.delete(MissaoIniciadaTable.tableName);
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> finalLocalMissao(uid, missaoId, Position currentLocation) async {
    final missiontimestamp = DateTime.now();
    try {
      await firestore
          .collection('Rotas')
          .doc(missaoId)
          .collection('Rota')
          .doc()
          .set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'uid': uid,
        'timestamp': missiontimestamp,
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool?> finalLocalMissaoRequest(
      String uid, missaoId, latitude, longitude) async {
    debugPrint('Enviando final local...');

    final timestamp = DateTime.now().toString();
    var dio = Dio();
    var url =
        'https://southamerica-east1-sombratestes.cloudfunctions.net/addFinalLocation';

    try {
      var response = await dio.post(url, data: {
        'uid': uid,
        'missaoId': missaoId,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
      });

      debugPrint(response.data);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Falha na requisição: Status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Exceção capturada ao final local: $e');
      return false;
    }
  }

  Future<bool> finalLocalMissaoOffline(
      String uid, missaoId, latitude, longitude) async {
    debugPrint('localizacao final offline...');
    try {
      final db = await MissionDatabaseHelper.instance.database;
      await db.insert(FinalLocalTable.tableName, {
        FinalLocalTable.columnUid: uid,
        FinalLocalTable.columnMissaoId: missaoId,
        FinalLocalTable.columnLatitude: latitude,
        FinalLocalTable.columnLongitude: longitude,
      });
      //debugPrint de cada campo adicionado
      List<Map> missao = await db.query(FinalLocalTable.tableName);
      debugPrint('missao offline salva: $missao');
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar localização final offline: $e');
      return false;
    }
  }

  Future<Tuple2<bool, String>> finalLocalMissaoSelectFunction(
      String uid, missaoId, latitude, longitude) async {
    var connectivityResult = await InternetConnection().hasInternetAccess;
    if (!connectivityResult) {
      try {
        final finalLocalOff =
            await finalLocalMissaoOffline(uid, missaoId, latitude, longitude);
        if (finalLocalOff) {
          return const Tuple2(
              true, 'Sem internet, localização salva com sucesso');
        } else {
          return const Tuple2(false, 'Erro ao salvar localização');
        }
      } catch (e) {
        return const Tuple2(false, 'Erro ao salvar localização');
      }
    } else {
      try {
        final finalLocalOn =
            await finalLocalMissaoRequest(uid, missaoId, latitude, longitude);
        if (finalLocalOn!) {
          return const Tuple2(true, 'Localização salva com sucesso');
        } else {
          return const Tuple2(false, 'Erro ao salvar localização');
        }
      } catch (e) {
        return const Tuple2(false, 'Erro ao salvar localização');
      }
    }
  }

  Future<bool> finalLocalPendente() async {
    Database db = await MissionDatabaseHelper.instance.database;
    List<Map> missao = await db.query(FinalLocalTable.tableName);
    debugPrint('missao: $missao');

    if (missao.isEmpty) {
      return true;
    }

    for (var missao in missao) {
      try {
        final sucesso = await finalLocalMissaoRequest(
          missao[FinalLocalTable.columnUid],
          missao[FinalLocalTable.columnMissaoId],
          missao[FinalLocalTable.columnLatitude],
          missao[FinalLocalTable.columnLongitude],
        );
        if (sucesso!) {
          await db.delete(
            FinalLocalTable.tableName,
            where: '${FinalLocalTable.columnId} = ?',
            whereArgs: [missao[FinalLocalTable.columnId]],
          );
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  Future<bool> verificarMissaoIniciada(String uid) async {
    final DocumentSnapshot result =
        await firestore.collection('Missão iniciada').doc(uid).get();

    return result.exists;
  }

  Future<Missao?> fetchMissionData(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Missões aceitas')
          .doc(uid)
          .get();

      if (doc.exists) {
        return Missao.fromFirestore(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (error) {
      debugPrint('Erro ao buscar dados da missão: $error');
      return null;
    }
  }

  Future<MissaoConcluida?> fetchMissionId(String uid) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('Missões concluídas').doc(uid).get();

      if (doc.exists) {
        return MissaoConcluida.fromFirestore(
            doc.data() as Map<String, dynamic>, uid);
      } else {
        return null;
      }
    } catch (error) {
      debugPrint('Erro ao buscar dados da missão: $error');
      return null;
    }
  }

  Future<String?> recusarMissao(uid) async {
    try {
      await firestore.collection('Convites missões').doc(uid).delete();
      return 'Missão recusada.';
    } catch (e) {
      return 'Erro ao recusar missão';
    }
  }

  Future<String?> finalizarMissao(
    cnpj,
    nomedaEmpresa,
    placaCavalo,
    placaCarreta,
    motorista,
    corVeiculo,
    observacao,
    uid,
    userLatitude,
    userLongitude,
    userFinalLatitude,
    userFinalLongitude,
    missaoLatitude,
    missaoLongitude,
    tipo,
    missaoId,
  ) async {
    try {
      await firestore.collection('Missões aceitas').doc(uid).delete();
      await firestore
          .collection('Empresa')
          .doc(cnpj)
          .collection('Missões ativas')
          .doc(missaoId)
          .delete();
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Missões concluídas')
          .doc(uid)
          .collection('Missão')
          .doc(missaoId)
          .set({
        'cnpj': cnpj,
        'nome da empresa': nomedaEmpresa,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
        'tipo de missao': tipo,
        'missaoID': missaoId,
        'userUid': uid,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'userFinalLatitude': userFinalLatitude,
        'userFinalLongitude': userFinalLongitude,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'fim': timestamp,
        'relatorio': true,
        'finalizadaPor': 'Agente'
      });
      return 'Missão finalizada com sucesso';
    } catch (e) {
      return 'Erro ao finalizar missão';
    }
  }

  Future<bool?> finalizarMissaoRequest(
      cnpj,
      nomedaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      uid,
      userLatitude,
      userLongitude,
      userFinalLatitude,
      userFinalLongitude,
      missaoLatitude,
      missaoLongitude,
      local,
      tipo,
      missaoId,
      {fim}) async {
    debugPrint('Enviando final missão...');

    var dio = Dio();
    var url =
        'https://southamerica-east1-sombratestes.cloudfunctions.net/finalizarMissao';

    try {
      var response = await dio.post(url, data: {
        'cnpj': cnpj,
        'nomeDaEmpresa': nomedaEmpresa,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
        'tipo': tipo,
        'missaoID': missaoId,
        'userUid': uid,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'userFinalLatitude': userFinalLatitude,
        'userFinalLongitude': userFinalLongitude,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'local': local,
        'fim': fim,
      });

      debugPrint(response.data);

      if (response.statusCode == 200) {
        debugPrint('Missão finalizada com sucesso');
        return true;
      } else {
        debugPrint('Falha na requisição: Status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Exceção capturada ao finalizar missao: $e');
      return false;
    }
  }

  Future<Tuple2<bool, String?>> finalizarMissaoOffline(
      cnpj,
      nomedaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      uid,
      userLatitude,
      userLongitude,
      userFinalLatitude,
      userFinalLongitude,
      missaoLatitude,
      missaoLongitude,
      local,
      tipo,
      missaoId,
      {fim}) async {
    try {
      debugPrint('finalizando missao offline...');
      final db = await MissionDatabaseHelper.instance.database;
      await db.insert(MissaoFinalizadaTable.tableName, {
        MissaoFinalizadaTable.columnUid: uid,
        MissaoFinalizadaTable.columnMissaoId: missaoId,
        MissaoFinalizadaTable.columnCnpj: cnpj,
        MissaoFinalizadaTable.columnNomeDaEmpresa: nomedaEmpresa,
        MissaoFinalizadaTable.columnPlacaCavalo: placaCavalo,
        MissaoFinalizadaTable.columnPlacaCarreta: placaCarreta,
        MissaoFinalizadaTable.columnMotorista: motorista,
        MissaoFinalizadaTable.columnCorVeiculo: corVeiculo,
        MissaoFinalizadaTable.columnObservacao: observacao,
        MissaoFinalizadaTable.columnTipo: tipo,
        MissaoFinalizadaTable.columnUserLatitude: userLatitude,
        MissaoFinalizadaTable.columnUserLongitude: userLongitude,
        MissaoFinalizadaTable.columnUserFinalLatitude: userFinalLatitude,
        MissaoFinalizadaTable.columnUserFinalLongitude: userFinalLongitude,
        MissaoFinalizadaTable.columnMissaoLatitude: missaoLatitude,
        MissaoFinalizadaTable.columnMissaoLongitude: missaoLongitude,
        MissaoFinalizadaTable.columnLocal: local,
        MissaoFinalizadaTable.columnFim: DateTime.now().toIso8601String(),
      });
      //debugPrint de cada campo adicionado
      List<Map> missao = await db.query(MissaoFinalizadaTable.tableName);
      debugPrint('missao: $missao');
      return const Tuple2(true, 'Missão finalizada com sucesso');
    } catch (e) {
      debugPrint('Erro ao salvar missão finalizada offline: $e');
      return const Tuple2(false, 'Erro ao finalizar missão offline');
    }
  }

  Future<Tuple2<bool, String?>> finalizarMissaoSelectFunction(
    cnpj,
    nomedaEmpresa,
    placaCavalo,
    placaCarreta,
    motorista,
    corVeiculo,
    observacao,
    uid,
    userLatitude,
    userLongitude,
    userFinalLatitude,
    userFinalLongitude,
    missaoLatitude,
    missaoLongitude,
    local,
    tipo,
    missaoId, {
    fim,
  }) async {
    var connectivityResult = await InternetConnection().hasInternetAccess;
    if (!connectivityResult) {
      try {
        final sucesso = await finalizarMissaoOffline(
          cnpj,
          nomedaEmpresa,
          placaCavalo,
          placaCarreta,
          motorista,
          corVeiculo,
          observacao,
          uid,
          userLatitude,
          userLongitude,
          userFinalLatitude,
          userFinalLongitude,
          missaoLatitude,
          missaoLongitude,
          local,
          tipo,
          missaoId,
          fim: fim,
        );
        if (sucesso.item1) {
          return const Tuple2(
              true, 'Sem internet, missão finalizada com sucesso');
        } else {
          return const Tuple2(false, 'Erro ao finalizar missão offline');
        }
      } catch (e) {
        debugPrint('Erro ao finalizar missão offline: $e');
        return const Tuple2(false, 'Erro ao finaliar missão offline');
      }
    } else {
      try {
        final finalizar = await finalizarMissaoRequest(
          cnpj,
          nomedaEmpresa,
          placaCavalo,
          placaCarreta,
          motorista,
          corVeiculo,
          observacao,
          uid,
          userLatitude,
          userLongitude,
          userFinalLatitude,
          userFinalLongitude,
          missaoLatitude,
          missaoLongitude,
          local,
          tipo,
          missaoId,
        );
        if (finalizar!) {
          return const Tuple2(true, 'Missão finalizada com sucesso');
        } else {
          return const Tuple2(false, 'Erro ao finalizar missão');
        }
      } catch (e) {
        return const Tuple2(false, 'Erro ao finalizar missão');
      }
    }
  }

  Future<bool> finalizarMissaoPendente() async {
    Database db = await MissionDatabaseHelper.instance.database;
    List<Map> missao = await db.query(MissaoFinalizadaTable.tableName);
    debugPrint('missao finalizada: $missao');

    if (missao.isEmpty) {
      return true;
    }

    for (var missao in missao) {
      try {
        final sucesso = await finalizarMissaoRequest(
          missao[MissaoFinalizadaTable.columnCnpj],
          missao[MissaoFinalizadaTable.columnNomeDaEmpresa],
          missao[MissaoFinalizadaTable.columnPlacaCavalo],
          missao[MissaoFinalizadaTable.columnPlacaCarreta],
          missao[MissaoFinalizadaTable.columnMotorista],
          missao[MissaoFinalizadaTable.columnCorVeiculo],
          missao[MissaoFinalizadaTable.columnObservacao],
          missao[MissaoFinalizadaTable.columnUid],
          missao[MissaoFinalizadaTable.columnUserLatitude],
          missao[MissaoFinalizadaTable.columnUserLongitude],
          missao[MissaoFinalizadaTable.columnUserFinalLatitude],
          missao[MissaoFinalizadaTable.columnUserFinalLongitude],
          missao[MissaoFinalizadaTable.columnMissaoLatitude],
          missao[MissaoFinalizadaTable.columnMissaoLongitude],
          missao[MissaoFinalizadaTable.columnLocal],
          missao[MissaoFinalizadaTable.columnTipo],
          missao[MissaoFinalizadaTable.columnMissaoId],
          fim: missao[MissaoFinalizadaTable.columnFim],
        );
        if (sucesso!) {
          await db.delete(
            MissaoFinalizadaTable.tableName,
            where: '${MissaoFinalizadaTable.columnId} = ?',
            whereArgs: [missao[MissaoFinalizadaTable.columnId]],
          );
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  Future<bool> verificarFinalizacaoPendente() async {
    Database db = await MissionDatabaseHelper.instance.database;
    List<Map> missao = await db.query(MissaoFinalizadaTable.tableName);

    return missao.isNotEmpty;
  }

  Future<bool> forcarEncerrarMissao(
      cnpj,
      nomedaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      uid,
      userLatitude,
      userLongitude,
      userFinalLatitude,
      userFinalLongitude,
      missaoLatitude,
      missaoLongitude,
      tipo,
      missaoId,
      local,
      agente) async {
    try {
      await firestore
          .collection('Missões encerradas')
          .doc(uid)
          .set({'missaoEncerradaPelaCentral': true});
      await firestore.collection('Missões aceitas').doc(uid).delete();
      await firestore.collection('Missão iniciada').doc(uid).delete();
      await firestore
          .collection('Empresa')
          .doc(cnpj)
          .collection('Missões ativas')
          .doc(missaoId)
          .delete();
      await firestore.collection('Resposta do chamado').doc(uid).delete();
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Missões concluídas')
          .doc(uid)
          .collection('Missão')
          .doc(missaoId)
          .set({
        'cnpj': cnpj,
        'nome da empresa': nomedaEmpresa,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
        'tipo de missao': tipo,
        'missaoID': missaoId,
        'userUid': uid,
        'userLatitude': userLatitude,
        'userLongitude': userLongitude,
        'userFinalLatitude': userFinalLatitude,
        'userFinalLongitude': userFinalLongitude,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'fim': timestamp,
        'relatorio': true,
        'finalizadaPor': 'Central'
      });
      await relatorioMissao(
          cnpj,
          nomedaEmpresa,
          placaCavalo,
          placaCarreta,
          motorista,
          corVeiculo,
          observacao,
          uid,
          missaoId,
          agente,
          tipo,
          userLatitude,
          userLongitude,
          userFinalLatitude,
          userFinalLongitude,
          missaoLatitude,
          missaoLongitude,
          local,
          'Central');
      debugPrint('missao encerrada com sucesso');
    } catch (e) {
      debugPrint('=== erro ao encerrar missao: $e =====');
      return false;
    }
    return true;
  }

  // Future<bool> relatorioPendente(String uid) async {
  //   try {
  //     DocumentSnapshot doc =
  //         await firestore.collection('Missões concluídas').doc(uid).get();

  //     if (doc.exists) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       if (data.containsKey('relatorio') && data['relatorio'] == false) {
  //         return true;
  //       }
  //     }
  //     return false;
  //   } catch (error) {
  //     debugPrint('Erro ao verificar relatórios pendentes: $error');
  //     return false;
  //   }
  // }

  // Future<Missao?> missaoIdRelatorioPendente(String uid) async {
  //   try {
  //     DocumentSnapshot doc =
  //         await firestore.collection('Missões concluídas').doc(uid).get();
  //     if (doc.exists) {
  //       return Missao.fromFirestore(doc.data() as Map<String, dynamic>);
  //     }
  //     return null;
  //   } catch (error) {
  //     debugPrint('Erro ao verificar relatórios pendentes: $error');
  //     return null;
  //   }
  // }

  Future<Missao?> fetchDadosParaRelatorio(String uid) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection('Missões').doc(uid).get();

      if (doc.exists) {
        return Missao.fromFirestore(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (error) {
      debugPrint('Erro ao buscar dados da missão: $error');
      return null;
    }
  }

  Future<String> uploadPhoto(File file, missaoId) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload the photo to Firebase Storage
    final Reference storageReference = FirebaseStorage.instance
        .ref('Fotos missões')
        .child(missaoId)
        .child(fileName);
    final UploadTask uploadTask = storageReference.putFile(file);
    final TaskSnapshot downloadUrl =
        (await uploadTask.whenComplete(() => null));

    // Return the download URL of the photo
    final String url = (await downloadUrl.ref.getDownloadURL());
    return url;
  }

  Future<bool?> fotoRelatorioMissao(
    String uid,
    String missaoId,
    List<Map<String, dynamic>> novasFotosComLegendas,
  ) async {
    try {
      await firestore.collection('Fotos relatório').doc(uid).set(
        {
          'sinc': 'sinc',
        },
      );

      DocumentReference docRef = firestore
          .collection('Fotos relatório')
          .doc(uid)
          .collection('Missões')
          .doc(missaoId);

      // Adiciona as novas fotos à lista
      await docRef.set({
        'fotos': FieldValue.arrayUnion(novasFotosComLegendas),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      return false;
    }
  }

  //como sdk do cliente, funcao que envia foto do odometro para o firebase storage e depois salva a url no firestore
  Future<String?> enviarFotoOdometro(File file, String missaoId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageReference = FirebaseStorage.instance
          .ref('Fotos odometro')
          .child(missaoId)
          .child(fileName);
      final UploadTask uploadTask = storageReference.putFile(file);
      final TaskSnapshot downloadUrl =
          (await uploadTask.whenComplete(() => null));
      final String url = (await downloadUrl.ref.getDownloadURL());
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<bool?> enviarFotoRelatorio(
      String uid, String missaoId, String imageBase64, String caption) async {
    debugPrint('Enviando foto...');

    final timestamp = DateTime.now().toString();

    var dio = Dio();
    var url =
        'https://southamerica-east1-sombratestes.cloudfunctions.net/addFotoRelatorio2';

    try {
      var response = await dio.post(url, data: {
        'uid': uid,
        'missaoId': missaoId,
        'image': imageBase64,
        'caption': caption,
        'timestamp': timestamp,
      });

      debugPrint(response.data);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Falha na requisição: Status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Exceção capturada ao enviar foto: $e');
      return false;
    }
  }

  Future<Tuple2<bool, String>> enviarFotoRelatorioOffline(
      String uid, String missaoId, String imageBase64, String caption) async {
    try {
      Database db = await MissionDatabaseHelper.instance.database;
      await db.insert(FotoRelatorioTable.tableName, {
        FotoRelatorioTable.columnUid: uid,
        FotoRelatorioTable.columnMissaoId: missaoId,
        FotoRelatorioTable.columnImageBase64: imageBase64,
        FotoRelatorioTable.columnCaption: caption,
        FotoRelatorioTable.columnTimestamp: DateTime.now().toString(),
      });
      return const Tuple2(true, 'Foto salva com sucesso');
    } on DatabaseException catch (dbEx) {
      debugPrint('Erro de banco de dados: ${dbEx.toString()}');
      return const Tuple2(false, 'Erro ao salvar foto');
    } catch (e) {
      debugPrint('Erro geral ao salvar foto offline: $e');
      return const Tuple2(false, 'Erro ao salvar foto');
    }
  }

  Future<Tuple2<bool, String>> enviarFotoRelatorioSelectFunction(
      String uid, String missaoId, String imageBase64, String caption) async {
    var connectivityResult = await InternetConnection().hasInternetAccess;
    if (!connectivityResult) {
      try {
        final enviarFotoOff = await enviarFotoRelatorioOffline(
            uid, missaoId, imageBase64, caption);
        if (enviarFotoOff.item1) {
          return const Tuple2(true, 'Sem internet, foto salva com sucesso');
        } else {
          return const Tuple2(false, 'Erro ao salvar foto');
        }
      } catch (e) {
        return const Tuple2(false, 'Erro ao salvar foto');
      }
    } else {
      try {
        final enviarFotoOn =
            await enviarFotoRelatorio(uid, missaoId, imageBase64, caption);
        if (enviarFotoOn!) {
          return const Tuple2(true, 'Foto enviada com sucesso');
        } else {
          return const Tuple2(false, 'Erro ao enviar foto');
        }
      } catch (e) {
        return const Tuple2(false, 'Erro ao enviar foto');
      }
    }
  }

  Future<bool> enviarFotosPendentes() async {
    Database db = await MissionDatabaseHelper.instance.database;
    List<Map> fotos = await db.query(FotoRelatorioTable.tableName);
    debugPrint('fotos: $fotos');

    if (fotos.isEmpty) {
      return true;
    }

    for (var foto in fotos) {
      try {
        final sucesso = await enviarFotoRelatorio(
          foto[FotoRelatorioTable.columnUid],
          foto[FotoRelatorioTable.columnMissaoId],
          foto[FotoRelatorioTable.columnImageBase64],
          foto[FotoRelatorioTable.columnCaption],
        );
        if (sucesso!) {
          await db.delete(
            FotoRelatorioTable.tableName,
            where: '${FotoRelatorioTable.columnId} = ?',
            whereArgs: [foto[FotoRelatorioTable.columnId]],
          );
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  Future<bool> verificarMissao(
    String uid,
  ) async {
    debugPrint('Enviando foto...');
    debugPrint('uid: $uid');

    var dio = Dio();
    var url =
        'https://us-central1-primeval-rune-309222.cloudfunctions.net/getMissaoIniciada';

    try {
      var response = await dio.post(url, data: {
        'uid': uid,
      });

      debugPrint(' --------- ${response.data}   -------- ');

      if (response.statusCode == 200) {
        var data = response.data;
        if (data == true) {
          return true;
        } else {
          debugPrint(
              'Erro ao enviar foto: ${data['errorCode']}: ${data['errorMessage']}');
          return false;
        }
      } else {
        debugPrint('Falha na requisição: Status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Exceção capturada ao enviar foto: $e');
      return false;
    }
  }

  Future<String> imageToBase64(String imagePath) async {
    debugPrint('Comprimindo imagem...');
    File imageFile = File(imagePath);

    // final dir = await getTemporaryDirectory();
    // final targetPath = dir.absolute.path + "/temp.jpg";
    // var compressedFile = await FlutterImageCompress.compressAndGetFile(
    //   imageFile.absolute.path,
    //   targetPath,
    //   quality: 85,
    // );

    // Ler o arquivo como uma lista de bytes
    final imageBytes = await imageFile.readAsBytes();

    // Codificar os bytes em base64
    String base64String = base64Encode(imageBytes);
    debugPrint('Imagem comprimida e codificada em base64.');
    return base64String;
  }

  Future<List<Foto>> fetchFotosRelatorioMissao(
      String uid, String missaoId) async {
    try {
      DocumentSnapshot doc = await firestore
          .collection('Fotos relatório')
          .doc(uid)
          .collection('Missões')
          .doc(missaoId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<Foto> fotos = List.from(data['fotos'])
            .map((e) => Foto.fromMap(e))
            .cast<Foto>()
            .toList();
        return fotos;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint('Erro ao buscar fotos do relatório: $error');
      return [];
    }
  }

  Future<bool?> relatorioMissao(
      cnpj,
      nomedaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      uid,
      missaoId,
      nomeDoAgente,
      tipo,
      userInitialLatitude,
      userInitialLongitude,
      userFinalLatitude,
      userFinalLongitude,
      missaoLatitude,
      missaoLongitude,
      local,
      finalizador,
      //inicio,
      {fim,
      List<Map<String, dynamic>>? fotosComLegendas,
      infos}) async {
    final serverTime = FieldValue.serverTimestamp();

    try {
      debugPrint('Buscando fotos do relatório...');
      final fotos = await fetchFotosRelatorioMissao(uid, missaoId);
      var inicio;
      final inicioDoc =
          await firestore.collection('Missões').doc(missaoId).get();
      if (inicioDoc.exists) {
        inicio = inicioDoc.data()!['timestamp'];
      }

      var data = {
        'cnpj': cnpj,
        'nome da empresa': nomedaEmpresa,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
        'uid': uid,
        'missaoId': missaoId,
        'nome': nomeDoAgente,
        'tipo': tipo,
        'infos': infos,
        'userInitialLatitude': userInitialLatitude,
        'userInitialLongitude': userInitialLongitude,
        'userFinalLatitude': userFinalLatitude,
        'userFinalLongitude': userFinalLongitude,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'local': local,
        'finalizadaPor': finalizador,
        'inicio': inicio,
        'fim': fim ?? FieldValue.serverTimestamp(),
        'serverFim': serverTime,
      };

      if (fotos.isNotEmpty) {
        debugPrint('Fotos encontradas: ${fotos.length}');
        debugPrint('Fotos com legendas: $fotosComLegendas');
        data['fotos'] = fotos.map((foto) => foto.toMap()).toList();
      }
      debugPrint('foto enviada: ${data['fotos']}');
      debugPrint('Dados do relatório: $data');

      await firestore.collection('Relatórios').doc(uid).set({'sinc': 'sinc'});

      await firestore
          .collection('Relatórios')
          .doc(uid)
          .collection('Missões')
          .doc(missaoId)
          .set(data, SetOptions(merge: true));
      // await firestore.collection('Missões aceitas').doc(uid).delete();
      // await firestore.collection('Missão iniciada').doc(uid).delete();
      // await firestore.collection('Fotos relatório').doc(uid).delete();
      //!
      //await firestore.collection('Missões').doc(missaoId).delete();
      //await firestore.collection('Missões concluídas').doc(uid).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool?> relatorioMissaoRequest(
      cnpj,
      nomedaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      uid,
      missaoId,
      nomeDoAgente,
      tipo,
      userInitialLatitude,
      userInitialLongitude,
      userFinalLatitude,
      userFinalLongitude,
      missaoLatitude,
      missaoLongitude,
      local,
      finalizador,
      //inicio,
      {List<Map<String, dynamic>>? fotosComLegendas,
      infos,
      fim}) async {
    debugPrint('Enviando relatório!...');
    debugPrint('cnpj: $cnpj');
    debugPrint('nomeDaEmpresa: $nomedaEmpresa');
    debugPrint('placaCavalo: $placaCavalo');
    debugPrint('placaCarreta: $placaCarreta');
    debugPrint('motorista: $motorista');
    debugPrint('corVeiculo: $corVeiculo');
    debugPrint('observacao: $observacao');
    debugPrint('uid: $uid');
    debugPrint('missaoId: $missaoId');
    debugPrint('nome: $nomeDoAgente');
    debugPrint('tipo: $tipo');
    debugPrint('infos: $infos');
    debugPrint('userInitialLatitude: $userInitialLatitude');
    debugPrint('userInitialLongitude: $userInitialLongitude');
    debugPrint('userFinalLatitude: $userFinalLatitude');
    debugPrint('userFinalLongitude: $userFinalLongitude');
    debugPrint('missaoLatitude: $missaoLatitude');
    debugPrint('missaoLongitude: $missaoLongitude');
    debugPrint('local: $local');
    debugPrint('fim: $fim');
    debugPrint('finalizadaPor: $finalizador');

    var dio = Dio();
    var url =
        'https://southamerica-east1-sombratestes.cloudfunctions.net/addRelatorioMissao';
    //'http://127.0.0.1:5001/sombratestes/southamerica-east1/addRelatorioMissao';
    try {
      var response = await dio.post(url, data: {
        'cnpj': cnpj,
        'nomeDaEmpresa': nomedaEmpresa,
        'placaCavalo': placaCavalo,
        'placaCarreta': placaCarreta,
        'motorista': motorista,
        'corVeiculo': corVeiculo,
        'observacao': observacao,
        'uid': uid,
        'missaoId': missaoId,
        'nome': nomeDoAgente,
        'tipo': tipo,
        'infos': infos,
        'userInitialLatitude': userInitialLatitude,
        'userInitialLongitude': userInitialLongitude,
        'userFinalLatitude': userFinalLatitude,
        'userFinalLongitude': userFinalLongitude,
        'missaoLatitude': missaoLatitude,
        'missaoLongitude': missaoLongitude,
        'local': local,
        'fim': fim ?? FieldValue.serverTimestamp(),
        'finalizadaPor': finalizador
        //'inicio': inicio,
      });

      debugPrint(response.data);

      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('Dados do relatório: $data');
        return true;
      } else {
        debugPrint('Falha na requisição: Status code ${response.statusCode}');
        return false;
      }
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
      //e.message!;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(
            'Erro no servidor: ${e.response!.statusCode}, ${e.response!.data}');
        return false;
      } else {
        debugPrint('Erro de rede ou configuração: ${e.message}');
        return false;
      }
    } on Exception catch (e) {
      debugPrint("General Exception: $e, ${e.toString()}, ${e.jsify()}");
      return false;
      //e.toString();
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
      //e.toString();
    }
  }

  Future<bool> relatorioMissaoOffline(
      cnpj,
      nomedaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      uid,
      missaoId,
      nomeDoAgente,
      tipo,
      userInitialLatitude,
      userInitialLongitude,
      userFinalLatitude,
      userFinalLongitude,
      missaoLatitude,
      missaoLongitude,
      local,
      finalizador,
      {List<Map<String, dynamic>>? fotosComLegendas,
      infos,
      fim}) async {
    try {
      debugPrint('iniciando relatorio missao offline...');
      Database db = await MissionDatabaseHelper.instance.database;
      await db.insert(RelatorioTable.tableName, {
        RelatorioTable.columnUid: uid,
        RelatorioTable.columnMissaoId: missaoId,
        RelatorioTable.columnCnpj: cnpj,
        RelatorioTable.columnNomeDaEmpresa: nomedaEmpresa,
        RelatorioTable.columnPlacaCavalo: placaCavalo,
        RelatorioTable.columnPlacaCarreta: placaCarreta,
        RelatorioTable.columnMotorista: motorista,
        RelatorioTable.columnCorVeiculo: corVeiculo,
        RelatorioTable.columnObservacao: observacao,
        RelatorioTable.columnNome: nomeDoAgente,
        RelatorioTable.columnTipo: tipo,
        RelatorioTable.columnInfos: infos,
        RelatorioTable.columnUserInitialLatitude: userInitialLatitude,
        RelatorioTable.columnUserInitialLongitude: userInitialLongitude,
        RelatorioTable.columnUserFinalLatitude: userFinalLatitude,
        RelatorioTable.columnUserFinalLongitude: userFinalLongitude,
        RelatorioTable.columnMissaoLatitude: missaoLatitude,
        RelatorioTable.columnMissaoLongitude: missaoLongitude,
        RelatorioTable.columnLocal: local,
        RelatorioTable.columnFinalizador: finalizador,
        //RelatorioTable.columnInicio: inicio,
        RelatorioTable.columnFim: DateTime.now().toIso8601String(),
      });
      //debugPrint de cada campo adicionado
      List<Map> missao = await db.query(RelatorioTable.tableName);
      debugPrint('missao: $missao');
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar relatório offline: $e');
      return false;
    }
  }

  Future<Tuple2<bool, String>> relatorioMissaoSelectFunction(
      cnpj,
      nomedaEmpresa,
      placaCavalo,
      placaCarreta,
      motorista,
      corVeiculo,
      observacao,
      uid,
      missaoId,
      nomeDoAgente,
      tipo,
      userInitialLatitude,
      userInitialLongitude,
      userFinalLatitude,
      userFinalLongitude,
      missaoLatitude,
      missaoLongitude,
      local,
      finalizador,
      {List<Map<String, dynamic>>? fotosComLegendas,
      infos,
      fim}) async {
    try {
      var connectivityResult = await InternetConnection().hasInternetAccess;
      if (!connectivityResult) {
        try {
          final relatorioOff = await relatorioMissaoOffline(
            cnpj,
            nomedaEmpresa,
            placaCavalo,
            placaCarreta,
            motorista,
            corVeiculo,
            observacao,
            uid,
            missaoId,
            nomeDoAgente,
            tipo,
            userInitialLatitude,
            userInitialLongitude,
            userFinalLatitude,
            userFinalLongitude,
            missaoLatitude,
            missaoLongitude,
            local,
            finalizador,
            fotosComLegendas: fotosComLegendas,
            infos: infos,
          );
          if (relatorioOff) {
            debugPrint('Relatório salvo com sucesso');
            return const Tuple2(
                true, 'Sem internet, relatório salvo com sucesso');
          } else {
            debugPrint('Erro ao salvar relatório');
            return const Tuple2(false, 'Erro ao salvar relatório');
          }
        } catch (e) {
          debugPrint('Erro ao salvar relatório: $e');
          return const Tuple2(false, 'Erro ao salvar relatório');
        }
      } else {
        try {
          final relatorioOn = await relatorioMissaoRequest(
            cnpj,
            nomedaEmpresa,
            placaCavalo,
            placaCarreta,
            motorista,
            corVeiculo,
            observacao,
            uid,
            missaoId,
            nomeDoAgente,
            tipo,
            userInitialLatitude,
            userInitialLongitude,
            userFinalLatitude,
            userFinalLongitude,
            missaoLatitude,
            missaoLongitude,
            local,
            finalizador,
            //inicio,
            fim: fim,
            fotosComLegendas: fotosComLegendas,
            infos: infos,
          );
          if (relatorioOn!) {
            debugPrint('Relatório enviado com sucesso');
            return const Tuple2(true, 'Relatório enviado com sucesso');
          } else {
            debugPrint('Erro ao enviar relatório');
            return const Tuple2(false, 'Erro ao enviar relatório');
          }
        } catch (e) {
          debugPrint('Erro ao enviar relatório: $e');
          return const Tuple2(false, 'Erro ao enviar relatório');
        }
      }
    } catch (e) {
      debugPrint('Erro ao enviar relatório: $e');
      return const Tuple2(false, 'Erro ao enviar relatório');
    }
  }

  Future<bool?> enviarRelatorioPendente() async {
    debugPrint('Enviando relatório pendente...');
    Database db = await MissionDatabaseHelper.instance.database;
    List<Map> relatorios = await db.query(RelatorioTable.tableName);
    debugPrint('relatorios: ${relatorios.length}');

    if (relatorios.isEmpty) {
      return null;
    }

    for (var relatorio in relatorios) {
      try {
        final sucesso = await relatorioMissaoRequest(
          relatorio[RelatorioTable.columnCnpj],
          relatorio[RelatorioTable.columnNomeDaEmpresa],
          relatorio[RelatorioTable.columnPlacaCavalo],
          relatorio[RelatorioTable.columnPlacaCarreta],
          relatorio[RelatorioTable.columnMotorista],
          relatorio[RelatorioTable.columnCorVeiculo],
          relatorio[RelatorioTable.columnObservacao],
          relatorio[RelatorioTable.columnUid],
          relatorio[RelatorioTable.columnMissaoId],
          relatorio[RelatorioTable.columnNome],
          relatorio[RelatorioTable.columnTipo],
          relatorio[RelatorioTable.columnUserInitialLatitude],
          relatorio[RelatorioTable.columnUserInitialLongitude],
          relatorio[RelatorioTable.columnUserFinalLatitude],
          relatorio[RelatorioTable.columnUserFinalLongitude],
          relatorio[RelatorioTable.columnMissaoLatitude],
          relatorio[RelatorioTable.columnMissaoLongitude],
          relatorio[RelatorioTable.columnLocal],
          relatorio[RelatorioTable.columnFinalizador],
          fim: relatorio[RelatorioTable.columnFim],
          infos: relatorio[RelatorioTable.columnInfos],
        );
        if (sucesso!) {
          debugPrint('Relatório enviado com sucesso');
          await db.delete(
            RelatorioTable.tableName,
            where: '${RelatorioTable.columnId} = ?',
            whereArgs: [relatorio[RelatorioTable.columnId]],
          );
        } else {
          debugPrint('Erro ao enviar relatório');
          return false;
        }
      } catch (e) {
        debugPrint('Erro ao enviar relatório: $e');
        return false;
      }
    }
    debugPrint('Nenhum relatório pendente');
    return null;
  }

  Future<bool?> incrementoRelatorioMissao(uid, missaoId,
      {List<Foto>? fotosPosMissao, infos}) async {
    debugPrint('Incrementando relatório da missão $missaoId...');
    try {
      debugPrint('Buscando dados da missão $missaoId...');
      var data = {
        'infos': infos,
      };
      debugPrint('Dados da missão $missaoId: $data');
      if (fotosPosMissao!.isNotEmpty) {
        data['fotosPosMissao'] =
            fotosPosMissao.map((foto) => foto.toMap()).toList();
      }
      debugPrint('Dados da missão $missaoId: $data');
      await firestore
          .collection('Relatórios')
          .doc(uid)
          .collection('Missões')
          .doc(missaoId)
          .set(data, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Erro ao incrementar relatório da missão $missaoId: $e');
      return false;
    }
  }

  Future<bool?> incrementoRelatorioMissaoRequest(uid, missaoId,
      {List<Foto>? fotosPosMissao, infos}) async {
    debugPrint('Incrementando relatório da missão $missaoId...');
    var fotosPosMissaoMap;
    if (fotosPosMissao!.isNotEmpty) {
      fotosPosMissaoMap = fotosPosMissao.map((foto) {
        String timestampString = foto.timestamp.toDate().toIso8601String();
        return {
          'url': foto.url,
          'caption': foto.caption,
          'timestamp': timestampString,
        };
      }).toList();
    }
    var dio = Dio();
    var url =
        'https://southamerica-east1-sombratestes.cloudfunctions.net/incrementoRelatorioMissao2';
    try {
      var response = await dio.post(url, data: {
        'uid': uid,
        'missaoId': missaoId,
        'infos': infos,
        'fotosPosMissao': fotosPosMissaoMap,
      });

      debugPrint(response.toString());

      if (response.statusCode == 200) {
        var data = response.data;
        debugPrint('Dados do incremento: $data');
        return true;
      } else {
        debugPrint(
            'Falha na requisição de incremento: Status code ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Exceção capturada ao enviar incremento: ${e}');
      return false;
    }
  }

  Future<bool> incrementoRelatorioMissaoOffline(uid, missaoId,
      {List<Foto>? fotosPosMissao, infos}) async {
    try {
      Database db = await MissionDatabaseHelper.instance.database;

      // Insere os dados do incremento do relatório, excluindo fotos
      int incrementoId = await db.insert(IncrementoRelatorioTable.tableName, {
        IncrementoRelatorioTable.columnUid: uid,
        IncrementoRelatorioTable.columnMissaoId: missaoId,
        IncrementoRelatorioTable.columnInfos: infos,
      });
      // Insere cada foto na tabela fotos_incremento
      if (fotosPosMissao != null) {
        for (var foto in fotosPosMissao) {
          await db.insert(FotosIncrementoTable.tableName, {
            FotosIncrementoTable.columnIncrementoRelatorioId: incrementoId,
            FotosIncrementoTable.columnCaption: foto.caption,
            FotosIncrementoTable.columnFilePath: foto.url,
            FotosIncrementoTable.columnTimestamp:
                foto.timestamp.toDate().toIso8601String(),
          });
        }
      }

      debugPrint('Incremento do relatório salvo offline com ID: $incrementoId');
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar incremento relatório offline: $e');
      return false;
    }
  }

  Future<Tuple2<bool, String>> incrementoRelatorioMissaoSelectFunction(
      uid, missaoId,
      {List<Foto>? fotosPosMissao, infos}) async {
    var connectivityResult = await InternetConnection().hasInternetAccess;
    if (!connectivityResult) {
      try {
        final incrementoOff = await incrementoRelatorioMissaoOffline(
            uid, missaoId,
            fotosPosMissao: fotosPosMissao, infos: infos);
        if (incrementoOff) {
          return const Tuple2(
              true, 'Sem internet, incremento salvo com sucesso');
        } else {
          return const Tuple2(false, 'Erro ao salvar incremento');
        }
      } catch (e) {
        return const Tuple2(false, 'Erro ao salvar incremento');
      }
    } else {
      try {
        final incrementoOn = await incrementoRelatorioMissaoRequest(
            uid, missaoId,
            fotosPosMissao: fotosPosMissao, infos: infos);
        if (incrementoOn!) {
          return const Tuple2(true, 'Incremento enviado com sucesso');
        } else {
          return const Tuple2(false, 'Erro ao enviar incremento');
        }
      } catch (e) {
        return const Tuple2(false, 'Erro ao enviar incremento');
      }
    }
  }

  Future<bool> enviarIncrementoRelatorioPendente() async {
    Database db = await MissionDatabaseHelper.instance.database;
    List<Map> incrementos = await db.query(IncrementoRelatorioTable.tableName);

    if (incrementos.isEmpty) {
      return true;
    }

    for (var incremento in incrementos) {
      try {
        // Buscar fotos associadas a este incremento
        List<Map> fotos = await db.query(
          FotosIncrementoTable.tableName,
          where: '${FotosIncrementoTable.columnIncrementoRelatorioId} = ?',
          whereArgs: [incremento[IncrementoRelatorioTable.columnId]],
        );

        List<Foto> fotosPosMissao = [];

        for (var foto in fotos) {
          String base64Image = await convertImageFileToBase64(
              foto[FotosIncrementoTable.columnFilePath]);
          Timestamp timestamp = Timestamp.fromDate(
              DateTime.parse(foto[FotosIncrementoTable.columnTimestamp]));
          fotosPosMissao.add(
            Foto(
                caption: foto[FotosIncrementoTable.columnCaption],
                url: base64Image,
                timestamp: timestamp),
          );
        }

        // Envio dos dados
        final sucesso = await incrementoRelatorioMissaoRequest(
          incremento[IncrementoRelatorioTable.columnUid],
          incremento[IncrementoRelatorioTable.columnMissaoId],
          fotosPosMissao: fotosPosMissao,
          infos: incremento[IncrementoRelatorioTable.columnInfos],
        );

        if (sucesso!) {
          // Excluir o incremento e as fotos associadas
          await db.delete(
            FotosIncrementoTable.tableName,
            where: '${FotosIncrementoTable.columnIncrementoRelatorioId} = ?',
            whereArgs: [incremento[IncrementoRelatorioTable.columnId]],
          );
          await db.delete(
            IncrementoRelatorioTable.tableName,
            where: '${IncrementoRelatorioTable.columnId} = ?',
            whereArgs: [incremento[IncrementoRelatorioTable.columnId]],
          );
        } else {
          return false;
        }
      } catch (e) {
        debugPrint('Erro ao enviar incremento relatório pendente: $e');
        return false;
      }
    }
    return true;
  }

  Future<String> convertImageFileToBase64(String imagePath) async {
    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Stream<Missao?> getMissaoStream(String uid) {
    return firestore.collection('Convites missões').doc(uid).snapshots().map(
      (DocumentSnapshot doc) {
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          // Convertendo os dados para o objeto Missao
          debugPrint('Missão encontrada: ${doc.id}');
          debugPrint('Missão: $data');
          Missao missao = Missao.fromFirestore(data);
          return missao;
        } else {
          return null;
        }
      },
    );
  }

  Future<List<CoordenadaComTimestamp>> fetchCoordinates(String missaoId) async {
    final firestore = FirebaseFirestore.instance;

    debugPrint('Iniciando a busca das coordenadas...');

    final QuerySnapshot querySnapshot = await firestore
        .collection('Rotas')
        .doc(missaoId)
        .collection("Rota")
        .orderBy("timestamp", descending: false)
        .get();

    debugPrint(
        'Número de documentos encontrados: ${querySnapshot.docs.length}');

    if (querySnapshot.docs.isEmpty) {
      debugPrint('Nenhum documento foi encontrado.');
      return []; // Retorna uma lista vazia se não houver documentos
    }

    return querySnapshot.docs
        .map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          double? lat = data['latitude'] as double?;
          double? lng = data['longitude'] as double?;
          Timestamp? timestamp = data['timestamp'] as Timestamp?;
          bool online = data['online'] != null
              ? data['online'] == 'true'
                  ? true
                  : false
              : true;

          if (lat != null && lng != null && timestamp != null) {
            String formattedTimestamp =
                DateFormat('yMd Hms').format(timestamp.toDate());

            debugPrint(
                'Latitude: $lat, Longitude: $lng, Timestamp: $formattedTimestamp');
            return CoordenadaComTimestamp(
                gmap.LatLng(lat, lng), timestamp.toDate(), online);
          } else {
            debugPrint('Dados inválidos encontrados no documento ${doc.id}.');
            return null;
          }
        })
        .where((coordinate) => coordinate != null)
        .cast<CoordenadaComTimestamp>()
        .toList();
  }

  Stream<QuerySnapshot> buscarMissoes(cnpj) {
    CollectionReference missoes = FirebaseFirestore.instance
        .collection('Empresa')
        .doc(cnpj)
        .collection('Missões ativas');
    return missoes.snapshots();
  }

  Stream<QuerySnapshot> buscarTodasMissoesAtivas() {
    Query missoesAtivas =
        FirebaseFirestore.instance.collectionGroup('Missões ativas');
    return missoesAtivas.snapshots();
  }

  Stream<bool?> buscarResposta() {
    final uid = firebaseAuth.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('Resposta do chamado')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.data()?['aguardando'] as bool?;
    });
  }

  Future<String?> excluirResposta(uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('Resposta do chamado')
          .doc(uid)
          .delete();
      return 'Enviado com sucesso';
    } catch (e) {
      return 'Erro ao enviar resposta';
    }
  }

  Future<bool> verificarChamado(String missaoId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Chamado gerado')
        .doc(missaoId)
        .get();
    if (doc.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> verificarSeAgenteTemChamado(String uid) async {
    final DocumentSnapshot result =
        await firestore.collection('Convites missões').doc(uid).get();

    return result.exists;
  }

  Future<bool> verificarSeAgenteEstaDisponivel(String uid) async {
    final result = await firestore.collection('status').doc(uid).get();
    if (!result.exists) {
      return false;
    }
    final data = result.data() as Map<String, dynamic>;
    return data['disponivel'];
  }

  Future<bool> aguardandoresposta() async {
    final uid = firebaseAuth.currentUser!.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Resposta do chamado')
        .doc(uid)
        .get();
    if (doc.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<String?> missaoAguardada(uid) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('Convites missões').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        // Convertendo os dados para o objeto Missao
        Missao missao = Missao.fromFirestore(data);
        // Retornando o valor do campo missaoId
        return missao.missaoId;
      } else {
        return null; // Retornar null se o documento não existir ou não tiver dados
      }
    } catch (e) {
      // Você pode querer tratar o erro de alguma maneira ou simplesmente retornar null
      return null;
    }
  }

  Future<List<MissaoSolicitada>> buscarMissoesSolicitadas() async {
    debugPrint('Buscando missões solicitadas...');

    List<MissaoSolicitada> missoes = [];
    QuerySnapshot missoesSnapshot = await FirebaseFirestore.instance
        .collection('Missões solicitadas')
        .get();

    for (var missaoDoc in missoesSnapshot.docs) {
      String cnpj = missaoDoc.id;

      QuerySnapshot empresasSnapshot = await FirebaseFirestore.instance
          .collection('Missões solicitadas')
          .doc(cnpj)
          .collection('Missao')
          .get();

      for (var empresaDoc in empresasSnapshot.docs) {
        MissaoSolicitada missao = MissaoSolicitada.fromFirestore(
            cnpj, empresaDoc.data() as Map<String, dynamic>);
        missoes.add(missao);
      }
    }

    //ordenar a lista de missões por data
    missoes.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    debugPrint('Missões solicitadas encontradas: ${missoes.length}');
    return missoes;
  }

  // Stream<bool> missoesSolicitadasStream() {
  //   debugPrint('chegou aqui !!!!!');
  //   return FirebaseFirestore.instance
  //       .collection('Missões solicitadas')
  //       .snapshots()
  //       .map((snapshot) {
  //     for (var doc in snapshot.docs) {
  //       debugPrint('doc: ${doc.id}');
  //       final hasMission = FirebaseFirestore.instance
  //           .collection('Missões solicitadas')
  //           .doc(doc.id)
  //           .collection('Empresa')
  //           .snapshots()

  //           //stream para saber se tem documento dentro da Collection Empresa ou não e retorn
  //     }
  //     debugPrint('Notificação Chat: false');
  //     return false;
  //   });
  // }

  Future<bool> excluirMissaoSolicitada(String missaoId, String cnpj) async {
    try {
      await FirebaseFirestore.instance
          .collection('Missões solicitadas')
          .doc(cnpj)
          .collection('Missao')
          .doc(missaoId)
          .delete();
      final collection = await FirebaseFirestore.instance
          .collection('Missões solicitadas')
          .doc(cnpj)
          .collection('Missao')
          .get();
      if (collection.docs.isEmpty) {
        await FirebaseFirestore.instance
            .collection('Missões solicitadas')
            .doc(cnpj)
            .delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  //funcao para buscar missoes pendentes
  Future<List<MissaoSolicitada>> buscarMissoesPendentes() async {
    debugPrint('Buscando missões pendentes...');

    List<MissaoSolicitada> missoes = [];
    QuerySnapshot missoesSnapshot =
        await FirebaseFirestore.instance.collection('Missões pendentes').get();

    debugPrint('Missões pendentes: ${missoesSnapshot.docs.length}');

    for (var missaoDoc in missoesSnapshot.docs) {
      String cnpj = missaoDoc.id;

      debugPrint('CNPJ: $cnpj');

      QuerySnapshot empresasSnapshot = await FirebaseFirestore.instance
          .collection('Missões pendentes')
          .doc(cnpj)
          .collection('Missao')
          .get();

      for (var empresaDoc in empresasSnapshot.docs) {
        MissaoSolicitada missao = MissaoSolicitada.fromFirestore(
            cnpj, empresaDoc.data() as Map<String, dynamic>);
        missoes.add(missao);
      }
    }

    debugPrint('Missões pendentes encontradas: ${missoes.length}');

    //ordenar a lista de missões por data
    missoes.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    debugPrint('Missões pendentes encontradas: ${missoes.length}');
    return missoes;
  }

  Future<String?> fetchAgentAddress(String uid) async {
    Agente? agente = await AgenteServices().getAgenteInfos(uid);
    return agente?.cidade;
  }

  Future<MissaoRelatorio?> buscarRelatorio(uid, missaoId) async {
    debugPrint('UID: $uid');
    debugPrint('MissaoID: $missaoId');
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Relatórios')
          .doc(uid)
          .collection('Missões')
          .doc(missaoId)
          .get();

      if (doc.exists) {
        debugPrint('Dados do Documento: ${doc.data()}');
        return MissaoRelatorio.fromFirestore(
            doc.data() as Map<String, dynamic>);
      } else {
        debugPrint('Documento não encontrado.');
        return null;
      }
    } catch (error) {
      debugPrint('=======================');
      debugPrint('Erro ao buscar dados da missão: $error');
      return null;
    }
  }

  Future<bool> verificaSeRotaExiste(String missaoId) async {
    // Obter a referência do documento
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('Rotas').doc(missaoId);

    // Fazer a chamada assíncrona para obter o documento
    DocumentSnapshot docSnapshot = await docRef.get();

    // Verificar se o documento existe e retornar o resultado
    return docSnapshot.exists;
  }

  Future<Map<String, dynamic>?> getUltimoPontoRota(String missaoId) async {
    try {
      final rotaExiste = await verificaSeRotaExiste(missaoId);

      if (rotaExiste) {
        final rota = await firestore
            .collection('Rotas')
            .doc(missaoId)
            .collection('Rota')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (rota.docs.isNotEmpty) {
          final ultimoDoc = rota.docs.first;
          final data = ultimoDoc.data();
          return data;
        } else {
          // Não há documentos na coleção
          return null;
        }
      } else {
        // A rota não existe
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao buscar o último ponto da rota: $e');
      rethrow;
    }
  }

  Future<void>? getDistanceBetweenTwoPoints() {}

  Future<void> marcarFotoComoEnviada(
      String uid, String missaoId, String urlFoto) async {
    try {
      DocumentReference documentRef = FirebaseFirestore.instance
          .collection('Fotos relatório')
          .doc(uid)
          .collection('Missões')
          .doc(missaoId);

      DocumentSnapshot documentSnapshot = await documentRef.get();
      List<dynamic> fotos = documentSnapshot.get('fotos');

      // Encontre a foto que precisa ser atualizada
      for (int i = 0; i < fotos.length; i++) {
        if (fotos[i]['url'] == urlFoto) {
          fotos[i]['enviada'] = true;
          break;
        }
      }

      // Atualize o documento com a lista de fotos modificada
      await documentRef.update({'fotos': fotos, 'notificacaoCliente': true});
    } catch (e) {
      debugPrint('Erro ao atualizar a foto: $e');
      rethrow;
    }
  }

  Stream<bool> notificacaoFoto(String uid, String missaoId) {
    debugPrint('chegou aqui !!!!!');
    return FirebaseFirestore.instance
        .collection('Fotos relatório')
        .doc(uid)
        .collection('Missões')
        .doc(missaoId)
        .snapshots()
        .map((snapshot) {
      bool hasNotification = false;
      if (snapshot.data() != null) {
        if (snapshot.data()!['notificacaoCentral'] != null &&
            snapshot.data()!['notificacaoCentral'] == true) {
          hasNotification = true;
        }
      }
      debugPrint('Notificação Foto: $hasNotification');
      return hasNotification;
    });
  }

  Future<void> fotoVisualizada(String uid, String missaoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Fotos relatório')
          .doc(uid)
          .collection('Missões')
          .doc(missaoId)
          .set({'notificacaoCentral': false}, SetOptions(merge: true));
    } catch (e) {
      debugPrint(
          'Erro ao contabilizar visalização de foto da missão: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> enviarSinal(uid, missaoId) async {
    final timestamp = FieldValue.serverTimestamp();
    firestore.collection('sinal').doc(uid).set(
      {
        'sinalEnviadoEm': timestamp,
        'recebido': false,
        'missaoId': missaoId,
      },
    );
    final tokens = await ChatServices().fetchUserTokens(uid);
    if (tokens.isNotEmpty) {
      for (var token in tokens) {
        await FirebaseMessagingService(NotificationService()).sendNotification(
          token,
          'ATENÇÃO',
          'Você está em missão, mantenha-nos atualizados',
          null,
          data: {
            'tipo': 'sinal',
            'infoAdicional': missaoId,
          },
        );
      }
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getSinalResponse(
      uid, missaoId) {
    return firestore.collection('sinal').doc(uid).snapshots();
  }
}
