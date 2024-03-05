import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/log_services.dart';
import '../../services/user_services.dart';
import 'event_bloc.dart';
import 'state_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LogServices logServices;
  final UserServices userServices;

  LoginBloc(this.logServices, this.userServices) : super(LoginInitial()) {
    on<PerformLoginEvent>(_onPerformLoginEvent);
  }

  String _mapFirebaseErrorToMessage(FirebaseAuthException e) {
    debugPrint('---- Error: ${e.code} ----');
    switch (e.code) {
      case "user-not-found":
        return 'Nenhum usuário encontrado com esse e-mail.';
      case "wrong-password":
        return 'Senha incorreta.';
      case "invalid-credential":
        return 'Senha ou email inválidos.';
      default:
        return 'Ocorreu um erro durante o login. Por favor, tente novamente.';
    }
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
      Object object = await logServices.login(event.email, event.password);
      if (object == 'Sucesso') {
        emit(LoginSuccess());
      } else {
        if (object is FirebaseAuthException) {
          emit(LoginFailure(_mapFirebaseErrorToMessage(object)));
        } else {
          emit(LoginFailure('Ocorreu um erro. Tente novamente.'));
        }
      }
    } catch (e) {
      emit(LoginFailure('Ocorreu um erro. Tente novamente.'));
    }
  }
}
