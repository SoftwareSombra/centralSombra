import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../autenticacao/checagem/checagem.dart';
import '../autenticacao/screens/login/login_screen.dart';
import '../autenticacao/screens/login/reset_senha_screen.dart';
import '../chat/screens/chat_screen.dart';
import '../perfil_user/screens/add_infos.dart';
import '../web/checagem/checagem.dart';
import '../web/home/screens/dashboard.dart';

class Rotas {
  static Map<String, Widget Function(BuildContext)> list =
      <String, WidgetBuilder>{
    '/': (_) => kIsWeb ? const WebChecagem() : const Checagem(),
    '/login': (_) => const LoginScreen(),
    //'/cadastro': (_) => const CadastroScreen(),
    '/redefinirsenha': (_) => RedefinirSenha(),
    '/home': (_) => const WebLoginHome(),
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
