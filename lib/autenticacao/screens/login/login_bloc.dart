import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/log_services.dart';
import '../../services/user_services.dart';
import 'event_bloc.dart';
import 'state_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LogServices logServices;
  final UserServices userServices;

  LoginBloc(
    this.logServices,
    this.userServices
  ) : super(LoginInitial()) {
    on<PerformLoginEvent>(_onPerformLoginEvent);
  }

  Future<void> _onPerformLoginEvent(
    PerformLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    if (!userServices.isEmailValid(event.email)) {
      emit(LoginFailure('Por favor, insira um email válido.'));
      return;
    }
    if (!userServices.isPasswordValid(event.password)) {
      emit(LoginFailure('A senha deve conter no mínimo 6 caracteres.'));
      return;
    }

    emit(LoginLoading());

    try {
      bool isLoginSuccessful = await logServices.login(event.email, event.password);
      if (isLoginSuccessful) {
        emit(LoginSuccess());
      } else {
        emit(LoginFailure('Erro desconhecido.'));
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Traduz os códigos de erro para mensagens
        emit(LoginFailure(_mapFirebaseErrorToMessage(e)));
      } else {
        emit(LoginFailure('Ocorreu um erro. Tente novamente.'));
      }
    }
  }

  String _mapFirebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return 'Nenhum usuário encontrado com esse e-mail.';
      case "wrong-password":
        return 'Senha incorreta.';
      default:
        return 'Ocorreu um erro durante o login. Por favor, tente novamente.';
    }
  }
}
