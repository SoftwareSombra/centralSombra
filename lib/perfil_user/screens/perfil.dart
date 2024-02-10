import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/conta_bancaria/screens/add_conta.dart';
import 'package:sombra_testes/perfil_user/bloc/conta_bancaria/conta_bancaria_bloc.dart';
import 'package:sombra_testes/perfil_user/bloc/conta_bancaria/states.dart';
import 'package:validadores/validadores.dart';
import '../../agente/bloc/get_user/agente_bloc.dart';
import '../../agente/bloc/get_user/events.dart';
import '../../agente/bloc/get_user/states.dart';
import '../bloc/conta_bancaria/events.dart';
import '../bloc/foto/user/states.dart';
import '../bloc/foto/user/user_foto_bloc.dart';
import '../bloc/nome/get_name_bloc.dart';
import '../bloc/nome/get_name_states.dart';
import 'add_infos.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;
    context.read<AgenteBloc>().add(FetchAgenteInfo(uid!));
    context.read<ContaBancariaBloc>().add(FetchContaBancariaInfo(uid));

    return Scaffold(
      appBar: AppBar(
        actions: [
          // TextButton(
          //   onPressed: () async {
          //     final result =
          //         await Navigator.pushNamed(context, '/editarperfil');
          //     if (result != null && result is bool && result) {
          //       if (context.mounted) {
          //         context.read<UserBloc>().add(FetchUserName(uid!));
          //       }
          //     }
          //   },
          //   child: const Text(
          //     "Editar perfil",
          //     style: TextStyle(
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocBuilder<UserFotoBloc, UserFotoState>(
                      builder: (context, state) {
                        if (state is UserFotoLoading) {
                          return const CircularProgressIndicator();
                        } else if (state is UserFotoLoaded ||
                            state is UserFotoUpdated) {
                          return CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(
                                state is UserFotoLoaded
                                    ? state.foto
                                    : (state as UserFotoUpdated).foto),
                          );
                        } else if (state is UserFotoError) {
                          return const CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage(
                                'assets/images/fotoDePerfilNull.jpg'),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
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
              const SizedBox(
                height: 20,
              ),
              BlocBuilder<AgenteBloc, AgenteState>(
                builder: (context, state) {
                  if (state is AgenteLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is EmAnalise) {
                    return const Center(
                      child: Text('Dados em análise, aguarde'),
                    );
                  } else if (state is AgenteLoaded) {
                    return Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Seus dados pessoais:",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              enabled: false,
                              initialValue: state.agente.endereco,
                              decoration: const InputDecoration(
                                labelText: "Endereço",
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(
                                height: 10), // Espaço entre os campos
                            TextFormField(
                              enabled: false,
                              initialValue: state.agente.cep,
                              decoration: const InputDecoration(
                                labelText: "CEP",
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              enabled: false,
                              initialValue: state.agente.celular,
                              decoration: const InputDecoration(
                                labelText: "Celular",
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              enabled: false,
                              initialValue: state.agente.rg,
                              decoration: const InputDecoration(
                                labelText: "RG",
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              validator: (value) {
                                // Aqui entram as validações
                                return Validador()
                                    .add(Validar.CPF, msg: 'CPF Inválido')
                                    .add(Validar.OBRIGATORIO,
                                        msg: 'Campo obrigatório')
                                    .minLength(11)
                                    .maxLength(11)
                                    .valido(value, clearNoNumber: true);
                              },
                              enabled: false,
                              initialValue: state.agente.cpf,
                              decoration: const InputDecoration(
                                labelText: "CPF",
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (state is AgenteInfosRejected) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Alguns ou todos os dados foram rejeitados, reenvie.",
                            style: TextStyle(fontSize: 17),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddInfosScreen()));
                            },
                            child: const Text('Reenviar'),
                          )
                        ],
                      ),
                    );
                  } else if (state is AgenteNotExist) {
                    return Column(
                      children: [
                        const Text(
                          "Você não está cadastrado.",
                          style: TextStyle(fontSize: 17),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddInfosScreen()));
                          },
                          child: const Text('Cadastrar'),
                        )
                      ],
                    );
                  } else if (state is AgenteError) {
                    return Text("Erro: ${state.message}");
                  }
                  return const SizedBox.shrink();
                },
              ),
              BlocBuilder<ContaBancariaBloc, ContaBancariaState>(
                builder: (context, state) {
                  if (state is ContaBancariaLoading) {
                    return const CircularProgressIndicator();
                  } else if (state is ContaBancariaLoaded) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Sua conta bancária:",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              enabled: false,
                              initialValue: state.contaBancaria.titular,
                              decoration: const InputDecoration(
                                labelText: "Titular",
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(
                                height: 10), // Espaço entre os campos
                            TextFormField(
                              enabled: false,
                              initialValue: state.contaBancaria.agencia,
                              decoration: const InputDecoration(
                                labelText: "Agência",
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              enabled: false,
                              initialValue: state.contaBancaria.chavePix,
                              decoration: const InputDecoration(
                                labelText: "Chave pix",
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (state is ContaBancariaInfosRejected) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "Sua conta bancária ou alguns dados foram rejeitados",
                          style: TextStyle(fontSize: 17),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddContaBancariaScreeen(),
                                ),
                              );
                            }
                          },
                          child: const Text('Cadastrar'),
                        )
                      ],
                    );
                  } else if (state is ContaBancariaNotExist) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "Você não tem conta bancária cadastrada",
                          style: TextStyle(fontSize: 17),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddContaBancariaScreeen()));
                          },
                          child: const Text('Cadastrar'),
                        )
                      ],
                    );
                  } else if (state is ContaBancariaError) {
                    return Text("Erro: ${state.message}");
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
