import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../autenticacao/services/user_services.dart';
import '../bloc/foto/user/states.dart';
import '../bloc/foto/user/user_foto_bloc.dart';
import '../bloc/nome/get_name_bloc.dart';
import '../bloc/nome/get_name_events.dart';
import '../bloc/nome/get_name_states.dart';
import 'components/modal_name_edit.dart';

class EditarPerfilScreen extends StatelessWidget {
  const EditarPerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;
    context.read<UserBloc>().add(FetchUserName(uid!));
    bool atualizado = false;
    UserServices userServices = UserServices();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, atualizado);
          },
        ),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserNameUpdated || state is UserFotoUpdated) {
            atualizado = true;
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              BlocBuilder<UserFotoBloc, UserFotoState>(
                builder: (context, state) {
                  if (state is UserFotoLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is UserFotoLoaded ||
                      state is UserFotoUpdated) {
                    return CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(state is UserFotoLoaded
                          ? state.foto
                          : (state as UserFotoUpdated).foto),
                    );
                  } else if (state is UserFotoError) {
                    return const CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          AssetImage('assets/images/fotoDePerfilNull.jpg'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () async {
                      final foto = await userServices.selectImage();
                      if (foto != null) {
                        Uint8List bytes = await File(foto.path!).readAsBytes();
                        if (context.mounted) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmação'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Você quer usar esta foto?'),
                                    Image.memory(bytes),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await userServices.updateUserPhoto(
                                          context, uid, bytes);
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    child: const Text('Confirmar'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    child: const Text('Trocar foto'),
                  ),
                ],
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
                      } else if (state is UserNameLoaded ||
                          state is UserNameUpdated) {
                        return Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Nome: ',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .black // ou a cor que você quiser
                                        ),
                                  ),
                                  TextSpan(
                                    text: state is UserNameLoaded
                                        ? state.name
                                        : (state as UserNameUpdated).newName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return MySquareModal();
                                  },
                                );
                              },
                              child: const Icon(Icons.edit),
                            )
                          ],
                        );
                      } else if (state is UserNameError) {
                        return Text(state.message);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
