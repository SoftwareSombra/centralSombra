
import '../../model/usuario_empresa_model.dart';

sealed class EmpresaUsersState {}

final class EmpresaUsersInitial extends EmpresaUsersState {}

final class EmpresaUsersLoading extends EmpresaUsersState {}

final class EmpresaUsersLoaded extends EmpresaUsersState {
  final List<UsuarioEmpresa> users;
  EmpresaUsersLoaded({required this.users});
}

final class EmpresaUsersError extends EmpresaUsersState {
  final String message;
  EmpresaUsersError({required this.message});
}

final class EmpresaUsersEmpty extends EmpresaUsersState {}
