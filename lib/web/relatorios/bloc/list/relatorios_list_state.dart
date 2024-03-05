
import '../../../../missao/model/missao_model.dart';

sealed class RelatoriosListState {}

final class RelatoriosListInitial extends RelatoriosListState {}

final class RelatoriosListLoading extends RelatoriosListState {}

final class RelatoriosListLoaded extends RelatoriosListState {
  final List<MissaoRelatorio?> relatorios;

  RelatoriosListLoaded({required this.relatorios});
}

final class RelatoriosListError extends RelatoriosListState {
  final String message;

  RelatoriosListError({required this.message});
}

final class RelatoriosListEmpty extends RelatoriosListState {}
