import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'alert_criacao_event.dart';
part 'alert_criacao_state.dart';

class AlertCriacaoBloc extends Bloc<AlertCriacaoEvent, AlertCriacaoState> {
  AlertCriacaoBloc() : super(AlertCriacaoInitial()) {
    on<AlertCriacaoEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
