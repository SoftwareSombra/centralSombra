import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';
import '../../../../../agente/model/agente_model.dart';
import '../../../../../chat/screens/chat_screen.dart';
import '../../../../../chat/services/chat_services.dart';
import '../../../../admin/agentes/model/agente_model.dart';
import '../../../../admin/agentes/services/agentes_list_services.dart';

// class AppChatList extends StatelessWidget {
//   AppChatList({super.key});

//   final ChatServices chatServices = ChatServices();
//   String? nome;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: chatServices.getUsersConversations(),
//             builder:
//                 (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (snapshot.hasError) {
//                 return Center(child: Text('Erro: ${snapshot.error}'));
//               }

//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (snapshot.data!.docs.isEmpty) {
//                 return const Center(child: Text('Nenhuma conversa disponível'));
//               }

//               return ListView(
//                 children: snapshot.data!.docs.map((DocumentSnapshot document) {
//                   String uid = document.id;
//                   debugPrint('UID: $uid');
//                   Map<String, dynamic> data =
//                       document.data() as Map<String, dynamic>;
//                   int unreadCount = data['unreadCount'] ?? 0;

//                   resetUnreadCount() async {
//                     DocumentSnapshot document = await FirebaseFirestore.instance
//                         .collection('Chat')
//                         .doc(uid)
//                         .get();

//                     Map<String, dynamic> data =
//                         document.data() as Map<String, dynamic>;
//                     Timestamp lastMessageTimestamp =
//                         data['lastMessageTimestamp'];

//                     debugPrint('Antes da atualização: $lastMessageTimestamp');

//                     await FirebaseFirestore.instance
//                         .collection('Chat')
//                         .doc(uid)
//                         .set({
//                       'unreadCount': 0,
//                       //'lastMessageTimestamp': lastMessageTimestamp,
//                     }, SetOptions(merge: true));
//                   }

//                   return
// Card(
//                     shape: const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.zero,
//                     ),
//                     color: Colors.black,
//                     child: ListTile(
//                       title: Row(
//                         children: [
//                           Expanded(
//                             child: FutureBuilder<Map<String, String>>(
//                               future: chatServices.getUserName(uid),
//                               builder: (BuildContext context,
//                                   AsyncSnapshot<Map<String, String>> snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.waiting) {
//                                   return const Text('Carregando...');
//                                 } else if (snapshot.hasError) {
//                                   return const Text(
//                                       'Erro ao buscar o nome do usuário');
//                                 } else {
//                                   debugPrint('Nome: ${snapshot.data!['Nome']}');
//                                   nome = snapshot.data!['Nome']!;
//                                   return Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text('${snapshot.data!['Nome']}'),
//                                     ],
//                                   );
//                                 }
//                               },
//                             ),
//                           ),
//                           if (unreadCount > 0)
//                             Padding(
//                               padding: const EdgeInsets.only(left: 8.0),
//                               child: Text(
//                                 '($unreadCount)',
//                                 style: const TextStyle(
//                                     color: Colors.red,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                         ],
//                       ),
//                       onTap: () async {
//                         await resetUnreadCount();
//                         if (context.mounted) {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => ChatScreen(
//                                 agenteUid: uid,
//                                 agenteNome: nome,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

class AppChatList extends StatefulWidget {
  const AppChatList({super.key});

  @override
  State<AppChatList> createState() => _AppChatListState();
}

class _AppChatListState extends State<AppChatList> {
  final ChatServices chatServices = ChatServices();
  final Map<String, String> userNames = {};
  List<String> currentUids = []; // Armazena os uids atuais
  final TextEditingController searchTextController = TextEditingController();

  Future<void> fetchUserNames(List<String> userIds) async {
    final names = await chatServices.getUserNames(userIds);
    if (mounted) {
      setState(() {
        userNames.addAll(names);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(context: context, builder: (context) => buscarAgentes());
          }),
      body: Column(
        children: [
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

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma conversa disponível'));
                }

                // Extraia os uids dos documentos
                final uids = docs.map((doc) => doc.id).toList();

                // Verifica se os uids são diferentes dos atuais antes de buscar os nomes
                if (!listEquals(uids, currentUids)) {
                  currentUids = uids;
                  fetchUserNames(uids);
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final uid = doc.id;
                    final data = doc.data() as Map<String, dynamic>;
                    final unreadCount = data['unreadCount'] ?? 0;
                    final nome =
                        userNames[uid] ?? 'Carregando...'; // Use o nome do mapa

                    return Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      //color: Colors.black,
                      elevation: 4,
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nome),
                                ],
                              ),
                            ),
                            if (unreadCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '($unreadCount)',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                agenteUid: uid,
                                agenteNome: nome, // Passa o nome correto
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buscarAgentes() {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text('AGENTES'),
      content: Container(
        height: 400,
        width: 600,
        child: SearchableList<AgenteAdmList>.async(
          shrinkWrap: true,
          onPaginate: () async {
            // await Future.delayed(
            //     const Duration(milliseconds: 000));
            // setState(() {
            //   actors.addAll([
            //     Actor(
            //         age: 22,
            //         name: 'Fathi',
            //         lastName: 'Hadawi'),
            //     Actor(
            //         age: 22,
            //         name: 'Hichem',
            //         lastName: 'Rostom'),
            //     Actor(
            //         age: 22,
            //         name: 'Kamel',
            //         lastName: 'Twati'),
            //   ]);
            // });
          },
          itemBuilder: (AgenteAdmList agente) => MouseRegion(
            cursor: WidgetStateMouseCursor.clickable,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      agenteUid: agente.uid,
                      agenteNome: agente.nome, // Passa o nome correto
                    ),
                  ),
                );
              },
              child: AgenteItem(agente: agente),
            ),
          ),
          loadingWidget:
              //const SizedBox.shrink(),
              const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 15,
              ),
              Text('Buscando agentes...')
            ],
          ),
          errorWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                color: Colors.red,
              ),
              SizedBox(
                height: 20,
              ),
              Text('Error ao buscar agentes')
            ],
          ),
          asyncListCallback: () async {
            List<AgenteAdmList>? agentes =
                await AgentesListServices().getAllAgentes();
            return agentes;
          },
          asyncListFilter: (q, list) {
            List<AgenteAdmList>? geral = [];
            List<AgenteAdmList> nome = list
                .where((element) =>
                    element.nome.toLowerCase().contains(q.toLowerCase()))
                .toList();
            List<AgenteAdmList> uids =
                list.where((element) => element.uid.contains(q)).toList();
            geral.addAll(nome);
            searchTextController.text.isNotEmpty ? geral.addAll(uids) : null;
            return geral;
          },
          searchTextController: searchTextController,
          emptyWidget: const EmptyView(),
          onRefresh: () async {},
          // onItemSelected: (AgenteAdmList item) {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => ChatScreen(
          //         agenteUid: item.uid,
          //         agenteNome: item.nome, // Passa o nome correto
          //       ),
          //     ),
          //   );
          // },
          inputDecoration: const InputDecoration(
            labelText: 'Nome ou uid do agente',
            labelStyle: TextStyle(fontSize: 13, color: Colors.grey),
            //suffixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}

class AgenteItem extends StatelessWidget {
  final AgenteAdmList agente;

  const AgenteItem({
    Key? key,
    required this.agente,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            //color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Icon(
                Icons.person,
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        agente.nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Uid: ${agente.uid}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text('Nenhuma empresa encontrada'),
      ],
    );
  }
}
