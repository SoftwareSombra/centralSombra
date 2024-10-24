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
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:core';
import 'package:pdf/src/widgets/image_provider.dart' as pw;
import '../../chatview.dart';

class Message {
  /// Provides id
  String id;

  /// Used for accessing widget's render box.
  final GlobalKey key;

  /// Provides actual message it will be text or image/audio file path.
  final String message;

  /// Provides message created date time.
  final DateTime createdAt;
  final FieldValue? optionalCreatedAt;

  /// Provides id of sender of message.
  final String sendBy;

  /// Provides reply message if user triggers any reply on any message.
  final ReplyMessage replyMessage;

  /// Represents reaction on message.
  final Reaction reaction;

  /// Provides message type.
  final MessageType messageType;

  /// Status of the message.
  final ValueNotifier<MessageStatus> _status;

  /// Provides max duration for recorded voice message.
  int? voiceMessageDuration;

  final String autor;

  final pw.MemoryImage? pdfImage;

  Message({
    this.id = '',
    required this.message,
    required this.createdAt,
    this.optionalCreatedAt,
    required this.sendBy,
    this.replyMessage = const ReplyMessage(),
    Reaction? reaction,
    this.messageType = MessageType.text,
    this.voiceMessageDuration,
    required this.autor,
    this.pdfImage,
    MessageStatus status = MessageStatus.pending,
  })  : reaction = reaction ?? Reaction(reactions: [], reactedUserIds: []),
        key = GlobalKey(),
        _status = ValueNotifier(status),
        assert(
          (true),
          //"Voice messages are only supported with android and ios platform",
        );

  /// curret messageStatus
  MessageStatus get status => _status.value;

  /// For [MessageStatus] ValueNotfier which is used to for rebuilds
  /// when state changes.
  /// Using ValueNotfier to avoid usage of setState((){}) in order
  /// rerender messages with new receipts.
  ValueNotifier<MessageStatus> get statusNotifier => _status;

  /// This setter can be used to update message receipts, after which the configured
  /// builders will be updated.
  set setStatus(MessageStatus messageStatus) {
    _status.value = messageStatus;
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    MessageType messageType = MessageType.values.firstWhere(
      (e) => e.toString().split('.').last == json['message_type'],
      orElse: () =>
          MessageType.text, // Valor padrão, caso não encontre correspondência.
    );

    // Conversão de `status` de String para o enum `MessageStatus`
    MessageStatus status = MessageStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status'],
      orElse: () => MessageStatus.pending, // Valor padrão.
    );

    return Message(
        id: json["id"],
        message: json["message"],
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        sendBy: json["sendBy"],
        // replyMessage: ReplyMessage.fromJson(json["reply_message"]),
        // reaction: Reaction.fromJson(json["reaction"]),
        replyMessage: ReplyMessage.fromJson(json["reply_message"] ?? {}),
        reaction: Reaction.fromJson(json["reaction"] ?? {}),
        messageType: messageType, // Use a variável `messageType`
        // voiceMessageDuration:
        //     //timestamp para duration
        //     json["voice_message_duration"] != null
        //         ? Duration(milliseconds: json["voice_message_duration"])
        //         : null,
        voiceMessageDuration: json["voice_message_duration"],
        autor: json["autor"],
        status: status);
  }

  Map<String, dynamic> paraJson() => {
        'id': id,
        'message': message,
        'createdAt': optionalCreatedAt ?? createdAt,
        'sendBy': sendBy,
        'reply_message': replyMessage.toJson(),
        'reaction': reaction.toJson(),
        'message_type': messageType.toString().split('.').last,
        'voice_message_duration': voiceMessageDuration,
        'autor': autor,
        'status': status.name
      };

  Message copyWith({
    String? id,
    String? message,
    DateTime? createdAt,
    String? sendBy,
    ReplyMessage? replyMessage,
    Reaction? reaction,
    MessageType? messageType,
    int? voiceMessageDuration,
    String? autor,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      sendBy: sendBy ?? this.sendBy,
      replyMessage: replyMessage ?? this.replyMessage,
      reaction: reaction ?? this.reaction,
      messageType: messageType ?? this.messageType,
      voiceMessageDuration: voiceMessageDuration ?? this.voiceMessageDuration,
      autor: autor ?? this.autor,
      status: status ?? this.status,
    );
  }
}
