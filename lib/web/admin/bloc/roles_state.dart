sealed class RolesState {}

final class RolesInitial extends RolesState {}

final class RolesLoading extends RolesState {}

final class RolesLoaded extends RolesState {
  final bool isDev;
  final bool isAdmin;
  final bool isOperador;
  RolesLoaded({required this.isDev, required this.isAdmin, required this.isOperador});
}

final class RolesError extends RolesState {
  final String message;
  RolesError({required this.message});
}
