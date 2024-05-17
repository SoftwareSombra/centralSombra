import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../admin/services/admin_services.dart';
import '../../services/empresa_services.dart';
import 'empresa_users_event.dart';
import 'empresa_users_state.dart';

class EmpresaUsersBloc extends Bloc<EmpresaUsersEvent, EmpresaUsersState> {
  EmpresaUsersBloc() : super(EmpresaUsersInitial()) {
    final EmpresaServices empresaServices = EmpresaServices();
    //final AdminServices adminServices = AdminServices();

    on<EmpresaUsersEvent>(
      (event, emit) {},
    );
    on<BuscarUsuariosDaEmpresa>(
      (event, emit) async {
        emit(EmpresaUsersLoading());
        try {
          final users = await empresaServices.getUsuariosEmpresa(event.cnpj);
          //final users = await adminServices.getEmpresaUsers(event.cnpj);
          if (users.isEmpty) {
            emit(EmpresaUsersEmpty());
          } else {
            emit(EmpresaUsersLoaded(users: users));
          }
        } catch (e) {
          emit(EmpresaUsersError(message: e.toString()));
        }
      },
    );
  }
}
