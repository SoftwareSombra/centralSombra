import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_user_bloc/bloc/add_user_bloc.dart';
import '../bloc/add_user_bloc/bloc/add_user_event.dart';
import '../bloc/add_user_bloc/bloc/add_user_state.dart';
import 'components/form.dart';

class AddUser extends StatelessWidget {
  AddUser({super.key});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'Cadastro',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        body: BlocConsumer<AddUserBloc, AddUserState>(
          listener: (context, state) {
            if (state is RegisterUserSuccess) {
              debugPrint('chegou aqui, pos sucesso');
              _showModal(context);
            }
          },
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FormAddUser(
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      formKey: formKey,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // modal
  void _showModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 200,
            color: Colors.amber,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Modal BottomSheet'),
                  ElevatedButton(
                    child: const Text('Close BottomSheet'),
                    onPressed: () {
                      context.read<AddUserBloc>().add(ResetAddUser());
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }
}
