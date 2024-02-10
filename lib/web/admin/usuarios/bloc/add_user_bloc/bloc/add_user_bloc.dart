import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';
import '../../../../../../autenticacao/services/user_services.dart';
import 'add_user_event.dart';
import 'add_user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddUserBloc extends Bloc<AddUserEvent, AddUserState> {
  AddUserBloc() : super(AddUserInitial()) {
    on<RegisterUserEvent>(_performRegistration);
    on<ResetAddUser>(_reset);
  }
  void _performRegistration(
      RegisterUserEvent event, Emitter<AddUserState> emit) async {
    UserServices userServices = UserServices();
    if (!userServices.isEmailValid(event.email)) {
      emit(RegisterUserFailure('Por favor, insira um email válido.'));
      return;
    }
    if (!userServices.isPasswordValid(event.password)) {
      emit(RegisterUserFailure('A senha deve conter no mínimo 6 caracteres.'));
      return;
    }

    emit(RegisterUserLoading());

    try {
      Tuple2 isRegisterSuccessful = await userServices.performRegistration3(
          event.name, event.email, event.password);
      debugPrint('isRegisterSuccessful: ${isRegisterSuccessful.item1}');
      if (isRegisterSuccessful.item1) {
        debugPrint('chegou aqui, sucesso');
        debugPrint('isRegisterSuccessful: ${isRegisterSuccessful.item2}');
        //await Future.delayed(const Duration(seconds: 1));
        emit(RegisterUserSuccess(isRegisterSuccessful.item2));
      } else {
        emit(RegisterUserFailure(
            _mapFirebaseErrorToMessage(isRegisterSuccessful.item2)));
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Traduz os códigos de erro para mensagens
        emit(RegisterUserFailure(_mapFirebaseErrorToMessage(e.code)));
      } else {
        emit(RegisterUserFailure(_mapFirebaseErrorToMessage(e)));
      }
    }
  }

  String _mapFirebaseErrorToMessage(e) {
    debugPrint('e.code: $e');
    debugPrint('e: ${e.code}');
    switch (e.code) {
      case "weak-password":
        return 'Senha muito fraca.';
      case "invalid-argument":
        return 'E-mail inválido.';
      case "already-exists":
        return 'E-mail já cadastrado.';
      case "email-already-in-use":
        return 'E-mail já cadastrado.';
      case "user-not-found":
        return 'Nenhum usuário encontrado com esse e-mail.';
      case "wrong-password":
        return 'Senha incorreta.';
      default:
        return 'Ocorreu um erro durante o cadastro. Por favor, tente novamente.';
    }
  }

  void _reset(ResetAddUser event, Emitter<AddUserState> emit) async {
    emit(AddUserInitial());
  }
}
