import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../autenticacao/services/user_services.dart';
import 'get_name_events.dart';
import 'get_name_states.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    final UserServices userServices = UserServices();
    on<FetchUserName>((event, emit) async {
      emit(UserNameLoading());
      try {
        final user = FirebaseAuth.instance.currentUser;
        final email = user!.email;
        final name = await userServices.getName();
        debugPrint('nome buscado');
        emit(UserNameLoaded(name!, email!));
      } catch (_) {
        emit(UserNameError('Erro ao buscar nome'));
      }
    });
    on<UpdateUserName>((event, emit) async {
      emit(UserNameUpdated(event.newName));
    });
    // adicionar mais manipuladores conforme necessário...
  }
}
