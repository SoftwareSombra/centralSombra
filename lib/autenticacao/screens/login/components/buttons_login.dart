import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/autenticacao/screens/cadastro/cadastro_screen.dart';
import 'package:sombra_testes/autenticacao/screens/login/reset_senha_screen.dart';
import '../../tratamento/error_snackbar.dart';
import '../event_bloc.dart';
import '../login_bloc.dart';
import '../state_bloc.dart';

class LoginButtons extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final BuildContext loginContext;
  final GlobalKey<FormState> logKey;

  LoginButtons(
      {super.key,
      required this.emailController,
      required this.passwordController,
      required this.loginContext,
      required this.logKey});

  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) async {
        if (state is LoginSuccess) {
          await Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        } else if (state is LoginFailure) {
          tratamentoDeErros.showErrorSnackbar(context, state.error);
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            ElevatedButton(
              onPressed: state is LoginLoading
                  ? null
                  : () {
                      if (logKey.currentState!.validate()) {
                        context.read<LoginBloc>().add(PerformLoginEvent(
                            emailController.text, passwordController.text));
                      }
                    },
              child: state is LoginLoading
                  ? const CircularProgressIndicator()
                  : const Text('Entrar'),
            ),
            const SizedBox(height: 10),
            kIsWeb
                ? const SizedBox.shrink()
                : ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CadastroScreen(),
                        ),
                      );
                    },
                    child: const Text('Criar Conta'),
                  ),
            const SizedBox(height: kIsWeb ? 5 : 0),
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RedefinirSenha(),
                    ),
                  );
                }
              },
              child: const Text('Esqueci minha senha'),
            ),
          ],
        );
      },
    );
  }
}
