class AddUserEvent {}

class RegisterUserEvent extends AddUserEvent {
  final String name;
  final String email;
  final String password;
  final String? cargo;

  RegisterUserEvent(this.name, this.email, this.password, {this.cargo});
}

class ResetAddUser extends AddUserEvent {}
