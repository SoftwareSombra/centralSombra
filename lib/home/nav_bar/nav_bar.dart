import 'dart:io';

import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sombra_testes/mapa/screens/mapa.dart';
import '../../agente/bloc/get_user/agente_bloc.dart';
import '../../agente/bloc/get_user/events.dart';
import '../../agente/services/agente_services.dart';
import '../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../internet_connection.dart';
import '../../missao/bloc/agente/agente_bloc.dart';
import '../../missao/bloc/agente/events.dart';
import '../../missao/services/missao_services.dart';
import '../../perfil_user/bloc/conta_bancaria/conta_bancaria_bloc.dart';
import '../../perfil_user/bloc/conta_bancaria/events.dart';
import '../../perfil_user/bloc/foto/user/events.dart';
import '../../perfil_user/bloc/foto/user/user_foto_bloc.dart';
import '../../perfil_user/bloc/nome/get_name_bloc.dart';
import '../../perfil_user/bloc/nome/get_name_events.dart';
import '../../perfil_user/screens/perfil.dart';
import '../../veiculos/bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_bloc.dart';
import '../../veiculos/bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_event.dart';
import '../../veiculos/screens/veiculos_screen.dart';
import '../bloc/missao_bloc/events.dart';
import '../bloc/missao_bloc/get_missao_bloc.dart';
import '../screens/home_screen.dart';
import '../services/swipebutton_services.dart';
import 'bloc_events.dart';
import 'bloc_nav.dart';
import 'bloc_state.dart';

class NavBar extends StatefulWidget {
  final String? rota;
  const NavBar({super.key, this.rota});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final MissaoServices missaoServices = MissaoServices();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final PersistentTabController controller =
      PersistentTabController(initialIndex: 0);
  String? uid;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final AgenteServices agenteServices = AgenteServices();
  late bool userIsAgent;
  late bool status;
  SwipeButtonServices swipeButtonServices = SwipeButtonServices();

  @override
  void initState() {
    super.initState();
    firebaseAuth.authStateChanges().listen(
      (User? user) async {
        debugPrint('===== user: ${user.toString()} ======');
        uid = user?.uid;
        if (widget.rota != null) {
          goToRoute(widget.rota!);
        } else {
          if (user != null) {
            context.read<UserBloc>().add(FetchUserName(uid!));
            context.read<UserFotoBloc>().add(FetchUserFoto(uid!));
            context.read<AgenteBloc>().add(FetchAgenteInfo(uid!));
            context.read<GetMissaoBloc>().add(LoadMissao(uid!));
            context.read<AgentMissionBloc>().add(FetchMission());
            context.read<ContaBancariaBloc>().add(FetchContaBancariaInfo(uid!));
            userIsAgent = await isAgent(uid!);
            if (userIsAgent) {
              status = await swipeButtonServices.getStatus(uid!);
              if (status) {
                if (Platform.isIOS) {
                  BackgroundLocationTrackerManager.startTracking();
                }
                if (Platform.isAndroid) {
                  debugPrint('---- Android ----');
                  BackgroundLocationTrackerManager.startTracking(
                    config: const AndroidConfig(
                      notificationIcon: 'explore',
                      trackingInterval: Duration(minutes: 2),
                      distanceFilterMeters: 25,
                    ),
                  );
                  debugPrint('-- Bg started --');
                }
              }
            }
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        }
      },
    );
  }

  Future<bool> isAgent(uid) async {
    final bool isAgent = await agenteServices.isAgent(uid);
    return isAgent;
  }

  Future<void> goToRoute(String route) async {
    if (route == 'cadastro') {
      context.read<NavigationBloc>().add(ChangeToPerfil());
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    // final user = firebaseAuth.currentUser;
    // final uid = user?.uid;
    // context.read<UserBloc>().add(FetchUserName(uid!));
    // context.read<UserFotoBloc>().add(FetchUserFoto(uid));
    // context.read<AgenteBloc>().add(FetchAgenteInfo(uid));
    // context.read<ContaBancariaBloc>().add(FetchContaBancariaInfo(uid));

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        final hasConnection = ConnectionNotifier.of(context).value;
        if (!kIsWeb) {
          if (!hasConnection) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              TopBar.show(context, 'Sem conexão com a internet', Colors.red,
                  duration: const Duration(days: 356));
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              TopBar.hide();
              await missaoServices.finalLocalPendente();
              await missaoServices.finalizarMissaoPendente();
              await missaoServices.enviarRelatorioPendente();
              await missaoServices.enviarFotosPendentes();
              await missaoServices.enviarIncrementoRelatorioPendente();
            });
          }
        }
        return
            // Scaffold(
            //   appBar: AppBar(),
            //     key: scaffoldKey,
            //     endDrawer: Drawer(
            //       child: Column(
            //         children: [
            //           BuildDrawer(),
            //         ],
            //       ),
            //     ),
            //resizeToAvoidBottomInset: false,
            //backgroundColor: Colors.grey[800],
            // backgroundColor: Colors.black,
            //body: _getBodyForState(state),
            //extendBody: true,
            //bottomNavigationBar:
            PersistentTabView(
          context,
          onItemSelected: (item) {
            switch (item) {
              case 0:
                BlocProvider.of<NavigationBloc>(context).add(ChangeToHome());
                break;
              case 1:
                BlocProvider.of<NavigationBloc>(context).add(ChangeToMissao());
                break;
              case 2:
                BlocProvider.of<NavigationBloc>(context)
                    .add(ChangeToVeiculos());
                break;
              case 3:
                BlocProvider.of<NavigationBloc>(context).add(ChangeToPerfil());
                break;
            }
          },

          controller: controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineInSafeArea: true,
          backgroundColor: Colors.black,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardShows: true,
          // decoration: NavBarDecoration(
          //   borderRadius: BorderRadius.circular(10.0),
          //   colorBehindNavBar: Colors.black,
          // ),
          popAllScreensOnTapOfSelectedTab: true,
          popActionScreens: PopActionScreensType.all,
          itemAnimationProperties: const ItemAnimationProperties(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          ),
          screenTransitionAnimation: const ScreenTransitionAnimation(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            curve: Curves.ease,
            duration: Duration(milliseconds: 200),
          ),
          navBarStyle: NavBarStyle.style1,
          
        );
        // DotNavigationBar(
        //   marginR: const EdgeInsets.symmetric(vertical: 2, horizontal: 30),
        //   paddingR: const EdgeInsets.symmetric(vertical: 4, horizontal: 30),
        //   currentIndex: _getCurrentIndex(state),
        //   backgroundColor: Color.fromARGB(255, 21, 21, 21),
        //   enablePaddingAnimation: true,
        //   //backgroundColor: Colors.blue.withOpacity(0.3),
        //   enableFloatingNavBar: true,
        //   dotIndicatorColor: Colors.blue,

        //   onTap: (index) {
        //     switch (index) {
        //       case 0:
        //         BlocProvider.of<NavigationBloc>(context)
        //             .add(ChangeToHome());
        //         break;
        //       case 1:
        //         BlocProvider.of<NavigationBloc>(context)
        //             .add(ChangeToMissao());
        //         context.read<AgentMissionBloc>().add(FetchMission());
        //         break;
        //       case 2:
        //         BlocProvider.of<NavigationBloc>(context)
        //             .add(ChangeToVeiculos());
        //         break;
        //       case 3:
        //         BlocProvider.of<NavigationBloc>(context)
        //             .add(ChangeToPerfil());
        //         break;
        //     }
        //   },
        //   items: [
        //     DotNavigationBarItem(
        //       icon: const Icon(Icons.home),
        //       selectedColor: Colors.blue,
        //       unselectedColor: Colors.grey,
        //     ),
        //     DotNavigationBarItem(
        //       icon: const Icon(Icons.gps_fixed),
        //       selectedColor: Colors.blue,
        //       unselectedColor: Colors.grey,
        //     ),
        //     DotNavigationBarItem(
        //       icon: const Icon(Icons.time_to_leave),
        //       selectedColor: Colors.blue,
        //       unselectedColor: Colors.grey,
        //     ),
        //     DotNavigationBarItem(
        //       icon: const Icon(Icons.person),
        //       selectedColor: Colors.blue,
        //       unselectedColor: Colors.grey,
        //     ),
        //   ],
        // )

        // BottomNavigationBar(
        //     elevation: 10,
        //     currentIndex: _getCurrentIndex(state),
        //     onTap: (index) {
        //       switch (index) {
        //         case 0:
        //           BlocProvider.of<NavigationBloc>(context).add(ChangeToHome());
        //           break;
        //         case 1:
        //           BlocProvider.of<NavigationBloc>(context)
        //               .add(ChangeToMissao());
        //           context.read<AgentMissionBloc>().add(FetchMission());
        //           break;
        //         case 2:
        //           BlocProvider.of<NavigationBloc>(context)
        //               .add(ChangeToVeiculos());
        //           break;
        //         case 3:
        //           BlocProvider.of<NavigationBloc>(context)
        //               .add(ChangeToPerfil());
        //           break;
        //       }
        //     },
        //     items: const [
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.home),
        //         label: 'Home',
        //       ),
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.gps_fixed),
        //         label: 'Missão',
        //       ),
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.time_to_leave),
        //         label: 'Veículos',
        //       ),
        //       BottomNavigationBarItem(
        //         icon: Icon(Icons.person),
        //         label: 'Perfil',
        //       ),
        //     ],
        //   ),
        //);
      },
    );
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        title: ("Home"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
        // onPressed: (index) {
        //   controller.jumpToTab(0);
        //   // context.read<UserBloc>().add(
        //   //       FetchUserName(uid!),
        //   //     );
        //   // context.read<UserFotoBloc>().add(
        //   //       FetchUserFoto(uid!),
        //   //     );
        //   context.read<AgenteBloc>().add(
        //         FetchAgenteInfo(uid!),
        //       );
        // },
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.gps_fixed),
        title: ("Missão"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
        // onPressed: (index) async {
        //   controller.jumpToTab(1);
        //   context.read<GetMissaoBloc>().add(LoadMissao(uid!));
        //   context.read<AgentMissionBloc>().add(FetchMission());
        // },
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.time_to_leave),
        title: ("Veículos"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
        // onPressed: (index) {
        //   controller.jumpToTab(2);
        //   context.read<RespostaSolicitacaoVeiculoBloc>().add(
        //         FetchRespostaSolicitacaoVeiculo(
        //           uid!,
        //         ),
        //       );
        // },
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: ("Perfil"),
        activeColorPrimary: Colors.blue,
        inactiveColorPrimary: Colors.grey,
        // onPressed: (index) async {
        //   controller.jumpToTab(3);
        //   context.read<AgenteBloc>().add(FetchAgenteInfo(uid!));
        //   context.read<ContaBancariaBloc>().add(FetchContaBancariaInfo(uid!));
        // },
      ),
    ];
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(
        scaffoldKey: scaffoldKey,
        controller: controller,
      ),
      const SearchScreen(),
      VeiculosScreen(),
      PerfilScreen(),
    ];
  }

  Widget _getBodyForState(NavigationState state) {
    if (state is HomeSelected) {
      return HomeScreen(
        scaffoldKey: scaffoldKey,
      );
    } else if (state is MissaoSelected) {
      return const SearchScreen();
    } else if (state is VeiculosSelected) {
      return VeiculosScreen();
    } else if (state is PerfilSelected) {
      return PerfilScreen();
    }
    return Container(); // Tela padrão ou algum fallback
  }

  int _getCurrentIndex(NavigationState state) {
    if (state is HomeSelected) {
      return 0;
    } else if (state is MissaoSelected) {
      return 1;
    } else if (state is VeiculosSelected) {
      return 2;
    } else if (state is PerfilSelected) {
      return 3;
    }
    return 0; // Default
  }
}
