sealed class ChatHomeState {}

final class ChatHomeInitial extends ChatHomeState {}

final class ChatHomeLoading extends ChatHomeState {}

final class ChatHomeLoaded extends ChatHomeState {
  //QuerySnapshot<Map<String, dynamic>> snapshot;
  final String uid;
  final int unreadCount;
  ChatHomeLoaded(this.unreadCount, this.uid);
}

final class ChatHomeError extends ChatHomeState {
  ChatHomeError(this.error);

  final Object error;
}

final class ChatHomeEmpty extends ChatHomeState {}
