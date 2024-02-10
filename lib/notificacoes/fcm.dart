import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sombra_testes/autenticacao/services/user_services.dart';
import '../firebase_options.dart';
import '../rotas/rotas.dart';
import 'notificacoess.dart';

Future<void> backgroundMessageHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase inicializado.");
  } else {
    print("Firebase já foi inicializado.");
  }
  debugPrint('Handling a background message ${message.messageId}');

  if (message.data['type'] == 'requestLocation') {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng currentLocation = LatLng(position.latitude, position.longitude);

    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot document =
          await firestore.collection('User Name').doc(userId).get();
      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      String nome = data['Nome'];

      await firestore.collection('usersLocations').doc(userId).set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'nome do agente': nome,
        'uid': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      debugPrint('Erro ao atualizar localização: $error');
    }
  }
}

class FirebaseMessagingService {
  final NotificationService _notificationService;

  FirebaseMessagingService(this._notificationService);
  final UserServices userServices = UserServices();

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      badge: true,
      sound: true,
      alert: true,
    );
    await FirebaseMessaging.instance.requestPermission();
    getDeviceFirebaseToken();
    _onMessage();
  }

  getDeviceFirebaseToken() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
      sound: true,
    );

    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('TOKEN: $token');
  }

  _onMessage() async {
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('cheguei aqui');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      AppleNotification? apple = message.notification?.apple;

      if (notification != null && android != null || apple != null) {
        _notificationService.showNotification(CustomNotification(
          id: android.hashCode,
          title: notification?.title!,
          body: notification?.body!,
          payload: message.data['rota'] ?? '',
        ));
      }

      // Verifica se o tipo de mensagem é 'requestLocation'
      if (message.data['type'] == 'requestLocation') {
        debugPrint('cheguei aqui');
        // Obter a localização atual
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        // Preparar a localização para ser enviada ao Firestore
        LatLng currentLocation = LatLng(position.latitude, position.longitude);

        // Atualizar a localização no Firestore
        final String userId = FirebaseAuth.instance.currentUser!.uid;
        final firestore = FirebaseFirestore.instance;
        try {
          DocumentSnapshot document =
              await firestore.collection('User Name').doc(userId).get();
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          String nome = data['Nome'];

          await firestore.collection('usersLocations').doc(userId).set({
            'latitude': currentLocation.latitude,
            'longitude': currentLocation.longitude,
            'nome do agente': nome,
            'uid': userId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } catch (error) {
          debugPrint('Erro ao atualizar localização: $error');
        }
      }
    });
  }

  _onMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen(_goToPageAfterMessage);
  }

  _goToPageAfterMessage(message) {
    final String rota = message.data['rota'] ?? '';
    if (rota.isNotEmpty) {
      Rotas.navigatorKey?.currentState?.pushNamed(rota);
    }
  }

  Future<void> sendNotification(String token, String title, String body) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAADUL5rWQ:APA91bGw3R55wUgM6oMoJMVkqyq75GI1UTRJvY-ogplzzGmi89ZbY'
              'tj6Hlo8eLW2uWAoDIqXDHKGtFr_88oCHQft0lIAb14DAOQlxNgMrXPRTiiXkAU4jX'
              'IGmiWriWpRnOz2n92HfzPt',
    };
    Dio dio = Dio();

    try {
      Response response = await dio.post(
        postUrl,
        data: {
          'notification': {
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'data': {
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