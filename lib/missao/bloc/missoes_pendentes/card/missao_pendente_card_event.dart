
sealed class MissaoPendenteCardEvent {}

final class IniciarMissaoPendenteCard extends MissaoPendenteCardEvent {
  final String missaoId;

  IniciarMissaoPendenteCard(this.missaoId);
}
