import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/admin_services.dart';
import '../bloc/users_list_bloc/users_list_bloc.dart';
import '../bloc/users_list_bloc/users_list_event.dart';
import '../bloc/users_list_bloc/users_list_state.dart';

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  List<DataColumn> get columns => const [
        DataColumn(label: Text('Nome')),
        DataColumn(label: Text('UID')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Opções')),
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
                        source: EmpresaDataSource(
                            users: state.users, context: context),
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Usuários cadastrados'),
                            SizedBox(
                              width: width * 0.2,
                              height: 31,
                              child: TextFormField(
                                cursorHeight: 12,
                                decoration: InputDecoration(
                                  labelText: 'Buscar usuário pelo nome',
                                  labelStyle: TextStyle(
                                      color: Colors.grey[500], fontSize: 12),
                                  suffixIcon: Icon(
                                    Icons.search,
                                    size: 20,
                                    color: Colors.grey[500]!,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey[500]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey[500]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey[500]!),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => AddUser(),
      //       ),
      //     );
      //   },
      //   backgroundColor: Colors.blue.withOpacity(0.11),
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.white,
      //   ),
      // ),
    );
  }
}

class EmpresaDataSource extends DataTableSource {
  List<Usuario> users;
  BuildContext context;
  EmpresaDataSource({required this.users, required this.context});

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= users.length) {
      return null;
    }
    final user = users[index];

    return DataRow.byIndex(
      index: index,
      color: const MaterialStatePropertyAll(
        Color.fromARGB(255, 3, 9, 18),
      ),
      cells: [
        DataCell(
          Row(
            children: [
              // Checkbox(
              //   value: false,
              //   onChanged: (value) {
              //     value = !value!;
              //   },
              // ),
              // const SizedBox(
              //   width: 2,
              // ),
              SelectableText(user.nome),
            ],
          ),
        ),
        DataCell(
          SelectableText(user.uid),
        ),
        DataCell(
          SelectableText(user.email!),
        ),
        DataCell(
          Row(
            children: [
              MouseRegion(
                cursor: MaterialStateMouseCursor.clickable,
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red.withOpacity(0.8),
                        size: 15,
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      const Text(
                        'Excluir',
                        style: TextStyle(
                          //color: Colors.red,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              MouseRegion(
                cursor: MaterialStateMouseCursor.clickable,
                child: GestureDetector(
                  onTap: () {},
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_outlined,
                        size: 15,
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Text(
                        'Detalhes',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
