
import 'package:flutter_bloc/flutter_bloc.dart';

import 'missao_pendente_card_event.dart';
import 'missao_pendente_card_state.dart';

class MissaoPendenteCardBloc
    extends Bloc<MissaoPendenteCardEvent, MissaoPendenteCardState> {
  MissaoPendenteCardBloc() : super(MissaoPendenteCardInitial()) {
    on<MissaoPendenteCardEvent>((event, emit) {
      
    });
  }
}
