import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/v4.dart';
import '../../../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../screens/add_cargos.dart';
import '../../bloc/add_user_bloc/bloc/add_user_bloc.dart';
import '../../bloc/add_user_bloc/bloc/add_user_event.dart';
import '../../bloc/add_user_bloc/bloc/add_user_state.dart';
import '../../bloc/users_list_bloc/users_list_bloc.dart';
import '../../bloc/users_list_bloc/users_list_event.dart';

class FormAddUser extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const FormAddUser({super.key, required this.formKey});

  @override
  State<FormAddUser> createState() => _FormAddUserState();
}

class _FormAddUserState extends State<FormAddUser> {
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  final AddUserBloc registerBloc = AddUserBloc();
  String? selectedOption;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  String pass = const UuidV4().generate();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _updateButtonState() async {
    bool nameField = nameController.text.isNotEmpty;
    bool emailField = emailController.text.isNotEmpty;
    bool selectedOptionField = selectedOption != null;

    setState(() {
      if (nameField && emailField && selectedOptionField) {
        _isButtonEnabled = true;
      } else {
        _isButtonEnabled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddUserBloc, AddUserState>(
      bloc: registerBloc,
      listener: (context, state) async {
        if (state is RegisterUserSuccess) {
          nameController.clear();
          emailController.clear();
          passwordController.clear();
          if (context.mounted) {
            mensagemDeSucesso.showSuccessSnackbar(
                context, 'Conta criada com sucesso.');
          }
          context.read<UsersListBloc>().add(FetchUsersList());
          //showRegistrationSuccessModal(context, state.uid);
        }
        if (state is RegisterUserFailure) {
          tratamentoDeErros.showErrorSnackbar(context, state.error);
        }
      },
      builder: (context, state) {
        return Form(
          key: widget.formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: nameController,
                onChanged: (value) {
                  _updateButtonState();
                },
                keyboardType: TextInputType.name,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(30),
                  FilteringTextInputFormatter.allow(
                    RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
                  ),
                ],
                //style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu nome.';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
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
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                onChanged: (value) {
                  _updateButtonState();
                },
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(50),
                ],
                //style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email.';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.email,
                    color: Colors.grey,
                  ),
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: 'Administrador',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                        _updateButtonState();
                      });
                    },
                  ),
                  const Text('Administrador'),
                  const SizedBox(width: 10),
                  Radio<String>(
                    value: 'Operador',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value;
                        _updateButtonState();
                      });
                    },
                  ),
                  const Text('Operador'),
                ],
              ),
              const SizedBox(height: 20),
              state is RegisterUserLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _isButtonEnabled
                          ? () async {
                              if (widget.formKey.currentState!.validate()) {
                                registerBloc.add(
                                  RegisterUserEvent(
                                    nameController.text.trim(),
                                    emailController.text.trim(),
                                    pass,
                                    cargo: selectedOption,
                                  ),
                                );
                              }
                            }
                          : null,
                      child: const Text('Cadastrar'),
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _showModal(BuildContext context, String? uid) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.6,
      width: width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      context.read<AddUserBloc>().add(ResetAddUser());
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              const Text('Adicionar cargo?'),
              SizedBox(height: height * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text('Não'),
                    onPressed: () {
                      context.read<AddUserBloc>().add(ResetAddUser());
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: width * 0.035),
                  ElevatedButton(
                    child: const Text('Sim'),
                    onPressed: () {
                      context.read<AddUserBloc>().add(ResetAddUser());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCargos(
                            uid: uid,
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showRegistrationSuccessModal(BuildContext context, String? uid) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _showModal(context, uid);
      },
    );
  }
}
