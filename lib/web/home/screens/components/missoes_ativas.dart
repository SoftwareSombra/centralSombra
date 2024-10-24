import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sombra/missao/services/missao_services.dart';
import '../../../../chat/screens/central_missao_chat.dart';
import '../../../../chat/screens/missao_cliente.dart';
import '../../../../chat/services/chat_services.dart';
import '../../../missoes/agente/realtime_map.dart';
import '../../../missoes/misoes_ativas/fotos_missao_screen.dart';

class MissoesAtivasContainer extends StatelessWidget {
  MissoesAtivasContainer({super.key});

  static const canvasColor = Color.fromARGB(255, 0, 15, 42);
  final MissaoServices missaoServices = MissaoServices();
  final ChatServices chatServices = ChatServices();
  final Gradient g1 = const LinearGradient(
    colors: [
      Color.fromARGB(255, 0, 7, 30),
      Color.fromARGB(255, 0, 10, 27),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: width < 800 ? width * 0.04 : width * 0.08,
          ),
          child: Container(
            height: 480,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 5, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    AutoSizeText(
                                      'MISSÕES ATIVAS',
                                      maxFontSize: 20,
                                      minFontSize: 18,
                                      style: TextStyle(
                                          fontSize: 100,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: missaoServices.buscarTodasMissoesAtivas(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Erro: ${snapshot.error}'));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text(
                              'Nenhuma missão ativa',
                              style: TextStyle(color: canvasColor),
                            ));
                          }

                          return ListView(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: MouseRegion(
                                  cursor: WidgetStateMouseCursor.clickable,
                                  child: GestureDetector(
                                    // child: GradientCard(
                                    //   gradient: g1,
                                    //   shape: RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.circular(5),
                                    //   ),
                                    child: Container(
                                      color: Colors.grey[200],
                                      // color: const Color.fromARGB(255, 3, 9, 18)
                                      //     .withOpacity(0.5),
                                      child:
                                          //   ListTile(
                                          // title:
                                          Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      //missao id em cinza
                                                      Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.gps_fixed,
                                                            color: canvasColor,
                                                            size: 22,
                                                          ),
                                                          const SizedBox(
                                                            width: 6,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SelectableText(
                                                                '${data['missaoID']}',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              SelectableText(
                                                                '${data['tipo']}',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          FotosDaMissaoScreen(
                                                                    uid: data[
                                                                        'agenteUid'],
                                                                    missaoId: data[
                                                                        'missaoID'],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            icon: Row(
                                                              children: [
                                                                StreamBuilder<
                                                                    bool>(
                                                                  stream: missaoServices
                                                                      .notificacaoFoto(
                                                                          data[
                                                                              'agenteUid'],
                                                                          data[
                                                                              'missaoID']),
                                                                  builder: (BuildContext
                                                                          context,
                                                                      AsyncSnapshot<
                                                                              bool>
                                                                          snapshot) {
                                                                    if (snapshot
                                                                            .hasData &&
                                                                        snapshot
                                                                            .data!) {
                                                                      return Stack(
                                                                        children: [
                                                                          const Icon(
                                                                            Icons.photo,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                          Positioned(
                                                                            top:
                                                                                0,
                                                                            right:
                                                                                0,
                                                                            child:
                                                                                Container(
                                                                              width: 9,
                                                                              height: 9,
                                                                              decoration: const BoxDecoration(
                                                                                color: Colors.red, // Cor da bolinha
                                                                                shape: BoxShape.circle,
                                                                                // border: Border.all(
                                                                                //   color: Colors.white, // Cor da borda da bolinha
                                                                                //   width: 1, // Largura da borda
                                                                                // ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else {
                                                                      return const Icon(
                                                                        Icons
                                                                            .photo,
                                                                        size:
                                                                            20,
                                                                      );
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CentralMissaoChatScreen(
                                                                    missaoId: data[
                                                                        'missaoID'],
                                                                    agenteUid: data[
                                                                        'agenteUid'],
                                                                    agenteNome:
                                                                        data[
                                                                            'nome'],
                                                                    cnpj: data['cnpj'],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            icon: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons.person,
                                                                  size: 20,
                                                                ),
                                                                StreamBuilder<
                                                                    int>(
                                                                  stream: chatServices
                                                                      .getCentralMissionAgentConversationsUnreadCount(
                                                                          data[
                                                                              'missaoID']),
                                                                  builder: (BuildContext
                                                                          context,
                                                                      AsyncSnapshot<
                                                                              int>
                                                                          snapshot) {
                                                                    if (snapshot
                                                                            .hasData &&
                                                                        snapshot.data! >
                                                                            0) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                2.0),
                                                                        child:
                                                                            Text(
                                                                          '(${snapshot.data})',
                                                                          style: const TextStyle(
                                                                              color: Colors.red,
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.w300),
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      return const SizedBox
                                                                          .shrink(); // Se não houver dados ou unreadCount for 0, não mostra nada
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ClienteMissaoChatScreen(
                                                                    missaoId: data[
                                                                        'missaoID'],
                                                                    agenteUid: data[
                                                                        'agenteUid'],
                                                                    agenteNome:
                                                                        data[
                                                                            'nome da empresa'],
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            icon: Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .business,
                                                                  size: 20,
                                                                ),
                                                                StreamBuilder<
                                                                    int>(
                                                                  stream: chatServices
                                                                      .getCentralMissionClientConversationsUnreadCount(
                                                                          data[
                                                                              'missaoID']),
                                                                  builder: (BuildContext
                                                                          context,
                                                                      AsyncSnapshot<
                                                                              int>
                                                                          snapshot) {
                                                                    if (snapshot
                                                                            .hasData &&
                                                                        snapshot.data! >
                                                                            0) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                2.0),
                                                                        child:
                                                                            Text(
                                                                          '(${snapshot.data})',
                                                                          style: const TextStyle(
                                                                              color: Colors.red,
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      return const SizedBox
                                                                          .shrink();
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(
                                                    'Empresa: ',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SelectableText(
                                                    data['nome da empresa'],
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Text(
                                                    'Local: ',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  SelectableText(
                                                    data['local'],
                                                  ),
                                                  // emAndamento
                                                  //     ? const Text(
                                                  //         'Em andamento',
                                                  //         style: TextStyle(
                                                  //             color: Colors.grey,
                                                  //             fontSize: 15),
                                                  //       )
                                                  //     : const Text(
                                                  //         'Pendente',
                                                  //         style: TextStyle(
                                                  //             color: Colors.grey,
                                                  //             fontSize: 15),
                                                  //       ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RealTimeMapScreen(
                                                  missaoId: data['missaoID'],
                                                  missaoLatitude:
                                                      data['missaoLatitude'],
                                                  missaoLongitude:
                                                      data['missaoLongitude'],
                                                  missionData: data),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
