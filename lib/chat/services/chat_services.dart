import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sombra_testes/notificacoes/notificacoess.dart';
import 'package:sombra_testes/sqfLite/missao/model/missao_db_model.dart';
import 'package:sombra_testes/sqfLite/missao/services/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../../notificacoes/fcm.dart';

class ChatServices {
  FirebaseMessagingService firebaseMessagingService =
      FirebaseMessagingService(NotificationService());

  addMsg(
    body,
    autor,
    uid,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    var messageId = DateTime.now().microsecondsSinceEpoch.toString();

    var data = {
      'Id': messageId,
      'User uid': uid,
      'Mensagem': '${body.text}',
      'Autor': autor,
      'FotoUrl': photoUrl,
      'Timestamp': FieldValue.serverTimestamp()
    };

    DocumentReference conversationRef =
        FirebaseFirestore.instance.collection('Chat').doc(uid);

    // Incrementar unreadCount quando o atendente envia uma mensagem
    await FirebaseFirestore.instance
        .collection('Chat')
        .doc(uid)
        .set({'unreadCount': FieldValue.increment(1)}, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('Chat').doc(uid).set(
        {'lastMessageTimestamp': FieldValue.serverTimestamp()},
        SetOptions(merge: true));

    await conversationRef.collection('Mensagens').doc(messageId).set(data);

    body.clear();
  }

  addAtendenteMsg(
    body,
    autor,
    uid,
  ) async {
    var messageId = DateTime.now().microsecondsSinceEpoch.toString();
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;

    var data = {
      'Id': messageId,
      'User uid': userUid,
      'Mensagem': '${body.text}',
      'Autor': 'Atendente',
      'FotoUrl': 'teste',
      'Timestamp': FieldValue.serverTimestamp()
    };

    await FirebaseFirestore.instance
        .collection('Chat')
        .doc(uid)
        .collection('Mensagens')
        .doc(messageId)
        .set(data);

    // Incrementar unreadCount quando o atendente envia uma mensagem
    await FirebaseFirestore.instance
        .collection('Chat')
        .doc(uid)
        .update({'unreadCount': FieldValue.increment(1)});

    // Enviar a notificação usando o token FCM.
    List<String> userTokens = await fetchUserTokens(uid);

    for (String token in userTokens) {
      await firebaseMessagingService.sendNotification(
          token, 'Nova mensagem', body.text, null);
    }

    body.clear();
  }

  addMsgMissao(
    TextEditingController? body,
    String? autor,
    String? uid,
    String? missaoId,
    String? imageUrl,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    var messageId = DateTime.now().microsecondsSinceEpoch.toString();

    var data = {
      'Id': messageId,
      'User uid': uid,
      'Mensagem': body?.text ?? '',
      'Autor': autor,
      'FotoUrl': photoUrl,
      'Imagem': imageUrl, // URL da imagem enviada
      'Timestamp': FieldValue.serverTimestamp()
    };

    DocumentReference conversationRef =
        FirebaseFirestore.instance.collection('Chat missão').doc(missaoId);

    // Incrementar unreadCount quando o atendente envia uma mensagem
    await conversationRef
        .set({'unreadCount': FieldValue.increment(1)}, SetOptions(merge: true));

    await conversationRef.set(
        {'lastMessageTimestamp': FieldValue.serverTimestamp()},
        SetOptions(merge: true));

    await conversationRef.collection('Mensagens').doc(messageId).set(data);

    if (body != null) {
      body.clear();
    }
  }

  addCentralMsgMissao(
    body,
    autor,
    uid,
    missaoId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    var messageId = DateTime.now().microsecondsSinceEpoch.toString();

    var data = {
      'Id': messageId,
      'User uid': uid,
      'Mensagem': '${body.text}',
      'Autor': 'Atendente',
      'FotoUrl': photoUrl,
      'Timestamp': FieldValue.serverTimestamp()
    };

    DocumentReference conversationRef =
        FirebaseFirestore.instance.collection('Chat missão').doc(missaoId);

    // Incrementar unreadCount quando o atendente envia uma mensagem
    await conversationRef.set(
        {'userUnreadCount': FieldValue.increment(1)}, SetOptions(merge: true));

    await conversationRef.set(
        {'lastMessageTimestamp': FieldValue.serverTimestamp()},
        SetOptions(merge: true));

    await conversationRef.collection('Mensagens').doc(messageId).set(data);

    body.clear();
  }

  addMsgClienteMissao(
    TextEditingController? body,
    String? autor,
    String? uid,
    String? missaoId,
    String? imageUrl,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    var messageId = DateTime.now().microsecondsSinceEpoch.toString();

    var data = {
      'Id': messageId,
      'User uid': uid,
      'Mensagem': body?.text ?? '',
      'Autor': 'Atendente',
      'FotoUrl': photoUrl,
      'Imagem': imageUrl, // URL da imagem enviada
      'Timestamp': FieldValue.serverTimestamp()
    };

    DocumentReference conversationRef = FirebaseFirestore.instance
        .collection('Chat missão cliente')
        .doc(missaoId);

    // Incrementar unreadCount quando o atendente envia uma mensagem
    await conversationRef.set(
        {'userUnreadCount': FieldValue.increment(1)}, SetOptions(merge: true));

    await conversationRef.set(
        {'lastMessageTimestamp': FieldValue.serverTimestamp()},
        SetOptions(merge: true));

    await conversationRef.collection('Mensagens').doc(messageId).set(data);

    if (body != null) {
      body.clear();
    }
  }

  Future<List<String>> fetchUserTokens(String uid) async {
    List<String> tokens = [];

    // Referência à coleção de tokens de um usuário específico
    CollectionReference tokensCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tokens');

    // Busca todos os documentos da coleção de tokens
    QuerySnapshot tokensSnapshot = await tokensCollection.get();

    // Itera sobre os documentos e extrai o valor do token
    for (QueryDocumentSnapshot tokenDoc in tokensSnapshot.docs) {
      Map<String, dynamic> data = tokenDoc.data() as Map<String, dynamic>;
      String? token = data['fcmToken'];
      if (token != null) {
        tokens.add(token);
      }
    }

    return tokens;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersConversations() {
    return FirebaseFirestore.instance
        .collection('Chat')
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  Stream<bool> notificacaoChat() {
    return FirebaseFirestore.instance
        .collection('Chat')
        .snapshots()
        .map((snapshot) {
      for (var doc in snapshot.docs) {
        debugPrint('doc: ${doc.id}');
        if (doc.data()['unreadCount'] > 0) {
          debugPrint('Notificação Chat: true');
          return true;
        }
      }
      debugPrint('Notificação Chat: false');
      return false;
    });
  }

  Stream<int> getUsersMissionConversationsUnreadCount(String missaoId) {
    return FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(missaoId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['userUnreadCount'] ?? 0;
      } else {
        return 0;
      }
    });
  }

  Stream<int> getCentralMissionAgentConversationsUnreadCount(String missaoId) {
    return FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(missaoId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['unreadCount'] ?? 0;
      } else {
        return 0;
      }
    });
  }

  Stream<int> getCentralMissionClientConversationsUnreadCount(String missaoId) {
    return FirebaseFirestore.instance
        .collection('Chat missão cliente')
        .doc(missaoId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!['unreadCount'] ?? 0;
      } else {
        return 0;
      }
    });
  }

  Future<Map<String, String>> getUserName(String uid) async {
    DocumentSnapshot<Map<String, dynamic>> document =
        await FirebaseFirestore.instance.collection('User Name').doc(uid).get();

    if (document.data() != null) {
      return {
        'Nome': document.data()!['Nome'],
      };
    } else {
      return {
        'Nome': '',
      };
    }
  }

  Future<bool> insertChatMissaoCache(
      String userUid,
      String? mensagem,
      String? imagem,
      timestamp,
      missaoId,
      String? autor,
      String? fotoUrl) async {
    Database db = await MissionDatabaseHelper.instance.database;
    try {
      await db.insert(
          ChatMissaoTable.tableName,
          {
            ChatMissaoTable.columnUserUid: userUid,
            ChatMissaoTable.columnMensagem: mensagem,
            ChatMissaoTable.columnImagem: imagem,
            ChatMissaoTable.columnTimestamp: timestamp,
            ChatMissaoTable.columnMissaoId: missaoId,
            ChatMissaoTable.columnAutor: autor,
            ChatMissaoTable.columnFotoUrl: fotoUrl,
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      debugPrint('Erro ao inserir mensagem no banco de dados: $e');
      return false;
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> getChatMissaoCache(String missaoId) async {
    Database db = await MissionDatabaseHelper.instance.database;
    List<Map<String, dynamic>> result = await db.query(
      ChatMissaoTable.tableName,
      where: '${ChatMissaoTable.columnMissaoId} = ?',
      whereArgs: [missaoId],
      orderBy: '${ChatMissaoTable.columnTimestamp} ASC',
    );
    return result;
  }

  Future<void> deleteChatMissaoCache(String missaoId) async {
    Database db = await MissionDatabaseHelper.instance.database;
    await db.delete(
      ChatMissaoTable.tableName,
      where: '${ChatMissaoTable.columnMissaoId} = ?',
      whereArgs: [missaoId],
    );
  }

  //verificar se ha conversa de chat salva no banco de dados local
  Future<bool> verificarChatMissaoCache(String missaoId) async {
    Database db = await MissionDatabaseHelper.instance.database;
    List<Map<String, dynamic>> result = await db.query(
      ChatMissaoTable.tableName,
      where: '${ChatMissaoTable.columnMissaoId} = ?',
      whereArgs: [missaoId],
    );
    if (result.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
