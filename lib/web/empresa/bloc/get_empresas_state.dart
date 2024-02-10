import '../model/empresa_model.dart';

sealed class GetEmpresasState {}

final class GetEmpresasInitial extends GetEmpresasState {}

final class GetEmpresasLoading extends GetEmpresasState {}

final class GetEmpresasLoaded extends GetEmpresasState {
  final List<Empresa>? empresas;

  GetEmpresasLoaded({this.empresas});
}

final class GetEmpresasError extends GetEmpresasState {
  final String message;

  GetEmpresasError({required this.message});
}
