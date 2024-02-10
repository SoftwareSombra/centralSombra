import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sombra_testes/chat/services/chat_services.dart';
import 'admin_chat.dart';

class CentralMissaoChatScreen extends StatefulWidget {
  final String missaoId;

  const CentralMissaoChatScreen({Key? key, required this.missaoId})
      : super(key: key);

  @override
  State<CentralMissaoChatScreen> createState() =>
      _CentralMissaoChatScreenState();
}

class _CentralMissaoChatScreenState extends State<CentralMissaoChatScreen> {
  final ChatServices chatServices = ChatServices();
  TextEditingController _bodyController = TextEditingController();
  ValueNotifier<bool> isSubmitting = ValueNotifier(false);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _listener;
  ScrollController controller = ScrollController();
  bool firstLoad = true;

  Stream<QuerySnapshot<Map<String, dynamic>>> getConversationMessages() {
    return FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(widget.missaoId)
        .collection('Mensagens')
        .orderBy('Timestamp', descending: false)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _listener = FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(widget.missaoId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        FirebaseFirestore.instance
            .collection('Chat missão')
            .doc(widget.missaoId)
            .update({'unreadCount': 0});
      }
    });
    getConversationMessages();
  }

  @override
  void dispose() {
    _listener?.cancel();
    controller.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    final userName = user?.displayName;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getConversationMessages(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                debugPrint("Mensagens Snapshot Data: ${snapshot.data}");
                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (firstLoad) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.jumpTo(controller.position.maxScrollExtent);
                  });
                  firstLoad = false;
                }

                return Listener(
                  onPointerDown: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  child: ListView.builder(
                    controller: controller,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = snapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      final autor = data['Autor'];
                      final messageText = data['Mensagem'];
                      final imageUrl = data['Imagem'];
                      final timestamp = data['Timestamp'];
                      final isCurrentUser = autor == "Atendente";

                      return MessageBubbleAtendente(
                        message: messageText,
                        sender: autor,
                        isCurrentUser: isCurrentUser,
                        imageUrl: imageUrl,
                        timestamp: timestamp,
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Center(
                          child: TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: _bodyController,
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 500,
                            decoration: InputDecoration(
                              labelText: 'Digite sua mensagem aqui',
                              labelStyle: const TextStyle(color: Colors.grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 10.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ValueListenableBuilder(
                    valueListenable: isSubmitting,
                    builder: (context, bool value, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          value
                              ? const CircularProgressIndicator()
                              : RawMaterialButton(
                                  onPressed: value
                                      ? null
                                      : () async {
                                          isSubmitting.value = true;
                                          if (_bodyController.text
                                              .trim()
                                              .isNotEmpty) {
                                            chatServices.addCentralMsgMissao(
                                                _bodyController,
                                                userName,
                                                userUid,
                                                widget.missaoId);
                                          }
                                          isSubmitting.value = false;
                                          controller.animateTo(
                                            controller.position.maxScrollExtent,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeOut,
                                          );
                                        },
                                  shape: const CircleBorder(),
                                  fillColor: Colors.blue,
                                  constraints: const BoxConstraints.expand(
                                      width: 40, height: 40),
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                ),
                          if (value) const CircularProgressIndicator(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
