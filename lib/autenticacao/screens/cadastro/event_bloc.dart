abstract class RegisterEvent {}

class PerformRegisterEvent extends RegisterEvent {
  final String name;
  final String email;
  final String password;

  PerformRegisterEvent(this.name, this.email, this.password);
}
