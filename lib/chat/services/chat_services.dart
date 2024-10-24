import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sombra/chat_view/chatview.dart';
import 'package:sombra/notificacoes/notificacoess.dart';
import 'package:sombra/sqfLite/missao/model/missao_db_model.dart';
import 'package:sombra/sqfLite/missao/services/db_helper.dart';
import 'package:sqflite/sqflite.dart';
import '../../notificacoes/fcm.dart';

class ChatServices {
  FirebaseMessagingService firebaseMessagingService =
      FirebaseMessagingService(NotificationService());
  FirebaseFirestore firestore = FirebaseFirestore.instance;

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
        .set({'unreadCount': FieldValue.increment(1)}, SetOptions(merge: true));

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

  Future<void> resetUnreadCount(String uid) async {
    await FirebaseFirestore.instance.collection('Chat').doc(uid).set({
      'unreadCount': 0,
      //'lastMessageTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<String>> fetchUserTokens(String uid) async {
    List<String> tokens = [];

    // Referência à coleção de tokens de um usuário específico
    CollectionReference tokensCollection = FirebaseFirestore.instance
        .collection('FCM Tokens')
        .doc(uid)
        .collection('tokens');

    // Busca todos os documentos da coleção de tokens
    QuerySnapshot tokensSnapshot = await tokensCollection.get();

    debugPrint('Tokens snapshot: ${tokensSnapshot.docs.length}');

    // Itera sobre os documentos e extrai o valor do token
    for (QueryDocumentSnapshot tokenDoc in tokensSnapshot.docs) {
      Map<String, dynamic> data = tokenDoc.data() as Map<String, dynamic>;
      String? token = data['FCM Token'];
      if (token != null) {
        tokens.add(token);
      }
    }

    return tokens;
  }

  Future<bool> compartilharFotoComCliente(missaoId, fotoUrl, uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('Fotos compartilhadas')
          .doc(missaoId)
          .set({
        'foto': fotoUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'uid': uid,
        'missaoId': missaoId,
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao compartilhar foto com cliente: $e');
      return false;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersConversations() {
    return FirebaseFirestore.instance
        .collection('Chat')
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getClientsConversations() {
    debugPrint('buscando conversas com os clientes');
    return FirebaseFirestore.instance
        .collection('Chat cliente')
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  Stream<bool> notificacaoChat() {
    debugPrint('chegou aqui !!!!!');
    return FirebaseFirestore.instance
        .collection('Chat')
        .snapshots()
        .map((snapshot) {
      bool hasUnreadMessages = false;
      for (var doc in snapshot.docs) {
        debugPrint('doc: ${doc.id}');
        if (doc.data()['unreadCount'] != null &&
            doc.data()['unreadCount'] > 0) {
          hasUnreadMessages = true;
          break; // Saia do loop assim que encontrar uma mensagem não lida
        }
      }
      debugPrint('Notificação Chat: $hasUnreadMessages');
      return hasUnreadMessages;
    });
  }

  Stream<bool> notificacaoChatCliente() {
    debugPrint('chegou aqui/chatclientnotification !!!!!');
    return FirebaseFirestore.instance
        .collection('Chat cliente')
        .snapshots()
        .map((snapshot) {
      bool hasUnreadMessages = false;
      for (var doc in snapshot.docs) {
        debugPrint('doc: ${doc.id}');
        if (doc.data()['unreadCount'] != null &&
            doc.data()['unreadCount'] > 0) {
          hasUnreadMessages = true;
          break; // Saia do loop assim que encontrar uma mensagem não lida
        }
      }
      debugPrint('Notificação Chat cliente: $hasUnreadMessages');
      return hasUnreadMessages;
    });
  }

    void playAudio() async {
    await AudioPlayer().play(
      volume: 1,
      UrlSource(
          'https://firebasestorage.googleapis.com/v0/b/sombratestes.appspot.com/o/notification-message-incoming.mp3?alt=media&token=f99b5f13-6f86-4c82-b397-58bd95dc3a1a'),
    );
  }

  //   void notificacaoChat(messageStreamController, uid) {
  //   FirebaseFirestore.instance.collection('Chat').doc(uid).snapshots().listen(
  //     (snapshot) {
  //       debugPrint('snapshot: ${snapshot.data()}');
  //       if (snapshot.exists && snapshot.data()!['unreadCount'] > 0) {
  //         messageStreamController.add(true);
  //       } else {
  //         messageStreamController.add(false);
  //       }
  //     },
  //   );
  // }

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

  Future<Map<String, String>> getUserNames(List<String> uids) async {
    // A coleção de onde você quer buscar os nomes dos usuários
    final collection = FirebaseFirestore.instance.collection('User Name');

    // Dividindo os uids em lotes de 10, porque Firestore tem um limite para o número de itens na cláusula whereIn
    final List<Map<String, String>> namesBatch = [];
    for (var i = 0; i < uids.length; i += 10) {
      final batchUids =
          uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);

      // Realizando a busca
      final querySnapshot = await collection
          .where(FieldPath.documentId, whereIn: batchUids)
          .get();

      // Processando os resultados e adicionando ao mapa
      for (var doc in querySnapshot.docs) {
        final uid = doc.id;
        final name = doc['Nome'] ??
            ''; // Use um valor padrão ou manipule a ausência de nome como achar melhor
        namesBatch.add({uid: name});
      }
    }

    // Combinando todos os lotes em um único mapa
    final Map<String, String> names = {};
    for (var batch in namesBatch) {
      names.addAll(batch);
    }

    return names;
  }

  Future<Map<String, String>> getEmpresasNames(List<String> cnpjs) async {
    // A coleção de onde você quer buscar os nomes dos usuários
    final collection = FirebaseFirestore.instance.collection('Empresas');

    // Dividindo os uids em lotes de 10, porque Firestore tem um limite para o número de itens na cláusula whereIn
    final List<Map<String, String>> namesBatch = [];
    for (var i = 0; i < cnpjs.length; i += 10) {
      final batchUids =
          cnpjs.sublist(i, i + 10 > cnpjs.length ? cnpjs.length : i + 10);

      // Realizando a busca
      final querySnapshot = await collection
          .where(FieldPath.documentId, whereIn: batchUids)
          .get();

      // Processando os resultados e adicionando ao mapa
      for (var doc in querySnapshot.docs) {
        final cnpj = doc.id;
        final name = doc['Nome da empresa'] ??
            ''; // Use um valor padrão ou manipule a ausência de nome como achar melhor
        namesBatch.add({cnpj: name});
      }
    }

    // Combinando todos os lotes em um único mapa
    final Map<String, String> names = {};
    for (var batch in namesBatch) {
      names.addAll(batch);
    }

    return names;
  }

  Future<List<Message>?> buscarChatMissao(String missaoId) async {
    final get = await firestore
        .collection('Chat missão cliente')
        .doc(missaoId)
        .collection('Mensagens')
        .orderBy('createdAt', descending: false)
        .get();

    if (get.docs.isEmpty) {
      return null;
    } else {
      final messages = get.docs.map((doc) {
        return Message.fromJson(doc.data());
      }).toList();

      return messages;
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

  Future<void> addFcmTokenAdm() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    final uid = user?.uid;

    String? token;
    if (kIsWeb) {
      token = await FirebaseMessaging.instance.getToken(
          vapidKey:
              'BPEMSDicznf8_uGi2RxViOkhH3hidRJo0WT6UzyTpkMB7CfMYHw6h9HfkmVoOP7m95JWTHGgiTdXYk3OquJmpnE');
    } else {
      token = await FirebaseMessaging.instance.getToken();
    }
    await FirebaseFirestore.instance
        .collection('FCM Tokens')
        .doc('Plataforma Sombra')
        .collection('tokens')
        .doc(uid)
        .set({'FCM Token': token});
  }

  Future<void> compartilharAudio(
      String missaoId, String cnpj, String audioUrl) async {
    await firestore
        .collection('Chat missão cliente')
        .doc(missaoId)
        .collection('Mensagens')
        .doc()
        .set(
          Message(
                  message: audioUrl,
                  messageType: MessageType.voice,
                  createdAt: DateTime.now(),
                  optionalCreatedAt: FieldValue.serverTimestamp(),
                  sendBy: 'Atendente',
                  id: DateTime.timestamp().microsecondsSinceEpoch.toString(),
                  autor: 'Atendente')
              .paraJson(),
        );
    await firestore.collection('Chat missão cliente').doc(missaoId).set(
      {
        'userUnreadCount': FieldValue.increment(1),
        'lastMessageTimestamp': FieldValue.serverTimestamp()
      },
    );
  }
}
