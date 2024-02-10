abstract class UserEvent {}

class FetchUserName extends UserEvent {
  final String uid;

  FetchUserName(this.uid);
}

class UpdateUserName extends UserEvent {
  final String newName;

  UpdateUserName(this.newName);
}