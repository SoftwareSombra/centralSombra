import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../missao/model/missao_model.dart';
import '../../home/screens/mapa_teste.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../models/relatorio_cliente.dart';

class RelatorioServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  Future<List<MissaoRelatorio?>> buscarTodosRelatorios() async {
    debugPrint('Buscando todos os relatórios 1...');
    List<MissaoRelatorio?> todasMissoes = [];
    try {
      // Busca todos os documentos na coleção 'Relatórios'
      debugPrint('Buscando todos os relatórios 2...');
      QuerySnapshot relatoriosSnapshot =
          await FirebaseFirestore.instance.collection('Relatórios').get();

      debugPrint(relatoriosSnapshot.docs.toString());
      //debugPrint da quantidade de documentos encontrados
      debugPrint(
          'Número de documentos encontrados: ${relatoriosSnapshot.docs.length}');

      for (var relatorio in relatoriosSnapshot.docs) {
        String uid = relatorio.id;

        // Busca todos os documentos na coleção 'Missões' para cada 'Relatório'
        QuerySnapshot missoesSnapshot = await FirebaseFirestore.instance
            .collection('Relatórios')
            .doc(uid)
            .collection('Missões')
            .orderBy('serverFim', descending: true)
            .get();

        for (var docMissao in missoesSnapshot.docs) {
          todasMissoes.add(MissaoRelatorio.fromFirestore(
              docMissao.data() as Map<String, dynamic>));
        }
      }
    } catch (error) {
      debugPrint('Erro ao buscar dados: $error');
    }

    //ordenar a lista de missões por data de fim
    todasMissoes.sort((a, b) => b!.serverFim!.compareTo(a!.serverFim!));

    return todasMissoes;
  }

  Future<void> editarRelatorio(MissaoRelatorio relatorio) async {
    try {
      await firestore
          .collection('Relatórios')
          .doc(relatorio.uid)
          .collection('Missões')
          .doc(relatorio.missaoId)
          .set(
            MissaoRelatorio.objectToMap(relatorio),
            SetOptions(merge: true),
          );
    } catch (e) {
      rethrow;
    }
  }

  Future<Foto?> buscarFotoOdometroInicial(
      String agenteUid, String missaoId) async {
    try {
      final doc = await firestore
          .collection('Fotos relatório')
          .doc(agenteUid)
          .collection('Missões')
          .doc(missaoId)
          .collection('Odometro')
          .doc('odometroInicial')
          .get();

      if (doc.exists) {
        debugPrint('doc com foto do odometro existe !!!!');
        final List<dynamic> fotosIniciais = doc.data()?['fotos'];
        for (var foto in fotosIniciais) {
          return Foto.fromMap(foto as Map<String, dynamic>);
        }
      } else {
        // Tratar caso em que algum dos documentos não existe
        debugPrint('Documento odometroInicial não encontrado.');
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao obter os documentos: $e');
      rethrow;
    }
    return null;
  }

  Future<Foto?> buscarFotoOdometroFinal(
      String agenteUid, String missaoId) async {
    try {
      final doc = await firestore
          .collection('Fotos relatório')
          .doc(agenteUid)
          .collection('Missões')
          .doc(missaoId)
          .collection('Odometro')
          .doc('odometroFinal')
          .get();

      if (doc.exists) {
        debugPrint('doc com foto do odometro existe !!!!');
        final List<dynamic> fotosFinais = doc.data()?['fotos'];
        for (var foto in fotosFinais) {
          return Foto.fromMap(foto as Map<String, dynamic>);
        }
      } else {
        // Tratar caso em que algum dos documentos não existe
        debugPrint('Documento odometroInicial não encontrado.');
        return null;
      }
    } catch (e) {
      debugPrint('Erro ao obter os documentos: $e');
      rethrow;
    }
    return null;
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

  Future<FunctionResult> enviarRelatorioCliente(
      RelatorioCliente relatorioCliente) async {
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore
          .collection('Empresa')
          .doc(relatorioCliente.cnpj)
          .set({'sinc': 'sinc'});
      await firestore
          .collection('Empresa')
          .doc(relatorioCliente.cnpj)
          .collection('Relatórios')
          .doc(relatorioCliente.missaoId)
          .set(relatorioCliente.toFirestore());

      return FunctionResult(true);
    } catch (e) {
      debugPrint('Erro ao enviar relatório para o cliente: $e');
      return FunctionResult(false,
          message: 'Erro ao enviar relatório ${e.toString()}');
    }
  }

  //funcao para buscar o relatorio do cliente
  Future<RelatorioCliente?> buscarRelatorioCliente(
      String cnpj, String missaoId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Empresa')
          .doc(cnpj)
          .collection('Relatórios')
          .doc(missaoId)
          .get();

      if (doc.exists) {
        debugPrint('Dados do Documento: ${doc.data()}');
        return RelatorioCliente.fromFirestore(
            doc.data() as Map<String, dynamic>);
      } else {
        debugPrint('Documento não encontrado.');
        return null;
      }
    } catch (error) {
      debugPrint('Erro ao buscar dados da missão: $error');
      return null;
    }
  }

  Future<void> editarKmOdometro(
      String missaoId, String uid, String valor, String tipo) async {
    try {
      await firestore
          .collection('Relatórios')
          .doc(uid)
          .collection('Missões')
          .doc(missaoId)
          .set(
        {tipo: valor},
        SetOptions(merge: true),
      );
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Foto>> streamDeFotosDaMissao(String uid, String missaoId) {
    try {
      return firestore
          .collection('Fotos relatório')
          .doc(uid)
          .collection('Missões')
          .doc(missaoId)
          .snapshots()
          .map((doc) {
        final data = doc.data();
        if (data != null && data.containsKey('fotos')) {
          // final fotos =
          //     List.from(data['fotos']).map((e) => Foto.fromMap(e)).toList();
          // for (var foto in fotos) {
          //   debugPrint(foto.url);
          // }
          return List.from(data['fotos']).map((e) => Foto.fromMap(e)).toList();
        } else {
          return [];
        }
      });
    } catch (e) {
      rethrow;
    }
  }
}

// Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         List<Foto> fotos = List.from(data['fotos'])
//             .map((e) => Foto.fromMap(e))
//             .cast<Foto>()
//             .toList();

class FunctionResult {
  final bool success;
  final String? message;

  FunctionResult(this.success, {this.message});
}
