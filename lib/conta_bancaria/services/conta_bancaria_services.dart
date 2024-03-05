import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/conta_bancaria_model.dart';

class ContaBancariaServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> preAddConta(
    String uid,
    String titular,
    String numero,
    String agencia,
    String chavePix,
  ) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore.collection('Solicitação Conta Bancária').doc(uid).set({
        'Titular': titular,
        'Numero': numero,
        'Agência': agencia,
        'Chave Pix': chavePix,
        'uid': uid,
        'Timestamp': timestamp
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addConta(
    String uid,
    String titular,
    String numero,
    String agencia,
    String chavePix,
  ) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore.collection('Contas Bancárias').doc(uid).set({
        'Titular': titular,
        'Numero': numero,
        'Agência': agencia,
        'Chave Pix': chavePix,
        'uid': uid,
        'Timestamp': timestamp
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<ContaBancaria?> getConta(String uid) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('Contas Bancárias').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return ContaBancaria.fromFirestore(
            doc.data() as Map<String, dynamic>, uid);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("Erro ao buscar a conta: $e");
      return null;
    }
  }

  Future<List<ContaBancaria>> getSolicitacoesContaBancaria() async {
    try {
      List<ContaBancaria> contasBancarias = [];
      final uidsSnapshot = await firestore
          .collection('Solicitação Conta Bancária')
          .orderBy('Timestamp', descending: true)
          .get();

      for (var contaDoc in uidsSnapshot.docs) {
        contasBancarias
            .add(ContaBancaria.fromFirestore(contaDoc.data(), contaDoc.id));
      }

      return contasBancarias;
    } catch (e) {
      debugPrint("Erro ao buscar a conta: $e");
      return [];
    }
  }

  Future<bool> solicitacaoRemove(String uid) async {
    try {
      await firestore
          .collection('Solicitação Conta Bancária')
          .doc(uid)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> aprovacaoParcial(String uid,
      [String? titular,
      String? numero,
      String? agencia,
      String? chavePix]) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Contas bancárias aguardando aprovação')
          .doc(uid)
          .set({
        "uid": uid,
        "timestamp": timestamp,
        if (titular != null) "titular": titular,
        if (numero != null) "numero": numero,
        if (agencia != null) "agencia": agencia,
        if (chavePix != null) "chavePix": chavePix,
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
          .collection('Contas bancárias aguardando aprovação')
          .doc(uid)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejeicaoParcial(String uid,
      [String? titular,
      String? numero,
      String? agencia,
      String? chavePix]) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Contas bancárias infos rejeitadas')
          .doc(uid)
          .set({
        "uid": uid,
        "timestamp": timestamp,
        if (titular != null) "titular": titular,
        if (numero != null) "numero": numero,
        if (agencia != null) "agencia": agencia,
        if (chavePix != null) "chavePix": chavePix,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //excluir collection da rejeição parcial
  Future<bool> excluirRejeicaoParcial(String uid) async {
    try {
      await firestore
          .collection('Contas bancárias infos rejeitadas')
          .doc(uid)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getDadosAguardandoAprovacao(String uid) async {
    try {
      var documento = await firestore
          .collection('Contas bancárias aguardando aprovação')
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
          .collection('Contas bancárias infos rejeitadas')
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
      debugPrint("Erro ao buscar os dados rejeitados: $e");
      return {};
    }
  }

  Future<bool> existeDocDoAgenteAguardandoAprovacao(String uid) async {
    try {
      var documento = await firestore
          .collection('Solicitação Conta Bancária')
          .doc(uid)
          .get();
      return documento.exists;
    } catch (e) {
      debugPrint("Erro ao buscar os dados aguardando aprovação: $e");
      return false;
    }
  }

  Stream<bool> existeDocumentoAguardandoAprovacao() {
    try {
      return firestore
          .collection('Solicitação Conta Bancária')
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty);
    } catch (e) {
      debugPrint("Erro ao buscar os dados aguardando aprovação: $e");
      return Stream.value(false);
    }
  }
}
