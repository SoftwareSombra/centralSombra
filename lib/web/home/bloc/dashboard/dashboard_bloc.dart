import 'package:flutter_bloc/flutter_bloc.dart';
import 'events.dart';
import 'states.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final bool _isDev;
  final bool _isAdmin;

  DashboardBloc(bool isDev, bool isAdmin)
      : _isAdmin = isAdmin, _isDev = isDev,
        super(DashboardInitial()) {
    // Registrando os eventos
    on<ChangeDashboard>((event, emit) {
      emit(DashboardChanged(event.index));
    });
  }

  bool get isDev => _isDev;
  bool get isAdmin => _isAdmin;
}
