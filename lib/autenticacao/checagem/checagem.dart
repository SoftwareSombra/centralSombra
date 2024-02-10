import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import 'event_bloc.dart';
import 'state_bloc.dart';

class Checagem extends StatelessWidget {
  const Checagem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AuthenticationBloc(FirebaseAuth.instance)..add(CheckAuthentication()),
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) async {
          debugPrint(state.status.toString());
          String routeName;
          switch (state.status) {
            case AuthStatus.web:
              routeName = '/webchecagem';
              break;
            case AuthStatus.login:
              routeName = '/login';
              break;
            case AuthStatus.home:
              routeName = '/home';
              break;
            case AuthStatus.error:
              // lidar com erros aqui, talvez mostrando um diálogo
              debugPrint('Erro de autenticação: ${state.message}');
              return;
          }
          await Navigator.of(context).pushNamedAndRemoveUntil(
              routeName, (Route<dynamic> route) => false);
        },
        child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
