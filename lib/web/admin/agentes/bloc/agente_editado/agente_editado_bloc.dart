import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'agente_editado_event.dart';
part 'agente_editado_state.dart';

class AgenteEditadoBloc extends Bloc<AgenteEditadoEvent, AgenteEditadoState> {
  AgenteEditadoBloc() : super(AgenteEditadoInitial()) {
    on<AgenteEditadoEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
