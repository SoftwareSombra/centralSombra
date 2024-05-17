import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sombra_testes/chat/screens/chat_screen.dart';
import 'package:sombra_testes/chat/services/chat_services.dart';
import 'package:url_launcher/url_launcher.dart';

class MissaoChatScreen extends StatefulWidget {
  final String missaoId;
  const MissaoChatScreen({super.key, required this.missaoId});

  @override
  State<MissaoChatScreen> createState() => _MissaoChatScreenState();
}

class _MissaoChatScreenState extends State<MissaoChatScreen> {
  final TextEditingController msgController = TextEditingController();
  final ValueNotifier<bool> isSubmitting = ValueNotifier(false);
  final ScrollController controller = ScrollController();
  bool firstLoad = true;
  late final FirebaseMessaging firebaseMessaging;
  final ChatServices chatServices = ChatServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final ChatStatus chatStatus = ChatStatus();
  final ValueNotifier<bool> isUploading = ValueNotifier<bool>(false);
  //StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _listener;

  Stream<QuerySnapshot<Map<String, dynamic>>> getConversationMessages(uid) {
    return FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(widget.missaoId)
        .collection('Mensagens')
        .orderBy('Timestamp', descending: false)
        .snapshots();
  }

  Future<void> resetUserUnreadCount(String missaId) async {
    await FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(widget.missaoId)
        .set({'userUnreadCount': 0}, SetOptions(merge: true));
  }

  @override
  void initState() {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    getConversationMessages(userUid);
    resetUserUnreadCount(widget.missaoId);
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
      backgroundColor: const Color.fromARGB(255, 14, 14, 14),
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
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
              stream: getConversationMessages(userUid),
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
                      final imageUrl = data['Imagem'];
                      final timestamp = data['Timestamp'];
                      final isCurrentUser = autor == userUid;
                      return MessageBubble(
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
                  // Botão para anexos

                  RawMaterialButton(
                    onPressed: () async {
                      // Ação para anexar arquivo
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        File imageFile = File(image.path);
                        await _showImagePreviewAndUpload(imageFile, userName,
                            userUid); // Mostra a prévia da imagem
                      }
                    },
                    shape: const CircleBorder(),
                    fillColor: Colors.blue,
                    constraints:
                        const BoxConstraints.expand(width: 40, height: 40),
                    child: ValueListenableBuilder(
                      valueListenable: isUploading,
                      builder: (context, bool isUploading, child) {
                        return isUploading
                            ? CircularProgressIndicator()
                            : const Icon(
                                Icons.attach_file,
                                color: Colors.white,
                              );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // TextFormField
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
                                            await chatServices.addMsgMissao(
                                                msgController,
                                                userName,
                                                userUid,
                                                widget.missaoId,
                                                null);
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

  Future<void> _showImagePreviewAndUpload(
      File imageFile, userName, userUid) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.file(imageFile),
                const Text('Deseja enviar esta imagem?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enviar'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _uploadAndSendMessage(imageFile, userName, userUid);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadAndSendMessage(File imageFile, userName, userUid) async {
    isUploading.value = true;
    try {
      String filePath = 'chat_images/${DateTime.now()}.png';
      TextEditingController msgFotoController = TextEditingController();

      // Fazer upload da imagem
      UploadTask uploadTask =
          FirebaseStorage.instance.ref().child(filePath).putFile(imageFile);

      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();

      // Enviar a URL da imagem como mensagem
      await chatServices.addMsgMissao(
        msgFotoController,
        userName,
        userUid,
        widget.missaoId,
        url,
      );
    } catch (e) {
      // Tratar possíveis erros aqui
    } finally {
      isUploading.value = false;
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String? message;
  final String sender;
  final bool isCurrentUser;
  final String? imageUrl;
  final Timestamp? timestamp;

  const MessageBubble(
      {super.key,
      this.message,
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
                    ? GestureDetector(
                        onTap: () => _showImageDialog(context, imageUrl!),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl!,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
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
