import 'package:flutter_bloc/flutter_bloc.dart';
part 'agente_editado_event.dart';
part 'agente_editado_state.dart';

class AgenteEditadoBloc extends Bloc<AgenteEditadoEvent, AgenteEditadoState> {
  AgenteEditadoBloc() : super(AgenteEditadoInitial()) {
    on<AgenteEditadoEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
