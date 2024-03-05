import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/veiculo_model.dart';

class VeiculoServices {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> preAddVeiculo(
    String nome,
    String uid,
    String placa,
    String marca,
    String modelo,
    String cor,
    String ano,
  ) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Aprovação de veículos')
          .doc(uid)
          .set({'sinc': true});
      await firestore
          .collection('Aprovação de veículos')
          .doc(uid)
          .collection('Veículo')
          .doc(placa)
          .set({
        'Nome': nome,
        'uid': uid,
        'Placa': placa,
        'Marca': marca,
        'Modelo': modelo,
        'Cor': cor,
        'Ano': ano,
        'Timestamp': timestamp
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> solicitacaoRemove(String uid, placa) async {
    try {
      await firestore
          .collection('Aprovação de veículos')
          .doc(uid)
          .collection('Veículo')
          .doc(placa)
          .delete();
      await firestore.collection('Aprovação de veículos').doc(uid).delete();
      return true;
    } catch (e) {
      debugPrint("Erro ao excluir solicitação: $e");
      return false;
    }
  }

  Future<bool> excluirPendencias(String uid) async {
    try {
      await firestore
          .collection('Veículos infos aguardando aprovação')
          .doc(uid)
          .delete();
      await firestore.collection('Veículos infos rejeitadas').doc(uid).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addVeiculo(String nome, String uid, String placa, String marca,
      String modelo, String cor, String ano, Timestamp timestamp) async {
    try {
      await firestore.collection('Veículos').doc(uid).set({'sinc': true});
      await firestore
          .collection('Veículos')
          .doc(uid)
          .collection('Veículo')
          .doc(placa)
          .set({
        'Nome': nome,
        'uid': uid,
        'Placa': placa,
        'Marca': marca,
        'Modelo': modelo,
        'Cor': cor,
        'Ano': ano,
        'Timestamp': timestamp
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Veiculo?> getVeiculo(String uid, String placa) async {
    try {
      DocumentSnapshot document = await firestore
          .collection('Veículos')
          .doc(uid)
          .collection('Veículo')
          .doc(placa)
          .get();

      if (document.exists) {
        return Veiculo.fromFirestore(
            document.data() as Map<String, dynamic>, uid);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Erro ao buscar veículo: $e");
      return null;
    }
  }

  Future<bool> aprovacaoParcial(String uid,
      [String? nome,
      String? placa,
      String? marca,
      String? modelo,
      String? cor,
      String? ano]) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Veículos infos aguardando aprovação')
          .doc(uid)
          .set({
        "uid": uid,
        "timestamp": timestamp,
        if (nome != null) "Nome": nome,
        if (placa != null) "Placa": placa,
        if (marca != null) "Marca": marca,
        if (modelo != null) "Modelo": modelo,
        if (cor != null) "Cor": cor,
        if (ano != null) "Ano": ano,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //excluir collection da aprovação parcial
  Future<bool> excluirAprovacaoParcial(String uid) async {
    try {
      await firestore
          .collection('Veículos infos aguardando aprovação')
          .doc(uid)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejeicaoParcial(String uid,
      [String? nome,
      String? placa,
      String? marca,
      String? modelo,
      String? cor,
      String? ano]) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore.collection('Veículos infos rejeitadas').doc(uid).set({
        "uid": uid,
        "timestamp": timestamp,
        if (nome != null) "Nome": nome,
        if (placa != null) "Placa": placa,
        if (marca != null) "Marca": marca,
        if (modelo != null) "Modelo": modelo,
        if (cor != null) "Cor": cor,
        if (ano != null) "Ano": ano,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //excluir collection da rejeição parcial
  Future<bool> excluirRejeicaoParcial(String uid) async {
    try {
      await firestore.collection('Veículos infos rejeitadas').doc(uid).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getDadosAguardandoAprovacao(String uid) async {
    try {
      var documento = await firestore
          .collection('Veículos infos aguardando aprovação')
          .doc(uid)
          .get();
      if (documento.exists) {
        var dados = documento.data();
        dados?.remove('uid');
        dados?.remove('timestamp');
        return dados ?? {};
      } else {
        return {};
      }
    } catch (e) {
      debugPrint("Erro ao buscar os dados aguardando aprovação: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> getDadosRejeitados(String uid) async {
    try {
      var documento = await firestore
          .collection('Veículos infos rejeitadas')
          .doc(uid)
          .get();
      if (documento.exists) {
        debugPrint('------ documento existe ------');
        var dados = documento.data();
        dados?.remove('uid');
        dados?.remove('timestamp');
        return dados ?? {};
      } else {
        return {};
      }
    } catch (e) {
      debugPrint("Erro ao buscar os dados rejeitados: $e");
      return {};
    }
  }

  Future<bool> existeDocDoAgenteAguardandoAprovacao(String uid) async {
    try {
      var documento =
          await firestore.collection('Aprovação de veículos').doc(uid).get();
      return documento.exists;
    } catch (e) {
      debugPrint("Erro ao buscar os dados aguardando aprovação: $e");
      return false;
    }
  }

  Stream<bool> existeDocumentoAguardandoAprovacao() {
    try {
      return firestore
          .collection('Aprovação de veículos')
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty);
    } catch (e) {
      debugPrint("Erro ao buscar os dados aguardando aprovação: $e");
      return Stream.value(false);
    }
  }
}
