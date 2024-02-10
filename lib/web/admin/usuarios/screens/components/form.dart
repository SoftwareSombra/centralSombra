import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import '../../../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import '../../../screens/add_cargos.dart';
import '../../bloc/add_user_bloc/bloc/add_user_bloc.dart';
import '../../bloc/add_user_bloc/bloc/add_user_event.dart';
import '../../bloc/add_user_bloc/bloc/add_user_state.dart';
import '../../bloc/users_list_bloc/users_list_bloc.dart';
import '../../bloc/users_list_bloc/users_list_event.dart';

class FormAddUser extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  FormAddUser(
      {super.key,
      required this.nameController,
      required this.emailController,
      required this.passwordController,
      required this.formKey});

  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  final AddUserBloc registerBloc = AddUserBloc();

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
          showRegistrationSuccessModal(context, state.uid);
        }
        if (state is RegisterUserFailure) {
          tratamentoDeErros.showErrorSnackbar(context, state.error);
        }
      },
      builder: (context, state) {
        return Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
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
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
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
              const SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha.';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  labelStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(
                    Icons.lock,
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
              state is RegisterUserLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          registerBloc.add(RegisterUserEvent(
                            nameController.text,
                            emailController.text,
                            passwordController.text,
                          ));
                        }
                      },
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
              const SizedBox(height: 5,),
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
