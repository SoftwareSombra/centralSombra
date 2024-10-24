import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_user_bloc/bloc/add_user_bloc.dart';
import '../bloc/add_user_bloc/bloc/add_user_event.dart';
import '../bloc/add_user_bloc/bloc/add_user_state.dart';
import 'components/form.dart';

class AddUser extends StatelessWidget {
  AddUser({super.key});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        appBar: AppBar(),
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Preencha os campos abaixo para criar um novo usuário.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: FormAddUser(
                        formKey: formKey,
                      ),
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
