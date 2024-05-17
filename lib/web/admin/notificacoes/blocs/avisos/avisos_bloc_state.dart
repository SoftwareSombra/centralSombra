import '../../services/notificacoes_services.dart';

sealed class AvisosBlocState {}

final class AvisosBlocInitial extends AvisosBlocState {}

final class AvisosBlocLoading extends AvisosBlocState {}

final class AvisosBlocLoaded extends AvisosBlocState {
  final List<AvisoModel>? avisos;

  AvisosBlocLoaded({required this.avisos});
}

final class AvisosBlocIsEmpty extends AvisosBlocState {}

final class AvisosBlocError extends AvisosBlocState {
  final String? message;

  AvisosBlocError({this.message});
}
