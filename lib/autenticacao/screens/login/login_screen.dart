import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/log_services.dart';
import '../../services/user_services.dart';
import 'components/buttons_login.dart';
import 'components/formulario_widget.dart';
import 'components/image_login.dart';
import 'login_bloc.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> logKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(LogServices(), UserServices()),
      child: Listener(
        onPointerDown: (_) {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text(
              'Login',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.black,
          ),
          body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const LoginImage(),
                      const SizedBox(height: 20),
                      FormularioLogin(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        logKey: logKey,
                      ),
                      const SizedBox(height: 20),
                      LoginButtons(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        loginContext: context,
                        logKey: logKey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
