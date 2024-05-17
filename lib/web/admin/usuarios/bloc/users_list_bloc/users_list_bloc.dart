import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/admin_services.dart';
import 'users_list_event.dart';
import 'users_list_state.dart';

class UsersListBloc extends Bloc<UsersListEvent, UsersListState> {
  UsersListBloc() : super(UsersListInitial()) {
    on<FetchUsersList>(
      (event, emit) async {
        emit(UsersListLoading());
        try {
          //final users = await AdminServices().getAllUsers();
          final users = await AdminServices().getAllUsers2();
          if (users != null) {
            emit(UsersListLoaded(users));
          } else {
            emit(UsersListEmpty());
          }
        } catch (e) {
          emit(UsersListError('Erro ao carregar usuários'));
        }
      },
    );
  }
}
