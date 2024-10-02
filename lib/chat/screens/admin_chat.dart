import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sombra/autenticacao/services/log_services.dart';
import 'package:sombra/chat/services/chat_services.dart';
import '../../web/admin/bloc/roles_bloc.dart';
import '../../web/admin/bloc/roles_event.dart';
import '../../web/admin/bloc/roles_state.dart';

class AtendenteMsg extends StatefulWidget {
  final String uid;

  const AtendenteMsg({super.key, required this.uid});

  @override
  State<AtendenteMsg> createState() => _AtendenteMsgState();
}

class _AtendenteMsgState extends State<AtendenteMsg> {
  final ChatServices chatServices = ChatServices();
  final TextEditingController _bodyController = TextEditingController();
  ValueNotifier<bool> isSubmitting = ValueNotifier(false);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _listener;
  ScrollController controller = ScrollController();
  bool firstLoad = true;
  LogServices logServices = LogServices();

  Stream<QuerySnapshot<Map<String, dynamic>>> getConversationMessages() {
    return FirebaseFirestore.instance
        .collection('Chat')
        .doc(widget.uid)
        .collection('Mensagens')
        .orderBy('Timestamp', descending: false)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _listener = FirebaseFirestore.instance
        .collection('Chat')
        .doc(widget.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        FirebaseFirestore.instance.collection('Chat').doc(widget.uid).set({
          'unreadCount': 0,
        }, SetOptions(merge: true));
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
    //final user = FirebaseAuth.instance.currentUser;
    //final userUid = user?.uid;
    context.read<RolesBloc>().add(BuscarRoles());

    return BlocBuilder<RolesBloc, RolesState>(
      builder: (context, state) {
        if (state is RolesInitial) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is RolesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is RolesError) {
          return Center(
            child: Text(state.message),
          );
        } else if (state is RolesLoaded) {
          if (state.isDev || state.isAdmin || state.isOperador) {
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

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (firstLoad) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller
                                .jumpTo(controller.position.maxScrollExtent);
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
                              Map<String, dynamic> data =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                              final autor = data['Autor'];
                              final messageText = data['Mensagem'];
                              final timestamp = data['Timestamp'];
                              final isCurrentUser = autor == "Atendente";

                              return MessageBubbleAtendente(
                                message: messageText,
                                sender: autor,
                                isCurrentUser: isCurrentUser,
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
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                return Center(
                                  child: TextFormField(
                                    style: const TextStyle(color: Colors.white),
                                    controller: _bodyController,
                                    minLines: 1,
                                    maxLines: 5,
                                    maxLength: 500,
                                    decoration: InputDecoration(
                                      labelText: 'Digite sua mensagem aqui',
                                      labelStyle:
                                          const TextStyle(color: Colors.grey),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.grey),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                                    chatServices
                                                        .addAtendenteMsg(
                                                            _bodyController,
                                                            "Atendente",
                                                            widget.uid);
                                                  }
                                                  isSubmitting.value = false;
                                                  controller.animateTo(
                                                    controller.position
                                                        .maxScrollExtent,
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeOut,
                                                  );
                                                },
                                          shape: const CircleBorder(),
                                          fillColor: Colors.blue,
                                          constraints:
                                              const BoxConstraints.expand(
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
          } else {
            return Column(
              children: [
                const AlertDialog(
                  title: Text('Acesso negado'),
                  content:
                      Text('Você não tem permissão para acessar esta página'),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await logServices.logOut(context);
                    if (context.mounted) {
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                          '/', (Route<dynamic> route) => false);
                    }
                  },
                  child: const Text('Sair'),
                ),
              ],
            );
          }
        } else {
          return const AlertDialog(
            title: Text('Erro ao buscar credenciais'),
            content: Text('Recarregue a página'),
          );
        }
      },
    );
  }
}

class MessageBubbleAtendente extends StatelessWidget {
  final String? message;
  final String sender;
  final bool isCurrentUser;
  final String? imageUrl;
  final Timestamp? timestamp;

  const MessageBubbleAtendente(
      {super.key,
      required this.message,
      required this.sender,
      required this.isCurrentUser,
      this.imageUrl,
      this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                margin: const EdgeInsets.only(
                    top: 10.0, left: 8.0, right: 8.0, bottom: 1),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue : Colors.grey[400],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(15.0),
                    topRight: const Radius.circular(15.0),
                    bottomLeft: isCurrentUser
                        ? const Radius.circular(15.0)
                        : const Radius.circular(0.0),
                    bottomRight: isCurrentUser
                        ? const Radius.circular(0.0)
                        : const Radius.circular(15.0),
                  ),
                ),
                child: imageUrl != null
                    ? Container(
                        constraints:
                            const BoxConstraints(maxHeight: 200, maxWidth: 200),
                        child: GestureDetector(
                          onTap: () => _showImageDialog(context, imageUrl!),
                          child: FutureBuilder(
                            future: _loadImage(imageUrl!),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return const Icon(Icons
                                    .error); // Ou algum outro widget para erro
                              }

                              return Image.network(imageUrl!);
                            },
                          ),
                        ),
                      )
                    : SelectableText(
                        message ?? '',
                        style: TextStyle(
                            color: isCurrentUser ? Colors.white : Colors.black),
                      ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
          child: Text(
            timestamp == null
                ? ''
                : DateFormat('dd/MM/yyyy HH:mm').format(timestamp!.toDate()),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  Future<bool> _loadImage(String imageUrl) async {
    try {
      NetworkImage(imageUrl).resolve(const ImageConfiguration());
      return true;
    } catch (e) {
      return false;
    }
  }
}
