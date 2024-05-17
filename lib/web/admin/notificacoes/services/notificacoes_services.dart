import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sombra_testes/notificacoes/notificacoess.dart';
import '../../../../notificacoes/fcm.dart';

class NotificacoesAdmServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessagingService messagingService =
      FirebaseMessagingService(NotificationService());
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> enviarNotificacao(
      String destinatario, String titulo, String conteudo) async {
    String? doc;
    List<String> tokens = [];

    if (destinatario == 'Central') {
      doc = 'Plataforma Sombra';
    } else if (destinatario == 'Clientes') {
      doc = 'Plataforma Cliente';
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot = doc != null
        ? await FirebaseFirestore.instance
            .collection('FCM Tokens')
            .where(FieldPath.documentId, isEqualTo: doc)
            .get()
        : await FirebaseFirestore.instance.collection('FCM Tokens').get();

    List<String> ids = snapshot.docs.map((doc) => doc.id).toList();

    if (doc == null) {
      List<String> filtro = ['Plataforma Sombra', 'Plataforma Cliente'];
      List<String> idsRestantes =
          ids.where((id) => !filtro.contains(id)).toList();
      ids = idsRestantes;
      for (final String uid in ids) {
        debugPrint('ids restantes: $uid');
      }
    }

    for (final String doc in ids) {
      debugPrint(doc);
      CollectionReference tokensCollection = FirebaseFirestore.instance
          .collection('FCM Tokens')
          .doc(doc)
          .collection('tokens');

      // Busca todos os documentos da coleção de tokens
      QuerySnapshot tokensSnapshot = await tokensCollection.get();

      for (QueryDocumentSnapshot tokenDoc in tokensSnapshot.docs) {
        Map<String, dynamic> data = tokenDoc.data() as Map<String, dynamic>;
        String? token = data['FCM Token'];
        if (token != null) {
          tokens.add(token);
          await messagingService.sendNotification(
              token, titulo, conteudo, null);
        }
      }
    }
  }

  Future<void> enviarAviso(String titulo, aviso) async {
    final nome = auth.currentUser!.displayName;
    final uid = auth.currentUser!.uid;
    await firestore.collection('Avisos app').doc().set({
      'aviso': aviso,
      'titulo': titulo,
      'nome': nome,
      'uid': uid,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  Future<void> excluirAviso(
    String id,
  ) async {
    await firestore.collection('Avisos app').doc(id).delete();
  }

  Future<List<AvisoModel>?> getAllAvisos() async {
    QuerySnapshot<Map<String, dynamic>> avisos = await firestore
        .collection('Avisos app')
        .orderBy('timestamp', descending: true)
        .get();
    if (avisos.docs.isEmpty) {
      return null;
    } else {
      return avisos.docs
          .map(
            (snapshot) =>
                AvisoModel.fromFirestore(snapshot.data(), snapshot.id),
          )
          .toList();
    }
  }
}

class AvisoModel {
  final String nome;
  final String uid;
  final Timestamp timestamp;
  final List<dynamic> aviso;
  final String titulo;
  final String id;

  AvisoModel(
      {required this.nome,
      required this.uid,
      required this.timestamp,
      required this.aviso,
      required this.titulo,
      required this.id});

  // Método para converter os dados do documento Firestore em um objeto Veiculo
  factory AvisoModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AvisoModel(
        nome: data['nome'],
        uid: data['uid'],
        timestamp: data['timestamp'],
        aviso: data['aviso'],
        titulo: data['titulo'],
        id: id);
  }
}
