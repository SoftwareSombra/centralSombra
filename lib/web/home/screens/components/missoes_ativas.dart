import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gradient_ui/gradient_ui_widgets.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import '../../../../chat/screens/central_missao_chat.dart';
import '../../../../chat/screens/missao_cliente.dart';
import '../../../../chat/services/chat_services.dart';
import '../../../missoes/agente/realtime_map.dart';

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
            //width: 400,
            height: 480,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  canvasColor.withOpacity(0.3),
                  canvasColor.withOpacity(0.33),
                  canvasColor.withOpacity(0.35),
                  //canvasColor.withOpacity(0.38),
                  //canvasColor.withOpacity(0.4),
                  //canvasColor.withOpacity(0.43),
                  // canvasColor.withOpacity(0.45),
                  // canvasColor.withOpacity(0.48),
                  // canvasColor.withOpacity(0.5),
                  // canvasColor.withOpacity(0.53),
                  // canvasColor.withOpacity(0.55),
                  // canvasColor.withOpacity(0.58),
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
                              style: TextStyle(color: Colors.white),
                            ));
                          }

                          return ListView(
                            children: snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              bool emAndamento = data['emAndamento'];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: MouseRegion(
                                  cursor: MaterialStateMouseCursor.clickable,
                                  child: GestureDetector(
                                    // child: GradientCard(
                                    //   gradient: g1,
                                    //   shape: RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.circular(5),
                                    //   ),
                                    child: Container(
                                      //color: Colors.grey[400],
                                      color: const Color.fromARGB(255, 3, 9, 18)
                                          .withOpacity(0.5),
                                      child:
                                          //   ListTile(
                                          // title:
                                          Padding(
                                        padding: EdgeInsets.all(20),
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
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          SelectableText(
                                                            '${data['missaoID']}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontSize: 12,
                                                            ),
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
                                                                          CentralMissaoChatScreen(
                                                                    missaoId: data[
                                                                        'missaoID'],
                                                                    agenteUid: data[
                                                                        'agenteUid'],
                                                                    agenteNome:
                                                                        data[
                                                                            'nome'],
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
                                                                            'nome'],
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
                                            missionData: data
                                          ),
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
