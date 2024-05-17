import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/conta_bancaria/screens/add_conta.dart';
import 'package:sombra_testes/veiculos/screens/add_veiculo.dart';
import '../agente/screens/solicitacoes_agentes.dart';
import '../autenticacao/checagem/checagem.dart';
import '../autenticacao/screens/cadastro/cadastro_screen.dart';
import '../autenticacao/screens/login/login_screen.dart';
import '../autenticacao/screens/login/reset_senha_screen.dart';
import '../chat/screens/chat_screen.dart';
import '../home/nav_bar/nav_bar.dart';
import '../perfil_user/bloc/foto/user/user_foto_bloc.dart';
import '../perfil_user/bloc/nome/get_name_bloc.dart';
import '../perfil_user/screens/add_infos.dart';
import '../perfil_user/screens/editar_perfil.dart';
import '../perfil_user/screens/perfil.dart';
import '../veiculos/screens/solicitacoes.dart';
import '../web/checagem/checagem.dart';
import '../web/home/screens/dashboard.dart';

class Rotas {
  static Map<String, Widget Function(BuildContext)> list =
      <String, WidgetBuilder>{
    '/': (_) => kIsWeb ? const WebChecagem() : const Checagem(),
    '/login': (_) => LoginScreen(),
    //'/cadastro': (_) => const CadastroScreen(),
    '/redefinirsenha': (_) => RedefinirSenha(),
    '/home': (_) => kIsWeb ? WebLoginHome() : NavBar(),
    // '/home': (_) {
    //   //final String uid = ModalRoute.of(_)!.settings.arguments as String;
    //   return ChatScreen();
    // },
    '/chat': (_) {
      final String uid = ModalRoute.of(_)!.settings.arguments as String;
      return ChatScreen(uid: uid);
    },
    '/adduserinfos': (_) => AddInfosScreen(),
    //'/agentes-solicitacoes': (_) => const AgentesSolicitacoes(),
    //'/addveiculo': (_) => AddVeiculoScreen(),
    //'/veiculos-solicitacoes':(_) => const VeiculosSolicitacoes(),
    //'/addcontabancaria': (_) => AddContaBancariaScreeen(),
    // '/perfil': (_) => MultiBlocProvider(
    //       providers: [
    //         BlocProvider<UserBloc>.value(
    //           value: BlocProvider.of<UserBloc>(_),
    //         ),
    //         BlocProvider<UserFotoBloc>.value(
    //           value: BlocProvider.of<UserFotoBloc>(_),
    //         ),
    //         // Adicionar mais BlocProviders aqui se necessário
    //       ],
    //       child: const PerfilScreen(),
    //     ),
    // '/editarperfil': (_) => MultiBlocProvider(
    //       providers: [
    //         BlocProvider<UserBloc>.value(
    //           value: BlocProvider.of<UserBloc>(_),
    //         ),
    //         BlocProvider<UserFotoBloc>.value(
    //           value: BlocProvider.of<UserFotoBloc>(_),
    //         ),
    //         // Adicionar mais BlocProviders aqui se necessário
    //       ],
    //       child: const EditarPerfilScreen(),
    //     ),
  };

  static String initial = '/';

  static GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();
}
