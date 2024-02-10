import 'dart:io';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../localizacao/loc_services.dart';
import '../../notificacoes/canal_android.dart';
import 'components/cabecalho.dart';
import 'components/chat.dart';
import 'components/drawer.dart';
import 'components/missao.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String? userId = FirebaseAuth.instance.currentUser!.uid;
   var isTracking = false;

  @override
  void initState() {
    super.initState();
    //initLocationTracking(userId);
  }

    Future<void> _getTrackingStatus() async {
    isTracking = await BackgroundLocationTrackerManager.isTracking();
    setState(() {});
  }

  Future<void> initLocationTracking(userId) async {
    try {
      // DocumentSnapshot isAgent =
      //     await firestore.collection('User infos').doc(userId).get();

      // if (isAgent.exists) {
        var status = await Permission.location.status;
        await Permission.location.status;

        await Permission.location.request();
        await Permission.locationWhenInUse.request();
        await Permission.locationAlways.request();

        await BackgroundLocationTrackerManager.initialize(
          backgroundCallback,
          config: const BackgroundLocationTrackerConfig(
            loggingEnabled: true,
            androidConfig: AndroidConfig(
              notificationIcon: 'explore',
              trackingInterval: Duration(minutes: 2),
              distanceFilterMeters: 25,
            ),
            iOSConfig: IOSConfig(
              activityType: ActivityType.AUTOMOTIVE,
              distanceFilterMeters: 25,
              restartAfterKill: false,
            ),
          ),
        );
        await _getTrackingStatus();
        if (!status.isGranted) {
          // Solicita a permissão
          status = await Permission.location.request();
          if (!status.isGranted) {
            // O usuário negou a permissão, lidar de acordo
            debugPrint('Permissão de localização negada.');
          }
        }
      //}
    } catch (error) {
      debugPrint('Erro ao atualizar localização: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(child: Column(children: [BuildDrawer()])),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Cabecalho(),
            const HomeChat(),
            SizedBox(
              height: height * 0.05,
            ),
            MissaoHome(),
            // SizedBox(
            //   height: height * 0.05,
            // ),
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => CameraScreen(
            //             camera: firstCamera,
            //           ),
            //         ),
            //       );
            //     },
            //     child: const Text('Camera'))
          ],
        ),
      ),
    );
  }
}
