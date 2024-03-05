import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../../chat/screens/admin_chat.dart';
import '../../../../../chat/services/chat_services.dart';

class AppChatList extends StatelessWidget {
  AppChatList({super.key});

  final ChatServices chatServices = ChatServices();

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

              if (snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Nenhuma conversa disponível'));
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  String uid = document.id;
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  int unreadCount = data['unreadCount'] ?? 0;

                  resetUnreadCount() async {
                    DocumentSnapshot document = await FirebaseFirestore.instance
                        .collection('Chat')
                        .doc(uid)
                        .get();

                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    Timestamp lastMessageTimestamp =
                        data['lastMessageTimestamp'];

                    debugPrint('Antes da atualização: $lastMessageTimestamp');

                    await FirebaseFirestore.instance
                        .collection('Chat')
                        .doc(uid)
                        .set({
                      'unreadCount': 0,
                      'lastMessageTimestamp': lastMessageTimestamp,
                    }, SetOptions(merge: true));
                  }

                  return Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    color: Colors.black,
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: FutureBuilder<Map<String, String>>(
                              future: chatServices.getUserName(uid),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Map<String, String>> snapshot) {
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
                              builder: (context) => AtendenteMsg(uid: uid),
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
    );
  }
}
