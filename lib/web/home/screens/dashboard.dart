import 'package:dynamic_tabbar/dynamic_tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:sombra_testes/autenticacao/services/log_services.dart';
import 'package:sombra_testes/missao/screens/criar_missao_screen.dart';
import 'package:sombra_testes/web/admin/desenvolvedor/dev_screen.dart';
import 'package:sombra_testes/web/home/screens/teste_web.dart';
import '../../../chat/services/chat_services.dart';
import '../../admin/bloc/roles_bloc.dart';
import '../../admin/bloc/roles_event.dart';
import '../../admin/bloc/roles_state.dart';
import '../../admin/screens/adm_screen.dart';
import '../../relatorios/screens/relatorios_screen.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/events.dart';
import '../bloc/dashboard/states.dart';
import 'components/chat/app_chat_list.dart';

class WebLoginHome extends StatefulWidget {
  const WebLoginHome({super.key});

  @override
  State<WebLoginHome> createState() => _WebLoginHomeState();
}

class _WebLoginHomeState extends State<WebLoginHome> {
  SidebarXController controller =
      SidebarXController(selectedIndex: 0, extended: false);
  final ChatServices chatServices = ChatServices();
  String? nome;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    });
    nome = FirebaseAuth.instance.currentUser!.displayName;
    controller = SidebarXController(selectedIndex: 0, extended: false);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  final LogServices logServices = LogServices();
  final key = GlobalKey<ScaffoldState>();
  final primaryColor = Colors.white;
  static const canvasColor = Color.fromARGB(255, 0, 15, 42);
  final scaffoldBackgroundColor = Colors.white.withOpacity(0.6);
  final accentCanvasColor = Colors.blue;
  final white = Colors.white;
  final actionColor = Colors.white.withOpacity(0.6);
  static const divider = Divider(color: Colors.white, height: 1);
  List<TabData> tabs = [
    TabData(
      index: 1,
      title: const Tab(
        child: Text('App'),
      ),
      content: const AppChatList(),
    ),
    TabData(
      index: 2,
      title: const Tab(
        child: Text('Clientes'),
      ),
      content: const Center(child: Text('Nenhuma conversa')),
    ),
  ];
  bool isScrollable = false;
  bool showNextIcon = true;
  bool showBackIcon = true;

  // Leading icon
  Widget? leading;

  // Trailing icon
  Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final bool isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final bool isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    context.read<RolesBloc>().add(BuscarRoles());

    return BlocBuilder<RolesBloc, RolesState>(
      builder: (context, state) {
        if (state is RolesInitial) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is RolesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is RolesError) {
          return Center(
            child: Text(state.message),
          );
        } else if (state is RolesLoaded) {
          if (state.isDev || state.isAdmin || state.isOperador) {
            String? cargo;
            if (state.isOperador) {
              cargo = 'Operador';
            }
            if (state.isAdmin) {
              cargo = 'Administrador';
            }
            if (state.isDev) {
              cargo = 'Desenvolvedor';
            }

            chatServices.addFcmTokenAdm();

            final screens = [
              HomeLoginWeb(cargo: cargo!, nome: nome!),
              CriarMissaoScreen(
                cargo: cargo,
                nome: nome!,
              ),
              RelatoriosScreen(cargo: cargo, nome: nome!),
              // const AgentesSolicitacoes(),
              // const VeiculosSolicitacoes(),
              // const ContasBancariasSolicitacoes(),
              AddRolesScreen(cargo: cargo, nome: nome!),
              const DevScreen(),
            ];
            return BlocProvider<DashboardBloc>(
              create: (context) => DashboardBloc(state.isDev, state.isAdmin),
              child: BlocConsumer<DashboardBloc, DashboardState>(
                listener: (context, state) {
                  // Handle side effects if needed
                },
                builder: (context, state) {
                  final bloc = context.read<DashboardBloc>();
                  int selectedIndex = 0;
                  if (state is DashboardChanged) {
                    selectedIndex = state.selectedIndex;
                  }
                  controller = SidebarXController(
                      selectedIndex: selectedIndex, extended: false);
                  return Scaffold(
                    backgroundColor: const Color.fromARGB(255, 3, 9, 18),
                    key: key,
                    appBar: isMobile || isTablet
                        ? AppBar(
                            backgroundColor: canvasColor,
                            title: const Text('Teste'),
                            leading: IconButton(
                              onPressed: () {
                                // if (!Platform.isAndroid && !Platform.isIOS) {
                                //   _controller.setExtended(true);
                                // }
                                key.currentState?.openDrawer();
                              },
                              icon: const Icon(Icons.menu),
                            ),
                          )
                        : null,
                    drawer: isMobile || isTablet
                        ? Drawer(child: NavigationList())
                        : null, // Drawer apenas para mobile
                    body: Row(
                      children: [
                        isDesktop
                            ? SidebarX(
                                controller: controller,
                                theme: SidebarXTheme(
                                  margin: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: canvasColor.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hoverColor: scaffoldBackgroundColor,
                                  textStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                  selectedTextStyle:
                                      const TextStyle(color: Colors.white),
                                  itemTextPadding:
                                      const EdgeInsets.only(left: 30),
                                  selectedItemTextPadding:
                                      const EdgeInsets.only(left: 30),
                                  // itemDecoration: BoxDecoration(
                                  //   borderRadius: BorderRadius.circular(10),
                                  //   border: Border.all(
                                  //     color: canvasColor.withOpacity(0.35),
                                  //   ),
                                  // ),
                                  selectedItemDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: canvasColor.withOpacity(0.35),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        accentCanvasColor.withOpacity(0.3),
                                        canvasColor
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.28),
                                        blurRadius: 30,
                                      )
                                    ],
                                  ),
                                  iconTheme: IconThemeData(
                                    color: Colors.white.withOpacity(0.7),
                                    size: 20,
                                  ),
                                  selectedIconTheme: const IconThemeData(
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                extendedTheme: SidebarXTheme(
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: canvasColor.withOpacity(0.35),
                                  ),
                                ),
                                footerDivider: divider,
                                headerBuilder: (context, extended) {
                                  return SizedBox(
                                    height: 100,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Image.asset(
                                          'assets/images/escudo.png'),
                                    ),
                                  );
                                },
                                items: [
                                  SidebarXItem(
                                    icon: Icons.home,
                                    label: 'Início',
                                    onTap: () {
                                      context
                                          .read<DashboardBloc>()
                                          .add(ChangeDashboard(0));
                                    },
                                  ),
                                  SidebarXItem(
                                    icon: Icons.gps_fixed,
                                    label: 'Missões',
                                    onTap: () {
                                      context
                                          .read<DashboardBloc>()
                                          .add(ChangeDashboard(1));
                                    },
                                  ),
                                  SidebarXItem(
                                    icon: Icons.assignment,
                                    label: 'Relatórios',
                                    onTap: () {
                                      context
                                          .read<DashboardBloc>()
                                          .add(ChangeDashboard(2));
                                    },
                                  ),
                                  bloc.isAdmin
                                      ? SidebarXItem(
                                          icon: Icons.admin_panel_settings,
                                          label: 'Administrador',
                                          onTap: () {
                                            context
                                                .read<DashboardBloc>()
                                                .add(ChangeDashboard(3));
                                          },
                                        )
                                      : SidebarXItem(),
                                  bloc.isDev
                                      ? SidebarXItem(
                                          icon: Icons.code,
                                          label: 'Dev',
                                          onTap: () {
                                            context
                                                .read<DashboardBloc>()
                                                .add(ChangeDashboard(4));
                                          },
                                        )
                                      : SidebarXItem(),
                                  SidebarXItem(
                                    icon: Icons.logout,
                                    label: 'Sair',
                                    onTap: () async {
                                      await logServices.logOut(context);
                                      if (context.mounted) {
                                        await Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                '/',
                                                (Route<dynamic> route) =>
                                                    false);
                                      }
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                        Expanded(
                          child: Center(
                            child: screens[selectedIndex],
                          ),
                        ),
                      ],
                    ),
                    floatingActionButton: Stack(
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            showGeneralDialog(
                              barrierColor: Colors.black.withOpacity(0.5),
                              context: context,
                              pageBuilder: (context, animation1, animation2) {
                                return const SizedBox.shrink();
                              },
                              barrierDismissible:
                                  true, // Fecha o modal ao tocar fora dele.
                              barrierLabel: "Barrier", // Descrição semântica.
                              transitionBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1,
                                        0), // Começa do lado direito da tela.
                                    end:
                                        Offset.zero, // Termina alinhado à tela.
                                  ).animate(animation),
                                  child: Align(
                                    alignment: Alignment
                                        .centerRight, // Alinha o modal à direita.
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25, // Define a largura do modal.
                                      height:
                                          MediaQuery.of(context).size.height,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          ),
                                          //color: Color.fromARGB(255, 0, 3, 7),
                                          color: Colors.grey[500]!),
                                      //color: const Color.fromARGB(255, 3, 9, 18),
                                      child: Material(
                                        // color:
                                        //     const Color.fromARGB(255, 0, 3, 7),
                                        color: Colors.grey[900]!,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: DynamicTabBarWidget(
                                                dynamicTabs: tabs,
                                                labelStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                isScrollable: isScrollable,
                                                onTabControllerUpdated:
                                                    (controller) {
                                                  debugPrint(
                                                      "onTabControllerUpdated");
                                                },
                                                onTabChanged: (index) {
                                                  debugPrint(
                                                      "Tab changed: $index");
                                                },
                                                onAddTabMoveTo: MoveToTab.last,
                                                // backIcon: Icon(Icons.keyboard_double_arrow_left),
                                                // nextIcon: Icon(Icons.keyboard_double_arrow_right),
                                                showBackIcon: showBackIcon,
                                                showNextIcon: showNextIcon,
                                                leading: leading,
                                                trailing: trailing,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              transitionDuration: const Duration(
                                  milliseconds: 500), // Duração da animação.
                            );
                          },
                          backgroundColor: Colors.blue.withOpacity(0.11),
                          child: const Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                        ),
                        StreamBuilder(
                          stream: chatServices.notificacaoChat(),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool?> snapshot) {
                            if (snapshot.hasError) {
                              return const SizedBox.shrink();
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            if (snapshot.data == true) {
                              return Positioned(
                                top: 5,
                                right: 5,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.red, // Cor da bolinha
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors
                                          .white, // Cor da borda da bolinha
                                      width: 1, // Largura da borda
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            return Column(
              children: [
                const AlertDialog(
                  title: Text('Acesso negado'),
                  content:
                      Text('Você não tem permissão para acessar esta página'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await logServices.logOut(context);
                    if (context.mounted) {
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', (Route<dynamic> route) => false);
                    }
                  },
                  child: const Text('Sair'),
                ),
              ],
            );
          }
        }
        return const AlertDialog(
          title: Text('Erro ao buscar credenciais'),
          content: Text('Recarregue a página'),
        );
      },
    );
  }

  void addTab() {
    setState(() {
      var tabNumber = tabs.length + 1;
      tabs.add(
        TabData(
          index: tabNumber,
          title: Tab(
            child: Text('Tab $tabNumber'),
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Dynamic Tab $tabNumber'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => removeTab(tabNumber - 1),
                child: const Text('Remove this Tab'),
              ),
            ],
          ),
        ),
      );
    });
  }

  void removeTab(int id) {
    setState(() {
      tabs.removeAt(id);
    });
  }

  void addLeadingWidget() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          'Adding Icon button Widget \nYou can add any customized widget)'),
    ));

    setState(() {
      leading = Tooltip(
        message: 'Add your desired Leading widget here',
        child: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz_rounded),
        ),
      );
    });
  }

  void removeLeadingWidget() {
    setState(() {
      leading = null;
    });
  }

  void addTrailingWidget() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text(
          'Adding Icon button Widget \nYou can add any customized widget)'),
    ));

    setState(() {
      trailing = Tooltip(
        message: 'Add your desired Trailing widget here',
        child: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz_rounded),
        ),
      );
    });
  }

  void removeTrailingWidget() {
    setState(() {
      trailing = null;
    });
  }
}

class SideBarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SideBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
          color: isSelected ? Colors.grey[300] : Colors.grey[800],
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(25), bottomRight: Radius.circular(25))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                EdgeInsets.only(left: screenWidth / 95, top: 15, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isSelected ? selectedIcon : icon,
                    color: isSelected ? Colors.black : Colors.grey),
                if (screenWidth > 1200) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: isSelected ? 15 : 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(title: Text('Item 1')),
        ListTile(title: Text('Item 2')),
        ListTile(title: Text('Item 3')),
      ],
    );
  }
}
