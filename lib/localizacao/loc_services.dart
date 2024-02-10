import 'package:background_location_tracker/background_location_tracker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sombra_testes/main.dart';

// Future<void> updateFirestoreData(BackgroundLocationUpdateData data) async {
//   debugPrint('-------------chegou aqui----------------');

//   LatLng currentLocation = LatLng(data.lat, data.lon);

//   final String userId = FirebaseAuth.instance.currentUser!.uid;
//   final firestore = FirebaseFirestore.instance;

//   try {
//     DocumentSnapshot document =
//         await firestore.collection('User Name').doc(userId).get();

//     if (document.exists) {
//       Map<String, dynamic> userData = document.data() as Map<String, dynamic>;
//       String nome = userData['Nome'];

//       await firestore.collection('usersLocations').doc(userId).set({
//         'latitude': currentLocation.latitude,
//         'longitude': currentLocation.longitude,
//         'nome do agente': nome,
//         'uid': userId,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } else {
//       debugPrint('Documento não encontrado');
//     }
//   } catch (error) {
//     debugPrint('Erro ao atualizar localização: $error');
//   }
// }

// @pragma('vm:entry-point')
// void backgroundCallback() {
//   BackgroundLocationTrackerManager.handleBackgroundUpdated(
//     (data) async => updateFirestoreData(data),
//   );
// }

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated(
    (data) async => Repo().update(data),
  );
}

// void rastreioDaMissao() {
//   debugPrint('funcao de rastreio chamada');
//   BackgroundLocationTrackerManager.handleBackgroundUpdated(
//     (data) async => Repo().rota(data),
//   );
// }
