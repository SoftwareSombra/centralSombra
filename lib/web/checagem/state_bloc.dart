enum WebUserStatus {
  desktopNaoLogado,
  mobileNaoLogado,
  desktopLogado,
  mobileLogado
}

class WebAuthenticationState {
  final WebUserStatus status;
  final String? message;

  WebAuthenticationState(this.status, this.message);
}
