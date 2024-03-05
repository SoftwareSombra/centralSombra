
sealed class EmpresaUsersEvent {}

// Buscar usuários da empresa recebendo o cnpj como parâmetro
class BuscarUsuariosDaEmpresa extends EmpresaUsersEvent {
  final String cnpj;
  BuscarUsuariosDaEmpresa({required this.cnpj});
}
