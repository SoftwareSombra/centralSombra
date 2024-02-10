import 'dart:async';
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import 'state_bloc.dart';

class ChecagemWebMobile {
  Stream<WebUserStatus> checarUsuarioWeb() {
    var userAgent = html.window.navigator.userAgent.toString();
    return FirebaseAuth.instance.authStateChanges().map((User? user) {
      if (userAgent.contains('Android') || userAgent.contains('iPhone')) {
        return user == null ? WebUserStatus.mobileNaoLogado : WebUserStatus.mobileLogado;
      } else {
        return user == null ? WebUserStatus.desktopNaoLogado : WebUserStatus.desktopLogado;
      }
    });
  }
}
