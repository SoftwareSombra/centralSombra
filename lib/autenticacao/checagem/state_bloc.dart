enum AuthStatus { web, login, home, error }

class AuthenticationState {
  final AuthStatus status;
  final String? message;

  AuthenticationState(this.status, this.message);
}
