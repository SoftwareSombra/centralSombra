/*
 * Copyright (c) 2022 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sombra/chat_view/src/extensions/extensions.dart';
import '../../chatview.dart';
import '../utils/constants/constants.dart';
import 'chat_view_inherited_widget.dart';
import 'message_time_widget.dart';
import 'message_view.dart';
import 'profile_circle.dart';
import 'reply_message_widget.dart';
import 'swipe_to_reply.dart';

class ChatBubbleWidget extends StatefulWidget {
  const ChatBubbleWidget(
      {required GlobalKey key,
      required this.message,
      required this.onLongPress,
      required this.slideAnimation,
      required this.onSwipe,
      this.profileCircleConfig,
      this.chatBubbleConfig,
      this.repliedMessageConfig,
      this.swipeToReplyConfig,
      this.messageTimeTextStyle,
      this.messageTimeIconColor,
      this.messageConfig,
      this.onReplyTap,
      this.shouldHighlight = false,
      this.compartilhavel,
      this.infoAdicional,
      this.infoAdicional2})
      : super(key: key);

  final String? infoAdicional;

  final String? infoAdicional2;

  final bool? compartilhavel;

  /// Represent current instance of message.
  final Message message;

  /// Give callback once user long press on chat bubble.
  final DoubleCallBack onLongPress;

  /// Provides configuration related to user profile circle avatar.
  final ProfileCircleConfiguration? profileCircleConfig;

  /// Provides configurations related to chat bubble such as padding, margin, max
  /// width etc.
  final ChatBubbleConfiguration? chatBubbleConfig;

  /// Provides configurations related to replied message such as textstyle
  /// padding, margin etc. Also, this widget is located upon chat bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides configurations related to swipe chat bubble which triggers
  /// when user swipe chat bubble.
  final SwipeToReplyConfiguration? swipeToReplyConfig;

  /// Provides textStyle of message created time when user swipe whole chat.
  final TextStyle? messageTimeTextStyle;

  /// Provides default icon color of message created time view when user swipe
  /// whole chat.
  final Color? messageTimeIconColor;

  /// Provides slide animation when user swipe whole chat.
  final Animation<Offset>? slideAnimation;

  /// Provides configuration of all types of messages.
  final MessageConfiguration? messageConfig;

  /// Provides callback of when user swipe chat bubble for reply.
  final MessageCallBack onSwipe;

  /// Provides callback when user tap on replied message upon chat bubble.
  final Function(String)? onReplyTap;

  /// Flag for when user tap on replied message and highlight actual message.
  final bool shouldHighlight;

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  String get replyMessage => widget.message.replyMessage.message;

  bool get isMessageBySender => widget.message.sendBy == currentUser?.id;

  bool get isLastMessage =>
      chatController?.initialMessageList.last.id == widget.message.id;

  ProfileCircleConfiguration? get profileCircleConfig =>
      widget.profileCircleConfig;
  FeatureActiveConfig? featureActiveConfig;
  ChatController? chatController;
  ChatUser? currentUser;
  int? maxDuration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      featureActiveConfig = provide!.featureActiveConfig;
      chatController = provide!.chatController;
      currentUser = provide!.currentUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user from id.
    final messagedUser = chatController?.getUserFromId(widget.message.sendBy);
    return Stack(
      children: [
        if (featureActiveConfig?.enableSwipeToSeeTime ?? true) ...[
          Visibility(
            visible: widget.slideAnimation?.value.dx == 0.0 ? false : true,
            child: Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: MessageTimeWidget(
                  messageTime: widget.message.createdAt,
                  isCurrentUser: isMessageBySender,
                  messageTimeIconColor: widget.messageTimeIconColor,
                  messageTimeTextStyle: widget.messageTimeTextStyle,
                ),
              ),
            ),
          ),
          SlideTransition(
            position: widget.slideAnimation!,
            child: _chatBubbleWidget(messagedUser),
          ),
        ] else
          _chatBubbleWidget(messagedUser),
      ],
    );
  }

  Widget _chatBubbleWidget(ChatUser? messagedUser) {
    return Column(
      children: [
        Container(
          padding: widget.chatBubbleConfig?.padding ??
              const EdgeInsets.only(left: 5.0),
          margin: widget.chatBubbleConfig?.margin ??
              const EdgeInsets.only(bottom: 0), //10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isMessageBySender
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMessageBySender &&
                  (featureActiveConfig?.enableOtherUserProfileAvatar ?? true))
                ProfileCircle(
                  bottomPadding: widget.message.reaction.reactions.isNotEmpty
                      ? profileCircleConfig?.bottomPadding ?? 15
                      : profileCircleConfig?.bottomPadding ?? 2,
                  profileCirclePadding: profileCircleConfig?.padding,
                  imageUrl: messagedUser?.profilePhoto,
                  circleRadius: profileCircleConfig?.circleRadius,
                  onTap: () => _onAvatarTap(messagedUser),
                  onLongPress: () => _onAvatarLongPress(messagedUser),
                ),
              Expanded(
                child: isMessageBySender
                    ? SwipeToReply(
                        onLeftSwipe: featureActiveConfig?.enableSwipeToReply ??
                                true
                            ? () {
                                if (maxDuration != null) {
                                  widget.message.voiceMessageDuration =
                                      maxDuration!;
                                }
                                if (widget.swipeToReplyConfig?.onLeftSwipe !=
                                    null) {
                                  widget.swipeToReplyConfig?.onLeftSwipe!(
                                      widget.message.message,
                                      widget.message.sendBy);
                                }
                                widget.onSwipe(widget.message);
                              }
                            : null,
                        replyIconColor:
                            widget.swipeToReplyConfig?.replyIconColor,
                        swipeToReplyAnimationDuration:
                            widget.swipeToReplyConfig?.animationDuration,
                        child: _messagesWidgetColumn(messagedUser),
                      )
                    : SwipeToReply(
                        onRightSwipe: featureActiveConfig?.enableSwipeToReply ??
                                true
                            ? () {
                                if (maxDuration != null) {
                                  widget.message.voiceMessageDuration =
                                      maxDuration!;
                                }
                                if (widget.swipeToReplyConfig?.onRightSwipe !=
                                    null) {
                                  widget.swipeToReplyConfig?.onRightSwipe!(
                                      widget.message.message,
                                      widget.message.sendBy);
                                }
                                widget.onSwipe(widget.message);
                              }
                            : null,
                        replyIconColor:
                            widget.swipeToReplyConfig?.replyIconColor,
                        swipeToReplyAnimationDuration:
                            widget.swipeToReplyConfig?.animationDuration,
                        child: _messagesWidgetColumn(messagedUser),
                      ),
              ),
              if (isMessageBySender) ...[getReciept()],
              if (isMessageBySender &&
                  (featureActiveConfig?.enableCurrentUserProfileAvatar ?? true))
                ProfileCircle(
                  bottomPadding: widget.message.reaction.reactions.isNotEmpty
                      ? profileCircleConfig?.bottomPadding ?? 15
                      : profileCircleConfig?.bottomPadding ?? 2,
                  profileCirclePadding: profileCircleConfig?.padding,
                  imageUrl: currentUser?.profilePhoto,
                  circleRadius: profileCircleConfig?.circleRadius,
                  onTap: () => _onAvatarTap(messagedUser),
                  onLongPress: () => _onAvatarLongPress(messagedUser),
                ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: isMessageBySender
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 65,
                right: 45,
                bottom: 10,
              ),
              child: Text(
                DateFormat('HH:mm', 'pt_BR').format(widget.message.createdAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  void _onAvatarTap(ChatUser? user) {
    if (profileCircleConfig?.onAvatarTap != null && user != null) {
      profileCircleConfig?.onAvatarTap!(user);
    }
  }

  Widget getReciept() {
    final showReceipts = widget.chatBubbleConfig?.outgoingChatBubbleConfig
            ?.receiptsWidgetConfig?.showReceiptsIn ??
        ShowReceiptsIn.lastMessage;
    if (showReceipts == ShowReceiptsIn.all) {
      return ValueListenableBuilder(
        valueListenable: widget.message.statusNotifier,
        builder: (context, value, child) {
          if (ChatViewInheritedWidget.of(context)
                  ?.featureActiveConfig
                  .receiptsBuilderVisibility ??
              true) {
            return widget.chatBubbleConfig?.outgoingChatBubbleConfig
                    ?.receiptsWidgetConfig?.receiptsBuilder
                    ?.call(value) ??
                sendMessageAnimationBuilder(value);
          }
          return const SizedBox();
        },
      );
    } else if (showReceipts == ShowReceiptsIn.lastMessage && isLastMessage) {
      return ValueListenableBuilder(
          valueListenable:
              chatController!.initialMessageList.last.statusNotifier,
          builder: (context, value, child) {
            if (ChatViewInheritedWidget.of(context)
                    ?.featureActiveConfig
                    .receiptsBuilderVisibility ??
                true) {
              return widget.chatBubbleConfig?.outgoingChatBubbleConfig
                      ?.receiptsWidgetConfig?.receiptsBuilder
                      ?.call(value) ??
                  sendMessageAnimationBuilder(value);
            }
            return sendMessageAnimationBuilder(value);
          });
    }
    return const SizedBox();
  }

  void _onAvatarLongPress(ChatUser? user) {
    if (profileCircleConfig?.onAvatarLongPress != null && user != null) {
      profileCircleConfig?.onAvatarLongPress!(user);
    }
  }

  Widget _messagesWidgetColumn(ChatUser? messagedUser) {
    return Column(
      crossAxisAlignment:
          isMessageBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if ((chatController?.chatUsers.length ?? 0) > 1 && !isMessageBySender)
          Padding(
            padding:
                widget.chatBubbleConfig?.inComingChatBubbleConfig?.padding ??
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0), //4
            child: const Text(
                // messagedUser?.name ?? '',
                // style: widget.chatBubbleConfig?.inComingChatBubbleConfig
                //     ?.senderNameTextStyle,
                ''),
          ),
        if (replyMessage.isNotEmpty)
          widget.repliedMessageConfig?.repliedMessageWidgetBuilder != null
              ? widget.repliedMessageConfig!
                  .repliedMessageWidgetBuilder!(widget.message.replyMessage)
              : ReplyMessageWidget(
                  message: widget.message,
                  repliedMessageConfig: widget.repliedMessageConfig,
                  onTap: () => widget.onReplyTap
                      ?.call(widget.message.replyMessage.messageId),
                ),
        MessageView(
          compartilhavel: widget.compartilhavel,
          infoAdicional: widget.infoAdicional,
          infoAdicional2: widget.infoAdicional2,
          outgoingChatBubbleConfig:
              widget.chatBubbleConfig?.outgoingChatBubbleConfig,
          isLongPressEnable:
              (featureActiveConfig?.enableReactionPopup ?? true) ||
                  (featureActiveConfig?.enableReplySnackBar ?? true),
          inComingChatBubbleConfig:
              widget.chatBubbleConfig?.inComingChatBubbleConfig,
          message: widget.message,
          isMessageBySender: isMessageBySender,
          messageConfig: widget.messageConfig,
          onLongPress: widget.onLongPress,
          chatBubbleMaxWidth: widget.chatBubbleConfig?.maxWidth,
          longPressAnimationDuration:
              widget.chatBubbleConfig?.longPressAnimationDuration,
          onDoubleTap: featureActiveConfig?.enableDoubleTapToLike ?? false
              ? widget.chatBubbleConfig?.onDoubleTap ??
                  (message) => currentUser != null
                      ? chatController?.setReaction(
                          emoji: heart,
                          messageId: message.id,
                          userId: currentUser!.id,
                        )
                      : null
              : null,
          shouldHighlight: widget.shouldHighlight,
          controller: chatController,
          highlightColor: widget.repliedMessageConfig
                  ?.repliedMsgAutoScrollConfig.highlightColor ??
              Colors.grey,
          highlightScale: widget.repliedMessageConfig
                  ?.repliedMsgAutoScrollConfig.highlightScale ??
              1.1,
          onMaxDuration: _onMaxDuration,
        ),
      ],
    );
  }

  void _onMaxDuration(int duration) => maxDuration = duration;
}

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

class RelatorioChatBubbleWidget extends StatefulWidget {
  const RelatorioChatBubbleWidget({
    super.key,
    required this.message,
    this.profileCircleConfig,
    this.chatBubbleConfig,
    this.chatControllerParam,
    this.repliedMessageConfig,
    this.swipeToReplyConfig,
    this.messageTimeTextStyle,
    this.messageTimeIconColor,
    this.messageConfig,
    this.onReplyTap,
    this.shouldHighlight = false,
  });

  /// Represent current instance of message.
  final Message message;

  /// Provides configuration related to user profile circle avatar.
  final ProfileCircleConfiguration? profileCircleConfig;

  /// Provides configurations related to chat bubble such as padding, margin, max
  /// width etc.
  final ChatBubbleConfiguration? chatBubbleConfig;

  final ChatController? chatControllerParam;

  /// Provides configurations related to replied message such as textstyle
  /// padding, margin etc. Also, this widget is located upon chat bubble.
  final RepliedMessageConfiguration? repliedMessageConfig;

  /// Provides configurations related to swipe chat bubble which triggers
  /// when user swipe chat bubble.
  final SwipeToReplyConfiguration? swipeToReplyConfig;

  /// Provides textStyle of message created time when user swipe whole chat.
  final TextStyle? messageTimeTextStyle;

  /// Provides default icon color of message created time view when user swipe
  /// whole chat.
  final Color? messageTimeIconColor;

  /// Provides configuration of all types of messages.
  final MessageConfiguration? messageConfig;

  /// Provides callback when user tap on replied message upon chat bubble.
  final Function(String)? onReplyTap;

  /// Flag for when user tap on replied message and highlight actual message.
  final bool shouldHighlight;

  @override
  State<RelatorioChatBubbleWidget> createState() =>
      _RelatorioChatBubbleWidgetState();
}

class _RelatorioChatBubbleWidgetState extends State<RelatorioChatBubbleWidget> {
  String get replyMessage => widget.message.replyMessage.message;

  bool get isMessageBySender => widget.message.sendBy == 'Atendente';

  bool get isLastMessage =>
      widget.chatControllerParam?.initialMessageList.last.id ==
      widget.message.id;

  ProfileCircleConfiguration? get profileCircleConfig =>
      widget.profileCircleConfig;
  FeatureActiveConfig? featureActiveConfig;
  //ChatController? chatController;
  ChatUser? currentUser;
  int? maxDuration;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      featureActiveConfig = provide!.featureActiveConfig;
      //chatController = provide!.chatController;
      currentUser = ChatUser(id: 'Atendente', name: 'Atendente');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user from id.
    debugPrint('iniciando chatbubble');
    debugPrint('sendBy: ${widget.message.sendBy}');
    final messagedUser = widget.message.sendBy == 'Cliente'
        ? ChatUser(id: 'Cliente', name: 'Cliente')
        : ChatUser(id: 'Atendente', name: 'Atendente');
    return Stack(
      children: [
        _chatBubbleWidget(messagedUser),
      ],
    );
  }

  Widget _chatBubbleWidget(ChatUser? messagedUser) {
    debugPrint('isMessageSender: ${isMessageBySender.toString()}');
    return Column(
      children: [
        Container(
          padding: widget.chatBubbleConfig?.padding ??
              const EdgeInsets.only(left: 5.0),
          margin: widget.chatBubbleConfig?.margin ??
              const EdgeInsets.only(bottom: 0), //10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: isMessageBySender
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMessageBySender)
                ProfileCircle(
                  bottomPadding: widget.message.reaction.reactions.isNotEmpty
                      ? profileCircleConfig?.bottomPadding ?? 15
                      : profileCircleConfig?.bottomPadding ?? 2,
                  profileCirclePadding: profileCircleConfig?.padding,
                  imageUrl: messagedUser?.profilePhoto,
                  circleRadius: profileCircleConfig?.circleRadius,
                ),
              Expanded(
                child: isMessageBySender
                    ? SwipeToReply(
                        onLeftSwipe: featureActiveConfig?.enableSwipeToReply ??
                                true
                            ? () {
                                if (maxDuration != null) {
                                  widget.message.voiceMessageDuration =
                                      maxDuration!;
                                }
                                if (widget.swipeToReplyConfig?.onLeftSwipe !=
                                    null) {
                                  widget.swipeToReplyConfig?.onLeftSwipe!(
                                      widget.message.message,
                                      widget.message.sendBy);
                                }
                              }
                            : null,
                        replyIconColor:
                            widget.swipeToReplyConfig?.replyIconColor,
                        swipeToReplyAnimationDuration:
                            widget.swipeToReplyConfig?.animationDuration,
                        child: _messagesWidgetColumn(messagedUser),
                      )
                    : SwipeToReply(
                        onRightSwipe: featureActiveConfig?.enableSwipeToReply ??
                                true
                            ? () {
                                if (maxDuration != null) {
                                  widget.message.voiceMessageDuration =
                                      maxDuration!;
                                }
                                if (widget.swipeToReplyConfig?.onRightSwipe !=
                                    null) {
                                  widget.swipeToReplyConfig?.onRightSwipe!(
                                      widget.message.message,
                                      widget.message.sendBy);
                                }
                              }
                            : null,
                        replyIconColor:
                            widget.swipeToReplyConfig?.replyIconColor,
                        swipeToReplyAnimationDuration:
                            widget.swipeToReplyConfig?.animationDuration,
                        child: _messagesWidgetColumn(messagedUser),
                      ),
              ),
              if (isMessageBySender) ...[getReciept()],
              if (isMessageBySender)
                ProfileCircle(
                  bottomPadding: widget.message.reaction.reactions.isNotEmpty
                      ? profileCircleConfig?.bottomPadding ?? 15
                      : profileCircleConfig?.bottomPadding ?? 2,
                  profileCirclePadding: profileCircleConfig?.padding,
                  imageUrl: currentUser?.profilePhoto,
                  circleRadius: profileCircleConfig?.circleRadius,
                ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: isMessageBySender
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 65,
                right: 45,
                bottom: 10,
              ),
              child: Text(
                DateFormat('HH:mm', 'pt_BR').format(widget.message.createdAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget getReciept() {
    final showReceipts = widget.chatBubbleConfig?.outgoingChatBubbleConfig
            ?.receiptsWidgetConfig?.showReceiptsIn ??
        ShowReceiptsIn.lastMessage;
    if (showReceipts == ShowReceiptsIn.all) {
      return ValueListenableBuilder(
        valueListenable: widget.message.statusNotifier,
        builder: (context, value, child) {
          if (ChatViewInheritedWidget.of(context)
                  ?.featureActiveConfig
                  .receiptsBuilderVisibility ??
              true) {
            return widget.chatBubbleConfig?.outgoingChatBubbleConfig
                    ?.receiptsWidgetConfig?.receiptsBuilder
                    ?.call(value) ??
                sendMessageAnimationBuilder(value);
          }
          return const SizedBox();
        },
      );
    } else if (showReceipts == ShowReceiptsIn.lastMessage && isLastMessage) {
      return ValueListenableBuilder(
          valueListenable: widget
              .chatControllerParam!.initialMessageList.last.statusNotifier,
          builder: (context, value, child) {
            if (ChatViewInheritedWidget.of(context)
                    ?.featureActiveConfig
                    .receiptsBuilderVisibility ??
                true) {
              return widget.chatBubbleConfig?.outgoingChatBubbleConfig
                      ?.receiptsWidgetConfig?.receiptsBuilder
                      ?.call(value) ??
                  sendMessageAnimationBuilder(value);
            }
            return sendMessageAnimationBuilder(value);
          });
    }
    return const SizedBox();
  }

  Widget _messagesWidgetColumn(ChatUser? messagedUser) {
    return Column(
      crossAxisAlignment:
          isMessageBySender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if ((widget.chatControllerParam?.chatUsers.length ?? 0) > 1 &&
            !isMessageBySender)
          Padding(
            padding:
                widget.chatBubbleConfig?.inComingChatBubbleConfig?.padding ??
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0), //4
            child: const Text(''),
          ),
        if (replyMessage.isNotEmpty)
          widget.repliedMessageConfig?.repliedMessageWidgetBuilder != null
              ? widget.repliedMessageConfig!
                  .repliedMessageWidgetBuilder!(widget.message.replyMessage)
              : ReplyMessageWidget(
                  message: widget.message,
                  repliedMessageConfig: widget.repliedMessageConfig,
                  onTap: () => widget.onReplyTap
                      ?.call(widget.message.replyMessage.messageId),
                ),
        MessageView(
          outgoingChatBubbleConfig:
              widget.chatBubbleConfig?.outgoingChatBubbleConfig,
          isLongPressEnable:
              (featureActiveConfig?.enableReactionPopup ?? true) ||
                  (featureActiveConfig?.enableReplySnackBar ?? true),
          inComingChatBubbleConfig:
              widget.chatBubbleConfig?.inComingChatBubbleConfig,
          message: widget.message,
          isMessageBySender: isMessageBySender,
          messageConfig: widget.messageConfig,
          onLongPress: (yCoordinate, xCoordinate) =>
              (yCoordinate, xCoordinate, message) {
            if (featureActiveConfig?.enableReactionPopup ?? false) {}
            if (featureActiveConfig?.enableReplySnackBar ?? false) {}
          },
          chatBubbleMaxWidth: widget.chatBubbleConfig?.maxWidth,
          longPressAnimationDuration:
              widget.chatBubbleConfig?.longPressAnimationDuration,
          onDoubleTap: featureActiveConfig?.enableDoubleTapToLike ?? false
              ? widget.chatBubbleConfig?.onDoubleTap ??
                  (message) => currentUser != null
                      ? widget.chatControllerParam?.setReaction(
                          emoji: heart,
                          messageId: message.id,
                          userId: currentUser!.id,
                        )
                      : null
              : null,
          shouldHighlight: widget.shouldHighlight,
          controller: widget.chatControllerParam,
          highlightColor: widget.repliedMessageConfig
                  ?.repliedMsgAutoScrollConfig.highlightColor ??
              Colors.grey,
          highlightScale: widget.repliedMessageConfig
                  ?.repliedMsgAutoScrollConfig.highlightScale ??
              1.1,
          onMaxDuration: _onMaxDuration,
        ),
      ],
    );
  }

  void _onMaxDuration(int duration) => maxDuration = duration;
}
