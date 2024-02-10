import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/agente_model.dart';

class AgentesListServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<AgenteAdmList>?> getAllAgentes() async {
    try {
      final querySnapshot = await firestore.collection('User infos').get();

      debugPrint(querySnapshot.size.toString());

      List<AgenteAdmList> agentes = [];
      for (var doc in querySnapshot.docs) {
        agentes.add(AgenteAdmList.fromFirestore(doc.data()));
      }
      return agentes;
    } catch (e) {
      return null;
    }
  }
}