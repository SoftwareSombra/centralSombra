import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra/agente/bloc/get_user/agente_bloc.dart';
import 'package:sombra/internet_connection.dart';
import 'package:sombra/missao/bloc/agente/agente_bloc.dart';
import 'package:sombra/perfil_user/bloc/conta_bancaria/conta_bancaria_bloc.dart';
import 'package:sombra/veiculos/bloc/solicitacoes_list/solicitacoes_veiculos_bloc.dart';
import 'package:sombra/veiculos/bloc/veiculos_list/veiculo_bloc.dart';
import 'package:sombra/web/home/bloc/dashboard/dashboard_bloc.dart';
import 'package:sombra/widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'agente/bloc/solicitacoes/solicitacoes_agente_bloc.dart';
import 'autenticacao/screens/login/login_bloc.dart';
import 'autenticacao/services/log_services.dart';
import 'autenticacao/services/user_services.dart';
import 'chat/bloc/chat_app/notificacao_chat_bloc.dart';
import 'chat/bloc/chat_cliente/notificacao_chat_bloc.dart';
import 'conta_bancaria/bloc/solicitacoes_conta_bancaria_bloc.dart';
import 'firebase_options.dart';
import 'missao/bloc/missao_solicitacao_card/missao_solicitacao_card_bloc.dart';
import 'missao/bloc/missoes_pendentes/missoes_pendentes_bloc.dart';
import 'missao/bloc/missoes_pendentes/qtd_missoes_pendentes_bloc.dart';
import 'missao/bloc/missoes_solicitadas/missoes_solicitadas_bloc.dart';
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
import 'package:sombra/notificacoes/canal_android.dart';
import 'veiculos/bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_bloc.dart';
import 'versao_service.dart';
import 'web/admin/agentes/bloc/agentes_list_bloc.dart';
import 'web/admin/bloc/roles_bloc.dart';
import 'web/admin/notificacoes/blocs/avisos/avisos_bloc_bloc.dart';
import 'web/admin/usuarios/bloc/add_user_bloc/bloc/add_user_bloc.dart';
import 'web/admin/usuarios/bloc/users_list_bloc/users_list_bloc.dart';
import 'web/empresa/bloc/empresa_user_bloc/empresa_users_bloc.dart';
import 'web/empresa/bloc/get_empresas_bloc.dart';
import 'web/home/screens/components/solicitacoes/bloc/solicitacoes_bloc/notificacao_chat_bloc.dart';
import 'web/missoes/misoes_ativas/bloc/notificacao_foto_bloc.dart';
import 'web/relatorios/bloc/list/relatorios_list_bloc.dart';
import 'web/relatorios/bloc/mission_details_bloc.dart';
import 'widgets_comuns/elevated_button/elevated_button_2/elevated_button_bloc.dart';
import 'widgets_comuns/elevated_button/elevated_button_bloc_3/elevated_button_bloc.dart';

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
    hasConnection = await InternetConnection().hasInternetAccess;

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
  late final StreamSubscription<InternetStatus> listener;
  late bool status;
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
      //bgLocationTrackerInitialize();
      //_getTrackingStatus();
      listener =
          InternetConnection().onStatusChange.listen((InternetStatus status) {
        final notifier = ConnectionNotifier.of(context);
        notifier.value = status == InternetStatus.connected;
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //return
    // BlocProvider<ThemeBloc>(
    //   create: (context) => ThemeBloc(),
    //   child: BlocBuilder<ThemeBloc, ThemeState>(
    //     builder: (context, state) {
    //       debugPrint(state.toString());
    //       ThemeData themeData;
    //       if (state is DarkMode) {
    //         themeData = ThemeData.dark().copyWith(
    //           textButtonTheme: TextButtonThemeData(
    //             style: ButtonStyle(
    //               textStyle: WidgetStateProperty.resolveWith(
    //                   (states) => const TextStyle(color: Colors.white)),
    //             ),
    //           ),
    //           elevatedButtonTheme: ElevatedButtonThemeData(
    //             style: ButtonStyle(
    //               textStyle: WidgetStateProperty.resolveWith(
    //                   (states) => const TextStyle(color: Colors.white)),
    //             ),
    //           ),
    //           primaryColor: blueColor,
    //           iconTheme: const IconThemeData(color: Colors.white),
    //           iconButtonTheme: IconButtonThemeData(
    //             style: ButtonStyle(
    //               iconColor: WidgetStateProperty.all(Colors.white),
    //             ),
    //           ),
    //           bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    //               elevation: 10,
    //               showUnselectedLabels: true,
    //               selectedItemColor: Colors.blue,
    //               unselectedItemColor: Colors.grey),
    //           colorScheme: const ColorScheme.dark(
    //             primary: Colors.white,
    //             secondary: kIsWeb ? Colors.white : Colors.blue,
    //           ),
    //           appBarTheme: const AppBarTheme(
    //             iconTheme: IconThemeData(color: Colors.white),
    //             actionsIconTheme: IconThemeData(color: Colors.white),
    //           ),
    //         );
    //       } else {
    //         themeData = ThemeData.light().copyWith(
    //           primaryColor: Colors.blue,
    //           colorScheme: ColorScheme.light(primary: blueColor),
    //         );
    //       }
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
          create: (context) => AgentMissionBloc(),
        ),
        BlocProvider(
          create: (context) => ElevatedButtonBloc(),
        ),
        BlocProvider(
          create: (context) => ElevatedButtonBloc2(),
        ),
        BlocProvider(
          create: (context) => ElevatedButtonBloc3(),
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
          create: (context) => LoginBloc(LogServices(), UserServices()),
        ),
        BlocProvider(
          create: (context) => EmpresaUsersBloc(),
        ),
        BlocProvider(
          create: (context) => AvisosBloc(),
        ),
        BlocProvider(
          create: (context) => NotificacaoChatBloc(),
        ),
        BlocProvider(
          create: (context) => NotificacaoFotoBloc(),
        ),
        BlocProvider(
          create: (context) => MissoesSolicitadasStreamBloc(),
        ),
        BlocProvider(
          create: (context) => NotificacaoChatClienteBloc(),
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
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
        title: 'SOMBRA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        routes: Rotas.list,
        initialRoute: Rotas.initial,
        navigatorKey: Rotas.navigatorKey,
      ),
    );
  }
  //     ),
  //   );
  // }
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
