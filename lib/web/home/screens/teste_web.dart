import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra/chat/services/chat_services.dart';
import 'package:sombra/missao/services/missao_services.dart';
import 'package:sombra/web/home/notificacao/not_teste.dart';
import 'package:sombra/web/home/screens/components/second_row.dart';
import 'package:sombra/web/home/screens/components/solicitacoes.dart';
import 'package:sombra/web/home/screens/mapa_teste.dart';
import '../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../autenticacao/services/user_services.dart';
import '../../../chat/screens/central_missao_chat.dart';
import '../../../chat/screens/chat_screen.dart';
import '../../../chat/screens/missao_cliente.dart';
import '../../../missao/bloc/missoes_pendentes/qtd_missoes_pendentes_bloc.dart';
import '../../../missao/bloc/missoes_pendentes/qtd_missoes_pendentes_event.dart';
import '../../../notificacoes/bloc/qtd_missoes_pendentes_bloc.dart';
import '../../../notificacoes/bloc/qtd_missoes_pendentes_event.dart';
import '../../../notificacoes/bloc/qtd_missoes_pendentes_state.dart';
import '../../../notificacoes/notificacoess.dart';
import '../../admin/services/admin_services.dart';
import '../../missoes/agente/realtime_map.dart';
import '../../perfil/screens/perfil_screen.dart';
import 'components/missoes_ativas.dart';
import 'components/solicitacoes/bloc/solicitacoes_bloc/notificacao_chat_bloc.dart';

class HomeLoginWeb extends StatefulWidget {
  final String cargo;
  final String nome;
  const HomeLoginWeb({super.key, required this.cargo, required this.nome});

  @override
  State<HomeLoginWeb> createState() => _HomeLoginWebState();
}

const primaryColor = Colors.white;
const canvasColor = Color.fromARGB(255, 0, 15, 42);
final scaffoldBackgroundColor = Colors.white.withOpacity(0.6);
const accentCanvasColor = Colors.blue;
const white = Colors.white;
final actionColor = Colors.white.withOpacity(0.6);
const divider = Divider(color: white, height: 1);

class _HomeLoginWebState extends State<HomeLoginWeb> {
  final NotTesteService notTesteService = NotTesteService();
  final ChatServices chatServices = ChatServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final UserServices userServices = UserServices();
  List<CoordenadaComTimestamp> portoRealRoute = [];
  MissaoServices missaoServices = MissaoServices();
  AdminServices adminServices = AdminServices();
  late final StreamSubscription<bool> missaoSolicitadaPendenteListener;
  bool showNotification = false;
  late StreamSubscription<bool> notificationSubscription;
  final StreamController<bool> notificationController =
      StreamController<bool>();
  //String funcao = 'carregando...';
  //String nome = 'carregando...';

  @override
  void initState() {
    //nome = firebaseAuth.currentUser!.displayName!;
    // loadCoordinates();
    super.initState();
    context.read<QtdMissoesPendentesBloc>().add(
          BuscarQtdMissoesPendentes(),
        );
    BlocProvider.of<MissoesSolicitadasStreamBloc>(context)
        .add(BuscarMissoesSolicitadasStream());
    missaoSolicitadaPendenteListener =
        missaoServices.existeSolicitacaoPendente().listen((existe) {
      if (existe) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          TopBar.show(context, 'Solicitação de missão recebida', Colors.red,
              duration: const Duration(days: 356));
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          TopBar.hide();
        });
      }
    });
    //BlocProvider.of<AttsHomeBloc>(context).add(BuscarAttsHome());
    // notificationSubscription = NotificationService()
    //     .notificacoesCentral()
    //     .listen((hasNewNotification) {
    //   if (hasNewNotification) {
    //     notificationController.add(true);
    //     playAudio();
    //     // Adiciona um delay para depois esconder a notificação
    //     Future.delayed(const Duration(seconds: 3), () {
    //       notificationController.add(false); // Esconde a notificação
    //     });
    //   }
    // });
    //buscarFuncao();
    userServices.addFcmToken();
  }

  @override
  void dispose() {
    notificationSubscription.cancel();
    notificationController.close();
    super.dispose();
  }

  void playAudio() async {
    await AudioPlayer().play(
      volume: 1,
      UrlSource(
          'https://firebasestorage.googleapis.com/v0/b/sombratestes.appspot.com/o/notification-message-incoming.mp3?alt=media&token=f99b5f13-6f86-4c82-b397-58bd95dc3a1a'),
    );
  }

  // Future<void> buscarFuncao() async {
  //   final getFunction = await adminServices.getUserRole();
  //   setState(() {
  //     funcao = getFunction;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: canvasColor.withAlpha(15),
      //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
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
        child: Stack(
          children: [
            // StreamBuilder<bool>(
            //   stream: notificationController.stream,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const SizedBox
            //           .shrink(); // Não exibe nada enquanto carrega
            //     }

            //     if (snapshot.hasData && snapshot.data == true) {
            //       // Mostra o NotificacaoCard quando a stream retorna true
            //       return const NotificacaoCard(
            //         message: 'Nova notificação recebida!',
            //         color: Colors.blueAccent,
            //         duration: Duration(seconds: 5), // Exibe por 3 segundos
            //       );
            //     }

            //     return const SizedBox
            //         .shrink(); // Se não houver nova notificação, não exibe nada
            //   },
            // ),
            // BlocBuilder<AttsHomeBloc, AttsHomeState>(
            //   builder: (context, notState) {
            //     debugPrint(notState.toString());
            //     if (notState is AttsHomeLoaded) {
            //       if (notState.att) {
            //         notificationController.add(true);
            //         playAudio();
            //         return const NotificacaoCard(
            //           message: 'Nova notificação recebida!',
            //           color: Colors.blueAccent,
            //           duration: Duration(seconds: 5),
            //         );
            //       } else {
            //         return const SizedBox.shrink();
            //       }
            //     } else {
            //       return const SizedBox.shrink();
            //     }
            //   },
            // ),
            Column(
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      MouseRegion(
                        cursor: WidgetStateMouseCursor.clickable,
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CentralPerfilScreen()));
                          },
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(
                                'assets/images/fotoDePerfilNull.jpg'),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nome,
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            widget.cargo,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
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
                        String agenteUid = document.id;
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        int unreadCount = data['unreadCount'] ?? 0;

                        resetUnreadCount() async {
                          DocumentSnapshot document = await FirebaseFirestore
                              .instance
                              .collection('Chat')
                              .doc(agenteUid)
                              .get();

                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          Timestamp lastMessageTimestamp =
                              data['lastMessageTimestamp'];

                          debugPrint(
                              'Antes da atualização: $lastMessageTimestamp');

                          await FirebaseFirestore.instance
                              .collection('Chat')
                              .doc(agenteUid)
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
                                    future: chatServices.getUserName(agenteUid),
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
                                        ChatScreen(agenteUid: agenteUid),
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
                                                    cnpj: data['cnpj']),
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
                                              agenteUid: data['agenteUid'],
                                              agenteNome:
                                                  data['nome da empresa'],
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
                                    missionData: data,
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
