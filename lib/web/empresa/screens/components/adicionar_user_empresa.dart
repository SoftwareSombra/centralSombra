import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra/widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import 'package:sombra/widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import 'package:sombra/widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';
import 'package:tuple/tuple.dart';
import '../../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../../autenticacao/services/user_services.dart';
import '../../../admin/services/admin_services.dart';
import '../../../admin/usuarios/bloc/add_user_bloc/bloc/add_user_bloc.dart';

class AddEmpresaUser extends StatefulWidget {
  final String cnpj;
  const AddEmpresaUser({super.key, required this.cnpj});

  @override
  State<AddEmpresaUser> createState() => _AddEmpresaUserState();
}

class _AddEmpresaUserState extends State<AddEmpresaUser> {
  final UserServices userServices = UserServices();
  final TextEditingController senha = TextEditingController(text: '1234567');
  final TextEditingController nome = TextEditingController();
  final TextEditingController email = TextEditingController();
  bool administradorIsChecked = false;
  bool operadorIsChecked = false;
  String cargo = '';
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  final AddUserBloc registerBloc = AddUserBloc();
  final AdminServices adminServices = AdminServices();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return AlertDialog(
      title: const Text('Adicionar usuário'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  activeColor: Colors.transparent,
                  checkColor: Colors.green,
                  value: administradorIsChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      administradorIsChecked = value!;
                      cargo = 'administrador';
                    });
                  },
                ),
                const Text(
                  'Administrador',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(width: 10),
                Checkbox(
                  value: operadorIsChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      operadorIsChecked = value!;
                      cargo = 'operador';
                    });
                  },
                ),
                const Text(
                  'Operador',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 90),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: width * 0.001, vertical: 0),
              child: SizedBox(
                width: width * 0.33,
                child: TextFormField(
                  cursorHeight: 14,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 3) {
                        return 'Nome muito curto';
                      }
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    label: Text('Nome'),
                    labelStyle: TextStyle(fontSize: 13),
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
                  controller: nome,
                  onChanged: (value) {
                    // Update the button state
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 50,
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 90),
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: width * 0.001, vertical: 0),
              child: SizedBox(
                width: width * 0.33,
                child: TextFormField(
                  cursorHeight: 14,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (userServices.isEmailValid(email.text) == false) {
                        return 'Email inválido';
                      }
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    label: Text('Email'),
                    labelStyle: TextStyle(fontSize: 13),
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
                  controller: email,
                  onChanged: (value) {
                    // Update the button state
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
            builder: (context, state) {
              if (state is ElevatedButtonBlocLoading) {
                return const CircularProgressIndicator();
              } else {
                return ElevatedButton(
                  onPressed: () async {
                    context.read<ElevatedButtonBloc>().add(
                          ElevatedButtonPressed(),
                        );
                    Tuple2 isRegisterSuccessful =
                        await userServices.performRegistration3(
                            nome.text, email.text, senha.text);
                    debugPrint(isRegisterSuccessful.item2);
                    Future.delayed(const Duration(seconds: 1));
                    if (isRegisterSuccessful.item1 == true) {
                      try {
                        debugPrint(cargo);
                        if (cargo == 'administrador') {
                          debugPrint(
                              'uid do adm: ${isRegisterSuccessful.item2}');
                          final addAdmin = await adminServices.addAdminCliente(
                              isRegisterSuccessful.item2,
                              widget.cnpj.toString(),
                              nome: nome.text.trim());
                          debugPrint(addAdmin.toString());
                        } else if (cargo == 'operador') {}
                        if (context.mounted) {
                          context.read<ElevatedButtonBloc>().add(
                                ElevatedButtonActionCompleted(),
                              );
                          mensagemDeSucesso.showSuccessSnackbar(
                              context, 'Usuário adicionado com sucesso');
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          context.read<ElevatedButtonBloc>().add(
                                ElevatedButtonActionCompleted(),
                              );
                          _showErrorModal(context, ' Erro: $e');
                        }
                      }
                    } else if (context.mounted) {
                      context.read<ElevatedButtonBloc>().add(
                            ElevatedButtonActionCompleted(),
                          );
                      _showErrorModal(
                          context, ' Erro: ${isRegisterSuccessful.item2}');
                    }
                  },
                  child: const Text(
                    'Adicionar',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  //dialogo de erro ao adicionar usuario
  void _showErrorModal(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro ao adicionar usuário'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
