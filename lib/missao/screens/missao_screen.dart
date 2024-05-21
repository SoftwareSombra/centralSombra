import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sombra_testes/missao/model/missao_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../chat/screens/chat_screen.dart';
import '../../chat/services/chat_services.dart';
import '../../internet_connection.dart';
import '../../mapa/screens/map_screen.dart';
import '../bloc/agente/agente_bloc.dart';
import '../bloc/agente/events.dart';
import '../camera/camera_screen.dart';
import '../relatorio/screens/add_relatorio_screen.dart';
import '../services/missao_services.dart';

class MissaoScreen extends StatefulWidget {
  final Missao missao;
  final gmap.LatLng startPosition;
  final String userUid;
  final String userName;
  const MissaoScreen(
      {super.key,
      required this.missao,
      required this.startPosition,
      required this.userUid,
      required this.userName});

  @override
  State<MissaoScreen> createState() => _MissaoScreenState();
}

class _MissaoScreenState extends State<MissaoScreen> {
  final TextEditingController msgController = TextEditingController();
  final ValueNotifier<bool> isSubmitting = ValueNotifier(false);
  final ScrollController controller = ScrollController();
  bool firstLoad = true;
  late final FirebaseMessaging firebaseMessaging;
  final ChatServices chatServices = ChatServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final ChatStatus chatStatus = ChatStatus();
  final ValueNotifier<bool> isUploading = ValueNotifier<bool>(false);
  bool? hasConnection;
  DateTime? initialTime;
  CameraDescription firstCamera = const CameraDescription(
      name: '', lensDirection: CameraLensDirection.back, sensorOrientation: 0);
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MissaoServices missaoServices = MissaoServices();
  Place? selectedStartLocation;
  bool isLoading = false;
  HawkFabMenuController hawkFabMenuController = HawkFabMenuController();

  //StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _listener;

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // Atualizando selectedStartLocation com a currentLocation
    setState(() {
      selectedStartLocation = Place(
        address: "Current Location",
        latLng: LatLng(lat: position.latitude, lng: position.longitude),
        name: "My Location",
        addressComponents: null,
        businessStatus: null,
        attributions: null,
        openingHours: null,
        phoneNumber: null,
        photoMetadatas: null,
        plusCode: null,
        priceLevel: null,
        rating: null,
        types: null,
        userRatingsTotal: null,
        utcOffsetMinutes: null,
        viewport: null,
        websiteUri: null,
        id: null,
      );
    });
  }

  Future<LatLng> getFinalLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(lat: position.latitude, lng: position.longitude);
  }

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      // A permissão ainda não foi concedida
      status = await Permission.camera.request();
      if (status.isGranted) {
        // Permissão concedida
        debugPrint("Permissão de câmera concedida");
      } else {
        // Permissão negada
        debugPrint("Permissão de câmera negada");
      }
    } else {
      // A permissão já foi concedida
      debugPrint("Permissão de câmera já está concedida");
    }
  }

  listarCameras() async {
    await requestCameraPermission();

    // Obtém uma lista de câmeras disponíveis no dispositivo.
    final cameras = await availableCameras();

    // Pega a primeira câmera da lista (geralmente a câmera traseira).
    firstCamera = cameras.first;
  }

  Future<void> salvarChatEmCache(hasConnection) async {
    if (!hasConnection) {
      return;
    }
    final chatEmCache =
        await chatServices.verificarChatMissaoCache(widget.missao.missaoId);
    debugPrint('chat em cache: ${chatEmCache.toString()}');
    if (chatEmCache) {
      await chatServices.deleteChatMissaoCache(widget.missao.missaoId);
    }
    debugPrint('Salvando chat em cache');
    try {
      final chatMessages = await FirebaseFirestore.instance
          .collection('Chat missão')
          .doc(widget.missao.missaoId)
          .collection('Mensagens')
          .orderBy('Timestamp', descending: false)
          .get();
      //usando for
      for (var element in chatMessages.docs) {
        final Timestamp timestamp = element['Timestamp'];
        final DateTime dateTime = timestamp.toDate();
        final String iso8601 = dateTime.toIso8601String();

        await chatServices.insertChatMissaoCache(
          element['User uid'],
          element['Mensagem'],
          //verificar se existe o campo imagem
          element.data().containsKey('Imagem') ? element['Imagem'] : null,
          iso8601,
          widget.missao.missaoId,
          element['Autor'],
          element['FotoUrl'],
        );
      }
    } catch (e) {
      debugPrint('Erro ao salvar chat em cache: $e');
    }
    //debugPrint das mensagens armazenadas no cache
    final chatMessagesCache =
        await chatServices.getChatMissaoCache(widget.missao.missaoId);
    debugPrint('chatMessagesCache: ${chatMessagesCache.toString()}');
  }

  Stream<List<Map<String, dynamic>>> getConversationMessages(
      bool hasConnection) async* {
    if (hasConnection) {
      // Aqui, convertemos os documentos do Firestore para Map e os emitimos como uma lista.
      yield* FirebaseFirestore.instance
          .collection('Chat missão')
          .doc(widget.missao.missaoId)
          .collection('Mensagens')
          .orderBy('Timestamp', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    } else {
      // Busca mensagens do armazenamento interno e emite como uma lista.
      var messages =
          await chatServices.getChatMissaoCache(widget.missao.missaoId);
      yield messages; // Supondo que 'messages' já seja uma List<Map<String, dynamic>>.
    }
  }

  Future<void> resetUserUnreadCount(String missaId) async {
    await FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(widget.missao.missaoId)
        .set({'userUnreadCount': 0}, SetOptions(merge: true));
  }

  void _updateChat() {
    FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(widget.missao.missaoId)
        .collection('Mensagens')
        .snapshots()
        .listen(
      (snapshot) {
        {
          controller.jumpTo(controller.position.maxScrollExtent);
        }
      },
    );
  }

  void updateChatCache() {
    final initialTimestamp = initialTime == null
        ? Timestamp.fromDate(DateTime.now())
        : Timestamp.fromDate(initialTime!);

    FirebaseFirestore.instance
        .collection('Chat missão')
        .doc(widget.missao.missaoId)
        .collection('Mensagens')
        .where('Timestamp', isGreaterThan: initialTimestamp)
        .orderBy('Timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final Timestamp timestamp = snapshot.docs[0].data()['Timestamp'];
        final DateTime dateTime = timestamp.toDate();
        final String iso8601 = dateTime.toIso8601String();

        await chatServices.insertChatMissaoCache(
            snapshot.docs[0].data()['User uid'],
            snapshot.docs[0].data()['Mensagem'],
            snapshot.docs[0].data()['Imagem'],
            iso8601,
            widget.missao.missaoId,
            snapshot.docs[0].data()['Autor'],
            snapshot.docs[0].data()['FotoUrl']);
      }
    });
  }

  Future<bool> checkConnectivity() async {
    setState(() {
      hasConnection = ConnectionNotifier.of(context).value;
    });
    return ConnectionNotifier.of(context).value;
  }

  @override
  void initState() {
    getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        listarCameras();
        final connection = await checkConnectivity();
        initialTime = DateTime.now();
        await salvarChatEmCache(connection);
        getConversationMessages(connection);
        resetUserUnreadCount(widget.missao.missaoId);
        chatStatus.isInChatScreen = true;
        firebaseMessaging = FirebaseMessaging.instance;
        _updateChat();
        //updateChatCache();
        // Checa e atualiza o FCM Token se necessário
        // _checkAndUpdateFcmToken();
        super.initState();
      },
    );
  }

  @override
  void dispose() {
    msgController.dispose();
    controller.dispose();
    chatStatus.isInChatScreen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // final nomeDoMotorista = missao.motorista!.split(' ');
    // final nome = nomeDoMotorista.length > 2
    //     ? nomeDoMotorista.take(2).join(" ")
    //     : nomeDoMotorista[0];
    return hasConnection == null
        ? const Center(child: CircularProgressIndicator())
        : HawkFabMenu(
            icon: AnimatedIcons.menu_arrow,
            fabColor: Colors.blue.withOpacity(0.7),
            iconColor: Colors.white,
            hawkFabMenuController: hawkFabMenuController,
            items: [
              HawkFabMenuItem(
                label: 'Câmera',
                ontap: () {
                  abrirCamera();
                },
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.blue,
                ),
                color: Colors.white,
                labelColor: Colors.black,
              ),
              HawkFabMenuItem(
                label: 'Mapa',
                ontap: () {
                  abrirMapa();
                },
                icon: const Icon(
                  Icons.map,
                  color: Colors.blue,
                ),
                labelColor: Colors.black,
                color: Colors.white,
                //labelBackgroundColor: Colors.blue,
              ),
              HawkFabMenuItem(
                label: 'Finalizar missão',
                ontap: () {
                  dialogoParaFinalizarMissao();
                },
                icon: const Icon(
                  Icons.done,
                  color: Colors.red,
                ),
                color: Colors.white,
                labelColor: Colors.white,
                labelBackgroundColor: Colors.red,
              ),
            ],
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Card(
                  //   elevation: 2,
                  //   child:
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 25),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.gps_fixed,
                              color: Colors.blue,
                            ),
                            SizedBox(width: width * 0.02),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tipo:',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  widget.missao.tipo,
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                            ),
                            SizedBox(width: width * 0.02),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Local:',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: width * 0.8,
                                  child: Text(
                                    widget.missao.local,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Padding(
                  //   padding: EdgeInsets.only(left: width * 0.08),
                  //   child: Row(
                  //     children: [
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const Text(
                  //             'Placa cavalo:',
                  //             style: TextStyle(
                  //                 fontSize: 15, fontWeight: FontWeight.w300),
                  //           ),
                  //           Text(
                  //             widget.missao.placaCavalo == ''
                  //                 ? ' - '
                  //                 : widget.missao.placaCavalo!,
                  //             style: const TextStyle(
                  //                 fontSize: 21, fontWeight: FontWeight.bold),
                  //           ),
                  //           const SizedBox(height: 5),
                  //           const Text(
                  //             'Motorista:',
                  //             overflow: TextOverflow.ellipsis,
                  //             maxLines: 1,
                  //             style: TextStyle(
                  //                 fontSize: 15, fontWeight: FontWeight.w300),
                  //           ),
                  //           Text(
                  //             widget.missao.motorista == ''
                  //                 ? ' - '
                  //                 : widget.missao.motorista!,
                  //             style: const TextStyle(
                  //                 fontSize: 21, fontWeight: FontWeight.bold),
                  //           )
                  //         ],
                  //       ),
                  //       SizedBox(width: width * 0.2),
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           const Text(
                  //             'Placa carreta:',
                  //             style: TextStyle(
                  //                 fontSize: 15, fontWeight: FontWeight.w300),
                  //           ),
                  //           Text(
                  //             widget.missao.placaCarreta == ''
                  //                 ? ' - '
                  //                 : widget.missao.placaCarreta!,
                  //             style: const TextStyle(
                  //                 fontSize: 21, fontWeight: FontWeight.bold),
                  //           ),
                  //           const SizedBox(height: 5),
                  //           const Text(
                  //             'Cor do veículo:',
                  //             style: TextStyle(
                  //                 fontSize: 15, fontWeight: FontWeight.w300),
                  //           ),
                  //           Text(
                  //             widget.missao.corVeiculo == ''
                  //                 ? ' - '
                  //                 : widget.missao.corVeiculo!,
                  //             style: const TextStyle(
                  //                 fontSize: 21, fontWeight: FontWeight.bold),
                  //           )
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Card(
                      color: Colors.blue.withOpacity(0.5),
                      elevation: 1,
                      child: Container(
                        width: width,
                        height: height * 0.35,
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            children: [
                              //const SizedBox(height: 10),
                              Container(
                                color: Colors.black.withOpacity(0.3),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        BoxIcons.bx_expand_alt,
                                        size: 16,
                                        color: Colors.transparent,
                                      ),
                                      Row(
                                        children: [
                                          Icon(Bootstrap.whatsapp,
                                              color: Colors.white, size: 22),
                                          SizedBox(width: 8),
                                          Text(
                                            'CENTRAL',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        BoxIcons.bx_expand_alt,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Expanded(
                                child:
                                    StreamBuilder<List<Map<String, dynamic>>>(
                                  stream:
                                      getConversationMessages(hasConnection!),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Erro: ${snapshot.error}');
                                    }

                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        !snapshot.hasData) {
                                      // Aqui você retorna um CircularProgressIndicator se o snapshot ainda está carregando
                                      // ou se os dados ainda não estão disponíveis (null).
                                      return const CircularProgressIndicator();
                                    }

                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (controller.hasClients) {
                                        controller.jumpTo(controller
                                            .position.maxScrollExtent);
                                      }
                                    });

                                    return Listener(
                                      onPointerDown: (_) {
                                        FocusScope.of(context).unfocus();
                                      },
                                      child: ListView.builder(
                                        controller: controller,
                                        itemCount: snapshot.data?.length ??
                                            0, // Usa 0 se snapshot.data for null.
                                        itemBuilder: (context, index) {
                                          Map<String, dynamic>? data =
                                              snapshot.data?[
                                                  index]; // data pode ser null.
                                          if (data == null) {
                                            // Você pode decidir o que fazer se o dado for null.
                                            // Por exemplo, retornar um widget vazio ou algum placeholder.
                                            return const SizedBox.shrink();
                                          }

                                          debugPrint('Data: $data');
                                          final autor =
                                              data['User uid']?.isEmpty ?? true
                                                  ? data['userUid']
                                                  : data['User uid'];
                                          final messageText = data['Mensagem'];
                                          final imageUrl = data['Imagem'];
                                          final timestamp = data['Timestamp'];
                                          final isCurrentUser =
                                              autor == widget.userUid;

                                          if (timestamp is String) {
                                            final timestamp2 =
                                                DateTime.parse(timestamp);
                                            final timestamp3 =
                                                Timestamp.fromDate(timestamp2);

                                            return MessageBubble(
                                              message: messageText,
                                              sender: autor,
                                              isCurrentUser: isCurrentUser,
                                              imageUrl: imageUrl,
                                              timestamp: timestamp3,
                                            );
                                          } else {
                                            return MessageBubble(
                                              message: messageText,
                                              sender: autor,
                                              isCurrentUser: isCurrentUser,
                                              imageUrl: imageUrl,
                                              timestamp: timestamp,
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Botão para anexos

                                      RawMaterialButton(
                                        onPressed: () async {
                                          // Ação para anexar arquivo
                                          final ImagePicker picker =
                                              ImagePicker();
                                          final XFile? image =
                                              await picker.pickImage(
                                                  source: ImageSource.gallery);

                                          if (image != null) {
                                            File imageFile = File(image.path);
                                            await _showImagePreviewAndUpload(
                                                imageFile,
                                                widget.userName,
                                                widget
                                                    .userUid); // Mostra a prévia da imagem
                                          }
                                        },
                                        shape: const CircleBorder(),
                                        //fillColor: Colors.blue,
                                        constraints:
                                            const BoxConstraints.expand(
                                                width: 20, height: 20),
                                        child: ValueListenableBuilder(
                                          valueListenable: isUploading,
                                          builder: (context, bool isUploading,
                                              child) {
                                            return isUploading
                                                ? const CircularProgressIndicator()
                                                : const Icon(
                                                    Icons.attach_file,
                                                    color: Colors.white,
                                                  );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // TextFormField
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (BuildContext context,
                                              BoxConstraints constraints) {
                                            return Center(
                                              child: SingleChildScrollView(
                                                reverse: true,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom:
                                                        MediaQuery.of(context)
                                                            .viewInsets
                                                            .bottom,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          controller:
                                                              msgController,
                                                          minLines: 1,
                                                          maxLines: 3,
                                                          maxLength: 500,
                                                          decoration:
                                                              InputDecoration(
                                                            counter:
                                                                const Offstage(),
                                                            //counterText: '',
                                                            labelText:
                                                                'Digite sua mensagem aqui',
                                                            labelStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .grey),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 10.0,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: isSubmitting,
                                        builder: (context, bool value, child) {
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              value
                                                  ? const CircularProgressIndicator()
                                                  : RawMaterialButton(
                                                      onPressed: value
                                                          ? null
                                                          : () async {
                                                              isSubmitting
                                                                  .value = true;
                                                              if (msgController
                                                                  .text
                                                                  .trim()
                                                                  .isNotEmpty) {
                                                                await chatServices.addMsgMissao(
                                                                    msgController,
                                                                    widget
                                                                        .userName,
                                                                    widget
                                                                        .userUid,
                                                                    widget
                                                                        .missao
                                                                        .missaoId,
                                                                    null);
                                                              }
                                                              isSubmitting
                                                                      .value =
                                                                  false;
                                                              controller
                                                                  .animateTo(
                                                                controller
                                                                    .position
                                                                    .maxScrollExtent,
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                curve: Curves
                                                                    .easeOut,
                                                              );
                                                            },
                                                      shape:
                                                          const CircleBorder(),
                                                      fillColor: Colors.white
                                                          .withOpacity(0.9),
                                                      constraints:
                                                          const BoxConstraints
                                                              .expand(
                                                              width: 35,
                                                              height: 35),
                                                      child: const Icon(
                                                        Icons.send,
                                                        size: 20,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                              if (value)
                                                const CircularProgressIndicator(),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     IconButton(
                  //       iconSize: 27,
                  //       padding: const EdgeInsets.all(10),
                  //       onPressed: () {
                  //         debugPrint(
                  //             'selectedStartLocation: $selectedStartLocation');
                  //         if (selectedStartLocation != null) {
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (context) => MapScreen(
                  //                 cnpj: widget.missao.cnpj,
                  //                 nomeDaEmpresa: widget.missao.nomeDaEmpresa,
                  //                 placaCavalo: widget.missao.placaCavalo,
                  //                 placaCarreta: widget.missao.placaCarreta,
                  //                 motorista: widget.missao.motorista,
                  //                 corVeiculo: widget.missao.corVeiculo,
                  //                 observacao: widget.missao.observacao,
                  //                 startPosition: LatLng(
                  //                     lat: selectedStartLocation!.latLng!.lat,
                  //                     lng: selectedStartLocation!.latLng!.lng),
                  //                 endPosition: LatLng(
                  //                     lat: widget.missao.missaoLatitude,
                  //                     lng: widget.missao.missaoLongitude),
                  //                 missaoId: widget.missao.missaoId,
                  //                 tipo: widget.missao.tipo,
                  //                 inicio: widget.missao.inicio,
                  //               ),
                  //             ),
                  //           );
                  //         }
                  //       },
                  //       icon: const Icon(Icons.map),
                  //     ),
                  //     isLoading
                  //         ? const CircularProgressIndicator()
                  //         : ElevatedButton(
                  //             style: ElevatedButton.styleFrom(
                  //               backgroundColor: Colors.red,
                  //             ),
                  //             onPressed: () async {
                  //               setState(() {
                  //                 isLoading = true;
                  //               });

                  //               // final userFinal = getCurrentLocation();
                  //               final userFinalLocation =
                  //                   await getFinalLocation();
                  //               //final now = DateTime.now();
                  //               final userFinalLatitude = userFinalLocation.lat;
                  //               final userFinalLongitude =
                  //                   userFinalLocation.lng;
                  //               final currentLocation =
                  //                   await Geolocator.getCurrentPosition(
                  //                       desiredAccuracy: LocationAccuracy.high);
                  //               if (selectedStartLocation != null) {
                  //                 // await missaoServices.finalLocalMissao(
                  //                 //     uid, widget.missaoId, currentLocation);
                  //                 final finalLocal = await missaoServices
                  //                     .finalLocalMissaoSelectFunction(
                  //                         widget.userUid,
                  //                         widget.missao.missaoId,
                  //                         currentLocation.latitude,
                  //                         currentLocation.longitude);
                  //                 final finalizar = await missaoServices
                  //                     .finalizarMissaoSelectFunction(
                  //                   widget.missao.cnpj,
                  //                   widget.missao.nomeDaEmpresa,
                  //                   widget.missao.placaCavalo,
                  //                   widget.missao.placaCarreta,
                  //                   widget.missao.motorista,
                  //                   widget.missao.corVeiculo,
                  //                   widget.missao.observacao,
                  //                   widget.userUid,
                  //                   widget.startPosition.latitude,
                  //                   widget.startPosition.longitude,
                  //                   userFinalLatitude,
                  //                   userFinalLongitude,
                  //                   widget.missao.missaoLatitude,
                  //                   widget.missao.missaoLongitude,
                  //                   widget.missao.local,
                  //                   widget.missao.tipo,
                  //                   widget.missao.missaoId,
                  //                   fim: DateTime.now().toIso8601String(),
                  //                 );
                  //                 final relatorio = await missaoServices
                  //                     .relatorioMissaoSelectFunction(
                  //                   widget.missao.cnpj,
                  //                   widget.missao.nomeDaEmpresa,
                  //                   widget.missao.placaCavalo,
                  //                   widget.missao.placaCarreta,
                  //                   widget.missao.motorista,
                  //                   widget.missao.corVeiculo,
                  //                   widget.missao.observacao,
                  //                   widget.userUid,
                  //                   widget.missao.missaoId,
                  //                   widget.userName,
                  //                   widget.missao.tipo,
                  //                   widget.startPosition.latitude,
                  //                   widget.startPosition.longitude,
                  //                   userFinalLatitude,
                  //                   userFinalLongitude,
                  //                   widget.missao.missaoLatitude,
                  //                   widget.missao.missaoLongitude,
                  //                   widget.missao.local,
                  //                   fim: DateTime.now().toIso8601String(),
                  //                 );
                  //                 debugPrint(
                  //                     "Final local: ${finalLocal.item2}");
                  //                 debugPrint("Finalizar: ${finalizar.item2}");
                  //                 debugPrint("Relatorio: ${relatorio.item2}");

                  //                 setState(() {
                  //                   isLoading = false;
                  //                 });

                  //                 if (context.mounted) {
                  //                   finalLocal.item1
                  //                       ? mensagemDeSucesso.showSuccessSnackbar(
                  //                           context, finalLocal.item2)
                  //                       : tratamentoDeErros.showErrorSnackbar(
                  //                           context, finalLocal.item2);
                  //                   finalizar.item1
                  //                       ? mensagemDeSucesso.showSuccessSnackbar(
                  //                           context, finalizar.item2!)
                  //                       : tratamentoDeErros.showErrorSnackbar(
                  //                           context, finalizar.item2!);
                  //                   relatorio.item1
                  //                       ? mensagemDeSucesso.showSuccessSnackbar(
                  //                           context, relatorio.item2)
                  //                       : tratamentoDeErros.showErrorSnackbar(
                  //                           context, relatorio.item2);
                  //                   context
                  //                       .read<AgentMissionBloc>()
                  //                       .add(FetchMission());
                  //                   Navigator.push(
                  //                     context,
                  //                     MaterialPageRoute(
                  //                       builder: (context) =>
                  //                           AddRelatorioScreen(
                  //                               uid: widget.userUid,
                  //                               missaoId:
                  //                                   widget.missao.missaoId),
                  //                     ),
                  //                   );
                  //                 }
                  //               }
                  //             },
                  //             child: const Text('Finalizar'),
                  //           ),
                  //     IconButton(
                  //       padding: const EdgeInsets.all(10),
                  //       iconSize: 27,
                  //       onPressed: () async {
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (context) => CameraScreen(
                  //               camera: firstCamera,
                  //               missaoId: widget.missao.missaoId,
                  //             ),
                  //           ),
                  //         );
                  //       },
                  //       icon: const Icon(Icons.camera_alt),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          );
  }

  abrirMapa() {
    PersistentNavBarNavigator.pushNewScreen(context,
        screen: MapScreen(
          cnpj: widget.missao.cnpj,
          nomeDaEmpresa: widget.missao.nomeDaEmpresa,
          placaCavalo: widget.missao.placaCavalo,
          placaCarreta: widget.missao.placaCarreta,
          motorista: widget.missao.motorista,
          corVeiculo: widget.missao.corVeiculo,
          observacao: widget.missao.observacao,
          startPosition: LatLng(
              lat: selectedStartLocation!.latLng!.lat,
              lng: selectedStartLocation!.latLng!.lng),
          endPosition: LatLng(
              lat: widget.missao.missaoLatitude,
              lng: widget.missao.missaoLongitude),
          missaoId: widget.missao.missaoId,
          tipo: widget.missao.tipo,
          inicio: widget.missao.inicio,
        ),
        withNavBar: false);
  }

  abrirCamera() {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: CameraScreen(
        camera: firstCamera,
        missaoId: widget.missao.missaoId,
      ),
      withNavBar: false,
    );
  }

  dialogoParaFinalizarMissao() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text('Confirmação'),
          content: const Text(
              'Deseja finalizar a missão? Esta ação não poderá ser desfeita.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Finalizar'),
              onPressed: () async {
                Navigator.of(context).pop();
                finalizarMissao();
              },
            ),
          ],
        );
      },
    );
  }

  finalizarMissao() async {
    setState(() {
      isLoading = true;
    });

    // final userFinal = getCurrentLocation();
    final userFinalLocation = await getFinalLocation();
    //final now = DateTime.now();
    final userFinalLatitude = userFinalLocation.lat;
    final userFinalLongitude = userFinalLocation.lng;
    final currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (selectedStartLocation != null) {
      // await missaoServices.finalLocalMissao(
      //     uid, widget.missaoId, currentLocation);
      final finalLocal = await missaoServices.finalLocalMissaoSelectFunction(
          widget.userUid,
          widget.missao.missaoId,
          currentLocation.latitude,
          currentLocation.longitude);
      final finalizar = await missaoServices.finalizarMissaoSelectFunction(
        widget.missao.cnpj,
        widget.missao.nomeDaEmpresa,
        widget.missao.placaCavalo,
        widget.missao.placaCarreta,
        widget.missao.motorista,
        widget.missao.corVeiculo,
        widget.missao.observacao,
        widget.userUid,
        widget.startPosition.latitude,
        widget.startPosition.longitude,
        userFinalLatitude,
        userFinalLongitude,
        widget.missao.missaoLatitude,
        widget.missao.missaoLongitude,
        widget.missao.local,
        widget.missao.tipo,
        widget.missao.missaoId,
        fim: DateTime.now().toIso8601String(),
      );
      final relatorio = await missaoServices.relatorioMissaoSelectFunction(
        widget.missao.cnpj,
        widget.missao.nomeDaEmpresa,
        widget.missao.placaCavalo,
        widget.missao.placaCarreta,
        widget.missao.motorista,
        widget.missao.corVeiculo,
        widget.missao.observacao,
        widget.userUid,
        widget.missao.missaoId,
        widget.userName,
        widget.missao.tipo,
        widget.startPosition.latitude,
        widget.startPosition.longitude,
        userFinalLatitude,
        userFinalLongitude,
        widget.missao.missaoLatitude,
        widget.missao.missaoLongitude,
        widget.missao.local,
        'Agente',
        fim: DateTime.now().toIso8601String(),
      );
      debugPrint("Final local: ${finalLocal.item2}");
      debugPrint("Finalizar: ${finalizar.item2}");
      debugPrint("Relatorio: ${relatorio.item2}");

      setState(() {
        isLoading = false;
      });

      if (context.mounted) {
        finalLocal.item1
            ? mensagemDeSucesso.showSuccessSnackbar(context, finalLocal.item2)
            : tratamentoDeErros.showErrorSnackbar(context, finalLocal.item2);
        finalizar.item1
            ? mensagemDeSucesso.showSuccessSnackbar(context, finalizar.item2!)
            : tratamentoDeErros.showErrorSnackbar(context, finalizar.item2!);
        relatorio.item1
            ? mensagemDeSucesso.showSuccessSnackbar(context, relatorio.item2)
            : tratamentoDeErros.showErrorSnackbar(context, relatorio.item2);
        context.read<AgentMissionBloc>().add(FetchMission());
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: AddRelatorioScreen(
              uid: widget.userUid, missaoId: widget.missao.missaoId),
          withNavBar: false,
        );
      }
    }
  }

  Future<void> _showImagePreviewAndUpload(
      File imageFile, userName, userUid) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Image.file(imageFile),
                const Text('Deseja enviar esta imagem?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Enviar'),
              onPressed: () async {
                Navigator.of(context).pop();
                // comprimir e enviar a imagem
                final Uint8List? compressedImage =
                    await FlutterImageCompress.compressWithFile(
                  imageFile.path,
                  quality: 50,
                );

                final Directory tempDir = await getTemporaryDirectory();
                final String targetPath = '${tempDir.path}/temp_image.jpg';

                File image =
                    await File(targetPath).writeAsBytes(compressedImage!);
                debugPrint('image: $image');
                await _uploadAndSendMessage(image, userName, userUid);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadAndSendMessage(File imageFile, userName, userUid) async {
    isUploading.value = true;
    try {
      String filePath = 'chat_images/${DateTime.now()}.png';
      TextEditingController msgFotoController = TextEditingController();

      // Fazer upload da imagem
      UploadTask uploadTask =
          FirebaseStorage.instance.ref().child(filePath).putFile(imageFile);

      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();

      // Enviar a URL da imagem como mensagem
      await chatServices.addMsgMissao(
        msgFotoController,
        userName,
        userUid,
        widget.missao.missaoId,
        url,
      );
    } catch (e) {
      // Tratar possíveis erros aqui
    } finally {
      isUploading.value = false;
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String? message;
  final String sender;
  final bool isCurrentUser;
  final String? imageUrl;
  final Timestamp? timestamp;

  const MessageBubble(
      {super.key,
      this.message,
      required this.sender,
      required this.isCurrentUser,
      this.imageUrl,
      this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
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
                    ? GestureDetector(
                        onTap: () => _showImageDialog(context, imageUrl!),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl!,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
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
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10),
          child: Text(
            timestamp == null
                ? ''
                : DateFormat('dd/MM/yyyy HH:mm').format(timestamp!.toDate()),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // void _showImageDialog(BuildContext context, String imageUrl) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => Dialog(
  //       child: Container(
  //         padding: const EdgeInsets.all(10),
  //         child: CachedNetworkImage(
  //           imageUrl: imageUrl,
  //           placeholder: (context, url) =>
  //               const Center(child: CircularProgressIndicator()),
  //           errorWidget: (context, url, error) => const Icon(Icons.error),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: PhotoView(
            maxScale: PhotoViewComputedScale.covered * 2,
            minScale: PhotoViewComputedScale.contained,
            imageProvider: CachedNetworkImageProvider(
              imageUrl,
            ),
          ),
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
