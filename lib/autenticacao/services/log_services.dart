import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/tratamento/error_snackbar.dart';
import '../screens/tratamento/success_snackbar.dart';

class LogServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

   Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logOut(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      debugPrint('Erro: $e');
      tratamentoDeErros.showErrorSnackbar(
          context, 'Falha ao tentar sair, tente novamente');
      return false;
    }
  }
}
