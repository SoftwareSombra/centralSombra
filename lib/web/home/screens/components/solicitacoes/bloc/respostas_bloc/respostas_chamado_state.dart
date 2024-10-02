part of 'respostas_chamado_bloc.dart';

@immutable
sealed class RespostasChamadoState {}

final class RespostasChamadoInitial extends RespostasChamadoState {}

final class RespostasChamadoLoading extends RespostasChamadoState {}

final class RespostasChamadoLoaded extends RespostasChamadoState {
  final bool respostas;

  RespostasChamadoLoaded(this.respostas);
}

final class RespostasChamadoError extends RespostasChamadoState {}
