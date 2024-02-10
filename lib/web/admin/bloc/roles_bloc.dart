import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/admin_services.dart';
import 'roles_event.dart';
import 'roles_state.dart';

class RolesBloc extends Bloc<RolesEvent, RolesState> {
  RolesBloc() : super(RolesInitial()) {
    AdminServices adminServices = AdminServices();
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      throw Exception('Usuário não autenticado');
    } else {
      final uid = auth.currentUser!.uid;
      debugPrint('----- bloc uid: $uid-----');
      on<BuscarRoles>((event, emit) async {
        emit(RolesLoading());
        try {
          final isDev = await adminServices.checkIfUserIsDev();
          final isAdmin = await adminServices.checkIfUserIsAdmin();
          debugPrint ('----- bloc isAdmin: $isAdmin-----');
          final isOperador = await adminServices.checkIfUserIsOperador();
          emit(RolesLoaded(
              isDev: isDev, isAdmin: isAdmin, isOperador: isOperador));
        } catch (e) {
          emit(RolesError(message: e.toString()));
        }
      });
    }
  }
}