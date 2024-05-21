import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../chat/screens/chat_screen.dart';
import '../../../../../chat/services/chat_services.dart';

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
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: chatServices.getUsersConversations(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text('Nenhuma conversa disponível'));
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
                    color: Colors.black,
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
    );
  }
}
