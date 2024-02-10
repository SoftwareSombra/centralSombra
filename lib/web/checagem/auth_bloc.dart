import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'event_bloc.dart';
import 'export_lib.dart';
import 'state_bloc.dart';

class WebAuthenticationBloc
    extends Bloc<WebAuthenticationEvent, WebAuthenticationState> {
  final StreamController<WebUserStatus> _authenticationStatusController =
      StreamController<WebUserStatus>.broadcast();

  StreamSubscription<WebUserStatus>? _statusSubscription;

  WebAuthenticationBloc() : super(WebAuthenticationState(WebUserStatus.desktopNaoLogado, null)) {
    var checagem = ChecagemWebMobile();
    _statusSubscription = checagem.checarUsuarioWeb().listen(_handleAuthChange);
    on<CheckWebAuthentication>(_onCheckWebAuthentication);
  }

  void _handleAuthChange(WebUserStatus status) {
    _authenticationStatusController.add(status);
  }


  Future<void> _onCheckWebAuthentication(
    CheckWebAuthentication event,
    Emitter<WebAuthenticationState> emit,
  ) async {
    try {
      await for (var status in _authenticationStatusController.stream) {
        emit(WebAuthenticationState(status, null));
      }
    } catch (e) {
      emit(WebAuthenticationState(WebUserStatus.desktopNaoLogado, e.toString()));
    }
  }

@override
  Future<void> close() {
    _statusSubscription?.cancel();
    _authenticationStatusController.close();
    return super.close();
  }
}
