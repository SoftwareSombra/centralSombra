import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../autenticacao/services/user_services.dart';
import 'events.dart';
import 'states.dart';

class UserFotoBloc extends Bloc<UserFotoEvent, UserFotoState> {
  final UserServices userServices;

  UserFotoBloc({required this.userServices}) : super(UserFotoInitial()) {
    on<FetchUserFoto>((event, emit) async {
      emit(UserFotoLoading());
      try {
        final foto = await userServices.getPhoto();
        debugPrint('foto buscada');
        emit(UserFotoLoaded(foto!));
      } catch (_) {
        emit(UserFotoError('Erro ao buscar foto'));
      }
    });
    on<UpdateUserFoto>((event, emit) async {
      emit(UserFotoUpdated(event.foto));
    });
    // adicionar mais manipuladores conforme necessário...
  }
}
