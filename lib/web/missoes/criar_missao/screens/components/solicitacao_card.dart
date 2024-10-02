import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import '../../../../../chat/screens/missao_cliente.dart';
import '../../../../../chat/services/chat_services.dart';
import '../../../../../missao/bloc/missoes_solicitadas/missoes_solicitadas_bloc.dart';
import '../../../../../missao/bloc/missoes_solicitadas/missoes_solicitadas_event.dart';
import '../../../../../missao/model/missao_solicitada.dart';
import '../../../../../missao/screens/criar_missao_screen.dart';
import '../../../../../missao/services/missao_services.dart';
import '../../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import '../../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import '../../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';

class SolicitacaoMissaoCard extends StatefulWidget {
  final MissaoSolicitada missaoSolicitada;
  final BuildContext? initialContext;
  final bool? padding;
  const SolicitacaoMissaoCard(
      {super.key,
      required this.missaoSolicitada,
      this.initialContext,
      this.padding});
  @override
  State<SolicitacaoMissaoCard> createState() => _SolicitacaoMissaoCardState();
}

final ChatServices chatServices = ChatServices();

class _SolicitacaoMissaoCardState extends State<SolicitacaoMissaoCard> {
  static const canvasColor = Color.fromARGB(255, 0, 15, 42);
  final MissaoServices missaoServices = MissaoServices();

  void mostrarListaAgentes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListaAgentesModal(
          missaoSolicitada: widget.missaoSolicitada,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // context.read<MissaoSolicitacaoCardBloc>().add(
    //       BuscarMissao(
    //         missaoId: widget.missaoSolicitada.missaoId,
    //       ),
    //     );
    return Padding(
      padding: widget.padding != null
          ? const EdgeInsets.symmetric(horizontal: 5, vertical: 5)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child:
          //BlocBuilder<MissaoSolicitacaoCardBloc, MissaoSolicitacaoCardState>(
          //   builder: (context, state) {
          //     if (state is MissaoSolicitacaoCardLoading) {
          //return
          //   Container(
          //     height: 310,
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         begin: Alignment.centerLeft,
          //         end: Alignment.centerRight,
          //         colors: [
          //           canvasColor.withOpacity(0.3),
          //           canvasColor.withOpacity(0.33),
          //           canvasColor.withOpacity(0.35),
          //           canvasColor.withOpacity(0.38),
          //           canvasColor.withOpacity(0.4),
          //           canvasColor.withOpacity(0.43),
          //           canvasColor.withOpacity(0.45),
          //           canvasColor.withOpacity(0.48),
          //           canvasColor.withOpacity(0.5),
          //           canvasColor.withOpacity(0.53),
          //           canvasColor.withOpacity(0.55),
          //           canvasColor.withOpacity(0.58),
          //         ],
          //       ),
          //       borderRadius: BorderRadius.circular(10),
          //       border: Border.all(
          //         color: Colors.blue.withOpacity(0.1),
          //         width: 0.5,
          //       ),
          //       boxShadow: [
          //         BoxShadow(
          //           color: canvasColor.withOpacity(0.1),
          //           blurRadius: 10,
          //         )
          //       ],
          //       //color: Colors.blue,
          //     ),
          //     child: const Center(
          //       child: CircularProgressIndicator(),
          //     ),
          //   );
          // }
          // else if (state is MissaoSolicitacaoCardError) {
          //   return Card(
          //     elevation: 4,
          //     margin: const EdgeInsets.all(8.0),
          //     child: Padding(
          //       padding: const EdgeInsets.all(20.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         //mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Text(state.message),
          //             ],
          //           )
          //         ],
          //       ),
          //     ),
          //   );
          // } else if (state is MissaoJaSolicitadaCard) {
          //   return
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
          //       const SizedBox.shrink();
          // }
          //return
          Container(
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
                  widget.padding == null
                      ? MouseRegion(
                          cursor: WidgetStateMouseCursor.clickable,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClienteMissaoChatScreen(
                                  missaoId: widget.missaoSolicitada.missaoId,
                                  agenteUid: widget.missaoSolicitada.cnpj,
                                  agenteNome:
                                      widget.missaoSolicitada.nomeDaEmpresa,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Bootstrap.whatsapp,
                                  size: 16,
                                ),
                                StreamBuilder<int>(
                                  stream: chatServices
                                      .getCentralMissionClientConversationsUnreadCount(
                                          widget.missaoSolicitada.missaoId),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<int> snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data! > 0) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 2.0),
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
                          ),
                          //padding: const EdgeInsets.all(0),
                        )
                      : const SizedBox.shrink(),
                ],
              ),

              // const SizedBox(
              //   height: 3,
              // ),
              widget.padding == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          'Em: ${DateFormat('dd/MM/yyyy').format(widget.missaoSolicitada.timestamp)}'
                          ' às ${DateFormat('kk:mm').format(widget.missaoSolicitada.timestamp)}h',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        SelectableText(
                          'Tipo: ${widget.missaoSolicitada.tipo}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        SelectableText(
                          'Id: ${widget.missaoSolicitada.missaoId}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                height: widget.padding == null ? 20 : 10,
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
                      widget.padding == null
                          ? const Text(
                              'Empresa:',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                            )
                          : const SizedBox.shrink(),
                      Text(
                        widget.missaoSolicitada.nomeDaEmpresa,
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
                      widget.padding == null
                          ? const Text(
                              'Local:',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                            )
                          : const SizedBox.shrink(),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: Text(
                          widget.missaoSolicitada.local,
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
                      backgroundColor: WidgetStatePropertyAll(Colors.green),
                      minimumSize: WidgetStatePropertyAll(
                        Size(30, 35),
                      ),
                      maximumSize: WidgetStatePropertyAll(
                        Size(80, 50),
                      ),
                      padding: WidgetStatePropertyAll(
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
                            cnpj: widget.missaoSolicitada.cnpj,
                            nomeDaEmpresa:
                                widget.missaoSolicitada.nomeDaEmpresa,
                            placaCavalo: widget.missaoSolicitada.placaCavalo,
                            placaCarreta: widget.missaoSolicitada.placaCarreta,
                            motorista: widget.missaoSolicitada.motorista,
                            corVeiculo: widget.missaoSolicitada.corVeiculo,
                            observacao: widget.missaoSolicitada.observacao,
                            latitude: widget.missaoSolicitada.latitude,
                            longitude: widget.missaoSolicitada.longitude,
                            local: widget.missaoSolicitada.local,
                            tipo: widget.missaoSolicitada.tipo,
                            missaoId: widget.missaoSolicitada.missaoId,
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
                      backgroundColor: WidgetStatePropertyAll(Colors.red),
                      minimumSize: WidgetStatePropertyAll(
                        Size(30, 35),
                      ),
                      maximumSize: WidgetStatePropertyAll(
                        Size(80, 50),
                      ),
                      padding: WidgetStatePropertyAll(
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
                            title: const Text('Atenção'),
                            content: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 50),
                              child: const Column(
                                children: [
                                  Text(
                                      'Rejeitar missão? Esta ação não poderá ser desfeita!')
                                ],
                              ),
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
                                        child: const Text('Rejeitar'),
                                        onPressed: () async {
                                          context
                                              .read<ElevatedButtonBloc>()
                                              .add(ElevatedButtonPressed());
                                          try {
                                            await missaoServices
                                                .rejeitarSolicitacao(
                                                    widget.missaoSolicitada
                                                        .missaoId,
                                                    widget
                                                        .missaoSolicitada.cnpj,
                                                    widget
                                                        .missaoSolicitada.local,
                                                    widget.missaoSolicitada
                                                        .timestamp);

                                            BlocProvider.of<
                                                        MissoesSolicitadasBloc>(
                                                    context)
                                                .add(BuscarMissoes());
                                            context
                                                .read<ElevatedButtonBloc>()
                                                .add(ElevatedButtonReset());
                                            Navigator.of(context).pop();
                                          } catch (e) {
                                            context
                                                .read<ElevatedButtonBloc>()
                                                .add(ElevatedButtonReset());
                                            debugPrint(
                                                'erro ao rejeitar missao: ${e.toString()}');
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
                                          context
                                              .read<ElevatedButtonBloc>()
                                              .add(ElevatedButtonReset());
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
        //);
        //},
      ),
    );
  }
}
