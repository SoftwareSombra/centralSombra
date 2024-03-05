import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/chat/services/chat_services.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import 'package:sombra_testes/web/home/notificacao/not_teste.dart';
import 'package:sombra_testes/web/home/screens/components/second_row.dart';
import 'package:sombra_testes/web/home/screens/components/solicitacoes.dart';
import 'package:sombra_testes/web/home/screens/mapa_teste.dart';
import '../../../chat/screens/admin_chat.dart';
import '../../../chat/screens/central_missao_chat.dart';
import '../../../chat/screens/missao_cliente.dart';
import '../../../missao/bloc/missoes_pendentes/qtd_missoes_pendentes_bloc.dart';
import '../../../missao/bloc/missoes_pendentes/qtd_missoes_pendentes_event.dart';
import '../../missoes/agente/realtime_map.dart';
import 'components/missoes_ativas.dart';

class HomeLoginWeb extends StatefulWidget {
  const HomeLoginWeb({super.key});

  @override
  State<HomeLoginWeb> createState() => _HomeLoginWebState();
}

class _HomeLoginWebState extends State<HomeLoginWeb> {
  final NotTesteService notTesteService = NotTesteService();
  final ChatServices chatServices = ChatServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  List<CoordenadaComTimestamp> portoRealRoute = [];
  MissaoServices missaoServices = MissaoServices();

  @override
  void initState() {
    // loadCoordinates();
    super.initState();
    context.read<QtdMissoesPendentesBloc>().add(BuscarQtdMissoesPendentes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   elevation: 0,
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text(
      //         'Painel Administrativo',
      //         style: SafeGoogleFont(
      //           "Lato",
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: 50,
                  left: MediaQuery.of(context).size.width * 0.084,
                  right: MediaQuery.of(context).size.width * 0.08,
                  bottom: 20),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        AssetImage('assets/images/fotoDePerfilNull.jpg'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nome do usuário',
                        style: TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Função',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SolicitacoesComponent(),
            const SecondRow(),
            MissoesAtivasContainer()
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChildren(double width) {
    return [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[800],
          ),
          height: 600,
          width: width < 1300 ? width / 1.5 : width / 4,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chat',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatServices.getUsersConversations(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('Nenhuma conversa disponível'));
                    }

                    return ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        String uid = document.id;
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        int unreadCount = data['unreadCount'] ?? 0;

                        resetUnreadCount() async {
                          DocumentSnapshot document = await FirebaseFirestore
                              .instance
                              .collection('Chat')
                              .doc(uid)
                              .get();

                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          Timestamp lastMessageTimestamp =
                              data['lastMessageTimestamp'];

                          debugPrint(
                              'Antes da atualização: $lastMessageTimestamp');

                          await FirebaseFirestore.instance
                              .collection('Chat')
                              .doc(uid)
                              .set({
                            'unreadCount': 0,
                            'lastMessageTimestamp': lastMessageTimestamp,
                          }, SetOptions(merge: true));
                        }

                        return Card(
                          //color: Colors.grey[400],
                          child: ListTile(
                            title: Row(
                              children: [
                                Expanded(
                                  child: FutureBuilder<Map<String, String>>(
                                    future: chatServices.getUserName(uid),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<Map<String, String>>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Text('Carregando...');
                                      } else if (snapshot.hasError) {
                                        return const Text(
                                            'Erro ao buscar o nome do usuário');
                                      } else {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('${snapshot.data!['Nome']}'),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '($unreadCount)',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () async {
                              await resetUnreadCount();
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AtendenteMsg(uid: uid),
                                  ),
                                );
                              }
                            },
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
      Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[800],
          ),
          height: 600,
          width: width < 1300 ? width / 1.5 : width / 1.8,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Missões ativas',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: missaoServices.buscarTodasMissoesAtivas(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text(
                        'Nenhuma missão ativa',
                        style: TextStyle(color: Colors.white),
                      ));
                    }

                    return ListView(
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;
                        bool emAndamento = data['emAndamento'];
                        return Card(
                          //color: Colors.grey[400],
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SelectableText(
                                        data['missaoID'],
                                      ),
                                      emAndamento
                                          ? const Text(
                                              'Em andamento',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15),
                                            )
                                          : const Text(
                                              'Pendente',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15),
                                            ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CentralMissaoChatScreen(
                                              missaoId: data['missaoID'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          const Text('Agente'),
                                          StreamBuilder<int>(
                                            stream: chatServices
                                                .getCentralMissionAgentConversationsUnreadCount(
                                                    data['missaoID']),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<int> snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data! > 0) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 2.0),
                                                  child: Text(
                                                    '(${snapshot.data})',
                                                    style: const TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ClienteMissaoChatScreen(
                                              missaoId: data['missaoID'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          const Text('Cliente'),
                                          StreamBuilder<int>(
                                            stream: chatServices
                                                .getCentralMissionClientConversationsUnreadCount(
                                                    data['missaoID']),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<int> snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data! > 0) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 2.0),
                                                  child: Text(
                                                    '(${snapshot.data})',
                                                    style: const TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.bold),
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
                                  ],
                                ),
                              ],
                            ),
                            onTap: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RealTimeMapScreen(
                                    missaoId: data['missaoID'],
                                    missaoLatitude: data['missaoLatitude'],
                                    missaoLongitude: data['missaoLongitude'],
                                  ),
                                ),
                              );
                            },
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
    ];
  }

  // void loadCoordinates() async {
  //   debugPrint('loadCoordinates iniciado');
  //   try {
  //     portoRealRoute = await missaoServices.fetchCoordinates();
  //     setState(() {});
  //   } catch (e) {
  //     debugPrint('Erro ao carregar coordenadas: $e');
  //   }
  //   debugPrint('loadCoordinates finalizado');
  // }
}
