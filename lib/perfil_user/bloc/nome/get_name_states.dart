abstract class UserState {}

class UserInitial extends UserState {}

class UserNameLoading extends UserState {}

class UserNameLoaded extends UserState {
  final String name;

  UserNameLoaded(this.name);
}

class UserNameError extends UserState {
  final String message;

  UserNameError(this.message);
}

class UserNameUpdated extends UserState {
  final String newName;

  UserNameUpdated(this.newName);
}