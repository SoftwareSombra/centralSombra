import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/home/nav_bar/bloc_events.dart';
import 'package:sombra_testes/missao/bloc/agente/agente_bloc.dart';
import 'package:sombra_testes/missao/bloc/agente/states.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import '../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../missao/bloc/agente/events.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_state.dart';
import '../../bloc/missao_bloc/events.dart';
import '../../bloc/missao_bloc/get_missao_bloc.dart';
import '../../bloc/missao_bloc/states.dart';
import '../../nav_bar/bloc_nav.dart';

class MissaoHome extends StatelessWidget {
  MissaoHome({super.key});

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final uid = firebaseAuth.currentUser!.uid;
    final nome = firebaseAuth.currentUser!.displayName;
    MissaoServices missaoServices = MissaoServices();
    context.read<GetMissaoBloc>().add(LoadMissao(uid));
    TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
    //final navBloc = context.read<NavigationBloc>();

    return BlocBuilder<GetMissaoBloc, GetMissaoState>(
      builder: (context, missaoState) {
        return BlocBuilder<AgentMissionBloc, AgentState>(
          builder: (context, agentState) {
            if (agentState is ReportPending) {
              return grayContainer(
                  const Center(
                    child: Text('Você possui um relatório pendente'),
                  ),
                  context);
            }
            if (missaoState is GetMissaoLoading) {
              return grayContainer(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                context,
              );
            } else if (missaoState is GetMissaoLoaded) {
              return Column(
                children: [
                  Card(
                    elevation: 5,
                    child: Container(
                      height: 250,
                      width: MediaQuery.of(context).size.width - 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Missão: ${missaoState.missao.tipo}',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Center(
                              child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Você recebeu um chamado',
                                    style: TextStyle(fontSize: 17),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  // missionBloc.add(
                                  //   StartLocationTracking(
                                  //       MissionType.type1, state.missao.missaoId),
                                  // );
                                  context.read<GetMissaoBloc>().add(
                                        AceitarChamado(
                                            missaoState.missao.missaoId, nome!),
                                      );
                                  //navBloc.add(ChangeToMissao());
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.green),
                                ),
                                child: const Text('Aceitar missão'),
                              ),
                              const SizedBox(
                                height: 0,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => ));
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Aviso'),
                                        content: const SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text('Em desenvolvimento'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Ok'),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                child: const Text('Recusar missão'),
                              ),
                            ],
                          ))
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (missaoState is EmMissao) {
              return grayContainer(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Você está em uma missão',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
                        builder: (context, buttonState) {
                          if (buttonState is ElevatedButtonBlocLoading) {
                            return const CircularProgressIndicator();
                          } else {
                            return ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                              ),
                              onPressed: () async {
                                context
                                    .read<ElevatedButtonBloc>()
                                    .add(ElevatedButtonPressed());
                                context.read<NavigationBloc>().add(
                                      ChangeToMissao(),
                                    );
                                if (context.mounted) {
                                  context
                                      .read<ElevatedButtonBloc>()
                                      .add(ElevatedButtonActionCompleted());
                                }
                              },
                              child: const Text('Ver missão'),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  context);
            } else if (missaoState is SemMissao) {
              return grayContainer(
                  const Center(
                    child: Text(
                      'Sem missões no momento',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  context);
            } else if (missaoState is GetMissaoError) {
              return grayContainer(
                  Center(
                    child: Text('Erro: ${missaoState.error}'),
                  ),
                  context);
            } else if (missaoState is AceitarChamadoLoading) {
              return grayContainer(
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  context);
            } else if (missaoState is AceitarChamadoLoaded) {
              return grayContainer(
                  const Center(
                    child: Text(
                      'Aguardando retorno da central',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  context);
            } else if (missaoState is ConfirmacaoMissaoSuccess) {
              return grayContainer(
                  Center(
                    child: Text(missaoState.message),
                  ),
                  context);
            } else if (missaoState is ConfirmacaoMissaoFailed) {
              return grayContainer(
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(missaoState.message),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await missaoServices.excluirResposta(uid);
                            Future.delayed(
                              const Duration(seconds: 1),
                            );
                            if (context.mounted) {
                              context
                                  .read<GetMissaoBloc>()
                                  .add(LoadMissao(uid));
                            }
                          },
                          child: const Text('Ok'),
                        )
                      ],
                    ),
                  ),
                  context);
            } else if (missaoState is ChamadoError) {
              return grayContainer(
                  Center(
                    child: Text('Erro: ${missaoState.message}'),
                  ),
                  context);
            } else if (missaoState is ChamadoError) {
              return grayContainer(
                  Center(
                    child: Text('Erro: ${missaoState.message}'),
                  ),
                  context);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget grayContainer(Widget child, BuildContext context) {
    return Card(
      //color: Colors.grey[800],
      elevation: 5,
      child: SizedBox(
        height: 250,
        width: MediaQuery.of(context).size.width - 50,
        child: child,
      ),
    );
  }
}
