import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra/web/admin/usuarios/screens/add_user.dart';
import 'package:sombra/web/admin/usuarios/screens/profile_screen.dart';
import '../../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../../paginated_data_table/paginated_data_table.dart';
import '../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import '../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import '../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';
import '../../services/admin_services.dart';
import '../bloc/users_list_bloc/users_list_bloc.dart';
import '../bloc/users_list_bloc/users_list_event.dart';
import '../bloc/users_list_bloc/users_list_state.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final canvasColor = const Color.fromARGB(255, 0, 15, 42);
  TextEditingController searchController = TextEditingController();
  List<Usuario> users = [];
  List<DataColumn> get columns => const [
        DataColumn(label: Text('Nome')),
        DataColumn(label: Text('UID')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Opções')),
      ];
  List<Usuario> filtrarUsuarios(List<Usuario> usuarios, String searchText) {
    searchText = searchText.toLowerCase();
    return usuarios.where((usuarios) {
      return usuarios.nome.toLowerCase().contains(searchText);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<UsersListBloc>(context).add(FetchUsersList());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
          //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
          ),
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
            users = state.users;

            List<Usuario> usuariosFiltrados =
                filtrarUsuarios(users, searchController.text);
            usuariosFiltrados.sort((a, b) =>
                (removeDiacritics(a.nome).toLowerCase()).trim().compareTo(removeDiacritics(b.nome).toLowerCase().trim()));

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      child: SizedBox(
                        width: width * 0.4,
                        height: 40,
                        child: TextFormField(
                          controller: searchController,
                          cursorHeight: 15,
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
                              borderSide: BorderSide(color: Colors.grey[500]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]!),
                            ),
                          ),
                          onChanged: (text) {
                            setState(() {
                              //relatorios = filtrarRelatorios();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: width * 0.99,
                  child: usuariosFiltrados.isNotEmpty
                      ? PaginatedDataTable(
                          columns: columns,
                          source: EmpresaDataSource(
                              users: usuariosFiltrados,
                              context: context),
                          header: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Usuários'),
                            ],
                          ),
                          columnSpacing:
                              MediaQuery.of(context).size.width * 0.05,
                          showCheckboxColumn: true,
                          rowsPerPage:
                              state.users.length < 10 ? state.users.length : 10,
                        )
                      : const Center(
                          child: Text('Nenhum user cadastrado'),
                        ),
                ),
              ],
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
        backgroundColor: canvasColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class EmpresaDataSource extends DataTableSource {
  List<Usuario> users;
  BuildContext context;
  EmpresaDataSource({required this.users, required this.context});

  final AdminServices adminServices = AdminServices();
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  Color canvasColor = const Color.fromARGB(255, 3, 9, 18);

  void _showDialog(Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
          title: const Text('Confirmação'),
          content: const Text('Deseja realmente excluir este usuário?'),
          actions: <Widget>[
            BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
              builder: (buttonContext, buttonState) {
                return buttonState is ElevatedButtonBlocLoading
                    ? const CircularProgressIndicator()
                    : Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              buttonContext.read<ElevatedButtonBloc>().add(
                                    ElevatedButtonPressed(),
                                  );
                              final delete =
                                  await adminServices.deleteUser(usuario.uid);
                              if (context.mounted) {
                                if (delete) {
                                  mensagemDeSucesso.showSuccessSnackbar(
                                      context, 'Usuário excluído com sucesso.');
                                } else {
                                  tratamentoDeErros.showErrorSnackbar(context,
                                      'Erro ao excluir usuário, tente novamente.');
                                }
                                context
                                    .read<UsersListBloc>()
                                    .add(FetchUsersList());
                                buttonContext.read<ElevatedButtonBloc>().add(
                                      ElevatedButtonReset(),
                                    );
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Confirmar'),
                          ),
                        ],
                      );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= users.length) {
      return null;
    }
    final user = users[index];

    return DataRow.byIndex(
      index: index,
      color: WidgetStatePropertyAll(
        canvasColor.withAlpha(15),
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
                  onTap: () {
                    _showDialog(user);
                  },
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          user: user,
                        ),
                      ),
                    );
                  },
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
