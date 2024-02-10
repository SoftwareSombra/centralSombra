import '../../../services/admin_services.dart';

sealed class UsersListState {}

final class UsersListInitial extends UsersListState {}

final class UsersListLoading extends UsersListState {}

final class UsersListLoaded extends UsersListState {
  final List<Usuario> users;

  UsersListLoaded(this.users);
}

final class UsersListEmpty extends UsersListState {}

final class UsersListError extends UsersListState {
  final String message;

  UsersListError(this.message);
}
