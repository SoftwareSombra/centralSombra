import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/perfil_user/bloc/foto/user/states.dart';
import 'package:sombra_testes/perfil_user/bloc/foto/user/user_foto_bloc.dart';
import '../../../perfil_user/bloc/nome/get_name_bloc.dart';
import '../../../perfil_user/bloc/nome/get_name_states.dart';

class Cabecalho extends StatelessWidget {
  const Cabecalho({super.key});

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    // final user = firebaseAuth.currentUser;
    // final uid = user?.uid;
    //context.read<UserBloc>().add(FetchUserName(uid!));
    //context.read<UserFotoBloc>().add(FetchUserFoto(uid));

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: BlocBuilder<UserFotoBloc, UserFotoState>(
              builder: (context, state) {
                if (state is UserFotoLoading) {
                  return const CircularProgressIndicator();
                } else if (state is UserFotoLoaded ||
                    state is UserFotoUpdated) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(state is UserFotoLoaded
                            ? state.foto
                            : (state as UserFotoUpdated).foto),
                      ),
                    ],
                  );
                } else if (state is UserFotoError) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                    ],
                  );
                }
                return const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/fotoDePerfilNull.jpg'),
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 3,
              ),
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserNameLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is UserNameLoaded) {
                    return Column(
                      children: [
                        const Text(
                          'Seja bem vindo',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          state.name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    );
                  } else if (state is UserNameError) {
                    return Text(state.message);
                  }
                  return const SizedBox
                      .shrink(); // Pode ser substituído por um widget padrão ou vazio
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
