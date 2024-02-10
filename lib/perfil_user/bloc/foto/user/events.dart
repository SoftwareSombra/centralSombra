abstract class UserFotoEvent {}

class FetchUserFoto extends UserFotoEvent {
  final String uid;

  FetchUserFoto(this.uid);
}

class UpdateUserFoto extends UserFotoEvent {
  final String foto;

  UpdateUserFoto(this.foto);
}