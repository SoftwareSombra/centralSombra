import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/mapa/screens/mapa.dart';
import '../../agente/bloc/get_user/agente_bloc.dart';
import '../../agente/bloc/get_user/events.dart';
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
import '../../veiculos/screens/veiculos_screen.dart';
import '../screens/home_screen.dart';
import 'bloc_events.dart';
import 'bloc_nav.dart';
import 'bloc_state.dart';

class NavBar extends StatelessWidget {
  NavBar({super.key});

  final MissaoServices missaoServices = MissaoServices();

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
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.grey[800],
          body: _getBodyForState(state),
          bottomNavigationBar: BottomNavigationBar(
            elevation: 10,
            currentIndex: _getCurrentIndex(state),
            onTap: (index) {
              switch (index) {
                case 0:
                  BlocProvider.of<NavigationBloc>(context).add(ChangeToHome());
                  break;
                case 1:
                  BlocProvider.of<NavigationBloc>(context)
                      .add(ChangeToMissao());
                  context.read<AgentMissionBloc>().add(FetchMission());
                  break;
                case 2:
                  BlocProvider.of<NavigationBloc>(context)
                      .add(ChangeToVeiculos());
                  break;
                case 3:
                  BlocProvider.of<NavigationBloc>(context)
                      .add(ChangeToPerfil());
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map),
                label: 'Missão',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.time_to_leave),
                label: 'Veículos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getBodyForState(NavigationState state) {
    if (state is HomeSelected) {
      return const HomeScreen();
    } else if (state is MissaoSelected) {
      return const SearchScreen();
    } else if (state is VeiculosSelected) {
      return VeiculosScreen();
    } else if (state is PerfilSelected) {
      return const PerfilScreen();
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
