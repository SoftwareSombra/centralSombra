import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../bloc/empresa_user_bloc/empresa_users_bloc.dart';
import '../../bloc/empresa_user_bloc/empresa_users_event.dart';
import '../../bloc/empresa_user_bloc/empresa_users_state.dart';
import '../../model/empresa_model.dart';
import '../../services/empresa_services.dart';
import 'adicionar_user_empresa.dart';

class EmpresaUsersListDialog extends StatefulWidget {
  final Empresa empresa;
  const EmpresaUsersListDialog({super.key, required this.empresa});

  @override
  State<EmpresaUsersListDialog> createState() => _EmpresaUsersListDialogState();
}

class _EmpresaUsersListDialogState extends State<EmpresaUsersListDialog> {
  final EmpresaServices empresaServices = EmpresaServices();
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<EmpresaUsersBloc>(context)
        .add(BuscarUsuariosDaEmpresa(cnpj: widget.empresa.cnpj));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Usuários cadastrados'),
      content: BlocBuilder<EmpresaUsersBloc, EmpresaUsersState>(
        builder: (context, state) {
          if (state is EmpresaUsersInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is EmpresaUsersLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is EmpresaUsersError) {
            return const Center(
              child: Text('Erro ao buscar usuários, tente novamente.'),
            );
          } else if (state is EmpresaUsersEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Nenhum usuário está vinculado a esta empresa.'),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AddEmpresaUser(cnpj: widget.empresa.cnpj);
                        });
                  },
                  child: const Text(
                    'Adicionar usuário',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          } else if (state is EmpresaUsersLoaded) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AddEmpresaUser(cnpj: widget.empresa.cnpj);
                            },
                          );
                        },
                        child: const Text('Adicionar usuário'),
                      )
                    ],
                  ),
                  ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text(state.users[index].nome),
                                  Text(state.users[index].email),
                                  Text(state.users[index].cargo),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Confirmação'),
                                        content: const Text(
                                            'Deseja realmente excluir este usuário?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              try {
                                                await empresaServices
                                                    .deleteUsuarioEmpresa(
                                                        state.users[index].cnpj,
                                                        state.users[index].uid);
                                                if (context.mounted) {
                                                  mensagemDeSucesso
                                                      .showSuccessSnackbar(
                                                          context,
                                                          'Usuário excluído com sucesso.');
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).pop();
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  Navigator.of(context).pop();
                                                  tratamentoDeErros
                                                      .showErrorSnackbar(
                                                          context,
                                                          'Erro ao excluir usuário, tente novamente.');
                                                }
                                              }
                                            },
                                            child: const Text('Excluir'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Erro ao buscar usuários, tente novamente.'),
            );
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Fechar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}