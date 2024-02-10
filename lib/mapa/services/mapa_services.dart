import 'package:cloud_firestore/cloud_firestore.dart';

class UserLocation {
  final String uid;
  final double latitude;
  final double longitude;
  final String nomeDoAgente;
  final Timestamp timestamp;

  UserLocation({
    required this.uid,
    required this.latitude,
    required this.longitude,
    required this.nomeDoAgente,
    required this.timestamp,
  });

  // Método para converter os dados do documento Firestore em um objeto UserLocation
  factory UserLocation.fromFirestore(Map<String, dynamic> data) {
    if (data['uid'] == null ||
        data['latitude'] == null ||
        data['longitude'] == null ||
        data['nome do agente'] == null ||
        data['timestamp'] == null) {
      throw Exception('Dados inválidos ou ausentes.');
    }
    
    return UserLocation(
      uid: data['uid'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      nomeDoAgente: data['nome do agente'],
      timestamp: data['timestamp'],
    );
  }
}

class MapaServices {
  Future<List<UserLocation>> fetchAllUsersLocations() async {
    final firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await firestore.collection('usersLocations').get();

    List<UserLocation> allUsersLocations = [];

    for (DocumentSnapshot doc in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        UserLocation userLocation = UserLocation.fromFirestore(data);
        allUsersLocations.add(userLocation);
      } catch (e) {
        // Ignora o documento se houver um erro (por exemplo, campos ausentes)
        print('Erro ao processar localização do usuário: $e');
      }
    }

    return allUsersLocations;
  }
}
