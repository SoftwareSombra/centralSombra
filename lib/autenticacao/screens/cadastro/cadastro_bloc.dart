import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuple/tuple.dart';
import '../../services/user_services.dart';
import 'state_bloc.dart';
import 'event_bloc.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserServices userServices;

  RegisterBloc(this.userServices) : super(RegisterInitial()) {
    on<PerformRegisterEvent>(_performRegistration);
  }

  void _performRegistration(
      PerformRegisterEvent event, Emitter<RegisterState> emit) async {
    if (!userServices.isEmailValid(event.email)) {
      emit(RegisterFailure('Por favor, insira um email válido.'));
      return;
    }
    if (!userServices.isPasswordValid(event.password)) {
      emit(RegisterFailure('A senha deve conter no mínimo 6 caracteres.'));
      return;
    }

    emit(RegisterLoading());

    try {
      Tuple2 isRegisterSuccessful = await userServices.performRegistration2(
          event.name, event.email, event.password);
      if (isRegisterSuccessful.item1) {
        //await Future.delayed(const Duration(seconds: 1));
        emit(RegisterSuccess('Conta criada com sucesso.'));
      } else {
        emit(RegisterFailure(
            _mapFirebaseErrorToMessage(isRegisterSuccessful.item2)));
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Traduz os códigos de erro para mensagens
        emit(RegisterFailure(_mapFirebaseErrorToMessage(e.code)));
      } else {
        emit(RegisterFailure(_mapFirebaseErrorToMessage(e)));
      }
    }
  }

  String _mapFirebaseErrorToMessage(e) {
    switch (e.code) {
      case "email-already-in-use":
        return 'E-mail já cadastrado.';
      case "already-exists":
        return 'E-mail já cadastrado.';
      case "user-not-found":
        return 'Nenhum usuário encontrado com esse e-mail.';
      case "wrong-password":
        return 'Senha incorreta.';
      default:
        return 'Ocorreu um erro durante o cadastro. Por favor, tente novamente.';
    }
  }
}
