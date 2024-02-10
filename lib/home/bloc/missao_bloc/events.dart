import 'package:sombra_testes/missao/model/missao_model.dart';

abstract class GetMissaoEvent {}

class LoadMissao extends GetMissaoEvent {
  final String uid;
  LoadMissao(this.uid);
}

class LoadSavedMission extends GetMissaoEvent {
  final Missao missao;
  LoadSavedMission(this.missao);
}

final class AceitarChamado extends GetMissaoEvent {
  final String? missaoId;
  final String nome;

  AceitarChamado(this.missaoId, this.nome);
}

final class RecusarChamado extends GetMissaoEvent {}
