import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../rotas/rotas.dart';

class CustomNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  CustomNotification({required this.id, this.title, this.body, this.payload});
}

class NotificationService {
  late FlutterLocalNotificationsPlugin localNotificationsPlugin;
  late AndroidNotificationDetails androidDetails;
  late DarwinNotificationDetails iosDetails;
  final firestore = FirebaseFirestore.instance;

  NotificationService() {
    localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  _initializeNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await localNotificationsPlugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
      ),
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
  }

  void _onSelectNotification(NotificationResponse? payload) {
    if (payload != null) {
      String? routeName = payload.payload;
      Rotas.navigatorKey?.currentState!.pushNamed(routeName!);
    }
  }

  showNotification(CustomNotification notification) {
    androidDetails = const AndroidNotificationDetails(
      'lembretes_notifications_x',
      'Lembretes',
      channelDescription: 'Este canal é para lembretes!',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      showWhen: true,
    );

    // iosDetails = const DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    //   badgeNumber: 1,
    // );

    localNotificationsPlugin.show(
      notification.id,
      notification.title,
      notification.body,
      NotificationDetails(
        android: androidDetails,
        //iOS: iosDetails,
      ),
      payload: notification.payload,
    );
  }

  checkForNotifications() async {
    final details =
        await localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      _onSelectNotification(details.notificationResponse);
    }
  }

  Stream<bool> notificacoesCentral() {
    debugPrint('chegou em: notificacoesCentral');
    try {
      return FirebaseFirestore.instance
          .collection('notificacoesCentral')
          .snapshots()
          .skip(1) // Ignora o primeiro snapshot
          .map((snapshot) {
        debugPrint('snapshot realizado');
        // Filtra as mudanças que indicam adição de documentos
        final addedDocs = snapshot.docChanges
            .where((change) => change.type == DocumentChangeType.added);

        // Se houver documentos adicionados, retorna true
        return addedDocs.isNotEmpty;
      }).handleError((error) {
        debugPrint("Erro ao buscar notificações: $error");
        return false; // Retorna false em caso de erro
      });
    } catch (e) {
      debugPrint("Erro ao buscar notificações: $e");
      return Stream.value(false); // Retorna false se houver uma exceção
    }
  }
}
