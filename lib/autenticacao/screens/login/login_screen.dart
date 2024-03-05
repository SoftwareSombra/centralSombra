import 'package:animated_login/animated_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/log_services.dart';
import '../../services/user_services.dart';
import '../tratamento/error_snackbar.dart';
import 'components/buttons_login.dart';
import 'components/formulario_widget.dart';
import 'components/image_login.dart';
import 'event_bloc.dart';
import 'login_bloc.dart';
import 'package:async/async.dart' as ayc;
import 'reset_senha_screen.dart';
import 'state_bloc.dart';

class LoginScreen extends StatefulWidget {
  /// Simulates the multilanguage, you will implement your own logic.
  /// According to the current language, you can display a text message
  /// with the help of [LoginTexts] class.
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();

class _LoginScreenState extends State<LoginScreen> {
  /// Current auth mode, default is [AuthMode.login].
  AuthMode currentMode = AuthMode.login;
  //cor azul muito escuro
  static const Color blueColor = Color.fromARGB(255, 0, 8, 42);

  ayc.CancelableOperation? _operation;

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
        return AnimatedLogin(
          onLogin: (LoginData data) async {
            context.read<LoginBloc>().add(
                  PerformLoginEvent(data.email, data.password),
                );
            return null;
          },
          // onSignup: (SignUpData data) async {
          //   return _authOperation(
          //     LoginFunctions(context).onSignup(data),
          //   );
          // },
          //validatePassword: false,
          showChangeActionTitle: false,
          passwordValidator: ValidatorModel(
            validatorCallback: (String? password) {
              if (password == null) {
                return 'Senha não pode ser vazia';
              }
              if (password.length < 6) {
                return 'Senha muito curta';
              }
              return '';
            },
          ),
          onForgotPassword: _onForgotPassword,
          logo: Image.asset('assets/images/escudo.png'),
          //backgroundImage: 'assets/images/escudo.png',
          //signUpMode: SignUpModes.both,
          socialLogins: _socialLogins(context),
          loginDesktopTheme: _desktopTheme,
          loginMobileTheme: _mobileTheme,
          loginTexts: _loginTexts,
          emailValidator: ValidatorModel(
              validatorCallback: (String? email) => 'Email $email'),
          changeLangDefaultOnPressed: () async => _operation?.cancel(),
          initialMode: currentMode,
          privacyPolicyChild: const Text(
              'Ao clicar em "Login" você concorda com os termos de uso.'),
          // onAuthModeChange: (AuthMode newMode) async {
          //   currentMode = newMode;
          //   await _operation?.cancel();
          // },
        );
      },
    );
  }

  Future<String?> _authOperation(Future<String?> func) async {
    await _operation?.cancel();
    _operation = ayc.CancelableOperation.fromFuture(func);
    final String? res = await _operation?.valueOrCancellation();
    if (_operation?.isCompleted == true) {
      DialogBuilder(context).showResultDialog(res ?? 'Successful.');
    }
    return res;
  }

  Future<String?> _onForgotPassword(String email) async {
    await _operation?.cancel();
    return await LoginFunctions(context).onForgotPassword(email);
  }

  /// You can adjust the colors, text styles, button styles, borders
  /// according to your design preferences for *DESKTOP* view.
  /// You can also set some additional display options such as [showLabelTexts].
  LoginViewTheme get _desktopTheme => _mobileTheme.copyWith(
        // To set the color of button text, use foreground color.
        actionButtonStyle: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.white),
        ),
        dialogTheme: const AnimatedDialogTheme(
          languageDialogTheme: LanguageDialogTheme(
              optionMargin: EdgeInsets.symmetric(horizontal: 80)),
        ),
        loadingSocialButtonColor: blueColor,
        loadingButtonColor: Colors.white,
        privacyPolicyStyle: const TextStyle(color: Colors.black87),
        privacyPolicyLinkStyle: const TextStyle(
            color: blueColor, decoration: TextDecoration.underline),
      );

  /// You can adjust the colors, text styles, button styles, borders
  /// according to your design preferences for *MOBILE* view.
  /// You can also set some additional display options such as [showLabelTexts].
  LoginViewTheme get _mobileTheme => LoginViewTheme(
        // showLabelTexts: false,
        backgroundColor: blueColor, // const Color(0xFF6666FF),
        formFieldBackgroundColor: Colors.white,
        formWidthRatio: 60,
        actionButtonStyle: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(blueColor),
        ),
        animatedComponentOrder: const <AnimatedComponent>[
          AnimatedComponent(
            component: LoginComponents.logo,
            animationType: AnimationType.right,
          ),
          AnimatedComponent(component: LoginComponents.title),
          AnimatedComponent(component: LoginComponents.description),
          AnimatedComponent(component: LoginComponents.formTitle),
          AnimatedComponent(component: LoginComponents.socialLogins),
          AnimatedComponent(component: LoginComponents.useEmail),
          AnimatedComponent(component: LoginComponents.form),
          //AnimatedComponent(component: LoginComponents.notHaveAnAccount),
          AnimatedComponent(component: LoginComponents.forgotPassword),
          AnimatedComponent(component: LoginComponents.policyCheckbox),
          //AnimatedComponent(component: LoginComponents.changeActionButton),
          AnimatedComponent(component: LoginComponents.actionButton),
        ],
        privacyPolicyStyle: const TextStyle(color: Colors.white70),
        privacyPolicyLinkStyle: const TextStyle(
            color: Colors.white, decoration: TextDecoration.underline),
      );

  LoginTexts get _loginTexts => LoginTexts(
        nameHint: 'Nome',
        login: 'Login',
        signUp: 'Cadastrar',
        // signupEmailHint: 'Signup Email',
        // loginEmailHint: 'Login Email',
        // signupPasswordHint: 'Signup Password',
        // loginPasswordHint: 'Login Password',
      );

  /// You can adjust the texts in the screen according to the current language
  /// With the help of [LoginTexts], you can create a multilanguage scren.

  /// Social login options, you should provide callback function and icon path.
  /// Icon paths should be the full path in the assets
  /// Don't forget to also add the icon folder to the "pubspec.yaml" file.
  List<SocialLogin> _socialLogins(BuildContext context) => <SocialLogin>[
        SocialLogin(
            callback: () async => _socialCallback('Google'),
            iconPath: 'assets/images/google_icon.png'),
        SocialLogin(
            callback: () async => _socialCallback('Facebook'),
            iconPath: 'assets/images/facebook_icon.png'),
      ];

  Future<String?> _socialCallback(String type) async {
    // await _operation?.cancel();
    // _operation = ayc.CancelableOperation.fromFuture(
    //     LoginFunctions(context).socialLogin(type));
    // final String? res = await _operation?.valueOrCancellation();
    // if (_operation?.isCompleted == true && res == null) {
    // DialogBuilder(context)
    //     .showResultDialog('Successfully logged in with $type.');
    //}
    //return res;
    DialogBuilder(context).showResultDialog('Em desenvolvimento, aguarde.');
    return null;
  }
}

/// Example forgot password screen
class ForgotPasswordScreen extends StatelessWidget {
  /// Example forgot password screen that user is navigated to
  /// after clicked on "Forgot Password?" text.
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Esqueceu a senha'),
      ),
    );
  }
}

class LoginFunctions {
  /// Collection of functions will be performed on login/signup.
  /// * e.g. [onLogin], [onSignup], [socialLogin], and [onForgotPassword]
  const LoginFunctions(this.context);
  final BuildContext context;

  /// Login action that will be performed on click to action button in login mode.
  Future<String?> onLogin(LoginData loginData) async {
    context.read<LoginBloc>().add(
          PerformLoginEvent(loginData.email, loginData.password),
        );
    return null;
  }

  /// Sign up action that will be performed on click to action button in sign up mode.
  Future<String?> onSignup(SignUpData signupData) async {
    if (signupData.password != signupData.confirmPassword) {
      return 'As senhas não coincidem. Por favor, tente novamente.';
    }
    await Future.delayed(const Duration(seconds: 2));
    return null;
  }

  /// Social login callback example.
  Future<String?> socialLogin(String type) async {
    await Future.delayed(const Duration(seconds: 2));
    return null;
  }

  /// Action that will be performed on click to "Forgot Password?" text/CTA.
  /// Probably you will navigate user to a page to create a new password after the verification.
  Future<String?> onForgotPassword(String email) async {
    DialogBuilder(context).showLoadingDialog();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RedefinirSenha(),
      ),
    );
    return null;
  }
}

class LoadingIndicator extends StatelessWidget {
  /// Loading indicator widget to show in processes.
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getLoadingIndicator(context),
            _getHeading(context),
          ],
        ),
      );

  Padding _getLoadingIndicator(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          width: 100,
          height: 100,
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              strokeWidth: 3,
            ),
          ),
        ),
      );

  Widget _getHeading(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Text('Carregando...'),
      );
}

class DialogBuilder {
  /// Builds various dialogs with different methods.
  /// * e.g. [showLoadingDialog], [showResultDialog]
  const DialogBuilder(this.context);

  /// Takes [context] as parameter.
  final BuildContext context;

  /// Example loading dialog
  Future<void> showLoadingDialog() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => WillPopScope(
          onWillPop: () async => false,
          child: const AlertDialog(
            content: LoadingIndicator(),
          ),
        ),
      );

  /// Example result dialog
  Future<void> showResultDialog(String text) => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: SizedBox(
            height: 100,
            width: 100,
            child: Center(child: Text(text, textAlign: TextAlign.center)),
          ),
        ),
      );
}


// class LoginScreen extends StatelessWidget {
//   LoginScreen({Key? key}) : super(key: key);

//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final GlobalKey<FormState> logKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => LoginBloc(LogServices(), UserServices()),
//       child: Listener(
//         onPointerDown: (_) {
//           FocusScope.of(context).unfocus();
//         },
//         child: Scaffold(
//           backgroundColor: Colors.black,
//           appBar: AppBar(
//             title: const Text(
//               'Login',
//               style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//             backgroundColor: Colors.black,
//           ),
//           body: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 30.0),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       const LoginImage(),
//                       const SizedBox(height: 20),
//                       FormularioLogin(
//                         emailController: _emailController,
//                         passwordController: _passwordController,
//                         logKey: logKey,
//                       ),
//                       const SizedBox(height: 20),
//                       LoginButtons(
//                         emailController: _emailController,
//                         passwordController: _passwordController,
//                         loginContext: context,
//                         logKey: logKey,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//     );
//   }
// }
