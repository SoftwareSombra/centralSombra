import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sombra_testes/chat/services/chat_services.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String uid;
  const ChatScreen({super.key, required this.uid});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgController = TextEditingController();
  final ValueNotifier<bool> isSubmitting = ValueNotifier(false);
  final ScrollController controller = ScrollController();
  bool firstLoad = true;
  late final FirebaseMessaging firebaseMessaging;
  final ChatServices chatServices = ChatServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final ChatStatus chatStatus = ChatStatus();

  Stream<QuerySnapshot<Map<String, dynamic>>> getConversationMessages() {
    return FirebaseFirestore.instance
        .collection('Chat')
        .doc(widget.uid)
        .collection('Mensagens')
        .orderBy('Timestamp', descending: false)
        .snapshots();
  }

  Future<void> resetUserUnreadCount(String uid) async {
    await FirebaseFirestore.instance
        .collection('Chat')
        .doc(uid)
        .update({'userUnreadCount': 0});
  }

  @override
  void initState() {
    getConversationMessages();
    chatStatus.isInChatScreen = true;
    firebaseMessaging = FirebaseMessaging.instance;
    // Checa e atualiza o FCM Token se necessário
    // _checkAndUpdateFcmToken();
    super.initState();
  }

  @override
  void dispose() {
    msgController.dispose();
    controller.dispose();
    chatStatus.isInChatScreen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    final userName = user?.displayName;
    resetUserUnreadCount(userUid!);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              children: [
                Text(
                  'Você está em um chat com a central',
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  'e será atendido em breve.',
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getConversationMessages(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                      final autor = data['User uid'];
                      final messageText = data['Mensagem'];
                      final isCurrentUser = autor == userUid;
                      return MessageBubble(
                        message: messageText,
                        sender: autor,
                        isCurrentUser: isCurrentUser,
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
                            controller: msgController,
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 500,
                            decoration: InputDecoration(
                              labelText: 'Digite sua mensagem aqui',
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
                                          if (msgController.text
                                              .trim()
                                              .isNotEmpty) {
                                            await chatServices.addMsg(
                                                msgController,
                                                userName,
                                                userUid);
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

class MessageBubble extends StatelessWidget {
  final String? message;
  final String sender;
  final bool isCurrentUser;
  final String? imageUrl;

  const MessageBubble(
      {super.key,
      this.message,
      required this.sender,
      required this.isCurrentUser,
      this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          child: Container(
            padding: const EdgeInsets.only(
                top: 10.0, left: 20.0, right: 20.0, bottom: 10),
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
                    constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
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
                            return const Icon(
                                Icons.error); // Ou algum outro widget para erro
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
    );
  }

  Future<bool> _loadImage(String imageUrl) async {
    try {
      await NetworkImage(imageUrl).resolve(const ImageConfiguration());
      return true; // Imagem carregada com sucesso
    } catch (e) {
      return false; // Erro ao carregar a imagem
    }
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

  List<TextSpan> _linkify(
      String text, BuildContext context, bool isCurrentUser) {
    final RegExp linkRegExp = RegExp(r'\b(https?://\S+)\b');
    final Iterable<Match> matches = linkRegExp.allMatches(text);

    if (matches.isEmpty) return [TextSpan(text: text)];

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
              color: isCurrentUser ? Colors.white : Colors.blue,
              decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final url = match.group(0);
              if (await canLaunchUrl(Uri.parse(url!))) {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Container(),
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível abrir o link'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
        ),
      );
      lastMatchEnd = match.end;
    }

    spans.add(TextSpan(text: text.substring(lastMatchEnd)));

    return spans;
  }
}

class ChatStatus {
  bool isInChatScreen = false;
  static final ChatStatus _singleton = ChatStatus._internal();

  factory ChatStatus() {
    return _singleton;
  }

  ChatStatus._internal();
}

// E em algum lugar no seu código (por exemplo, no início de main.dart), você pode inicializá-la:
ChatStatus chatStatus = ChatStatus();
