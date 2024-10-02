import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../../../../chat/screens/missao_cliente.dart';
import '../../../../../chat/services/chat_services.dart';
import '../../../../../missao/bloc/missoes_pendentes/missoes_pendentes_bloc.dart';
import '../../../../../missao/bloc/missoes_pendentes/missoes_pendentes_event.dart';
import '../../../../../missao/model/missao_solicitada.dart';
import '../../../../../missao/screens/criar_missao_screen.dart';
import '../../../../../missao/services/missao_services.dart';
import '../../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import '../../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import '../../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';

class MissaoPendenteCard extends StatelessWidget {
  final MissaoSolicitada missaoSolicitada;
  final BuildContext initialContext;
  MissaoPendenteCard(
      {super.key,
      required this.missaoSolicitada,
      required this.initialContext});

  static const canvasColor = Color.fromARGB(255, 0, 15, 42);
  final ChatServices chatServices = ChatServices();
  final MissaoServices missaoServices = MissaoServices();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: 310,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              canvasColor.withOpacity(0.3),
              canvasColor.withOpacity(0.33),
              canvasColor.withOpacity(0.35),
              canvasColor.withOpacity(0.38),
              canvasColor.withOpacity(0.4),
              canvasColor.withOpacity(0.43),
              canvasColor.withOpacity(0.45),
              canvasColor.withOpacity(0.48),
              canvasColor.withOpacity(0.5),
              canvasColor.withOpacity(0.53),
              canvasColor.withOpacity(0.55),
              canvasColor.withOpacity(0.58),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue.withOpacity(0.1),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: canvasColor.withOpacity(0.1),
              blurRadius: 10,
            )
          ],
          //color: Colors.blue,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MISSÃO:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  //icone de expandir
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Bootstrap.plus_circle,
                      size: 16,
                    ),
                    //padding: const EdgeInsets.all(0),
                  ),
                ],
              ),
              // const SizedBox(
              //   height: 3,
              // ),
              Text(
                  'Em: ${DateFormat('dd/MM/yyyy').format(missaoSolicitada.timestamp)}'
                  ' às ${DateFormat('kk:mm').format(missaoSolicitada.timestamp)}h',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  )),
              Text(
                'Tipo: ${missaoSolicitada.tipo}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              //texts
              //Text('Empresa: ${missaoSolicitada.nomeDaEmpresa}'),
              Row(
                children: [
                  const Icon(
                    Icons.business,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Empresa:',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w300),
                      ),
                      Text(
                        missaoSolicitada.nomeDaEmpresa,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              // Text('Placa cavalo: ${missaoSolicitada.placaCavalo}'),
              // const SizedBox(
              //   height: 3,
              // ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.blue,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Local:',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w300),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(
                          missaoSolicitada.local,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder(
                    stream: MissaoServices().verificarSeAlgumAgenteAceitou(
                        missaoSolicitada.missaoId),
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      return Stack(
                        children: [
                          IconButton(
                            style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.blue),
                            ),
                            onPressed: () {
                              mostrarListaAgentes(context, width);
                            },
                            icon: const Icon(Icons.person_outlined),
                          ),
                          snapshot.data != null
                              ? snapshot.data!
                                  ? Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.red, // Cor da bolinha
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors
                                                .white, // Cor da borda da bolinha
                                            width: 1, // Largura da borda
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink()
                              : const SizedBox.shrink(),
                        ],
                      );
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.green),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapAddMissao(
                            cnpj: missaoSolicitada.cnpj,
                            nomeDaEmpresa: missaoSolicitada.nomeDaEmpresa,
                            placaCavalo: missaoSolicitada.placaCavalo,
                            placaCarreta: missaoSolicitada.placaCarreta,
                            motorista: missaoSolicitada.motorista,
                            corVeiculo: missaoSolicitada.corVeiculo,
                            observacao: missaoSolicitada.observacao,
                            latitude: missaoSolicitada.latitude,
                            longitude: missaoSolicitada.longitude,
                            local: missaoSolicitada.local,
                            tipo: missaoSolicitada.tipo,
                            missaoId: missaoSolicitada.missaoId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_outlined),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  IconButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.red),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Atenção'),
                            content: const Column(
                              children: [
                                Text(
                                    'Excluir missão? Esta ação não poderá ser desfeita!')
                              ],
                            ),
                            actions: <Widget>[
                              BlocBuilder<ElevatedButtonBloc,
                                  ElevatedButtonBlocState>(
                                builder: (context, state) {
                                  if (state is ElevatedButtonBlocLoading) {
                                    return const CircularProgressIndicator();
                                  }
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: const Text('Excluir'),
                                        onPressed: () async {
                                          context
                                              .read<ElevatedButtonBloc>()
                                              .add(ElevatedButtonPressed());
                                          try {
                                            await missaoServices
                                                .rejeitarSolicitacaoPendente(
                                                    missaoSolicitada.missaoId,
                                                    missaoSolicitada.cnpj,
                                                    missaoSolicitada.local,
                                                    missaoSolicitada.timestamp);
                                            context
                                                .read<ElevatedButtonBloc>()
                                                .add(ElevatedButtonReset());
                                            BlocProvider.of<
                                                    MissoesPendentesBloc>(context)
                                                .add(BuscarMissoesPendentes());
                                            Navigator.of(context).pop();
                                          } catch (e) {
                                            context
                                                .read<ElevatedButtonBloc>()
                                                .add(ElevatedButtonReset());
                                            debugPrint(
                                                'erro ao excluir missao: ${e.toString()}');
                                            tratamentoDeErros.showErrorSnackbar(
                                                context,
                                                'Erro, tente novamente');
                                          }
                                        },
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Voltar',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              )
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_outlined),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      IconButton(
                        style: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClienteMissaoChatScreen(
                                missaoId: missaoSolicitada.missaoId,
                                agenteUid: missaoSolicitada.uid,
                                agenteNome: missaoSolicitada.nomeDaEmpresa,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.message_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      StreamBuilder<int>(
                        stream: chatServices
                            .getCentralMissionClientConversationsUnreadCount(
                                missaoSolicitada.missaoId),
                        builder: (BuildContext context,
                            AsyncSnapshot<int> snapshot) {
                          if (snapshot.hasData && snapshot.data! > 0) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Text(
                                '(${snapshot.data})',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     ElevatedButton(
                  //       style: const ButtonStyle(
                  //         backgroundColor: MaterialStatePropertyAll(Colors.red),
                  //       ),
                  //       onPressed: () {
                  //         showDialog(
                  //           context: context,
                  //           builder: (BuildContext context) {
                  //             return AlertDialog(
                  //               title: const Text('Aviso'),
                  //               content: const SingleChildScrollView(
                  //                 child: ListBody(
                  //                   children: <Widget>[
                  //                     Text('Em desenvolvimento'),
                  //                   ],
                  //                 ),
                  //               ),
                  //               actions: <Widget>[
                  //                 TextButton(
                  //                   child: const Text('Ok'),
                  //                   onPressed: () async {
                  //                     Navigator.of(context).pop();
                  //                   },
                  //                 ),
                  //               ],
                  //             );
                  //           },
                  //         );
                  //       },
                  //       child: const Text('Rejeitar missão'),
                  //     ),
                  //   ],
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void mostrarListaAgentes(BuildContext context, double width) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              const Text('AGENTES DISPONÍVEIS'),
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close))
            ],
          ),
          content: SizedBox(
            width: width * 0.5,
            child: ListaAgentesModal(
              missaoSolicitada: missaoSolicitada,
            ),
          ),
          actions: const [
            // TextButton(
            //   child: const Text('Fechar'),
            //   onPressed: () async {
            //     Navigator.of(context).pop();
            //   },
            // ),
          ],
        );
      },
    );
  }
}
