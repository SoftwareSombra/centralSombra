import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../../perfil_user/screens/perfil.dart';
import '../bloc/veiculos_list/events.dart';
import '../bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_bloc.dart';
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
    final uid = firebaseAuth.currentUser!.uid;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 14, 14, 14),
      appBar: AppBar(
        title: const Text(
          'MEUS VEÍCULOS',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AddVeiculoScreen(),
                  withNavBar: false,
                );
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => AddVeiculoScreen()));
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
          return BlocBuilder<VeiculoBloc, VeiculoState>(
            builder: (context, state) {
              if (state is VeiculoLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is VeiculoError) {
                return Center(child: Text('Erro: ${state.message}'));
              }
              if (state is VeiculoNotFound) {
                debugPrint('state: ${state.toString()}');
                debugPrint('respostaState: ${respostaState.toString()}');
                if (respostaState is RespostaSolicitacaoVeiculoLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (respostaState
                    is RespostaSolicitacaoVeiculoAguardandoAprovacao) {
                  debugPrint('passou aqui 1');
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 50,
                            color: Colors.yellow,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Os dados do veículo estão sendo analisados, aguarde.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                } else if (respostaState is RespostaSolicitacaoVeiculoLoaded) {
                  debugPrint('passou aqui 2');
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            size: 50,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Um ou mais dados foram rejeitados, corrija e envie novamente.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 50),
                        child: PanaraButton(
                          buttonTextColor: Colors.white,
                          text: 'Reenviar',
                          onTap: () {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: AddVeiculoScreen(),
                              withNavBar: false,
                            );
                          },
                          bgColor: Colors.blue,
                          isOutlined: false,
                        ),
                      ),
                    ],
                  );
                } else if (respostaState is RespostaSolicitacaoNotFound) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PanaraInfoDialogWidget(
                          title: "Veículos",
                          message:
                              "Você não possui veículo cadastrado, cadastre",
                          buttonText: "Cadastrar",
                          onTapDismiss: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => AddVeiculoScreen()));
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: AddVeiculoScreen(),
                              withNavBar: false,
                            );
                          },
                          panaraDialogType: PanaraDialogType.normal,
                          noImage: false,
                          imagePath: 'assets/images/car-pana.png',
                          textColor: Colors.white,
                          containerColor: Colors.grey[800],
                          buttonTextColor: Colors.white,
                        ),
                      ],
                    ),
                  );
                } else if (respostaState is RespostaSolicitacaoVeiculoError) {
                  return const Center(
                    child: Text('Erro, recarregue a página.'),
                  );
                }
              }
              if (state is VeiculoLoaded) {
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
                    respostaState
                            is RespostaSolicitacaoVeiculoAguardandoAprovacao
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 50,
                                    color: Colors.yellow,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Os dados do veículo estão sendo analisados, aguarde.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    respostaState is RespostaSolicitacaoVeiculoLoaded
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error,
                                    size: 50,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  "Um ou mais dados foram rejeitados, corrija e envie novamente.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 50),
                                child: PanaraButton(
                                  buttonTextColor: Colors.white,
                                  text: 'Reenviar',
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddVeiculoScreen()));
                                  },
                                  bgColor: Colors.blue,
                                  isOutlined: false,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ],
                );
              } else if (state is VeiculoError) {
                return Center(child: Text('Erro: ${state.message}'));
              } else {
                debugPrint('state: ${state.toString()}');
                debugPrint('respostaState: ${respostaState.toString()}');
                return const SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }
}
