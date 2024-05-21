import 'dart:async';
import 'dart:io';
import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra_testes/agente/bloc/get_user/agente_bloc.dart';
import 'package:sombra_testes/home/bloc/missao_bloc/get_missao_bloc.dart';
import 'package:sombra_testes/internet_connection.dart';
import 'package:sombra_testes/missao/bloc/agente/agente_bloc.dart';
import 'package:sombra_testes/perfil_user/bloc/conta_bancaria/conta_bancaria_bloc.dart';
import 'package:sombra_testes/veiculos/bloc/solicitacoes_list/solicitacoes_veiculos_bloc.dart';
import 'package:sombra_testes/veiculos/bloc/veiculos_list/veiculo_bloc.dart';
import 'package:sombra_testes/web/home/bloc/dashboard/dashboard_bloc.dart';
import 'package:sombra_testes/widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'agente/bloc/solicitacoes/solicitacoes_agente_bloc.dart';
import 'autenticacao/screens/login/login_bloc.dart';
import 'autenticacao/services/log_services.dart';
import 'autenticacao/services/user_services.dart';
import 'conta_bancaria/bloc/solicitacoes_conta_bancaria_bloc.dart';
import 'firebase_options.dart';
import 'home/bloc/swipe_button_bloc/swipe_button_bloc.dart';
import 'home/nav_bar/bloc_nav.dart';
import 'home/services/swipebutton_services.dart';
import 'localizacao/loc_services.dart';
import 'missao/bloc/missao_solicitacao_card/missao_solicitacao_card_bloc.dart';
import 'missao/bloc/missoes_pendentes/missoes_pendentes_bloc.dart';
import 'missao/bloc/missoes_pendentes/qtd_missoes_pendentes_bloc.dart';
import 'missao/bloc/missoes_solicitadas/missoes_solicitadas_bloc.dart';
import 'missao/model/missao_model.dart';
import 'missao/services/missao_services.dart';
import 'notificacoes/fcm.dart';
import 'notificacoes/notificacoess.dart';
import 'perfil_user/bloc/foto/user/user_foto_bloc.dart';
import 'perfil_user/bloc/infos/docs_imgs/comp_resid/bloc/comp_resid_bloc.dart';
import 'perfil_user/bloc/infos/docs_imgs/rg_frente/bloc/rg_frente_bloc.dart';
import 'perfil_user/bloc/infos/docs_imgs/rg_verso/bloc/rg_verso_bloc.dart';
import 'perfil_user/bloc/nome/get_name_bloc.dart';
import 'rotas/rotas.dart';
import 'sqfLite/sincronizacao/workmanager.dart';
import 'tema/state_bloc.dart';
import 'tema/tema_bloc.dart';
import 'package:sombra_testes/notificacoes/canal_android.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'veiculos/bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_bloc.dart';
import 'versao_service.dart';
import 'web/admin/agentes/bloc/agentes_list_bloc.dart';
import 'web/admin/bloc/roles_bloc.dart';
import 'web/admin/notificacoes/blocs/avisos/avisos_bloc_bloc.dart';
import 'web/admin/usuarios/bloc/add_user_bloc/bloc/add_user_bloc.dart';
import 'web/admin/usuarios/bloc/users_list_bloc/users_list_bloc.dart';
import 'web/empresa/bloc/empresa_user_bloc/empresa_users_bloc.dart';
import 'web/empresa/bloc/get_empresas_bloc.dart';
import 'web/relatorios/bloc/list/relatorios_list_bloc.dart';
import 'web/relatorios/bloc/mission_details_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR', null);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  bool updateRequired = await isUpdateAvailable();
  bool webupdateRequired = await isWebUpdateAvailable();

  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  bool hasConnection = true;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (!kIsWeb) {
    hasConnection = await InternetConnectionChecker().hasConnection;

    await Workmanager().initialize(
      callbackDispatcher,
    );

    await Workmanager().registerPeriodicTask(
      "uniqueName",
      "simplePeriodicTask",
      frequency: const Duration(minutes: 15),
    );

    var status = await Permission.location.status;
    //await Permission.location.status;
    await Permission.location.request();
    await Permission.locationWhenInUse.request();
    await Permission.locationAlways.request();
    //* permissao para gravar audio
    await Permission.microphone.request();

    if (!status.isGranted) {
      // Solicita a permissão
      status = await Permission.location.request();
      if (!status.isGranted) {
        // O usuário negou a permissão, lidar de acordo
        debugPrint('Permissão de localização negada.');
      }
    }
    if (Platform.isAndroid) {
      setupNotificationChannel();
    }
  }

  FirebaseMessagingService service =
      FirebaseMessagingService(NotificationService());
  service.initialize();

  if (kIsWeb) {
    if (webupdateRequired) {
      runApp(const VersionErrorApp());
    } else {
      runApp(const MyApp());
      service.tokenRefresh();
    }
  } else {
    if (updateRequired) {
      runApp(const VersionErrorApp());
    } else {
      runApp(
        ConnectionNotifier(
          notifier: ValueNotifier(hasConnection),
          child: const MyApp(),
        ),
      );
      service.tokenRefresh();
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  var isTracking = false;
  late final StreamSubscription<InternetConnectionStatus> listener;
  late bool status;
  SwipeButtonServices swipeButtonServices = SwipeButtonServices();
  Color blueColor = const Color.fromARGB(255, 0, 8, 42);
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    localization.init(
      mapLocales: [
        const MapLocale(
          'pt',
          ({
            'pt': 'Português',
          }),
        ),
      ],
      initLanguageCode: 'pt',
    );
    if (!kIsWeb) {
      bgLocationTrackerInitialize();
      //_getTrackingStatus();
      listener = InternetConnectionChecker().onStatusChange.listen((status) {
        final notifier = ConnectionNotifier.of(context);
        notifier.value = status == InternetConnectionStatus.connected;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!kIsWeb) {
      listener.cancel();
    }
    super.dispose();
  }

  Future<void> bgLocationTrackerInitialize() async {
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
          restartAfterKill: true,
        ),
      ),
    );
  }

  Future<void> _getTrackingStatus() async {
    isTracking = await BackgroundLocationTrackerManager.isTracking();
    setState(() {});
    debugPrint('Tracking status: $isTracking');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return BlocProvider<ThemeBloc>(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          debugPrint(state.toString());
          ThemeData themeData;
          if (state is DarkMode) {
            themeData = ThemeData.dark().copyWith(
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.resolveWith(
                      (states) => const TextStyle(color: Colors.white)),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.resolveWith(
                      (states) => const TextStyle(color: Colors.white)),
                ),
              ),
              primaryColor: blueColor,
              iconTheme: const IconThemeData(color: Colors.white),
              iconButtonTheme: IconButtonThemeData(
                style: ButtonStyle(
                  iconColor: MaterialStateProperty.all(Colors.white),
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  elevation: 10,
                  showUnselectedLabels: true,
                  selectedItemColor: Colors.blue,
                  unselectedItemColor: Colors.grey),
              colorScheme: const ColorScheme.dark(
                primary: Colors.white,
                secondary: kIsWeb ? Colors.white : Colors.blue,
              ),
              appBarTheme: const AppBarTheme(
                iconTheme: IconThemeData(color: Colors.white),
                actionsIconTheme: IconThemeData(color: Colors.white),
              ),
            );
          } else {
            themeData = ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              colorScheme: ColorScheme.light(primary: blueColor),
            );
          }
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => UserBloc(),
              ),
              BlocProvider(
                create: (context) => UserFotoBloc(),
              ),
              BlocProvider(
                create: (context) => AgenteBloc(),
              ),
              BlocProvider(
                create: (context) => VeiculoBloc(),
              ),
              BlocProvider(
                create: (context) => VeiculoSolicitacaoBloc(),
              ),
              BlocProvider(
                create: (context) => ContaBancariaBloc(),
              ),
              BlocProvider(
                create: (context) => GetMissaoBloc(),
              ),
              BlocProvider(
                create: (context) => AgentMissionBloc(),
              ),
              BlocProvider(
                create: (context) => ElevatedButtonBloc(),
              ),
              BlocProvider(
                create: (context) => MissoesSolicitadasBloc(),
              ),
              BlocProvider(
                create: (context) => MissaoSolicitacaoCardBloc(),
              ),
              BlocProvider(
                create: (context) => MissionDetailsBloc(),
              ),
              BlocProvider(
                create: (context) => SolicitacoesContaBancariaBloc(),
              ),
              BlocProvider(
                create: (context) => RespostaSolicitacaoVeiculoBloc(),
              ),
              BlocProvider(
                create: (context) => GetEmpresasBloc(),
              ),
              BlocProvider(
                create: (context) => RolesBloc(),
              ),
              BlocProvider(
                create: (context) => RgFrenteBloc(),
              ),
              BlocProvider(
                create: (context) => RgVersoBloc(),
              ),
              BlocProvider(
                create: (context) => CompResidBloc(),
              ),
              BlocProvider(
                create: (context) => AgentesListBloc(),
              ),
              BlocProvider(
                create: (context) => UsersListBloc(),
              ),
              BlocProvider(
                create: (context) => AddUserBloc(),
              ),
              BlocProvider(
                create: (context) => AgenteSolicitacaoBloc(),
              ),
              BlocProvider<NavigationBloc>(
                create: (context) => NavigationBloc(context),
              ),
              BlocProvider(
                create: (context) => DashboardBloc(false, false),
              ),
              BlocProvider(
                create: (context) => QtdMissoesPendentesBloc(MissaoServices()),
              ),
              BlocProvider(
                create: (context) => MissoesPendentesBloc(),
              ),
              BlocProvider(
                create: (context) => RelatoriosListBloc(),
              ),
              BlocProvider(
                create: (context) => SwipeButtonBloc(),
              ),
              BlocProvider(
                create: (context) => LoginBloc(LogServices(), UserServices()),
              ),
              BlocProvider(
                create: (context) => EmpresaUsersBloc(),
              ),
              BlocProvider(
                create: (context) => AvisosBloc(),
              ),
              // Adicionar quantos BLoCs precisar aqui
            ],
            child: MaterialApp(
              localizationsDelegates: localization.localizationsDelegates,
              supportedLocales: const [
                Locale('pt', 'BR'),
              ],
              builder: (context, child) => ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(
                      start: 1921, end: double.infinity, name: '4K'),
                ],
              ),
              title: 'Sombra beta',
              debugShowCheckedModeBanner: false,
              theme: themeData,
              routes: Rotas.list,
              initialRoute: Rotas.initial,
              navigatorKey: Rotas.navigatorKey,
            ),
          );
        },
      ),
    );
  }
}

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => new _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late bool _enabled;
//   late bool _persistEnabled;
//   late String _locationJSON;
//   JsonEncoder _encoder = new JsonEncoder.withIndent('  ');

//   @override
//   void initState() {
//     _enabled = false;
//     _persistEnabled = true;
//     _locationJSON = "Toggle the switch to start tracking.";

//     super.initState();
//     initPlatformState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {

//     bg.BackgroundGeolocation.onLocation((bg.Location location) {
//       debugPrint('[location] $location');
//       setState(() {
//         _locationJSON = _encoder.convert(location.toMap());
//       });
//     });

//     BackgroundGeolocationFirebase.configure(BackgroundGeolocationFirebaseConfig(
//       locationsCollection: "locations",
//       geofencesCollection: "geofences",
//       updateSingleDocument: false
//     ));

//     bg.BackgroundGeolocation.ready(bg.Config(
//       debug: true,
//       distanceFilter: 50,
//       logLevel: bg.Config.LOG_LEVEL_VERBOSE,
//       stopTimeout: 1,
//       stopOnTerminate: false,
//       startOnBoot: true
//     )).then((bg.State state) {
//       setState(() {
//         _enabled = state.enabled;
//       });
//     });

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//   }

//   void _onClickEnable(bool enabled) {
//     setState(() {
//       _enabled = enabled;
//     });

//     if (enabled) {
//       bg.BackgroundGeolocation.start();
//     } else {
//       bg.BackgroundGeolocation.stop();
//     }
//   }

//   void _onClickEnablePersist() {
//     setState(() {
//       _persistEnabled = !_persistEnabled;
//     });

//     if (_persistEnabled) {
//       bg.BackgroundGeolocation.setConfig(bg.Config(
//         persistMode: bg.Config.PERSIST_MODE_ALL
//       ));
//     } else {
//       bg.BackgroundGeolocation.setConfig(bg.Config(
//         persistMode: bg.Config.PERSIST_MODE_NONE
//       ));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new MaterialApp(
//       home: new Scaffold(
//         appBar: new AppBar(
//           title: const Text('BGGeo Firebase Example', style: TextStyle(color: Colors.black)),
//           backgroundColor: Colors.amberAccent,
//           foregroundColor: Colors.black,
//           actions: <Widget>[
//             Switch(value: _enabled, onChanged: _onClickEnable),
//           ]
//         ),
//         body: Text(_locationJSON),
//         bottomNavigationBar: BottomAppBar(
//           child: Container(
//             padding: EdgeInsets.only(left: 5.0, right:5.0),
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   MaterialButton(
//                       //minWidth: 50.0,
//                       child: Icon(Icons.play_arrow, color: Colors.white),
//                       color: Colors.red,
//                       onPressed: _onClickEnablePersist
//                   )
//                 ]
//             )
//           )
//         ),
//       ),
//     );
//   }
// }

class Repo {
  Future<void> update(BackgroundLocationUpdateData data) async {
    final text = 'Location Update: Lat: ${data.lat} Lon: ${data.lon}';
    debugPrint(text);
    await LocationDao().saveLocation(data);
  }

  // Future<void> rota(BackgroundLocationUpdateData data) async {
  //   final text = 'Location Update: Lat: ${data.lat} Lon: ${data.lon}';
  //   debugPrint(text);
  //   await LocationDao().saveRota(data);
  // }
}

class LocationDao {
  // static final _locationsCollection =
  //     FirebaseFirestore.instance.collection('locations');

  Future<void> saveLocation(BackgroundLocationUpdateData data) async {
    debugPrint('inciando save location');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('-------------chegou aqui----------------');

    final timestamp = FieldValue.serverTimestamp();
    final missiontimestamp = DateTime.now();
    LatLng currentLocation = LatLng(data.lat, data.lon);

    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    final DocumentSnapshot result =
        await firestore.collection('Missão iniciada').doc(userId).get();

    if (result.exists) {
      try {
        debugPrint('-------------missao----------------');
        DocumentSnapshot docSnapshot =
            await firestore.collection('Missões aceitas').doc(userId).get();
        final missao =
            Missao.fromFirestore(docSnapshot.data()! as Map<String, dynamic>);
        final missaoId = missao.missaoId;

        //await firestore.collection('Rotas').doc(missaoId).set({'sinc': 'sinc'});
        await firestore
            .collection('Rotas')
            .doc(missaoId)
            .collection('Rota')
            .doc()
            .set({
          'latitude': currentLocation.latitude,
          'longitude': currentLocation.longitude,
          //'nome do agente': nome,
          'uid': userId,
          'timestamp': missiontimestamp,
        });
        debugPrint('-------------loc missao salva----------------');
      } catch (error) {
        debugPrint('Erro ao atualizar localização: $error');
      }
    } else {
      try {
        DocumentSnapshot document =
            await firestore.collection('User Name').doc(userId).get();
        DocumentSnapshot isAgent =
            await firestore.collection('User infos').doc(userId).get();

        if (document.exists && isAgent.exists) {
          Map<String, dynamic> userData =
              document.data() as Map<String, dynamic>;
          String nome = userData['Nome'];

          await firestore.collection('usersLocations').doc(userId).set({
            'latitude': currentLocation.latitude,
            'longitude': currentLocation.longitude,
            'nome do agente': nome,
            'uid': userId,
            'timestamp': timestamp,
          });
        } else {
          debugPrint('Documento não encontrado');
        }
      } catch (error) {
        debugPrint('Erro ao atualizar localização: $error');
      }
    }
  }

  Future<void> saveRota(BackgroundLocationUpdateData data) async {
    // debugPrint('inciando save rota');
    // if (AppState.isAppInBackground) {
    //   debugPrint('O aplicativo está em background');
    // } else {
    //   debugPrint('O aplicativo está em foreground');
    // }
    // final app = Firebase.apps.first.name;
    // debugPrint('------$app--------------');
    // if (Firebase.apps.isEmpty) {
    //   // Se não, inicializa o Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    //   debugPrint("Firebase inicializado.");
    // } else {
    //   debugPrint("Firebase já foi inicializado.");
    // }
    debugPrint('-------------chegou aqui, save rota----------------');

    final timestamp = DateTime.now();
    LatLng currentLocation = LatLng(data.lat, data.lon);
    final courseAccuracy = data.courseAccuracy;
    final speed = data.speed;
    final course = data.course;
    final horizontalAccuracy = data.horizontalAccuracy;
    final verticalAccuracy = data.verticalAccuracy;

    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot docSnapshot =
          await firestore.collection('Missões aceitas').doc(userId).get();
      final missao =
          Missao.fromFirestore(docSnapshot.data()! as Map<String, dynamic>);
      final missaoId = missao.missaoId;

      await firestore.collection('Rotas').doc(missaoId).set({'sinc': 'sinc'});
      await firestore
          .collection('Rotas')
          .doc(missaoId)
          .collection('Rota')
          .doc()
          .set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'courseAccuracy': courseAccuracy,
        'speed': speed,
        'course': course,
        'horizontalAccuracy': horizontalAccuracy,
        'verticalAccuracy': verticalAccuracy,
        'uid': userId,
        'timestamp': timestamp,
      });
    } catch (error) {
      debugPrint('Erro ao atualizar localização: $error');
    }
  }
}

class VersionErrorApp extends StatelessWidget {
  const VersionErrorApp({super.key});

  Future<String?> fetchUpdateLink() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('settings')
        .doc('updateLink')
        .get();

    if (snapshot.exists) {
      final Map<String, dynamic>? data =
          snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        if (Platform.isAndroid && data.containsKey('androidLink')) {
          return data['androidLink'];
        } else if (Platform.isIOS && data.containsKey('iosLink')) {
          return data['iosLink'];
        }
      }
    }
    return null;
  }

  Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Não foi possível abrir o link';
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Por favor, atualize seu aplicativo para a versão mais recente.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: () async {
              //     final link = await fetchUpdateLink();
              //     if (link != null) {
              //       launchURL(link);
              //     }
              //   },
              //   child: const Text(
              //     'Atualizar agora',
              //     style: TextStyle(fontSize: 16),
              //   ),
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // ElevatedButton.icon(
              //   onPressed: () async {
              //     const url =
              //         "https://play.google.com/store/apps/details?id=com.singulares_beta.app";
              //     if (await canLaunchUrl(Uri.parse(url))) {
              //       await launchUrl(Uri.parse(url));
              //     } else {
              //       throw 'Could not launch $url';
              //     }
              //   },
              //   icon: const Icon(FontAwesomeIcons.android),
              //   label: const Text('Android'),
              //   style: ElevatedButton.styleFrom(
              //     foregroundColor: Colors.white,
              //     backgroundColor: Colors.green,
              //   ),
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              // ElevatedButton.icon(
              //   onPressed: () async {
              //     const url =
              //         "https://apps.apple.com/br/app/singulares/id6458876687";
              //     if (await canLaunchUrl(Uri.parse(url))) {
              //       await launchUrl(Uri.parse(url));
              //     } else {
              //       throw 'Could not launch $url';
              //     }
              //   },
              //   icon: const Icon(FontAwesomeIcons.apple),
              //   label: const Text('iOS'),
              //   style: ElevatedButton.styleFrom(
              //     foregroundColor: Colors.white,
              //     backgroundColor: Colors.blue,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// class AppState {
//   static bool isAppInBackground = false;
// }

// class MyApp2 extends StatelessWidget {
//   const MyApp2({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<ThemeBloc>(
//       create: (context) => ThemeBloc(),
//       child: BlocBuilder<ThemeBloc, ThemeState>(
//         builder: (context, state) {
//           ThemeData themeData;
//           if (state is DarkMode) {
//             themeData = ThemeData.dark().copyWith(
//               elevatedButtonTheme: ElevatedButtonThemeData(
//                 style: ButtonStyle(
//                   backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                     (Set<MaterialState> states) {
//                       return Colors
//                           .blue; // Retorna a cor azul independentemente do estado
//                     },
//                   ),
//                 ),
//               ),
//               switchTheme: SwitchThemeData(
//                 thumbColor: MaterialStateProperty.resolveWith<Color?>(
//                   (Set<MaterialState> states) {
//                     return Colors
//                         .blue; // Retorna a cor azul independentemente do estado
//                   },
//                 ),
//                 trackColor: MaterialStateProperty.resolveWith<Color?>(
//                   (Set<MaterialState> states) {
//                     return Colors
//                         .grey; // Retorna a cor azul independentemente do estado
//                   },
//                 ),
//               ),
//               iconTheme: const IconThemeData(color: Colors.blue),
//               iconButtonTheme: IconButtonThemeData(
//                 style: ButtonStyle(
//                   iconColor: MaterialStateProperty.resolveWith<Color?>(
//                     (Set<MaterialState> states) {
//                       return Colors
//                           .blue; // Retorna a cor azul independentemente do estado
//                     },
//                   ),
//                   backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                     (Set<MaterialState> states) {
//                       return Colors
//                           .blue; // Retorna a cor azul independentemente do estado
//                     },
//                   ),
//                 ),
//               ),
//               indicatorColor: Colors.blue,
//               primaryIconTheme: const IconThemeData(color: Colors.blue),
//               bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//                   selectedIconTheme: IconThemeData(color: Colors.blue),
//                   selectedLabelStyle: TextStyle(color: Colors.blue),
//                   selectedItemColor: Colors.blue,
//                   unselectedLabelStyle: TextStyle(color: Colors.white),
//                   unselectedItemColor: Colors.grey,
//                   unselectedIconTheme: IconThemeData(color: Colors.grey),
//                   showUnselectedLabels: true,
//                   backgroundColor: Colors.black),
//             );
//           } else {
//             themeData = ThemeData.light().copyWith(
//               primaryColor: Colors.grey[300],
//               iconTheme: const IconThemeData(color: Colors.blue),
//               iconButtonTheme: IconButtonThemeData(
//                 style: ButtonStyle(
//                   iconColor: MaterialStateProperty.resolveWith<Color?>(
//                     (Set<MaterialState> states) {
//                       return Colors
//                           .blue; // Retorna a cor azul independentemente do estado
//                     },
//                   ),
//                   backgroundColor: MaterialStateProperty.resolveWith<Color?>(
//                     (Set<MaterialState> states) {
//                       return Colors
//                           .blue; // Retorna a cor azul independentemente do estado
//                     },
//                   ),
//                 ),
//               ),
//               indicatorColor: Colors.blue,
//               primaryIconTheme: const IconThemeData(color: Colors.blue),
//               bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//                   selectedIconTheme: IconThemeData(color: Colors.blue),
//                   selectedLabelStyle: TextStyle(color: Colors.blue),
//                   unselectedLabelStyle: TextStyle(color: Colors.grey),
//                   unselectedIconTheme: IconThemeData(color: Colors.grey),
//                   showUnselectedLabels: true,
//                   selectedItemColor: Colors.blue,
//                   unselectedItemColor: Colors.grey),
//             );
//           }
//           return MultiBlocProvider(
//             providers: [
//               BlocProvider(
//                 create: (context) {
//                   final userBloc = UserBloc(userServices: UserServices());
//                   final user = FirebaseAuth.instance.currentUser;
//                   final uid = user?.uid;
//                   if (uid != null) {
//                     userBloc.add(FetchUserName(uid));
//                   }
//                   return userBloc;
//                 },
//               ),
//               BlocProvider(
//                 create: (context) => UserFotoBloc(
//                   userServices: UserServices(),
//                 ),
//               ),
//               BlocProvider(
//                 create: (context) => AgenteBloc(),
//               ),
//               BlocProvider(
//                 create: (context) => VeiculoBloc(),
//               ),
//               BlocProvider(
//                 create: (context) => VeiculoSolicitacaoBloc(),
//               ),
//               BlocProvider(
//                 create: (context) => DashboardBloc(),
//               ),
//               BlocProvider(
//                 create: (context) => ContaBancariaBloc(),
//               ),
//               // Adicionar quantos BLoCs precisar aqui
//             ],
//             child: MaterialApp(
//               title: 'Sombra beta',
//               debugShowCheckedModeBanner: false,
//               theme: themeData,
//               routes: Rotas.list,
//               initialRoute: Rotas.initial,
//               navigatorKey: Rotas.navigatorKey,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

///

// import 'dart:async';
// import 'dart:io';
// import 'dart:math';

// import 'package:background_location_tracker/background_location_tracker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// @pragma('vm:entry-point')
// void backgroundCallback() {
//   BackgroundLocationTrackerManager.handleBackgroundUpdated(
//     (data) async => Repo().update(data),
//   );
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await BackgroundLocationTrackerManager.initialize(
//     backgroundCallback,
//     config: const BackgroundLocationTrackerConfig(
//       loggingEnabled: true,
//       androidConfig: AndroidConfig(
//         notificationIcon: 'explore',
//         trackingInterval: Duration(seconds: 4),
//         distanceFilterMeters: null,
//       ),
//       iOSConfig: IOSConfig(
//         activityType: ActivityType.FITNESS,
//         distanceFilterMeters: null,
//         restartAfterKill: true,
//       ),
//     ),
//   );

//   runApp(MyApp());
// }

// @override
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   var isTracking = false;

//   Timer? _timer;
//   List<String> _locations = [];

//   @override
//   void initState() {
//     super.initState();
//     _getTrackingStatus();
//     _startLocationsUpdatesStream();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Plugin example app'),
//         ),
//         body: Container(
//           width: double.infinity,
//           child: Column(
//             children: [
//               Expanded(
//                 child: Column(
//                   children: [
//                     MaterialButton(
//                       child: const Text('Request location permission'),
//                       onPressed: _requestLocationPermission,
//                     ),
//                     if (Platform.isAndroid) ...[
//                       const Text(
//                           'Permission on android is only needed starting from sdk 33.'),
//                     ],
//                     MaterialButton(
//                       child: const Text('Request Notification permission'),
//                       onPressed: _requestNotificationPermission,
//                     ),
//                     MaterialButton(
//                       child: const Text('Send notification'),
//                       onPressed: () =>
//                           sendNotification('Hello from another world'),
//                     ),
//                     MaterialButton(
//                       child: const Text('Start Tracking'),
//                       onPressed: isTracking
//                           ? null
//                           : () async {
//                               await BackgroundLocationTrackerManager
//                                   .startTracking();
//                               setState(() => isTracking = true);
//                             },
//                     ),
//                     MaterialButton(
//                       child: const Text('Stop Tracking'),
//                       onPressed: isTracking
//                           ? () async {
//                               await LocationDao().clear();
//                               await _getLocations();
//                               await BackgroundLocationTrackerManager
//                                   .stopTracking();
//                               setState(() => isTracking = false);
//                             }
//                           : null,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 color: Colors.black12,
//                 height: 2,
//               ),
//               const Text('Locations'),
//               MaterialButton(
//                 child: const Text('Refresh locations'),
//                 onPressed: _getLocations,
//               ),
//               Expanded(
//                 child: Builder(
//                   builder: (context) {
//                     if (_locations.isEmpty) {
//                       return const Text('No locations saved');
//                     }
//                     return ListView.builder(
//                       itemCount: _locations.length,
//                       itemBuilder: (context, index) => Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 12,
//                         ),
//                         child: Text(
//                           _locations[index],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _getTrackingStatus() async {
//     isTracking = await BackgroundLocationTrackerManager.isTracking();
//     setState(() {});
//   }

//   Future<void> _requestLocationPermission() async {
//     final result = await Permission.locationAlways.request();
//     if (result == PermissionStatus.granted) {
//       debugPrint('GRANTED'); // ignore: avoid_debugPrint
//     } else {
//       debugPrint('NOT GRANTED'); // ignore: avoid_debugPrint
//     }
//   }

//   Future<void> _requestNotificationPermission() async {
//     final result = await Permission.notification.request();
//     if (result == PermissionStatus.granted) {
//       debugPrint('GRANTED'); // ignore: avoid_debugPrint
//     } else {
//       debugPrint('NOT GRANTED'); // ignore: avoid_debugPrint
//     }
//   }

//   Future<void> _getLocations() async {
//     final locations = await LocationDao().getLocations();
//     setState(() {
//       _locations = locations;
//     });
//   }

//   void _startLocationsUpdatesStream() {
//     _timer?.cancel();
//     _timer = Timer.periodic(
//         const Duration(milliseconds: 250), (timer) => _getLocations());
//   }
// }

// class Repo {
//   static Repo? _instance;

//   Repo._();

//   factory Repo() => _instance ??= Repo._();

//   Future<void> update(BackgroundLocationUpdateData data) async {
//     final text = 'Location Update: Lat: ${data.lat} Lon: ${data.lon}';
//     debugPrint(text); // ignore: avoid_debugPrint
//     sendNotification(text);
//     await LocationDao().saveLocation(data);
//   }
// }

// class LocationDao {
//   static const _locationsKey = 'background_updated_locations';
//   static const _locationSeparator = '-/-/-/';

//   static LocationDao? _instance;

//   LocationDao._();

//   factory LocationDao() => _instance ??= LocationDao._();

//   SharedPreferences? _prefs;

//   Future<SharedPreferences> get prefs async =>
//       _prefs ??= await SharedPreferences.getInstance();

//   Future<void> saveLocation(BackgroundLocationUpdateData data) async {
//     final locations = await getLocations();
//     locations.add(
//         '${DateTime.now().toIso8601String()}       ${data.lat},${data.lon}');
//     await (await prefs)
//         .setString(_locationsKey, locations.join(_locationSeparator));
//   }

//   Future<List<String>> getLocations() async {
//     final prefs = await this.prefs;
//     await prefs.reload();
//     final locationsString = prefs.getString(_locationsKey);
//     if (locationsString == null) return [];
//     return locationsString.split(_locationSeparator);
//   }

//   Future<void> clear() async => (await prefs).clear();
// }

// void sendNotification(String text) {
//   const settings = InitializationSettings(
//     android: AndroidInitializationSettings('app_icon'),
//     // iOS: IOSInitializationSettings(
//     //   requestAlertPermission: false,
//     //   requestBadgePermission: false,
//     //   requestSoundPermission: false,
//     // ),
//   );
//   // FlutterLocalNotificationsPlugin().initialize(
//   //   settings,
//   //   onSelectNotification: (data) async {
//   //     debugPrint('ON CLICK $data'); // ignore: avoid_debugPrint
//   //   },
//   // );
//   FlutterLocalNotificationsPlugin().show(
//     Random().nextInt(9999),
//     'Title',
//     text,
//     const NotificationDetails(
//       android: AndroidNotificationDetails('test_notification', 'Test'),
//       //iOS: IOSNotificationDetails(),
//     ),
//   );
// }
