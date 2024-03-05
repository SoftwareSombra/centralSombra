import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../../localizacao/loc_services.dart';
import 'components/cabecalho.dart';
import 'components/chat.dart';
import 'components/drawer.dart';
import 'components/missao.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final PersistentTabController? controller;
  final String? rota;
  const HomeScreen(
      {super.key, required this.scaffoldKey, this.rota, this.controller});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String? userId = FirebaseAuth.instance.currentUser!.uid;
  var isTracking = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    //initLocationTracking(userId);
    // if (widget.rota != null) {
    //   goToRoute(widget.rota!);
    // }
  }

  // Future<void> goToRoute(String route) async {
  //   if (route == 'cadastro') {
  //     context.read<NavigationBloc>().add(ChangeToPerfil());
  //   } else {
  //     return;
  //   }
  // }

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
    return Scaffold(
      //key: widget.scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 14, 14, 14),
      //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 14, 14),
        //backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset('assets/images/escudo.png', height: 20),
                const SizedBox(width: 3),
                const Text(
                  'SOMBRA',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                )
              ],
            ),
            //drawer
            // IconButton(
            //   onPressed: () {
            //     scaffoldKey.currentState?.openEndDrawer();
            //   },
            //   icon: const Icon(Icons.menu, color: Colors.blue),
            // ),
          ],
        ),
      ),
      key: scaffoldKey,
      endDrawer: Drawer(
        child: Column(
          children: [
            BuildDrawer(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Cabecalho(),
            const HomeChat(),
            MissaoHome(
              controller: widget.controller,
            ),
            //CustomSwipeSwitch(),
          ],
        ),
      ),
    );
  }
}
