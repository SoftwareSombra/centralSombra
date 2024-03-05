import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../../../../missao/bloc/missao_solicitacao_card/missao_solicitacao_card_bloc.dart';
import '../../../../../missao/bloc/missao_solicitacao_card/missao_solicitacao_card_event.dart';
import '../../../../../missao/bloc/missao_solicitacao_card/missao_solicitacao_card_state.dart';
import '../../../../../missao/model/missao_solicitada.dart';
import '../../../../../missao/screens/criar_missao_screen.dart';

class SolicitacaoMissaoCard extends StatelessWidget {
  final MissaoSolicitada missaoSolicitada;
  const SolicitacaoMissaoCard({super.key, required this.missaoSolicitada});

  static const canvasColor = Color.fromARGB(255, 0, 15, 42);

  void mostrarListaAgentes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListaAgentesModal(
          missaoSolicitada: missaoSolicitada,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<MissaoSolicitacaoCardBloc>().add(
          BuscarMissao(
            missaoId: missaoSolicitada.missaoId,
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: BlocBuilder<MissaoSolicitacaoCardBloc, MissaoSolicitacaoCardState>(
        builder: (context, state) {
          if (state is MissaoSolicitacaoCardLoading) {
            return Card(
              elevation: 1,
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //texts
                    Text(missaoSolicitada.tipo),
                    const SizedBox(
                      height: 30,
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    )
                  ],
                ),
              ),
            );
          } else if (state is MissaoSolicitacaoCardError) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //texts
                    Text(missaoSolicitada.tipo),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                      ],
                    )
                  ],
                ),
              ),
            );
          } else if (state is MissaoJaSolicitadaCard) {
            return
                // Card(
                //   elevation: 4,
                //   margin: const EdgeInsets.all(8.0),
                //   child: Padding(
                //     padding: const EdgeInsets.all(20.0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       //mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         //texts
                //         Text(missaoSolicitada.tipo),
                //         const SizedBox(
                //           height: 30,
                //         ),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             ElevatedButton(
                //               onPressed: () {
                //                 debugPrint('exibindo lista...');
                //                 mostrarListaAgentes(context);
                //               },
                //               child: const Text('Selecionar agente'),
                //             ),
                //           ],
                //         )
                //       ],
                //     ),
                //   ),
                // );
                const SizedBox.shrink();
          }
          return Container(
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
                        'MISSÃO SOLICITADA:',
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
                    ),
                  ),
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
                              maxLines: 2,
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
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.green),
                          minimumSize: MaterialStatePropertyAll(
                            Size(30, 35),
                          ),
                          maximumSize: MaterialStatePropertyAll(
                            Size(80, 50),
                          ),
                          padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await Navigator.push(
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
                        child: const Text('Criar'),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                          minimumSize: MaterialStatePropertyAll(
                            Size(30, 35),
                          ),
                          maximumSize: MaterialStatePropertyAll(
                            Size(80, 50),
                          ),
                          padding: MaterialStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                          ),
                        ),
                        onPressed: () {
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
                        child: const Text('Rejeitar'),
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
            ),
          );
        },
      ),
    );
  }
}
