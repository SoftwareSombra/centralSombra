import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/empresa_services.dart';
import 'get_empresas_event.dart';
import 'get_empresas_state.dart';

class GetEmpresasBloc extends Bloc<GetEmpresasEvent, GetEmpresasState> {
  GetEmpresasBloc() : super(GetEmpresasInitial()) {
    EmpresaServices empresaServices = EmpresaServices();
    on<GetEmpresas>((event, emit) async {
      emit(GetEmpresasLoading());
      try {
        await empresaServices.getAllEmpresas().then((empresas) {
          emit(GetEmpresasLoaded(empresas: empresas));
        });
      } catch (e) {
        emit(GetEmpresasError(message: e.toString()));
      }
    });
  }
}
