import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/agente/screens/solicitacoes_agentes.dart';
import 'package:sombra_testes/autenticacao/services/log_services.dart';
import 'package:sombra_testes/missao/screens/criar_missao_screen.dart';
import 'package:sombra_testes/veiculos/screens/solicitacoes.dart';
import 'package:sombra_testes/web/admin/desenvolvedor/dev_screen.dart';
import 'package:sombra_testes/web/home/screens/teste_web.dart';
import '../../../conta_bancaria/screens/solicitacoes_conta_bancaria.dart';
import '../../admin/bloc/roles_bloc.dart';
import '../../admin/bloc/roles_event.dart';
import '../../admin/bloc/roles_state.dart';
import '../../admin/screens/adm_screen.dart';
import '../../relatorios/screens/relatorios_screen.dart';
import '../bloc/dashboard/dashboard_bloc.dart';
import '../bloc/dashboard/events.dart';
import '../bloc/dashboard/states.dart';

class WebLoginHome extends StatefulWidget {
  const WebLoginHome({super.key});

  @override
  State<WebLoginHome> createState() => _WebLoginHomeState();
}

class _WebLoginHomeState extends State<WebLoginHome> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      }
    });
  }

  final _screens = [
    const HomeLoginWeb(),
    const CriarMissaoScreen(),
    const RelatoriosScreen(),
    const AgentesSolicitacoes(),
    const VeiculosSolicitacoes(),
    const ContasBancariasSolicitacoes(),
    AddRolesScreen(),
    const DevScreen(),
  ];
  final LogServices logServices = LogServices();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
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
                  // A estrutura do código continua, agora com o Bloc incorporado
                  return Scaffold(
                    backgroundColor: Colors.grey[800],
                    body: Row(
                      children: [
                        Container(
                          width: screenWidth / 7.5,
                          color: Colors.grey[800],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            // Adicione essa linha
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 25, top: 20, right: 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    //SizedBox(width: screenWidth * 0.0030),
                                    Image.asset(
                                      'assets/images/escudo.png',
                                      fit: BoxFit.contain,
                                      height: 32,
                                    ),
                                    const SizedBox(width: 2),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Column(
                                children: [
                                  SideBarItem(
                                    icon: Icons.home_outlined,
                                    selectedIcon: Icons.home,
                                    label: 'Início',
                                    isSelected: selectedIndex == 0,
                                    onTap: () => context
                                        .read<DashboardBloc>()
                                        .add(ChangeDashboard(0)),
                                  ),
                                  SideBarItem(
                                    icon: Icons.map_outlined,
                                    selectedIcon: Icons.map,
                                    label: 'Missões',
                                    isSelected: selectedIndex == 1,
                                    onTap: () => context
                                        .read<DashboardBloc>()
                                        .add(ChangeDashboard(1)),
                                  ),
                                  SideBarItem(
                                    icon: Icons.assignment_outlined,
                                    selectedIcon: Icons.assignment,
                                    label: 'Relatórios',
                                    isSelected: selectedIndex == 2,
                                    onTap: () => context
                                        .read<DashboardBloc>()
                                        .add(ChangeDashboard(2)),
                                  ),
                                  SideBarItem(
                                    icon: Icons.person_outlined,
                                    selectedIcon: Icons.person,
                                    label: 'Agentes',
                                    isSelected: selectedIndex == 3,
                                    onTap: () => context
                                        .read<DashboardBloc>()
                                        .add(ChangeDashboard(3)),
                                  ),
                                  SideBarItem(
                                    icon: Icons.time_to_leave_outlined,
                                    selectedIcon: Icons.time_to_leave,
                                    label: 'Veículos',
                                    isSelected: selectedIndex == 4,
                                    onTap: () => context
                                        .read<DashboardBloc>()
                                        .add(ChangeDashboard(4)),
                                  ),
                                  SideBarItem(
                                    icon: Icons.account_balance_outlined,
                                    selectedIcon: Icons.account_balance,
                                    label: 'Contas Bancárias',
                                    isSelected: selectedIndex == 5,
                                    onTap: () => context
                                        .read<DashboardBloc>()
                                        .add(ChangeDashboard(5)),
                                  ),
                                  bloc.isAdmin
                                      ? SideBarItem(
                                          icon: Icons
                                              .admin_panel_settings_outlined,
                                          selectedIcon:
                                              Icons.admin_panel_settings,
                                          label: 'Administrador',
                                          isSelected: selectedIndex == 6,
                                          onTap: () => context
                                              .read<DashboardBloc>()
                                              .add(ChangeDashboard(6)),
                                        )
                                      : const SizedBox.shrink(),
                                  bloc.isDev
                                      ? SideBarItem(
                                          icon: Icons.code_outlined,
                                          selectedIcon: Icons.code,
                                          label: 'Dev',
                                          isSelected: selectedIndex == 7,
                                          onTap: () => context
                                              .read<DashboardBloc>()
                                              .add(ChangeDashboard(7)),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              // Adicione um espaço vazio para empurrar a primeira coluna para cima e a segunda para o centro.
                              const SizedBox.shrink(),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () async {
                                      //await sair();
                                    },
                                    child: Column(
                                      children: [
                                        MouseRegion(
                                          cursor: MaterialStateMouseCursor
                                              .clickable,
                                          child: GestureDetector(
                                            onTap: () async {
                                              await logServices.logOut(context);
                                              if (context.mounted) {
                                                await Navigator.of(context)
                                                    .pushNamedAndRemoveUntil(
                                                        '/',
                                                        (Route<dynamic>
                                                                route) =>
                                                            false);
                                              }
                                            },
                                            child: Row(
                                              children: [
                                                const Text(
                                                  'Sair',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                ),
                                                SizedBox(
                                                  width: screenWidth * 0.005,
                                                ),
                                                const Icon(
                                                  Icons.exit_to_app,
                                                  size: 15,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _screens[selectedIndex],
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
        } else {
          return const AlertDialog(
            title: Text('Erro ao buscar credenciais'),
            content: Text('Recarregue a página'),
          );
        }
      },
    );
  }
}

class SideBarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  SideBarItem({
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
