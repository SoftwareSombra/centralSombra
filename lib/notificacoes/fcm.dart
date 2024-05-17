import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sombra_testes/autenticacao/services/user_services.dart';
import '../firebase_options.dart';
import '../rotas/rotas.dart';
import 'notificacoess.dart';

@pragma('vm:entry-point')
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

    String? token;
    if (kIsWeb) {
      token = await FirebaseMessaging.instance.getToken(
          vapidKey:
              'BPEMSDicznf8_uGi2RxViOkhH3hidRJo0WT6UzyTpkMB7CfMYHw6h9HfkmVoOP7m95JWTHGgiTdXYk3OquJmpnE');
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }
    debugPrint('TOKEN: $token');
  }

  _onMessage() async {
    FirebaseMessaging.onMessage.listen((message) async {
      final audio.AudioPlayer _audioPlayer = audio.AudioPlayer();
      await _audioPlayer.play(
        volume: 1,
        audio.UrlSource(
            'https://firebasestorage.googleapis.com/v0/b/sombratestes.appspot.com/o/notification-message-incoming.mp3?alt=media&token=f99b5f13-6f86-4c82-b397-58bd95dc3a1a'),
      );

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

  Future<void> sendNotification(
      String token, String title, String body, String? rota) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAALUTJYSs:APA91bGIZAJrPMeEvLMTO1BXLC1bXYH9B_8e4bd-KSlEBKuJ5Saw'
              'Kk0RU6tlCMFGLgBse39NvMqiBJYCmpbTXYHL8Wc0busnd3dDg__lwAMXcXzUTdQ-J4l2k'
              'MKXZa6mWR3ECCqe1ui-',
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
            //'rota': rota
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

  Future<List<String>> fetchUserTokens(String uid) async {
    List<String> tokens = [];

    // Referência à coleção de tokens de um usuário específico
    CollectionReference tokensCollection = FirebaseFirestore.instance
        .collection('FCM Tokens')
        .doc(uid)
        .collection('tokens');

    // Busca todos os documentos da coleção de tokens
    QuerySnapshot tokensSnapshot = await tokensCollection.get();

    debugPrint('Tokens snapshot: ${tokensSnapshot.docs.length}');

    // Itera sobre os documentos e extrai o valor do token
    for (QueryDocumentSnapshot tokenDoc in tokensSnapshot.docs) {
      Map<String, dynamic> data = tokenDoc.data() as Map<String, dynamic>;
      String? token = data['FCM Token'];
      if (token != null) {
        tokens.add(token);
      }
    }

    return tokens;
  }

  void tokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      debugPrint('Token atualizado: $token');
      final String userId = FirebaseAuth.instance.currentUser!.uid;
      final firestore = FirebaseFirestore.instance;

      await firestore.collection('FCM Tokens').doc('Plataforma Sombra').set({
        'sinc': 'sinc',
      });
      await firestore
          .collection('FCM Tokens')
          .doc('Plataforma Sombra')
          .collection('tokens')
          .doc(userId)
          .set({'FCM Token': token});
    });
  }
}
