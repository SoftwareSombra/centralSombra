import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/chat/services/chat_services.dart';
import 'package:sombra_testes/widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import 'package:sombra_testes/widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import 'package:sombra_testes/widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_state.dart';
import '../../chat_view/chatview.dart';
import '../../notificacoes/fcm.dart';
import '../../notificacoes/notificacoess.dart';
import 'chat_screen.dart';

class CentralMissaoChatScreen extends StatefulWidget {
  final String missaoId;
  final String? agenteUid;
  final String? agenteNome;

  const CentralMissaoChatScreen(
      {Key? key, required this.missaoId, this.agenteUid, this.agenteNome})
      : super(key: key);

  @override
  State<CentralMissaoChatScreen> createState() =>
      _CentralMissaoChatScreenState();
}

class _CentralMissaoChatScreenState extends State<CentralMissaoChatScreen> {
  final TextEditingController msgController = TextEditingController();
  final ValueNotifier<bool> isSubmitting = ValueNotifier(false);
  final ScrollController controller = ScrollController();
  bool firstLoad = true;
  late final FirebaseMessaging firebaseMessaging;
  final ChatServices chatServices = ChatServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AppTheme theme = DarkTheme();
  bool isDarkTheme = true;
  late ChatUser currentUser;
  late ChatController _chatController;
  List<Message> messageList = [];
  late StreamSubscription _messagesSubscription;
  FirebaseAuth auth = FirebaseAuth.instance;
  late User? user;
  late String? uid;
  final FirebaseMessagingService firebaseMessagingService =
      FirebaseMessagingService(NotificationService());
  late ChatController chatViewController;

  void _showHideTypingIndicator() {
    _chatController.setTypingIndicator = !_chatController.showTypingIndicator;
  }

  // Stream<QuerySnapshot<Map<String, dynamic>>> getConversationMessages() {
  //   return FirebaseFirestore.instance
  //       .collection('Chat')
  //       .doc(uid!)
  //       .collection('Mensagens')
  //       .orderBy('Timestamp', descending: false)
  //       .snapshots();
  // }

  Future<void> resetUnreadCount() async {
    await FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(widget.missaoId)
        .set({'unreadCount': 0}, SetOptions(merge: true));
  }

  Future<void> getCurrentChatUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName;
    final userPhoto = user?.photoURL;
    setState(() {
      currentUser = ChatUser(
        id: 'Atendente',
        name: userName!,
        profilePhoto: userPhoto!,
      );
    });
  }

  Future<void> chatController(uid, agenteUid) async {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName;
    _chatController = ChatController(
      initialMessageList: messageList,
      scrollController: ScrollController(),
      chatId: agenteUid,
      chatUsers: [
        ChatUser(
          id: 'Atendente',
          name: userName!,
          profilePhoto: fotoUrl,
        ),
        ChatUser(
          id: widget.agenteUid!,
          name: widget.agenteNome ?? 'Agente',
        ),
      ],
      chatCollection: 'Chat missão',
      missaoId: widget.missaoId,
    );
    setState(() {
      chatViewController = _chatController;
    });
  }

  @override
  void initState() {
    user = auth.currentUser;
    uid = user!.uid;
    //getConversationMessages();
    chatStatus.isInChatScreen = true;
    firebaseMessaging = FirebaseMessaging.instance;
    // getCurrentChatUser().then((_) {
    //   chatController(uid!);
    //   startListeningForNewMessages(uid!);
    // });
    chatController(uid!, widget.agenteUid!);
    getCurrentChatUser();

    chatViewController.startListeningForNewChatMissaoMessages();
    // Checa e atualiza o FCM Token se necessário
    // _checkAndUpdateFcmToken();
    super.initState();
  }

  @override
  void dispose() {
    msgController.dispose();
    controller.dispose();
    chatStatus.isInChatScreen = false;
    _chatController.dispose();
    _messagesSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    resetUnreadCount();
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 14, 14, 14),
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      // appBar: AppBar(
      //   title: const Text('Chat'),
      //   centerTitle: true,
      // ),
      body: Center(
        child: Container(
          color: const Color.fromARGB(255, 0, 20, 50),
          constraints: BoxConstraints(
            maxWidth: 800,
            maxHeight: MediaQuery.of(context).size.height,
          ),
          child: ChatView(
            //loadMoreData:
            currentUser: currentUser,
            chatController: _chatController,
            onSendTap: _onSendTap,
            featureActiveConfig: const FeatureActiveConfig(
              lastSeenAgoBuilderVisibility: false,
              receiptsBuilderVisibility: true,
              enableDoubleTapToLike: false,
            ),
            chatViewState: ChatViewState.hasMessages,
            chatViewStateConfig: ChatViewStateConfiguration(
              loadingWidgetConfig: ChatViewStateWidgetConfiguration(
                loadingIndicatorColor: theme.outgoingChatBubbleColor,
              ),
              onReloadButtonTap: () {},
            ),
            typeIndicatorConfig: TypeIndicatorConfiguration(
              flashingCircleBrightColor: theme.flashingCircleBrightColor,
              flashingCircleDarkColor: theme.flashingCircleDarkColor,
            ),
            appBar: ChatViewAppBar(
              padding: const EdgeInsets.only(top: 15, bottom: 10),
              elevation: theme.elevation,
              //backGroundColor: const Color.fromARGB(255, 14, 14, 14),
              backGroundColor: const Color.fromARGB(255, 0, 6, 15),
              profilePicture: fotoUrl,
              backArrowColor: theme.backArrowColor,
              chatTitle: widget.agenteNome ?? 'Agente',
              chatTitleTextStyle: TextStyle(
                color: theme.appBarTitleTextStyle,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.25,
              ),
            ),
            chatBackgroundConfig: ChatBackgroundConfiguration(
              messageTimeIconColor: theme.messageTimeIconColor,
              messageTimeTextStyle:
                  TextStyle(color: theme.messageTimeTextColor),
              defaultGroupSeparatorConfig: DefaultGroupSeparatorConfiguration(
                textStyle: TextStyle(
                  color: theme.chatHeaderColor,
                  fontSize: 17,
                ),
              ),
              //backgroundColor: const Color.fromARGB(255, 14, 14, 14),
              backgroundColor: const Color.fromARGB(255, 0, 6, 15),
            ),
            sendMessageConfig: SendMessageConfiguration(
              imagePickerIconsConfig: ImagePickerIconsConfiguration(
                cameraIconColor: theme.cameraIconColor,
                galleryIconColor: theme.galleryIconColor,
              ),
              replyMessageColor: theme.replyMessageColor,
              defaultSendButtonColor: theme.sendButtonColor,
              replyDialogColor: theme.replyDialogColor,
              replyTitleColor: theme.replyTitleColor,
              textFieldBackgroundColor: theme.textFieldBackgroundColor,
              closeIconColor: theme.closeIconColor,
              textFieldConfig: TextFieldConfiguration(
                onMessageTyping: (status) {
                  /// Do with status
                  debugPrint(status.toString());
                },
                compositionThresholdTime: const Duration(seconds: 1),
                textStyle: TextStyle(color: theme.textFieldTextColor),
              ),
              micIconColor: theme.replyMicIconColor,
              voiceRecordingConfiguration: VoiceRecordingConfiguration(
                backgroundColor: theme.waveformBackgroundColor,
                recorderIconColor: theme.recordIconColor,
                waveStyle: WaveStyle(
                  showMiddleLine: false,
                  waveColor: theme.waveColor ?? Colors.white,
                  extendWaveform: true,
                ),
              ),
            ),
            chatBubbleConfig: ChatBubbleConfiguration(
              outgoingChatBubbleConfig: ChatBubble(
                linkPreviewConfig: LinkPreviewConfiguration(
                  backgroundColor: theme.linkPreviewOutgoingChatColor,
                  bodyStyle: theme.outgoingChatLinkBodyStyle,
                  titleStyle: theme.outgoingChatLinkTitleStyle,
                ),
                receiptsWidgetConfig: const ReceiptsWidgetConfig(
                    showReceiptsIn: ShowReceiptsIn.all),
                color: theme.outgoingChatBubbleColor,
              ),
              inComingChatBubbleConfig: ChatBubble(
                linkPreviewConfig: LinkPreviewConfiguration(
                  linkStyle: TextStyle(
                    color: theme.inComingChatBubbleTextColor,
                    decoration: TextDecoration.underline,
                  ),
                  backgroundColor: theme.linkPreviewIncomingChatColor,
                  bodyStyle: theme.incomingChatLinkBodyStyle,
                  titleStyle: theme.incomingChatLinkTitleStyle,
                ),
                textStyle: TextStyle(color: theme.inComingChatBubbleTextColor),
                onMessageRead: (message) {
                  /// send your message reciepts to the other client
                  debugPrint('Message Read');
                },
                senderNameTextStyle:
                    TextStyle(color: theme.inComingChatBubbleTextColor),
                color: theme.inComingChatBubbleColor,
              ),
            ),
            replyPopupConfig: ReplyPopupConfiguration(
              backgroundColor: theme.replyPopupColor,
              buttonTextStyle: TextStyle(color: theme.replyPopupButtonColor),
              topBorderColor: theme.replyPopupTopBorderColor,
            ),
            reactionPopupConfig: ReactionPopupConfiguration(
              shadow: BoxShadow(
                color: isDarkTheme ? Colors.black54 : Colors.grey.shade400,
                blurRadius: 20,
              ),
              backgroundColor: theme.reactionPopupColor,
            ),
            messageConfig: MessageConfiguration(
              messageReactionConfig: MessageReactionConfiguration(
                backgroundColor: theme.messageReactionBackGroundColor,
                borderColor: theme.messageReactionBackGroundColor,
                reactedUserCountTextStyle:
                    TextStyle(color: theme.inComingChatBubbleTextColor),
                reactionCountTextStyle:
                    TextStyle(color: theme.inComingChatBubbleTextColor),
                reactionsBottomSheetConfig: ReactionsBottomSheetConfiguration(
                  backgroundColor: theme.backgroundColor,
                  reactedUserTextStyle: TextStyle(
                    color: theme.inComingChatBubbleTextColor,
                  ),
                  reactionWidgetDecoration: BoxDecoration(
                    color: theme.inComingChatBubbleColor,
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDarkTheme ? Colors.black12 : Colors.grey.shade200,
                        offset: const Offset(0, 20),
                        blurRadius: 40,
                      )
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              imageMessageConfig: ImageMessageConfiguration(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                shareIconConfig: ShareIconConfiguration(
                  defaultIconBackgroundColor: theme.shareIconBackgroundColor,
                  defaultIconColor: theme.shareIconColor,
                  onPressed: (foto) async {
                    dialogoParaEnviarImagem(foto);
                  },
                ),
              ),
            ),
            profileCircleConfig: ProfileCircleConfiguration(
              profileImageUrl: fotoUrl,
            ),
            repliedMessageConfig: RepliedMessageConfiguration(
              backgroundColor: theme.repliedMessageColor,
              verticalBarColor: theme.verticalBarColor,
              repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                enableHighlightRepliedMsg: true,
                highlightColor: Colors.pinkAccent.shade100,
                highlightScale: 1.1,
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.25,
              ),
              replyTitleTextStyle:
                  TextStyle(color: theme.repliedTitleTextColor),
            ),
            swipeToReplyConfig: SwipeToReplyConfiguration(
              replyIconColor: theme.swipeToReplyIconColor,
            ),
          ),
        ),
      ),
    );
  }

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) async {
    debugPrint('messagetype: ${messageType.name}');
    debugPrint('MessaType: ${messageType.toString()}');

    final lastid = messageList.isEmpty ? '0' : messageList.last.id;
    final id = int.parse(lastid) + 1;
    await _chatController.sendMessageChatMissaoToFirestore(
      Message(
        id: id.toString(),
        createdAt: DateTime.now(),
        message: message,
        sendBy: currentUser.id,
        replyMessage: replyMessage,
        messageType: messageType,
        voiceMessageDuration: MessageType.voice == messageType
            ? const Duration(minutes: 10).inSeconds
            : null,
        autor: 'Atendente',
      ),
    );

    // Enviar a notificação usando o token FCM.
    List<String> userTokens =
        await chatServices.fetchUserTokens(widget.agenteUid!);

    for (String token in userTokens) {
      await firebaseMessagingService.sendNotification(
          token, 'Nova mensagem', message, null);
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    });
  }

  void dialogoParaEnviarImagem(String foto) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enviar imagem?'),
          content: Image.network(foto),
          actions: [
            BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
              builder: (context, state) {
                if (state is ElevatedButtonBlocLoading) {
                  return const CircularProgressIndicator();
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        context
                            .read<ElevatedButtonBloc>()
                            .add(ElevatedButtonPressed());
                        try {
                          final lastid =
                              messageList.isEmpty ? '0' : messageList.last.id;
                          final id = int.parse(lastid) + 1;
                          await _chatController
                              .sendMessageChatMissaoClienteToFirestore(
                                  Message(
                                    id: id.toString(),
                                    createdAt: DateTime.now(),
                                    message: foto,
                                    sendBy: currentUser.id,
                                    replyMessage: const ReplyMessage(),
                                    messageType: MessageType.image,
                                    voiceMessageDuration: null,
                                    autor: 'Atendente',
                                  ),
                                  newChatCollection: 'Chat missão cliente');
                          context.mounted
                              ? ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Foto compartilhada com sucesso!'),
                                  ),
                                )
                              : null;
                        } catch (e) {
                          debugPrint('Erro ao enviar imagem: $e');
                          context.mounted
                              ? ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Erro ao compartilhar imagem, tente novamente!'),
                                  ),
                                )
                              : null;
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          context
                              .read<ElevatedButtonBloc>()
                              .add(ElevatedButtonReset());
                        }
                      },
                      child: const Text('Enviar'),
                    ),
                  ],
                );
              },
            )
          ],
        );
      },
    );
  }

  void _onThemeIconTap() {
    setState(() {
      if (isDarkTheme) {
        theme = LightTheme();
        isDarkTheme = false;
      } else {
        theme = DarkTheme();
        isDarkTheme = true;
      }
    });
  }
}


















  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//   final ChatServices chatServices = ChatServices();
//   final TextEditingController _bodyController = TextEditingController();
//   ValueNotifier<bool> isSubmitting = ValueNotifier(false);
//   StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _listener;
//   ScrollController controller = ScrollController();
//   bool firstLoad = true;

//   Stream<QuerySnapshot<Map<String, dynamic>>> getConversationMessages() {
//     return FirebaseFirestore.instance
//         .collection('Chat missão')
//         .doc(widget.missaoId)
//         .collection('Mensagens')
//         .orderBy('Timestamp', descending: false)
//         .snapshots();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _listener = FirebaseFirestore.instance
//         .collection('Chat missão')
//         .doc(widget.missaoId)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists) {
//         FirebaseFirestore.instance
//             .collection('Chat missão')
//             .doc(widget.missaoId)
//             .update({'unreadCount': 0});
//       }
//     });
//     getConversationMessages();
//   }

//   @override
//   void dispose() {
//     _listener?.cancel();
//     controller.dispose();
//     _bodyController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     final userUid = user?.uid;
//     final userName = user?.displayName;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.grey[900],
//         title: const Text('Chat'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: getConversationMessages(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<QuerySnapshot> snapshot) {
//                 debugPrint("Mensagens Snapshot Data: ${snapshot.data}");
//                 if (snapshot.hasError) {
//                   return Text('Erro: ${snapshot.error}');
//                 }

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 }

//                 if (firstLoad) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     controller.jumpTo(controller.position.maxScrollExtent);
//                   });
//                   firstLoad = false;
//                 }

//                 return Listener(
//                   onPointerDown: (_) {
//                     FocusScope.of(context).unfocus();
//                   },
//                   child: ListView.builder(
//                     controller: controller,
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (context, index) {
//                       Map<String, dynamic> data = snapshot.data!.docs[index]
//                           .data() as Map<String, dynamic>;
//                       final autor = data['Autor'];
//                       final messageText = data['Mensagem'];
//                       final imageUrl = data['Imagem'];
//                       final timestamp = data['Timestamp'];
//                       final isCurrentUser = autor == "Atendente";

//                       return MessageBubbleAtendente(
//                         message: messageText,
//                         sender: autor,
//                         isCurrentUser: isCurrentUser,
//                         imageUrl: imageUrl,
//                         timestamp: timestamp,
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(30.0),
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: LayoutBuilder(
//                       builder:
//                           (BuildContext context, BoxConstraints constraints) {
//                         return Center(
//                           child: TextFormField(
//                             style: const TextStyle(color: Colors.white),
//                             controller: _bodyController,
//                             minLines: 1,
//                             maxLines: 5,
//                             maxLength: 500,
//                             decoration: InputDecoration(
//                               labelText: 'Digite sua mensagem aqui',
//                               labelStyle: const TextStyle(color: Colors.grey),
//                               enabledBorder: OutlineInputBorder(
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 10.0,
//                                 horizontal: 10.0,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   ValueListenableBuilder(
//                     valueListenable: isSubmitting,
//                     builder: (context, bool value, child) {
//                       return Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           value
//                               ? const CircularProgressIndicator()
//                               : RawMaterialButton(
//                                   onPressed: value
//                                       ? null
//                                       : () async {
//                                           isSubmitting.value = true;
//                                           if (_bodyController.text
//                                               .trim()
//                                               .isNotEmpty) {
//                                             chatServices.addCentralMsgMissao(
//                                                 _bodyController,
//                                                 userName,
//                                                 userUid,
//                                                 widget.missaoId);
//                                           }
//                                           isSubmitting.value = false;
//                                           controller.animateTo(
//                                             controller.position.maxScrollExtent,
//                                             duration: const Duration(
//                                                 milliseconds: 300),
//                                             curve: Curves.easeOut,
//                                           );
//                                         },
//                                   shape: const CircleBorder(),
//                                   fillColor: Colors.blue,
//                                   constraints: const BoxConstraints.expand(
//                                       width: 40, height: 40),
//                                   child: const Icon(
//                                     Icons.send,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                           if (value) const CircularProgressIndicator(),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
