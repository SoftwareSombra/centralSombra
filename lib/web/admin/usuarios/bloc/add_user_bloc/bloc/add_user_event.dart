
class AddUserEvent {}

class RegisterUserEvent extends AddUserEvent {
  final String name;
  final String email;
  final String password;

  RegisterUserEvent(this.name, this.email, this.password);
}

class ResetAddUser extends AddUserEvent {}
