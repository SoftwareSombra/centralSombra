import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sombra/chat/services/chat_services.dart';
import '../../chat_view/chatview.dart';
import '../../notificacoes/fcm.dart';
import '../../notificacoes/notificacoess.dart';
import 'chat_screen.dart';

class ClienteChatScreen extends StatefulWidget {
  final String? cnpj;
  final String? empresaNome;

  const ClienteChatScreen({super.key, this.cnpj, this.empresaNome});

  @override
  State<ClienteChatScreen> createState() => _ClienteChatScreenState();
}

class _ClienteChatScreenState extends State<ClienteChatScreen> {
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
        .collection('Chat cliente')
        .doc(widget.cnpj)
        .set({'unreadCount': 0}, SetOptions(merge: true));
  }

  Future<void> getCurrentChatUser() async {
    final user = FirebaseAuth.instance.currentUser;
    final userPhoto = user?.photoURL;
    setState(() {
      currentUser = ChatUser(
        id: 'Atendente',
        name: 'Atendente',
        profilePhoto: userPhoto!,
      );
    });
  }

  Future<void> chatController(uid, agenteUid) async {
    _chatController = ChatController(
      initialMessageList: messageList,
      scrollController: ScrollController(),
      chatId: agenteUid,
      chatUsers: [
        ChatUser(
          id: 'Atendente',
          name: 'Atendente',
          profilePhoto: fotoUrl,
        ),
        ChatUser(
          id: 'Cliente',
          name: 'Cliente',
        ),
      ],
      chatCollection: 'Chat cliente',
      missaoId: widget.cnpj,
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
    chatController(uid!, widget.cnpj!);
    getCurrentChatUser();

    chatViewController.startListeningForNewChatClienteMessages();
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
      //backgroundColor: canvasColor.withAlpha(15),
      body: Center(
        child: Container(
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
              profilePicture: fotoUrl,
              backArrowColor: canvasColor,
              chatTitle: widget.empresaNome ?? 'Cliente',
              chatTitleTextStyle: const TextStyle(
                color: canvasColor,
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
            ),
            sendMessageConfig: SendMessageConfiguration(
              imagePickerIconsConfig: ImagePickerIconsConfiguration(
                cameraIconColor: theme.cameraIconColor,
                galleryIconColor: theme.galleryIconColor,
              ),
              replyMessageColor: theme.replyMessageColor,
              defaultSendButtonColor: Colors.blue,
              replyDialogColor: theme.replyDialogColor,
              replyTitleColor: theme.replyTitleColor,
              textFieldBackgroundColor: canvasColor.withAlpha(15),
              closeIconColor: theme.closeIconColor,
              textFieldConfig: TextFieldConfiguration(
                onMessageTyping: (status) {
                  /// Do with status
                  debugPrint(status.toString());
                },
                compositionThresholdTime: const Duration(seconds: 1),
                textStyle: const TextStyle(color: Colors.black),
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
                ),
                onTap: (message) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: PhotoView(
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.contained * 2.5,
                            imageProvider: NetworkImage(message),
                          ),
                        ),
                      );
                    },
                  );
                },
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
    await _chatController.sendMessageChatClienteToFirestore(
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
    // Incrementar unreadCount quando o atendente envia uma mensagem
    // await FirebaseFirestore.instance
    //     .collection('Chat cliente')
    //     .doc(widget.cnpj)
    //     .set({'userUnreadCount': FieldValue.increment(1)}, SetOptions(merge: true));

    // Enviar a notificação usando o token FCM.
    // List<String> userTokens =
    //     await chatServices.fetchUserTokens(widget.agenteUid!);

    // for (String token in userTokens) {
    //   await firebaseMessagingService.sendNotification(
    //       token, 'Nova mensagem', message, null);
    // }
    Future.delayed(const Duration(milliseconds: 300), () {
      _chatController.initialMessageList.last.setStatus =
          MessageStatus.undelivered;
    });
    Future.delayed(const Duration(seconds: 1), () {
      _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    });
  }
}
