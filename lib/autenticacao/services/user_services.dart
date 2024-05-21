import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuple/tuple.dart';
import '../../perfil_user/bloc/foto/user/events.dart';
import '../../perfil_user/bloc/foto/user/user_foto_bloc.dart';
import '../../perfil_user/bloc/nome/get_name_bloc.dart';
import '../../perfil_user/bloc/nome/get_name_events.dart';
import '../screens/tratamento/error_snackbar.dart';
import '../screens/tratamento/success_snackbar.dart';
import 'log_services.dart';

class UserServices {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  LogServices logServices = LogServices();
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String fotoDePerfilNull =
      'https://firebasestorage.googleapis.com/v0/b/primeval-rune-309222.appspot.com/o/FotoNull%2FfotoDePerfilNull.jpg?alt=media&token=83532362-51e3-4cbb-8f83-cf6accd7aedb';

  Future<bool> registerUser(String name, String email, String password) async {
    if (!isEmailValid(email)) {
      return false;
    }

    if (!isPasswordValid(password)) {
      return false;
    }
    return await performRegistration(name, email, password);
  }

  Future<bool> performRegistration(
      String name, String email, String password) async {
    String? token = await getFCMtoken();
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      debugPrint("criado com sucesso");
      try {
        await userCredential.user!.updateEmail(email);
      } catch (e) {
        debugPrint("Erro ao atualizar o email: $e");
      }

      try {
        await userCredential.user!.updateDisplayName(name);
      } catch (e) {
        debugPrint("Erro ao atualizar o nome: $e");
      }
      final uid = userCredential.user!.uid;
      debugPrint("uid: $uid");
      await firestore.collection('FCM Tokens').doc(uid).set({
        'sinc': 'sinc',
      });
      await firestore.collection('FCM Tokens').doc('Plataforma Sombra').set({
        'sinc': 'sinc',
      });
      if (token != null) {
        await firestore
            .collection('FCM Tokens')
            .doc(uid)
            .collection('tokens')
            .doc(token)
            .set({
          'FCM Token': token,
        });
        await firestore
            .collection('FCM Tokens')
            .doc('Plataforma Sombra')
            .collection('tokens')
            .doc(uid)
            .set({
          'FCM Token': token,
        });
        debugPrint("token: $token");
        await addFotoPerfil(uid, userCredential);
        debugPrint("foto de perfil adicionada, teste");
        await addNome(uid, name);
        debugPrint("nome adicionado");
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Tuple2<bool, Object?>> registerUser2(
      String name, String email, String password) async {
    if (!isEmailValid(email)) {
      return const Tuple2(false, "Email inválido");
    }

    if (!isPasswordValid(password)) {
      return const Tuple2(false, "Senha inválida");
    }

    // Aqui, performRegistration deve retornar Tuple2<bool, String>
    Tuple2<bool, Object?> registrationResult =
        await performRegistration2(name, email, password);

    // Se registrationResult.item2 for null, substitua por Object
    return Tuple2(registrationResult.item1, registrationResult.item2);
  }

  Future<Tuple2<bool, Object?>> performRegistration2(
      String name, String email, String password) async {
    String? token = await getFCMtoken();
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      debugPrint("criado com sucesso");
      try {
        await userCredential.user!.updateEmail(email);
      } catch (e) {
        debugPrint("Erro ao atualizar o email: $e");
      }

      try {
        await userCredential.user!.updateDisplayName(name);
      } catch (e) {
        debugPrint("Erro ao atualizar o nome: $e");
      }
      final uid = userCredential.user!.uid;
      debugPrint("uid: $uid");
      await firestore.collection('FCM Tokens').doc(uid).set({
        'sinc': 'sinc',
      });
      await firestore.collection('FCM Tokens').doc('Plataforma Sombra').set({
        'sinc': 'sinc',
      });
      if (token != null) {
        await firestore
            .collection('FCM Tokens')
            .doc(uid)
            .collection('tokens')
            .doc(token)
            .set({
          'FCM Token': token,
        });
        await firestore
            .collection('FCM Tokens')
            .doc('Plataforma Sombra')
            .collection('tokens')
            .doc(uid)
            .set({
          'FCM Token': token,
        });
        debugPrint("token: $token");
        await addFotoPerfil(uid, userCredential);
        debugPrint("foto de perfil adicionada, teste");
        await addNome(uid, name);
        debugPrint("nome adicionado");
      }
      return const Tuple2(true, null);
    } catch (e) {
      debugPrint(e.toString());
      return Tuple2(false, e);
    }
  }

  Future<Tuple2<bool, Object?>> performRegistration3(
      String name, String email, String password) async {
    //String? token = await getFCMtoken();
    try {
      //requisicao com HTTPSCallable
      HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'southamerica-east1')
              .httpsCallable('cadastro');

      // HttpsCallable newcallable =
      //     FirebaseFunctions.instanceFor(region: 'southamerica-east1')
      //         .httpsCallable('updateMissingDisplayNames');

      final response = await callable.call(<String, dynamic>{
        'nome': name,
        'email': email,
        'senha': password,
      });
      //await newcallable.call();
      debugPrint("response: ${response.data}");
      final uid = response.data['uid'];
      debugPrint("criado com sucesso");
      debugPrint("uid: $uid");

      // if (uid != null) {
      //   await firestore.collection('User Foto').doc(uid).set({
      //     'FotoUrl': fotoDePerfilNull,
      //   });
      //   debugPrint("foto de perfil adicionada");
      //   await firestore.collection('User Name').doc(uid).set({
      //     'Nome': name,
      //     'UID': uid,
      //   });
      // }

      return Tuple2(true, uid);
    } catch (e) {
      debugPrint(e.toString());
      return Tuple2(false, e);
    }
  }

  Future<void> addFcmToken() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    String? token = await getFCMtoken();
    await firestore
        .collection('FCM Tokens')
        .doc(uid)
        .collection('tokens')
        .doc(token)
        .set({
      'FCM Token': token,
    });
  }

  Future<void> addNome(uid, nome) async {
    await firestore.collection('User Name').doc(uid).set({
      'Nome': nome,
      'UID': uid,
    });
  }

  Future<void> addFotoPerfil(uid, userCredential) async {
    try {
      await firestore.collection('User Foto').doc(uid).set({
        'FotoUrl': fotoDePerfilNull,
      });
      debugPrint("foto de perfil adicionada");
      // // Carrega a imagem como um Uint8List
      // Uint8List imageData =
      //     (await rootBundle.load('assets/images/fotoDePerfilNull.jpg'))
      //         .buffer
      //         .asUint8List();

      // debugPrint("imagem carregada");

      // // Cria uma referência no Firebase Storage com o uid do usuário
      // final storageReference = FirebaseStorage.instance
      //     .ref()
      //     .child('profileImages/$uid/defaultProfileImage.jpg');

      //     debugPrint("referencia criada");

      // // Envia a imagem para o Firebase Storage
      // final uploadTask = storageReference.putData(
      //     imageData, SettableMetadata(contentType: 'image/jpeg'));

      //     debugPrint("imagem enviada");

      // // Obtem a URL de download após o upload ser concluído
      // final snapshot = await uploadTask.whenComplete(() {});
      // debugPrint("snapshot: $snapshot");
      // final downloadUrl = await snapshot.ref.getDownloadURL();
      // debugPrint("downloadUrl: $downloadUrl");
      // // Atualiza a foto do perfil do usuário
      try {
        await userCredential.user!.updatePhotoURL(fotoDePerfilNull);
        debugPrint("foto de perfil atualizada");
      } catch (e) {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint("Erro ao adicionar a foto de perfil: $e");
    }
  }

  Future<String?> getName() async {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    debugPrint("userUid: $userUid");
    if (user != null) {
      return user.displayName ?? 'Nome não disponível';
    } else {
      return 'Nenhum usuário autenticado';
    }
  }

  Future<String?> getUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      final snapshot = await firestore.collection('User Name').doc(uid).get();
      final data = snapshot.data() as Map<String, dynamic>;
      final nome = data['Nome'];
      return nome;
    } catch (e) {
      debugPrint("Erro ao obter o nome do usuário: $e");
      return null;
    }
  }

  Future<String?> getUidUserName(String uid) async {
    try {
      final snapshot = await firestore.collection('User Name').doc(uid).get();
      final data = snapshot.data() as Map<String, dynamic>;
      final nome = data['Nome'];
      return nome;
    } catch (e) {
      debugPrint("Erro ao obter o nome do usuário: $e");
      return null;
    }
  }

  Future<String?> getAgenteName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid;
      final snapshot = await firestore.collection('User infos').doc(uid).get();
      final data = snapshot.data() as Map<String, dynamic>;
      final nome = data['Nome'];
      return nome;
    } catch (e) {
      debugPrint("Erro ao obter o nome do usuário: $e");
      return null;
    }
  }

  Future<String?> getPhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.photoURL ?? 'Foto não disponível';
    } else {
      return 'Nenhum usuário autenticado';
    }
  }

  Future<Uint8List?> getPhotoBytes() async {
    final user = FirebaseAuth.instance.currentUser;
    final photoURL = user?.photoURL;
    var dio = Dio();

    if (photoURL != null) {
      try {
        final response = await dio.get<List<int>>(photoURL,
            options: Options(responseType: ResponseType.bytes));

        return Uint8List.fromList(response.data!);
      } catch (e) {
        throw Exception('Falha ao carregar a foto do usuário: $e');
      }
    } else {
      return null;
    }
  }

  Future<bool> updateUserName(context, uid, nome) async {
    final userBloc = BlocProvider.of<UserBloc>(context);
    final user = FirebaseAuth.instance.currentUser;
    try {
      await firestore.collection('User Name').doc(uid).update({
        'Nome': nome,
        'UID': uid,
      });
      await user!.updateDisplayName(nome);
      userBloc.add(UpdateUserName(nome));
      mensagemDeSucesso.showSuccessSnackbar(
          context, 'Nome alterado com sucesso');
      return true;
    } catch (e) {
      tratamentoDeErros.showErrorSnackbar(
          context, 'Falha ao alterar o nome, tente novamente');
      return false;
    }
  }

  Future<bool> updateUserPhoto(context, uid, Uint8List fotoBytes) async {
    final userBloc = BlocProvider.of<UserFotoBloc>(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profileImages/$uid/profileImage$timestamp.jpg');

      final uploadTask = storageRef.putData(fotoBytes);

      final snapshot = await uploadTask.whenComplete(() => null);
      final photoUrl = await snapshot.ref.getDownloadURL();

      await firestore.collection('User Foto').doc(uid).update({
        'FotoUrl': photoUrl,
      });

      await user!.updatePhotoURL(photoUrl);

      final newFoto = await getPhoto();
      userBloc.add(UpdateUserFoto(newFoto!));

      mensagemDeSucesso.showSuccessSnackbar(
          context, 'Foto alterada com sucesso');
      return true;
    } catch (e) {
      tratamentoDeErros.showErrorSnackbar(
          context, 'Falha ao alterar a foto, tente novamente');
      return false; // Retorno caso ocorra um erro
    }
  }

  Future<String?> getFCMtoken() async {
    try {
      String? token;
      if (kIsWeb) {
        token = await messaging.getToken(
            vapidKey:
                'BPEMSDicznf8_uGi2RxViOkhH3hidRJo0WT6UzyTpkMB7CfMYHw6h9HfkmVoOP7m95JWTHGgiTdXYk3OquJmpnE');
      } else {
        token = await messaging.getToken();
      }
      return token;
    } catch (error) {
      debugPrint("Erro ao tentar obter o FCM token: $error");
      return null;
    }
  }

  Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      return claims?['admin'] ?? false;
    }
    return false;
  }

  bool isEmailValid(String email) {
    return RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  bool isPasswordValid(String password) {
    return password.length >= 6;
  }

  Future<void> resetPassword(context, String email) async {
    try {
      if (isEmailValid(email)) {
        await firebaseAuth.sendPasswordResetEmail(email: email);
        mensagemDeSucesso.showSuccessSnackbar(
            context, 'Email enviado com sucesso');
      } else {
        tratamentoDeErros.showErrorSnackbar(
            context, 'Falha ao enviar email, tente novamente');
      }
    } catch (e) {
      debugPrint('Erro: $e');
      tratamentoDeErros.showErrorSnackbar(
          context, 'Falha ao enviar email, tente novamente');
    }
  }

  Future<PlatformFile?> selectImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result == null) return null;

    final PlatformFile file = result.files.first;

    return file;
  }

  Future<String?> uploadImageAndGetUrl(
      PlatformFile? file, String uid, String fileName) async {
    if (file == null) {
      return null;
    }

    final imageRef =
        FirebaseStorage.instance.ref().child('Usuários docs/$uid/$fileName');

    late TaskSnapshot snapshot;
    if (kIsWeb) {
      snapshot = await imageRef.putData(file.bytes!);
    } else {
      final imageFileMobile = File(file.path!);
      snapshot = await imageRef.putFile(imageFileMobile);
    }

    return await snapshot.ref.getDownloadURL();
  }
}
