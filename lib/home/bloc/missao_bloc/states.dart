import '../../../missao/model/missao_model.dart';

abstract class GetMissaoState {}

class GetMissaoLoading extends GetMissaoState {}

class GetMissaoLoaded extends GetMissaoState {
  final Missao missao;
  GetMissaoLoaded(this.missao);
}

class EmMissao extends GetMissaoState {}

class SemMissao extends GetMissaoState {
  final String semMissao;
  SemMissao(this.semMissao);
}

class GetMissaoError extends GetMissaoState {
  final String error;
  GetMissaoError(this.error);
}

final class AceitarChamadoLoading extends GetMissaoState {}

final class AceitarChamadoLoaded extends GetMissaoState {}

final class ChamadoError extends GetMissaoState {
  final String message;

  ChamadoError(this.message);
}

final class ConfirmacaoMissaoSuccess extends GetMissaoState {
  final String message;

  ConfirmacaoMissaoSuccess(this.message);
}


final class ConfirmacaoMissaoFailed extends GetMissaoState {
  final String message;

  ConfirmacaoMissaoFailed(this.message);
}