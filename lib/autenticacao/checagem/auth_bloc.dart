import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_bloc.dart';
import 'state_bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuth auth;

  AuthenticationBloc(this.auth)
      : super(AuthenticationState(AuthStatus.login, null)) {
    on<CheckAuthentication>(_handleCheckAuthentication);
  }

  Future<void> _handleCheckAuthentication(
    CheckAuthentication event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      if (kIsWeb) {
        emit(AuthenticationState(AuthStatus.web, null));
      } else if (auth.currentUser == null) {
        emit(AuthenticationState(AuthStatus.login, null));
      } else {
        emit(AuthenticationState(AuthStatus.home, null));
      }
    } catch (e) {
      emit(AuthenticationState(AuthStatus.error, e.toString()));
    }
  }
}
