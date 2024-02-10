import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/veiculos_list/events.dart';
import '../bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_bloc.dart';
import '../bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_event.dart';
import '../bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_state.dart';
import '../bloc/veiculos_list/states.dart';
import '../bloc/veiculos_list/veiculo_bloc.dart';
import 'add_veiculo.dart';
import 'details_screen.dart';

class VeiculosScreen extends StatelessWidget {
  VeiculosScreen({
    super.key,
  });

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    context.read<RespostaSolicitacaoVeiculoBloc>().add(
          FetchRespostaSolicitacaoVeiculo(
            firebaseAuth.currentUser!.uid,
          ),
        );

    final uid = firebaseAuth.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Veículos'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddVeiculoScreen()));
              },
              icon: const Icon(
                Icons.add,
                color: Colors.blue,
              ))
        ],
      ),
      body: BlocBuilder<RespostaSolicitacaoVeiculoBloc,
          RespostaSolicitacaoVeiculoState>(
        builder: (context, respostaState) {
          return BlocProvider(
            create: (context) => VeiculoBloc()..add(FetchVeiculos(uid)),
            child: BlocBuilder<VeiculoBloc, VeiculoState>(
              builder: (context, state) {
                if (state is VeiculoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is VeiculoLoaded &&
                    respostaState is RespostaSolicitacaoVeiculoLoaded) {
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.veiculos.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.time_to_leave),
                              title: Text(state.veiculos[index].modelo),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VeiculoDetailScreen(
                                        veiculo: state.veiculos[index]),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      Container(
                        color: Colors.grey,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Text(
                                'Você possui uma pendência.',
                                softWrap:
                                    true, // Isso permite a quebra de linha
                                overflow: TextOverflow
                                    .ellipsis, // Isso adiciona "..." se o texto for muito longo
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            TextButton(
                              onPressed: () {
                                //Navigator.pushNamed(context, '/respostasolicitacao');
                              },
                              child: const Text('Ver.'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (state is VeiculoNotFound) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        const Text('Nenhum veículo cadastrado!'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/addveiculo');
                          },
                          child: const Text('Cadastrar Veículo'),
                        ),
                        const Spacer(),
                        respostaState is RespostaSolicitacaoVeiculoLoaded
                            ? Container(
                                color: Colors.grey[300],
                                height: 50,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Você possui uma pendência.',
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddVeiculoScreen()));
                                        },
                                        child: const Text('Ver'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  );
                } else if (state is VeiculoError) {
                  return Center(child: Text('Erro: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
