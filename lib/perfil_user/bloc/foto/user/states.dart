abstract class UserFotoState {}

class UserFotoInitial extends UserFotoState {}

class UserFotoLoading extends UserFotoState {}

class UserFotoLoaded extends UserFotoState {
  final String foto;

  UserFotoLoaded(this.foto);
}

class UserFotoError extends UserFotoState {
  final String message;

  UserFotoError(this.message);
}

class UserFotoUpdated extends UserFotoState {
  final String foto;

  UserFotoUpdated(this.foto);
}