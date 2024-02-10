import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class NotTesteService {
  Future<void> sendPushNotificationWithDio2() async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAM1evzmY:APA91bFR6LcWcQQzhbSVZfryRHu6zCEoZaYZEKQV_pB2tXj_7nYmvsMorxRVIL1ERk51mZ2GA5BJ1BiWD0gthPn5lvM3XaVM_Btc454o_rZ2mI2gxC40NIjOtj-yuXiLQNE1Gp6CVJUW',
    };
    Dio dio = Dio();

    List<String> tokens = await fetchAllTokens();
    for (String token in tokens) {
      debugPrint(token);
      try {
        Response response = await dio.post(
          postUrl,
          data: {
            'notification': {
              'body': 'buscando sua localização atual',
              'title': 'sombra',
            },
            'priority': 'high',
            'data': {
              'type': 'requestLocation',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to': token,
          },
          options: Options(headers: headers),
        );

        if (response.statusCode == 200) {
          debugPrint('Notificação enviada com sucesso');
        } else {
          debugPrint('Falha ao enviar notificação: ${response.data}');
        }
      } catch (e) {
        debugPrint('Erro ao enviar notificação: $e');
      }
    }
  }

  Future<void> sendPushNotificationWithDio() async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAM1evzmY:APA91bFR6LcWcQQzhbSVZfryRHu6zCEoZaYZEKQV_pB2tXj_7nYmvsMorxRVIL1ERk51mZ2GA5BJ1BiWD0gthPn5lvM3XaVM_Btc454o_rZ2mI2gxC40NIjOtj-yuXiLQNE1Gp6CVJUW',
    };
    Dio dio = Dio();

    List<String> tokens = await fetchAllTokens();
    for (String token in tokens) {
      debugPrint(token);
      try {
        Response response = await dio.post(
          postUrl,
          data: {
            // Removido o campo 'notification'
            'priority': 'high',
            'data': {
              'type': 'requestLocation',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              // Adicione aqui quaisquer outros dados que você queira enviar
            },
            'to': token,
          },
          options: Options(headers: headers),
        );

        if (response.statusCode == 200) {
          debugPrint('Notificação enviada com sucesso');
        } else {
          debugPrint('Falha ao enviar notificação: ${response.data}');
        }
      } catch (e) {
        debugPrint('Erro ao enviar notificação: $e');
      }
    }
  }

  Future<List<String>> fetchAllTokens() async {
    List<String> tokens = [];

    // Referência para a coleção 'FCM Tokens'
    CollectionReference users =
        FirebaseFirestore.instance.collection('FCM Tokens');

    // Obter todos os documentos da coleção 'FCM Tokens'
    QuerySnapshot userSnapshot = await users.get();

    // Para cada usuário, buscar todos os tokens na subcoleção 'tokens'
    for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
      CollectionReference tokensRef =
          users.doc(userDoc.id).collection('tokens');
      QuerySnapshot tokenSnapshot = await tokensRef.get();

      for (QueryDocumentSnapshot tokenDoc in tokenSnapshot.docs) {
        Map<String, dynamic>? data = tokenDoc.data() as Map<String, dynamic>?;
        String? token = data?['FCM Token'];
        if (token != null) tokens.add(token);
      }
    }

    return tokens;
  }
}
