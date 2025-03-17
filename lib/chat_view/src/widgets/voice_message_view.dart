import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../chat/services/chat_services.dart';
import '../../chatview.dart';
import '../models/voice_message_configuration.dart';
import 'reaction_widget.dart';

class VoiceMessageView extends StatefulWidget {
  const VoiceMessageView(
      {super.key,
      required this.screenWidth,
      required this.message,
      required this.isMessageBySender,
      this.inComingChatBubbleConfig,
      this.outgoingChatBubbleConfig,
      this.onMaxDuration,
      this.messageReactionConfig,
      this.config,
      this.compartilhavel = false,
      this.infoAdicional,
      this.infoAdicional2});

  final String? infoAdicional;

  final String? infoAdicional2;

  final bool? compartilhavel;

  /// Provides configuration related to voice message.
  final VoiceMessageConfiguration? config;

  /// Allow user to set width of chat bubble.
  final double screenWidth;

  /// Provides message instance of chat.
  final Message message;
  final Function(int)? onMaxDuration;

  /// Represents current message is sent by current user.
  final bool isMessageBySender;

  /// Provides configuration of reaction appearance in chat bubble.
  final MessageReactionConfiguration? messageReactionConfig;

  /// Provides configuration of chat bubble appearance from other user of chat.
  final ChatBubble? inComingChatBubbleConfig;

  /// Provides configuration of chat bubble appearance from current user of chat.
  final ChatBubble? outgoingChatBubbleConfig;

  @override
  State<VoiceMessageView> createState() => _VoiceMessageViewState();
}

class _VoiceMessageViewState extends State<VoiceMessageView> {
  //late PlayerController controller;
  late AudioPlayer controller;
  //late StreamSubscription<PlayerState> playerStateSubscription;

  // final ValueNotifier<PlayerState> _playerState =
  //     ValueNotifier(PlayerState.stopped);

  PlayerState _playerState = PlayerState.stopped;

  Duration _duration = const Duration();
  Duration _position = const Duration();

  final ChatServices _chatServices = ChatServices();

  //PlayerState get playerState => _playerState.value;

  //PlayerWaveStyle playerWaveStyle = const PlayerWaveStyle(scaleFactor: 70);

  @override
  void initState() {
    super.initState();

    // controller = PlayerController()
    //   ..preparePlayer(
    //     path: widget.message.message,
    //     noOfSamples: widget.config?.playerWaveStyle
    //             ?.getSamplesForWidth(widget.screenWidth * 0.5) ??
    //         playerWaveStyle.getSamplesForWidth(widget.screenWidth * 0.5),
    //   ).whenComplete(() => widget.onMaxDuration?.call(controller.maxDuration));
    // playerStateSubscription = controller.onPlayerStateChanged
    //     .listen((state) => _playerState.value = state);

    controller = AudioPlayer();
    controller.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
    controller.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
      widget.onMaxDuration?.call(d.inSeconds);
    });
    controller.onPositionChanged.listen((Duration p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });
    controller.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero; // Reseta a posição
        });
      }
    });
  }

  @override
  void dispose() {
    //playerStateSubscription.cancel();
    //controller.dispose();
    //_playerState.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: widget.config?.decoration ??
                  BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: widget.isMessageBySender
                        ? widget.outgoingChatBubbleConfig?.color
                        : widget.inComingChatBubbleConfig?.color,
                  ),
              padding: widget.config?.padding ??
                  const EdgeInsets.symmetric(horizontal: 8),
              margin: widget.config?.margin ??
                  EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical:
                        widget.message.reaction.reactions.isNotEmpty ? 15 : 0,
                  ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ValueListenableBuilder<PlayerState>(
                  //   builder: (context, state, child) {
                  //     return IconButton(
                  //       onPressed: _playOrPause,
                  //       icon: player.state == PlayerState.stopped ||
                  //               player.state == PlayerState.paused ||
                  //               player.state == PlayerState.playing
                  //           ? widget.config?.playIcon ??
                  //               const Icon(
                  //                 Icons.play_arrow,
                  //                 color: Colors.white,
                  //               )
                  //           : widget.config?.pauseIcon ??
                  //               const Icon(
                  //                 Icons.stop,
                  //                 color: Colors.white,
                  //               ),
                  //     );
                  //   },
                  //   valueListenable: _playerState,
                  // ),
                  //!!!!!!!!!!!!!
                  IconButton(
                    onPressed: _playOrPause,
                    icon: (_playerState == PlayerState.stopped ||
                            _playerState == PlayerState.paused ||
                            _playerState ==
                                PlayerState
                                    .completed) // Adicione a condição para completed aqui
                        ? widget.config?.playIcon ??
                            const Icon(Icons.play_arrow, color: Colors.white)
                        : widget.config?.pauseIcon ??
                            const Icon(Icons.pause, color: Colors.white),
                  ),
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      seekToSecond(value.toInt());
                    },
                  ),
                  //!!!!!!!!!!!!!
                  // AudioFileWaveforms(
                  //   size: Size(widget.screenWidth * 0.50, 60),
                  //   playerController: controller,
                  //   waveformType: WaveformType.fitWidth,
                  //   playerWaveStyle:
                  //       widget.config?.playerWaveStyle ?? playerWaveStyle,
                  //   padding: widget.config?.waveformPadding ??
                  //       const EdgeInsets.only(right: 10),
                  //   margin: widget.config?.waveformMargin,
                  //   animationCurve: widget.config?.animationCurve ?? Curves.easeIn,
                  //   animationDuration: widget.config?.animationDuration ??
                  //       const Duration(milliseconds: 500),
                  //   enableSeekGesture: widget.config?.enableSeekGesture ?? true,
                  // ),
                ],
              ),
            ),
            if (widget.message.reaction.reactions.isNotEmpty)
              ReactionWidget(
                isMessageBySender: widget.isMessageBySender,
                reaction: widget.message.reaction,
                messageReactionConfig: widget.messageReactionConfig,
              ),
            widget.compartilhavel != null
                ? widget.compartilhavel!
                    ? IconButton(
                        onPressed: () async {
                          await _chatServices.compartilharAudio(
                              widget.infoAdicional!,
                              widget.infoAdicional2!,
                              widget.message.message);
                        },
                        icon: const Icon(Icons.send),
                      )
                    : const SizedBox.shrink()
                : const SizedBox.shrink()
          ],
        ),
      ],
    );
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);
    controller.seek(newDuration);
  }

  void _playOrPause() {
    // assert(
    //   defaultTargetPlatform == TargetPlatform.iOS ||
    //       defaultTargetPlatform == TargetPlatform.android,
    //   "Voice messages are only supported with android and ios platform",
    // );
    if (kIsWeb) {
      debugPrint('Estamos na web');
      if (_playerState == PlayerState.stopped ||
          _playerState == PlayerState.paused) {
        controller.play(UrlSource(widget.message.message));
      } else if (_playerState == PlayerState.playing) {
        controller.pause();
      } else if (_playerState == PlayerState.completed) {
        controller.seek(const Duration());
        controller.play(UrlSource(widget.message.message));
      }
    }
    // else if (playerState.playing ||
    //     playerState.isPaused ||
    //     playerState.isStopped) {
    //   controller.startPlayer(finishMode: FinishMode.pause);
    // } else {
    //   controller.pausePlayer();
    // }
  }
}
