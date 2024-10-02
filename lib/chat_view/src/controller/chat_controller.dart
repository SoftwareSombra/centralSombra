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
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/models.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../values/enumaration.dart';

import 'dart:core';

import 'package:flutter/foundation.dart';

import 'dart:html' as html;

class ChatController {
  /// Represents initial message list in chat which can be add by user.
  List<Message> initialMessageList;

  ScrollController scrollController;

  /// Allow user to show typing indicator defaults to false.
  final ValueNotifier<bool> _showTypingIndicator = ValueNotifier(false);

  /// TypingIndicator as [ValueNotifier] for [GroupedChatList] widget's typingIndicator [ValueListenableBuilder].
  ///  Use this for listening typing indicators
  ///   ```dart
  ///    chatcontroller.typingIndicatorNotifier.addListener((){});
  ///  ```
  /// For more functionalities see [ValueNotifier].
  ValueNotifier<bool> get typingIndicatorNotifier => _showTypingIndicator;

  /// Getter for typingIndicator value instead of accessing [_showTypingIndicator.value]
  /// for better accessibility.
  bool get showTypingIndicator => _showTypingIndicator.value;

  /// Setter for changing values of typingIndicator
  /// ```dart
  ///  chatContoller.setTypingIndicator = true; // for showing indicator
  ///  chatContoller.setTypingIndicator = false; // for hiding indicator
  ///  ````
  set setTypingIndicator(bool value) => _showTypingIndicator.value = value;

  /// Represents list of chat users
  List<ChatUser> chatUsers;

  String chatId;

  String chatCollection;

  String? missaoId;

  ChatController({
    required this.initialMessageList,
    required this.scrollController,
    required this.chatUsers,
    required this.chatId,
    required this.chatCollection,
    this.missaoId,
  });

  /// Represents message stream of chat
  StreamController<List<Message>> messageStreamController = StreamController();

  /// Used to dispose stream.
  void dispose() => messageStreamController.close();

  /// Used to add message in message list.
  void addMessage(Message message) {
    initialMessageList.add(message);
    messageStreamController.sink.add(initialMessageList);
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendMessageToFirestore(Message message) async {
    debugPrint(message.paraJson().toString());
    debugPrint('======= chegou aqui ==========');
    try {
      // Verifica se a mensagem é do tipo 'image' ou 'voice'
      if (message.messageType == MessageType.image ||
          message.messageType == MessageType.voice) {
        // Supondo que `message.message` contenha o caminho do arquivo local
        final UploadTask uploadTask;
        if (!kIsWeb) {
          File file = File(message.message);
          String filePath = message.messageType == MessageType.voice
              ? 'chatApp/$chatId/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
              : 'chatApp/$chatId/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // Faz o upload do arquivo para o Firebase Storage
          uploadTask =
              FirebaseStorage.instance.ref().child(filePath).putFile(file);
        } else {
          debugPrint('======= chegou aqui, web ==========');
          final response = await html.window.fetch(message.message);
          final blob = await response.blob();
          // String filePath = message.messageType == MessageType.voice
          //     ? 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
          //     : 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // // Faz o upload do arquivo para o Firebase Storage
          // uploadTask =
          //     FirebaseStorage.instance.ref().child(filePath).putBlob(blob);
          final storageRef = message.messageType == MessageType.voice
              ? FirebaseStorage.instance.ref().child(
                  'chatTeste/audio/${DateTime.now().millisecondsSinceEpoch}.m4a')
              : FirebaseStorage.instance.ref().child(
                  'chatTeste/images/${DateTime.now().millisecondsSinceEpoch}');

          uploadTask = storageRef.putBlob(blob);
        }

        // Aguarda a conclusão do upload e obtém a URL
        TaskSnapshot taskSnapshot = await uploadTask;
        String fileUrl = await taskSnapshot.ref.getDownloadURL();

        // Atualiza o campo 'message' do objeto Message com a URL do arquivo
        message.messageType == MessageType.voice
            ? message = message.copyWith(message: '${fileUrl}.m4a')
            : message = message.copyWith(message: fileUrl);
      }

      await firestore
          .collection(chatCollection)
          .doc(chatId)
          .collection('Mensagens')
          .doc()
          .set(message.paraJson());

      await firestore.collection(chatCollection).doc(chatId).set({
        'userUnreadCount': FieldValue.increment(1),
        'lastMessageTimestamp': FieldValue.serverTimestamp()
      });
      // Chama addMessage para atualizar a lista local e o stream de mensagens
      //addMessage(message);
      messageStreamController.sink.add(initialMessageList);
    } catch (e) {
      debugPrint("Erro ao enviar mensagem: $e");
    }
  }

  void startListeningForNewMessages() {
    FirebaseFirestore.instance
        .collection(chatCollection)
        .doc(chatId)
        .collection('Mensagens')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      debugPrint('snapshot: ${snapshot.docs.length}');
      // Itera sobre todas as alterações desde a última snapshot
      for (var change in snapshot.docChanges) {
        // Se uma mensagem foi adicionada, adiciona ao estado local
        if (change.type == DocumentChangeType.added) {
          Message message =
              Message.fromJson(change.doc.data() as Map<String, dynamic>);
          // message.id = change
          //     .doc.id; // Garante que o ID esteja sendo atribuído corretamente
          initialMessageList.add(message);
        }
        // Se uma mensagem foi removida, remove do estado local
        else if (change.type == DocumentChangeType.removed) {
          initialMessageList
              .removeWhere((message) => message.id == change.doc.id);
        }
        // Adicione aqui outros tipos de alterações, como modificação, se necessário
      }
      // Emite a lista atualizada de mensagens
      messageStreamController.add(List.from(initialMessageList));
      debugPrint('initialMessageList: ${initialMessageList.length}');
    });
  }

  Future<void> sendMessageChatMissaoToFirestore(Message message) async {
    debugPrint(message.paraJson().toString());
    debugPrint('======= chegou aqui ==========');
    try {
      // Verifica se a mensagem é do tipo 'image' ou 'voice'
      if (message.messageType == MessageType.image ||
          message.messageType == MessageType.voice) {
        // Supondo que `message.message` contenha o caminho do arquivo local
        final UploadTask uploadTask;
        if (!kIsWeb) {
          File file = File(message.message);
          String filePath = message.messageType == MessageType.voice
              ? 'chatMissao/$missaoId/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
              : 'chatMissao/$missaoId/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // Faz o upload do arquivo para o Firebase Storage
          uploadTask =
              FirebaseStorage.instance.ref().child(filePath).putFile(file);
        } else {
          debugPrint('======= chegou aqui, web ==========');
          final response = await html.window.fetch(message.message);
          final blob = await response.blob();
          // String filePath = message.messageType == MessageType.voice
          //     ? 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
          //     : 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // // Faz o upload do arquivo para o Firebase Storage
          // uploadTask =
          //     FirebaseStorage.instance.ref().child(filePath).putBlob(blob);
          final storageRef = message.messageType == MessageType.voice
              ? FirebaseStorage.instance.ref().child(
                  'chatMissao/audio/${DateTime.now().millisecondsSinceEpoch}.m4a')
              : FirebaseStorage.instance.ref().child(
                  'chatMissao/images/${DateTime.now().millisecondsSinceEpoch}');

          uploadTask = storageRef.putBlob(blob);
        }

        // Aguarda a conclusão do upload e obtém a URL
        TaskSnapshot taskSnapshot = await uploadTask;
        String fileUrl = await taskSnapshot.ref.getDownloadURL();

        // Atualiza o campo 'message' do objeto Message com a URL do arquivo
        message.messageType == MessageType.voice
            ? message = message.copyWith(message: '${fileUrl}.m4a')
            : message = message.copyWith(message: fileUrl);
      }

      // await firestore
      //     .collection('Chat missão cliente')
      //     .doc(chatId)
      //     .set({'sinc': 'sincronizado'});
      await firestore
          .collection('Chat missão')
          .doc(missaoId)
          .collection('Mensagens')
          .doc()
          .set(message.paraJson());
      // Incrementar unreadCount quando o atendente envia uma mensagem
      await FirebaseFirestore.instance
          .collection('Chat missão')
          .doc(missaoId)
          .set({'userUnreadCount': FieldValue.increment(1)},
              SetOptions(merge: true));
      // Chama addMessage para atualizar a lista local e o stream de mensagens
      //addMessage(message);
      messageStreamController.sink.add(initialMessageList);
    } catch (e) {
      debugPrint("Erro ao enviar mensagem: $e");
    }
  }

  void startListeningForNewChatMissaoMessages() {
    FirebaseFirestore.instance
        .collection(chatCollection)
        .doc(missaoId)
        .collection('Mensagens')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      debugPrint('snapshot: ${snapshot.docs.length}');
      // Itera sobre todas as alterações desde a última snapshot
      for (var change in snapshot.docChanges) {
        // Se uma mensagem foi adicionada, adiciona ao estado local
        if (change.type == DocumentChangeType.added) {
          Message message =
              Message.fromJson(change.doc.data() as Map<String, dynamic>);
          // message.id = change
          //     .doc.id; // Garante que o ID esteja sendo atribuído corretamente
          initialMessageList.add(message);
        }
        // Se uma mensagem foi removida, remove do estado local
        else if (change.type == DocumentChangeType.removed) {
          initialMessageList
              .removeWhere((message) => message.id == change.doc.id);
        }
        // Adicione aqui outros tipos de alterações, como modificação, se necessário
      }
      // Emite a lista atualizada de mensagens
      messageStreamController.add(List.from(initialMessageList));
      debugPrint('initialMessageList: ${initialMessageList.length}');
    });
  }

Future<void> sendMessageChatMissaoClienteToFirestore(Message message,
      {newChatCollection}) async {
    debugPrint(message.paraJson().toString());
    debugPrint('======= chegou aqui ==========');
    try {
      // Verifica se a mensagem é do tipo 'image' ou 'voice'
      if (message.messageType == MessageType.image ||
          message.messageType == MessageType.voice) {
        // Supondo que `message.message` contenha o caminho do arquivo local
        final UploadTask uploadTask;
        if (!kIsWeb) {
          File file = File(message.message);
          String filePath = message.messageType == MessageType.voice
              ? 'chatMissaoCliente/$missaoId/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
              : 'chatMissaoCliente/$missaoId/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // Faz o upload do arquivo para o Firebase Storage
          uploadTask =
              FirebaseStorage.instance.ref().child(filePath).putFile(file);
        } else {
          debugPrint('======= chegou aqui, web ==========');
          final response = await html.window.fetch(message.message);
          final blob = await response.blob();
          // String filePath = message.messageType == MessageType.voice
          //     ? 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
          //     : 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // // Faz o upload do arquivo para o Firebase Storage
          // uploadTask =
          //     FirebaseStorage.instance.ref().child(filePath).putBlob(blob);
          final storageRef = message.messageType == MessageType.voice
              ? FirebaseStorage.instance.ref().child(
                  'chatMissaoCliente/audio/${DateTime.now().millisecondsSinceEpoch}.m4a')
              : FirebaseStorage.instance.ref().child(
                  'chatMissaoCliente/images/${DateTime.now().millisecondsSinceEpoch}');

          uploadTask = storageRef.putBlob(blob);
        }

        // Aguarda a conclusão do upload e obtém a URL
        TaskSnapshot taskSnapshot = await uploadTask;
        String fileUrl = await taskSnapshot.ref.getDownloadURL();

        // Atualiza o campo 'message' do objeto Message com a URL do arquivo
        message.messageType == MessageType.voice
            ? message = message.copyWith(message: '${fileUrl}.m4a')
            : message = message.copyWith(message: fileUrl);
      }

      // await firestore
      //     .collection('Chat missão cliente')
      //     .doc(chatId)
      //     .set({'sinc': 'sincronizado'});
      await firestore
          .collection(newChatCollection ?? chatCollection)
          .doc(missaoId)
          .collection('Mensagens')
          .doc()
          .set(message.paraJson());
      // Chama addMessage para atualizar a lista local e o stream de mensagens
      //addMessage(message);
      messageStreamController.sink.add(initialMessageList);
    } catch (e) {
      debugPrint("Erro ao enviar mensagem: $e");
    }
  }

  void startListeningForNewChatMissaoClienteMessages() {
    FirebaseFirestore.instance
        .collection(chatCollection)
        .doc(missaoId)
        .collection('Mensagens')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      debugPrint('snapshot: ${snapshot.docs.length}');
      // Itera sobre todas as alterações desde a última snapshot
      for (var change in snapshot.docChanges) {
        // Se uma mensagem foi adicionada, adiciona ao estado local
        if (change.type == DocumentChangeType.added) {
          Message message =
              Message.fromJson(change.doc.data() as Map<String, dynamic>);
          // message.id = change
          //     .doc.id; // Garante que o ID esteja sendo atribuído corretamente
          initialMessageList.add(message);
        }
        // Se uma mensagem foi removida, remove do estado local
        else if (change.type == DocumentChangeType.removed) {
          initialMessageList
              .removeWhere((message) => message.id == change.doc.id);
        }
        // Adicione aqui outros tipos de alterações, como modificação, se necessário
      }
      // Emite a lista atualizada de mensagens
      messageStreamController.add(List.from(initialMessageList));
      debugPrint('initialMessageList: ${initialMessageList.length}');
    });
  }

  Future<void> sendMessageChatClienteToFirestore(Message message) async {
    debugPrint(message.paraJson().toString());
    debugPrint('======= chegou aqui ==========');
    try {
      // Verifica se a mensagem é do tipo 'image' ou 'voice'
      if (message.messageType == MessageType.image ||
          message.messageType == MessageType.voice) {
        // Supondo que `message.message` contenha o caminho do arquivo local
        final UploadTask uploadTask;
        if (!kIsWeb) {
          File file = File(message.message);
          String filePath = message.messageType == MessageType.voice
              ? 'chatCliente/$chatId/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
              : 'chatCliente/$chatId/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // Faz o upload do arquivo para o Firebase Storage
          uploadTask =
              FirebaseStorage.instance.ref().child(filePath).putFile(file);
        } else {
          debugPrint('======= chegou aqui, web ==========');
          final response = await html.window.fetch(message.message);
          final blob = await response.blob();
          // String filePath = message.messageType == MessageType.voice
          //     ? 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}.m4a'
          //     : 'chatApp/$uid/mensagens/${DateTime.now().millisecondsSinceEpoch}';

          // // Faz o upload do arquivo para o Firebase Storage
          // uploadTask =
          //     FirebaseStorage.instance.ref().child(filePath).putBlob(blob);
          final storageRef = message.messageType == MessageType.voice
              ? FirebaseStorage.instance.ref().child(
                  'chatCliente/audio/${DateTime.now().millisecondsSinceEpoch}.m4a')
              : FirebaseStorage.instance.ref().child(
                  'chatCliente/images/${DateTime.now().millisecondsSinceEpoch}');

          uploadTask = storageRef.putBlob(blob);
        }

        // Aguarda a conclusão do upload e obtém a URL
        TaskSnapshot taskSnapshot = await uploadTask;
        String fileUrl = await taskSnapshot.ref.getDownloadURL();

        // Atualiza o campo 'message' do objeto Message com a URL do arquivo
        message.messageType == MessageType.voice
            ? message = message.copyWith(message: '${fileUrl}.m4a')
            : message = message.copyWith(message: fileUrl);
      }

      await firestore
          .collection('Chat cliente')
          .doc(chatId)
          .collection('Mensagens')
          .doc()
          .set(message.paraJson());

      await firestore.collection(chatCollection).doc(chatId).set({
        'userUnreadCount': FieldValue.increment(1),
        'lastMessageTimestamp': FieldValue.serverTimestamp()
      });
      // Chama addMessage para atualizar a lista local e o stream de mensagens
      //addMessage(message);
      messageStreamController.sink.add(initialMessageList);
    } catch (e) {
      debugPrint("Erro ao enviar mensagem: $e");
    }
  }

  void startListeningForNewChatClienteMessages() {
    FirebaseFirestore.instance
        .collection('Chat cliente')
        .doc(chatId)
        .collection('Mensagens')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      debugPrint('snapshot: ${snapshot.docs.length}');
      // Itera sobre todas as alterações desde a última snapshot
      for (var change in snapshot.docChanges) {
        // Se uma mensagem foi adicionada, adiciona ao estado local
        if (change.type == DocumentChangeType.added) {
          Message message =
              Message.fromJson(change.doc.data() as Map<String, dynamic>);
          // message.id = change
          //     .doc.id; // Garante que o ID esteja sendo atribuído corretamente
          initialMessageList.add(message);
        }
        // Se uma mensagem foi removida, remove do estado local
        else if (change.type == DocumentChangeType.removed) {
          initialMessageList
              .removeWhere((message) => message.id == change.doc.id);
        }
        // Adicione aqui outros tipos de alterações, como modificação, se necessário
      }
      // Emite a lista atualizada de mensagens
      messageStreamController.add(List.from(initialMessageList));
      debugPrint('initialMessageList: ${initialMessageList.length}');
    });
  }

  /// Function for setting reaction on specific chat bubble
  void setReaction({
    required String emoji,
    required String messageId,
    required String userId,
  }) {
    final message =
        initialMessageList.firstWhere((element) => element.id == messageId);
    final reactedUserIds = message.reaction.reactedUserIds;
    final indexOfMessage = initialMessageList.indexOf(message);
    final userIndex = reactedUserIds.indexOf(userId);
    if (userIndex != -1) {
      if (message.reaction.reactions[userIndex] == emoji) {
        message.reaction.reactions.removeAt(userIndex);
        message.reaction.reactedUserIds.removeAt(userIndex);
      } else {
        message.reaction.reactions[userIndex] = emoji;
      }
    } else {
      message.reaction.reactions.add(emoji);
      message.reaction.reactedUserIds.add(userId);
    }
    initialMessageList[indexOfMessage] = Message(
      id: messageId,
      message: message.message,
      createdAt: message.createdAt,
      sendBy: message.sendBy,
      replyMessage: message.replyMessage,
      reaction: message.reaction,
      messageType: message.messageType,
      status: message.status,
      autor: message.autor,
    );
    messageStreamController.sink.add(initialMessageList);
  }

  /// Function to scroll to last messages in chat view
  void scrollToLastMessage() => Timer(
        const Duration(milliseconds: 300),
        () => scrollController.animateTo(
          scrollController.position.minScrollExtent,
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 300),
        ),
      );

  /// Function for loading data while pagination.
  void loadMoreData(List<Message> messageList) {
    /// Here, we have passed 0 index as we need to add data before first data
    debugPrint('======= chegou aqui, loadMoreData --------');
    initialMessageList.insertAll(0, messageList);
    messageStreamController.sink.add(messageList);
    //startListeningForNewMessages(chatId);
  }

  /// Function for getting ChatUser object from user id
  ChatUser getUserFromId(String userId) {
    debugPrint('buscando: $userId');
    debugPrint(
        'getUserFromId: ${chatUsers.firstWhere((element) => element.id == userId)}');
    return chatUsers.firstWhere((element) => element.id == userId);
  }

  //debugPrint do getCharUserFromId
  void debugPrintGetUserFromId(String userId) {
    debugPrint(
        'getUserFromId: ${chatUsers.firstWhere((element) => element.id == userId)}');
  }
}
