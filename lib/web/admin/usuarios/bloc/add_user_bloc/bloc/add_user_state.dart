sealed class AddUserState {}

class AddUserInitial extends AddUserState {}

class RegisterUserLoading extends AddUserState {}

class RegisterUserSuccess extends AddUserState {
  final String? uid;

  RegisterUserSuccess(this.uid);
}

class RegisterUserFailure extends AddUserState {
  final String error;

  RegisterUserFailure(this.error);
}
