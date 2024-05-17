import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sombra_testes/chat/services/chat_services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../chat_view/chatview.dart';
import '../../notificacoes/fcm.dart';
import '../../notificacoes/notificacoess.dart';

class ChatScreen extends StatefulWidget {
  final String? uid;
  final String? agenteUid;
  final String? agenteNome;
  const ChatScreen({super.key, this.uid, this.agenteUid, this.agenteNome});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

String fotoUrl =
    'https://firebasestorage.googleapis.com/v0/b/sombratestes.appspot.com/o/FotoNull%2FfotoDePerfilNull.jpg?alt=media&token=bec8dce5-1251-418a-821d-0ded68cf42e7';

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgController = TextEditingController();
  final ValueNotifier<bool> isSubmitting = ValueNotifier(false);
  final ScrollController controller = ScrollController();
  bool firstLoad = true;
  late final FirebaseMessaging firebaseMessaging;
  final ChatServices chatServices = ChatServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final ChatStatus chatStatus = ChatStatus();
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

  Stream<QuerySnapshot<Map<String, dynamic>>> getConversationMessages() {
    return FirebaseFirestore.instance
        .collection('Chat')
        .doc(uid!)
        .collection('Mensagens')
        .orderBy('Timestamp', descending: false)
        .snapshots();
  }

  Future<void> resetUserUnreadCount(String uid) async {
    await FirebaseFirestore.instance
        .collection('Chat')
        .doc(uid)
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
      chatCollection: 'Chat',
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
    chatServices.resetUnreadCount(widget.agenteUid!);
    chatViewController.startListeningForNewMessages();
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
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    resetUserUnreadCount(userUid!);
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 14, 14, 14),
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      // appBar: AppBar(
      //   title: const Text('Chat'),
      //   centerTitle: true,
      // ),
      body: Center(
        child: Container(
          color: Color.fromARGB(255, 0, 20, 50),
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
              backGroundColor: Color.fromARGB(255, 0, 6, 15),
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
              backgroundColor: Color.fromARGB(255, 0, 6, 15),
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
                  onPressed: (p0) {},
                ),
              ),
            ),
            // profileCircleConfig: ProfileCircleConfiguration(
            //   profileImageUrl: fotoUrl,
            // ),
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
    await _chatController.sendMessageToFirestore(
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
    debugPrint('Enviando notificação');
    debugPrint('agenteUid: ${widget.agenteUid}');
    List<String> userTokens =
        await chatServices.fetchUserTokens(widget.agenteUid!);

    debugPrint('userTokens: $userTokens');

    for (String token in userTokens) {
      debugPrint('Token: $token');
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

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
      NetworkImage(imageUrl).resolve(const ImageConfiguration());
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

class AppTheme {
  final Color? appBarColor;
  final Color? backArrowColor;
  final Color? backgroundColor;
  final Color? replyDialogColor;
  final Color? replyTitleColor;
  final Color? textFieldBackgroundColor;

  final Color? outgoingChatBubbleColor;

  final Color? inComingChatBubbleColor;

  final Color? inComingChatBubbleTextColor;
  final Color? repliedMessageColor;
  final Color? repliedTitleTextColor;
  final Color? textFieldTextColor;

  final Color? closeIconColor;
  final Color? shareIconBackgroundColor;

  final Color? sendButtonColor;
  final Color? cameraIconColor;
  final Color? galleryIconColor;
  final Color? recordIconColor;
  final Color? stopIconColor;
  final Color? swipeToReplyIconColor;
  final Color? replyMessageColor;
  final Color? appBarTitleTextStyle;
  final Color? messageReactionBackGroundColor;
  final Color? messageTimeIconColor;
  final Color? messageTimeTextColor;
  final Color? reactionPopupColor;
  final Color? replyPopupColor;
  final Color? replyPopupButtonColor;
  final Color? replyPopupTopBorderColor;
  final Color? reactionPopupTitleColor;
  final Color? flashingCircleDarkColor;
  final Color? flashingCircleBrightColor;
  final Color? waveformBackgroundColor;
  final Color? waveColor;
  final Color? replyMicIconColor;
  final Color? messageReactionBorderColor;

  final Color? verticalBarColor;
  final Color? chatHeaderColor;
  final Color? themeIconColor;
  final Color? shareIconColor;
  final double? elevation;
  final Color? linkPreviewIncomingChatColor;
  final Color? linkPreviewOutgoingChatColor;
  final TextStyle? linkPreviewIncomingTitleStyle;
  final TextStyle? linkPreviewOutgoingTitleStyle;
  final TextStyle? incomingChatLinkTitleStyle;
  final TextStyle? outgoingChatLinkTitleStyle;
  final TextStyle? outgoingChatLinkBodyStyle;
  final TextStyle? incomingChatLinkBodyStyle;

  AppTheme({
    this.cameraIconColor,
    this.galleryIconColor,
    this.flashingCircleDarkColor,
    this.flashingCircleBrightColor,
    this.outgoingChatLinkBodyStyle,
    this.incomingChatLinkBodyStyle,
    this.incomingChatLinkTitleStyle,
    this.outgoingChatLinkTitleStyle,
    this.linkPreviewOutgoingChatColor,
    this.linkPreviewIncomingChatColor,
    this.linkPreviewIncomingTitleStyle,
    this.linkPreviewOutgoingTitleStyle,
    this.repliedTitleTextColor,
    this.swipeToReplyIconColor,
    this.textFieldTextColor,
    this.reactionPopupColor,
    this.replyPopupButtonColor,
    this.replyPopupTopBorderColor,
    this.reactionPopupTitleColor,
    this.appBarColor,
    this.backArrowColor,
    this.backgroundColor,
    this.replyDialogColor,
    this.replyTitleColor,
    this.textFieldBackgroundColor,
    this.outgoingChatBubbleColor,
    this.inComingChatBubbleColor,
    this.inComingChatBubbleTextColor,
    this.repliedMessageColor,
    this.closeIconColor,
    this.shareIconBackgroundColor,
    this.sendButtonColor,
    this.replyMessageColor,
    this.appBarTitleTextStyle,
    this.messageReactionBackGroundColor,
    this.messageReactionBorderColor,
    this.verticalBarColor,
    this.chatHeaderColor,
    this.themeIconColor,
    this.shareIconColor,
    this.elevation,
    this.messageTimeIconColor,
    this.messageTimeTextColor,
    this.replyPopupColor,
    this.recordIconColor,
    this.stopIconColor,
    this.waveformBackgroundColor,
    this.waveColor,
    this.replyMicIconColor,
  });
}

class DarkTheme extends AppTheme {
  DarkTheme({
    Color flashingCircleDarkColor = Colors.grey,
    Color flashingCircleBrightColor = const Color(0xffeeeeee),
    TextStyle incomingChatLinkTitleStyle = const TextStyle(color: Colors.black),
    TextStyle outgoingChatLinkTitleStyle = const TextStyle(color: Colors.white),
    TextStyle outgoingChatLinkBodyStyle = const TextStyle(color: Colors.white),
    TextStyle incomingChatLinkBodyStyle = const TextStyle(color: Colors.white),
    double elevation = 1,
    Color repliedTitleTextColor = Colors.white,
    Color? swipeToReplyIconColor = Colors.white,
    Color textFieldTextColor = Colors.white,
    Color appBarColor = const Color.fromARGB(255, 27, 31, 37),
    Color backArrowColor = Colors.white,
    Color backgroundColor = const Color.fromARGB(255, 35, 42, 54),
    Color replyDialogColor = const Color.fromARGB(255, 35, 43, 54),
    Color linkPreviewOutgoingChatColor = const Color.fromARGB(255, 35, 43, 54),
    Color linkPreviewIncomingChatColor =
        const Color.fromARGB(255, 133, 180, 255),
    TextStyle linkPreviewIncomingTitleStyle = const TextStyle(),
    TextStyle linkPreviewOutgoingTitleStyle = const TextStyle(),
    Color replyTitleColor = Colors.white,
    Color textFieldBackgroundColor = const Color.fromARGB(255, 36, 54, 102),
    Color outgoingChatBubbleColor = Colors.blue,
    Color inComingChatBubbleColor = const Color.fromARGB(255, 49, 64, 82),
    Color reactionPopupColor = const Color.fromARGB(255, 49, 63, 82),
    Color replyPopupColor = const Color.fromARGB(255, 49, 64, 82),
    Color replyPopupButtonColor = Colors.white,
    Color replyPopupTopBorderColor = Colors.black54,
    Color reactionPopupTitleColor = Colors.white,
    Color inComingChatBubbleTextColor = Colors.white,
    Color repliedMessageColor = const Color.fromARGB(255, 133, 178, 255),
    Color closeIconColor = Colors.white,
    Color shareIconBackgroundColor = const Color.fromARGB(255, 49, 60, 82),
    Color sendButtonColor = Colors.white,
    Color cameraIconColor = const Color(0xff757575),
    Color galleryIconColor = const Color(0xff757575),
    Color recorderIconColor = const Color(0xff757575),
    Color stopIconColor = const Color(0xff757575),
    Color replyMessageColor = Colors.grey,
    Color appBarTitleTextStyle = Colors.white,
    Color messageReactionBackGroundColor =
        const Color.fromARGB(255, 31, 45, 79),
    Color messageReactionBorderColor = const Color.fromARGB(255, 29, 52, 88),
    Color verticalBarColor = const Color.fromARGB(255, 34, 53, 87),
    Color chatHeaderColor = Colors.white,
    Color themeIconColor = Colors.white,
    Color shareIconColor = Colors.white,
    Color messageTimeIconColor = Colors.white,
    Color messageTimeTextColor = Colors.white,
    Color waveformBackgroundColor = const Color.fromARGB(255, 22, 36, 78),
    Color waveColor = Colors.white,
    Color replyMicIconColor = Colors.white,
  }) : super(
          closeIconColor: closeIconColor,
          verticalBarColor: verticalBarColor,
          textFieldBackgroundColor: textFieldBackgroundColor,
          replyTitleColor: replyTitleColor,
          replyDialogColor: replyDialogColor,
          backgroundColor: backgroundColor,
          appBarColor: appBarColor,
          appBarTitleTextStyle: appBarTitleTextStyle,
          backArrowColor: backArrowColor,
          chatHeaderColor: chatHeaderColor,
          inComingChatBubbleColor: inComingChatBubbleColor,
          inComingChatBubbleTextColor: inComingChatBubbleTextColor,
          messageReactionBackGroundColor: messageReactionBackGroundColor,
          messageReactionBorderColor: messageReactionBorderColor,
          outgoingChatBubbleColor: outgoingChatBubbleColor,
          repliedMessageColor: repliedMessageColor,
          replyMessageColor: replyMessageColor,
          sendButtonColor: sendButtonColor,
          shareIconBackgroundColor: shareIconBackgroundColor,
          themeIconColor: themeIconColor,
          shareIconColor: shareIconColor,
          elevation: elevation,
          messageTimeIconColor: messageTimeIconColor,
          messageTimeTextColor: messageTimeTextColor,
          textFieldTextColor: textFieldTextColor,
          repliedTitleTextColor: repliedTitleTextColor,
          swipeToReplyIconColor: swipeToReplyIconColor,
          reactionPopupColor: reactionPopupColor,
          replyPopupColor: replyPopupColor,
          replyPopupButtonColor: replyPopupButtonColor,
          replyPopupTopBorderColor: replyPopupTopBorderColor,
          reactionPopupTitleColor: reactionPopupTitleColor,
          linkPreviewOutgoingChatColor: linkPreviewOutgoingChatColor,
          linkPreviewIncomingChatColor: linkPreviewIncomingChatColor,
          linkPreviewIncomingTitleStyle: linkPreviewIncomingTitleStyle,
          linkPreviewOutgoingTitleStyle: linkPreviewOutgoingTitleStyle,
          incomingChatLinkBodyStyle: incomingChatLinkBodyStyle,
          incomingChatLinkTitleStyle: incomingChatLinkTitleStyle,
          outgoingChatLinkBodyStyle: outgoingChatLinkBodyStyle,
          outgoingChatLinkTitleStyle: outgoingChatLinkTitleStyle,
          flashingCircleDarkColor: flashingCircleDarkColor,
          flashingCircleBrightColor: flashingCircleBrightColor,
          galleryIconColor: galleryIconColor,
          cameraIconColor: cameraIconColor,
          recordIconColor: recorderIconColor,
          stopIconColor: stopIconColor,
          waveformBackgroundColor: waveformBackgroundColor,
          waveColor: waveColor,
          replyMicIconColor: replyMicIconColor,
        );
}

class LightTheme extends AppTheme {
  LightTheme({
    Color flashingCircleDarkColor = const Color(0xffEE5366),
    Color flashingCircleBrightColor = const Color(0xffFCD8DC),
    TextStyle incomingChatLinkTitleStyle = const TextStyle(color: Colors.black),
    TextStyle outgoingChatLinkTitleStyle = const TextStyle(color: Colors.black),
    TextStyle outgoingChatLinkBodyStyle = const TextStyle(color: Colors.grey),
    TextStyle incomingChatLinkBodyStyle = const TextStyle(color: Colors.grey),
    Color textFieldTextColor = Colors.black,
    Color repliedTitleTextColor = Colors.black,
    Color swipeToReplyIconColor = Colors.black,
    double elevation = 2,
    Color appBarColor = Colors.white,
    Color backArrowColor = const Color(0xffEE5366),
    Color backgroundColor = const Color(0xffeeeeee),
    Color replyDialogColor = const Color(0xffFCD8DC),
    Color linkPreviewOutgoingChatColor = const Color(0xffFCD8DC),
    Color linkPreviewIncomingChatColor = const Color(0xFFEEEEEE),
    TextStyle linkPreviewIncomingTitleStyle = const TextStyle(),
    TextStyle linkPreviewOutgoingTitleStyle = const TextStyle(),
    Color replyTitleColor = const Color(0xffEE5366),
    Color reactionPopupColor = Colors.white,
    Color replyPopupColor = Colors.white,
    Color replyPopupButtonColor = Colors.black,
    Color replyPopupTopBorderColor = const Color(0xFFBDBDBD),
    Color reactionPopupTitleColor = Colors.grey,
    Color textFieldBackgroundColor = Colors.white,
    Color outgoingChatBubbleColor = const Color(0xffEE5366),
    Color inComingChatBubbleColor = Colors.white,
    Color inComingChatBubbleTextColor = Colors.black,
    Color repliedMessageColor = const Color(0xffff8aad),
    Color closeIconColor = Colors.black,
    Color shareIconBackgroundColor = const Color(0xFFE0E0E0),
    Color sendButtonColor = const Color(0xffEE5366),
    Color cameraIconColor = Colors.black,
    Color galleryIconColor = Colors.black,
    Color replyMessageColor = Colors.black,
    Color appBarTitleTextStyle = Colors.black,
    Color messageReactionBackGroundColor = const Color(0xFFEEEEEE),
    Color messageReactionBorderColor = Colors.white,
    Color verticalBarColor = const Color(0xffEE5366),
    Color chatHeaderColor = Colors.black,
    Color themeIconColor = Colors.black,
    Color shareIconColor = Colors.black,
    Color messageTimeIconColor = Colors.black,
    Color messageTimeTextColor = Colors.black,
    Color recorderIconColor = Colors.black,
    Color stopIconColor = Colors.black,
    Color waveformBackgroundColor = Colors.white,
    Color waveColor = Colors.black,
    Color replyMicIconColor = Colors.black,
  }) : super(
          reactionPopupColor: reactionPopupColor,
          closeIconColor: closeIconColor,
          verticalBarColor: verticalBarColor,
          textFieldBackgroundColor: textFieldBackgroundColor,
          replyTitleColor: replyTitleColor,
          replyDialogColor: replyDialogColor,
          backgroundColor: backgroundColor,
          appBarColor: appBarColor,
          appBarTitleTextStyle: appBarTitleTextStyle,
          backArrowColor: backArrowColor,
          chatHeaderColor: chatHeaderColor,
          inComingChatBubbleColor: inComingChatBubbleColor,
          inComingChatBubbleTextColor: inComingChatBubbleTextColor,
          messageReactionBackGroundColor: messageReactionBackGroundColor,
          messageReactionBorderColor: messageReactionBorderColor,
          outgoingChatBubbleColor: outgoingChatBubbleColor,
          repliedMessageColor: repliedMessageColor,
          replyMessageColor: replyMessageColor,
          sendButtonColor: sendButtonColor,
          shareIconBackgroundColor: shareIconBackgroundColor,
          themeIconColor: themeIconColor,
          shareIconColor: shareIconColor,
          elevation: elevation,
          messageTimeIconColor: messageTimeIconColor,
          messageTimeTextColor: messageTimeTextColor,
          textFieldTextColor: textFieldTextColor,
          repliedTitleTextColor: repliedTitleTextColor,
          swipeToReplyIconColor: swipeToReplyIconColor,
          replyPopupColor: replyPopupColor,
          replyPopupButtonColor: replyPopupButtonColor,
          replyPopupTopBorderColor: replyPopupTopBorderColor,
          reactionPopupTitleColor: reactionPopupTitleColor,
          linkPreviewOutgoingChatColor: linkPreviewOutgoingChatColor,
          linkPreviewIncomingChatColor: linkPreviewIncomingChatColor,
          linkPreviewIncomingTitleStyle: linkPreviewIncomingTitleStyle,
          linkPreviewOutgoingTitleStyle: linkPreviewOutgoingTitleStyle,
          incomingChatLinkBodyStyle: incomingChatLinkBodyStyle,
          incomingChatLinkTitleStyle: incomingChatLinkTitleStyle,
          outgoingChatLinkBodyStyle: outgoingChatLinkBodyStyle,
          outgoingChatLinkTitleStyle: outgoingChatLinkTitleStyle,
          flashingCircleDarkColor: flashingCircleDarkColor,
          flashingCircleBrightColor: flashingCircleBrightColor,
          galleryIconColor: galleryIconColor,
          cameraIconColor: cameraIconColor,
          stopIconColor: stopIconColor,
          recordIconColor: recorderIconColor,
          waveformBackgroundColor: waveformBackgroundColor,
          waveColor: waveColor,
          replyMicIconColor: replyMicIconColor,
        );
}
