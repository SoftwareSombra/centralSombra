import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/admin_services.dart';
import '../bloc/users_list_bloc/users_list_bloc.dart';
import '../bloc/users_list_bloc/users_list_event.dart';
import '../bloc/users_list_bloc/users_list_state.dart';
import 'add_user.dart';

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  List<DataColumn> get columns => const [
        DataColumn(label: Text('Nome')),
        DataColumn(label: Text('UID')),
        DataColumn(label: Text('Ver detalhes')),
      ];

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<UsersListBloc>(context).add(FetchUsersList());
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<UsersListBloc, UsersListState>(
        builder: (context, state) {
          if (state is UsersListInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UsersListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UsersListError) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is UsersListEmpty) {
            return const Center(
              child: Text('Nenhum user cadastrado'),
            );
          } else if (state is UsersListLoaded) {
            return Center(
              child: Container(
                width: width * 0.99,
                child: state.users.isNotEmpty
                    ? PaginatedDataTable(
                        columns: columns,
                        source: EmpresaDataSource(users: state.users),
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('users'),
                            SizedBox(
                              width: width * 0.4,
                              height: 40,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Buscar usuário pelo nome',
                                  labelStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  suffixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        columnSpacing: MediaQuery.of(context).size.width * 0.05,
                        showCheckboxColumn: true,
                        rowsPerPage:
                            state.users.length < 10 ? state.users.length : 10,
                      )
                    : const Center(
                        child: Text('Nenhum user cadastrado'),
                      ),
              ),
            );
          } else {
            return const Center(
              child: Text('Recarregue a página'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddUser(),
        ),
      );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EmpresaDataSource extends DataTableSource {
  List<Usuario> users;
  EmpresaDataSource({required this.users});

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= users.length) {
      return null;
    }
    final user = users[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Row(
            children: [
              Checkbox(
                value: false,
                onChanged: (value) {
                  value = !value!;
                },
              ),
              const SizedBox(
                width: 2,
              ),
              SelectableText(user.nome),
            ],
          ),
        ),
        DataCell(
          SelectableText(user.uid),
        ),
        DataCell(
          IconButton(
            // Adicione um IconButton para ver detalhes
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              // Navegue para a tela de detalhes
            },
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => users.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
