import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_view/photo_view.dart';
import 'package:sombra/autenticacao/screens/tratamento/error_snackbar.dart';
import 'package:sombra/autenticacao/screens/tratamento/success_snackbar.dart';
import 'package:sombra/chat_view/src/extensions/extensions.dart';
import 'package:sombra/web/home/screens/mapa_teste.dart';
import 'package:sombra/web/relatorios/models/relatorio_cliente.dart';
import 'package:sombra/web/relatorios/services/relatorio_services.dart';
import '../../../chat/screens/chat_screen.dart';
import '../../../chat_view/chatview.dart';
import '../../../chat_view/src/widgets/chat_bubble_widget.dart';
import '../../../chat_view/src/widgets/chat_group_header.dart';
import '../../../missao/model/missao_model.dart';
import '../../../widgets_comuns/elevated_button/elevated_button_2/elevated_button_bloc.dart';
import '../../../widgets_comuns/elevated_button/elevated_button_2/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/elevated_button/elevated_button_2/elevated_button_bloc_state.dart';
import '../../../widgets_comuns/elevated_button/elevated_button_bloc_3/elevated_button_bloc.dart';
import '../../../widgets_comuns/elevated_button/elevated_button_bloc_3/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/elevated_button/elevated_button_bloc_3/elevated_button_bloc_state.dart';
import '../bloc/mission_details_bloc.dart';
import '../bloc/mission_details_event.dart';
import '../bloc/mission_details_state.dart';
import '../components/edit_relatorio_dialog.dart';
import 'pdf_screen.dart';
import 'dart:ui' as ui;

class MissionDetails extends StatefulWidget {
  final String missaoId;
  final String agenteId;
  const MissionDetails(
      {super.key, required this.missaoId, required this.agenteId});

  @override
  State<MissionDetails> createState() => _MissionDetailsState();
}

const canvasColor = Color.fromARGB(255, 0, 15, 42);

class _MissionDetailsState extends State<MissionDetails> {
  final RelatorioServices relatorioServices = RelatorioServices();
  final Completer<gmap.GoogleMapController> _controller = Completer();
  final pdf = pw.Document();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool tipoChecked = true;
  bool cnpjChecked = true;
  bool nomeEmpresaChecked = true;
  bool localChecked = true;
  bool placaCavaloChecked = true;
  bool placaCarretaChecked = true;
  bool motoristaChecked = true;
  bool corVeiculoChecked = true;
  bool observacaoChecked = true;
  bool inicioChecked = true;
  bool fimChecked = true;
  bool serverFimChecked = true;
  bool infosChecked = true;
  bool distanciaChecked = true;
  bool distanciaIdaChecked = true;
  bool distanciaVoltaChecked = true;
  bool fotosChecked = true;
  bool fotosPosMissaoChecked = true;
  bool rotaChecked = true;
  bool messagesChecked = true;
  bool infosComplementaresChecked = true;
  bool odometroInicialChecked = true;
  bool odometroFinalChecked = true;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  gmap.BitmapDescriptor? icon;
  RelatorioChatAppTheme theme = RelatorioChatDarkTheme();
  late ChatUser currentUser;
  late ChatController _chatController;
  List<Message> messageList = [];
  late ChatController chatViewController;
  bool isDarkTheme = true;
  FeatureActiveConfig? featureActiveConfig;
  final ValueNotifier<String?> _replyId = ValueNotifier(null);
  ValueNotifier<bool> showPopUp = ValueNotifier(false);
  TextEditingController odometroInicialController = TextEditingController();
  TextEditingController odometroFinalController = TextEditingController();
  bool enableOdometroInicial = false;
  bool enableOdometroFinal = false;
  GlobalKey<FormState> odometroInicialFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> odometroFinalFormKey = GlobalKey<FormState>();
  double? distanciaOdometro;
  bool distanciaOdometroChecked = true;
  List<Foto>? fotosPosMissaoCheckList = [];
  List<Foto>? fotosMissaoCheckList = [];

  @override
  void initState() {
    String? uid = firebaseAuth.currentUser!.uid;
    getCurrentChatUser();
    chatController(uid, widget.agenteId);
    context
        .read<MissionDetailsBloc>()
        .add(FetchMissionDetails(widget.agenteId, widget.missaoId));
    getIcon();
    super.initState();
  }

  @override
  void dispose() {
    odometroFinalController.dispose();
    odometroInicialController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (provide != null) {
      featureActiveConfig = provide!.featureActiveConfig;
      _chatController = provide!.chatController;
    }
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
          id: widget.agenteId,
          name: 'Agente',
        ),
      ],
      chatCollection: 'Chat missão',
      missaoId: widget.missaoId,
    );
    setState(() {
      chatViewController = _chatController;
    });
  }

  Future<void> getIcon() async {
    final icon = await gmap.BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/images/missionIcon.png');
    setState(() {
      this.icon = icon;
    });
  }

  Future<Uint8List> resizeImage(Uint8List data, double diameter) async {
    ui.Codec codec = await ui.instantiateImageCodec(data);
    ui.FrameInfo fi = await codec.getNextFrame();

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder,
        Rect.fromPoints(const Offset(0, 0), Offset(diameter, diameter)));
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..shader = ui.ImageShader(fi.image, ui.TileMode.clamp, ui.TileMode.clamp,
          Matrix4.identity().storage);
    canvas.drawCircle(Offset(diameter / 2, diameter / 2), diameter / 2, paint);
    final ui.Picture picture = recorder.endRecording();

    // Adicione a linha abaixo para aguardar a resolução do Future
    final ui.Image image =
        await picture.toImage(diameter.round(), diameter.round());

    // Agora chame toByteData no objeto image.
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Set<gmap.Marker> _createMarkersFromLocations(
      List<CoordenadaComTimestamp> locations,
      double? latitude,
      double? longitude) {
    Set<gmap.Marker> markers = {};

    for (var location in locations) {
      String iso = location.timestamp.toIso8601String();
      DateTime data = DateTime.parse(iso);

      final marker = gmap.Marker(
        markerId: gmap.MarkerId(
            'lat: ${location.ponto.latitude.toString()}, lng: ${location.ponto.longitude}'),
        position:
            gmap.LatLng(location.ponto.latitude, location.ponto.longitude),
        infoWindow: gmap.InfoWindow(
          title: 'Agente sombra',
          snippet:
              'Data: ${DateFormat('dd/MM/yyyy').format(data)}\n - ${DateFormat('HH').format(data)}h ${DateFormat('mm').format(data)}min ${DateFormat('ss').format(data)}s',
        ),
      );
      markers.add(marker);
    }
    final missionMarker = gmap.Marker(
      markerId: const gmap.MarkerId('mission'),
      position: gmap.LatLng(
        latitude!,
        longitude!,
      ),
      infoWindow: gmap.InfoWindow(
          title: 'Local da Missão',
          snippet: 'Latitude: $latitude, Longitude: $longitude'),
      icon: icon ??
          gmap.BitmapDescriptor.defaultMarkerWithHue(
              gmap.BitmapDescriptor.hueBlue),
    );
    markers.add(missionMarker);
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('!!!!!!! relatorio !!!!!!!!!');
    final uid = firebaseAuth.currentUser!.uid;
    final width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        odometroInicialController.clear();
        odometroFinalController.clear();
        context.read<MissionDetailsBloc>().add(ResetMissionDetails());
      },
      child: Scaffold(
        //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        appBar: AppBar(
          title: const Text('Detalhes da missão'),
          //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        ),
        body: BlocBuilder<MissionDetailsBloc, MissionDetailsState>(
          builder: (context, state) {
            debugPrint(state.toString());
            if (state is MissionDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is MissionDetailsNoRouteFound) {
              return const Center(child: Text('Nenhum percurso feito'));
            }
            if (state is MissionDetailsLoaded) {
              debugPrint(' ----------> MISSAO CARREGADA !!!!!!!!!');
              // Acessando a missão carregada
              MissaoRelatorio missao = state.missao;
              odometroInicialController.value.text.isEmpty
                  ? odometroInicialController.text =
                      state.missao.odometroInicial ?? ''
                  : null;
              odometroFinalController.value.text.isEmpty
                  ? odometroFinalController.text =
                      state.missao.odometroFinal ?? ''
                  : null;

              if (state.missao.odometroInicial != null &&
                  state.missao.odometroFinal != null) {
                distanciaOdometro = double.parse(odometroFinalController.text) -
                    double.parse(odometroInicialController.text);
              }

              debugPrint('!!! MISSAO DECLARADA !!!');
              Set<gmap.Marker>? markers;
              if (state.locations != null) {
                markers = _createMarkersFromLocations(state.locations!,
                    state.missao.missaoLatitude, state.missao.missaoLongitude);
              }
              int limiteDeFotos = 4;

              state.messages
                  ?.sort((a, b) => a.createdAt.compareTo(b.createdAt));

              if (state.missao.fotosPosMissao != null) {
                fotosPosMissaoCheckList = state.missao.fotosPosMissao;
              }
              if (state.missao.fotos != null) {
                fotosMissaoCheckList = state.missao.fotos;
              }

              state.messages != null
                  ? _chatController = ChatController(
                      initialMessageList: state.messages!,
                      scrollController: ScrollController(),
                      chatId: widget.agenteId,
                      chatUsers: [
                        ChatUser(
                          id: 'Atendente',
                          name: 'Atendente',
                          profilePhoto: fotoUrl,
                        ),
                        ChatUser(
                          id: widget.agenteId,
                          name: 'Agente',
                        ),
                      ],
                      chatCollection: 'Chat missão',
                      missaoId: widget.missaoId,
                    )
                  : null;

              // final Path path = Path(
              //   color: Colors.blue,
              //   points: state.locations!,
              // );

              //Configurar o StaticMapController
              // final staticMapController = StaticMapController(
              //   googleApiKey:
              //       "AIzaSyBGozAuPStyTlmF22-zku_I-8gcX3EMfm4",
              //   width: 1000,
              //   height: 700,
              //   zoom: 11,
              //   center: state
              //       .middleLocation, // Usar a primeira localização como centro
              //   paths: [path], // Incluir o Path criado
              // );
              // final ImageProvider image = staticMapController.image;

              return SingleChildScrollView(
                child: Row(
                  children: [
                    Expanded(
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: width * 0.1,
                                  top: 10,
                                  bottom: 20,
                                  right: width * 0.1),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Image.asset(
                                              'assets/images/escudo.png'),
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Relatório de missão',
                                            style: TextStyle(
                                              fontFamily:
                                                  AutofillHints.jobTitle,
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SelectableText(
                                            'Id: ${widget.missaoId}',
                                            style: const TextStyle(
                                              fontFamily:
                                                  AutofillHints.jobTitle,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // if (ResponsiveBreakpoints.of(context)
                                  //     .largerThan(MOBILE))
                                  //   Spacer(),

                                  // Botão no final
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                EditRelatorioDialog(
                                              relatorio: state.missao,
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'EDITAR',
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => PdfScreen(
                                              missao: missao,
                                              distanciaValue: state.distancia,
                                              locations: state.locations,
                                              messages: state.messages,
                                              odometroInicial:
                                                  state.odometroInicial,
                                              odometroFinal:
                                                  state.odometroFinal,
                                              missaoId: widget.missaoId,
                                              agenteId: widget.agenteId,
                                              tipo: tipoChecked,
                                              cnpj: cnpjChecked,
                                              nomeDaEmpresa: nomeEmpresaChecked,
                                              local: localChecked,
                                              placaCavalo: placaCavaloChecked,
                                              placaCarreta: placaCarretaChecked,
                                              nomeMotorista: motoristaChecked,
                                              cor: corVeiculoChecked,
                                              obs: observacaoChecked,
                                              inicio: inicioChecked,
                                              fim: fimChecked,
                                              infos: infosChecked,
                                              distancia: distanciaChecked,
                                              fotos: fotosChecked,
                                              fotosPos: fotosPosMissaoChecked,
                                              mapa: rotaChecked,
                                              showMessages: messagesChecked,
                                              infosComplementares:
                                                  infosComplementaresChecked,
                                              showOdometroInicial:
                                                  odometroInicialChecked,
                                              showOdometroFinal:
                                                  odometroFinalChecked,
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'PDF',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: width * 0.15, right: width * 0.15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dados:',
                                        style: TextStyle(
                                          fontFamily: AutofillHints.jobTitle,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildDataItem(
                                          'Tipo: ',
                                          missao.tipo,
                                          tipoChecked,
                                          (val) => setState(
                                              () => tipoChecked = val!)),
                                      buildDataItem(
                                          'CNPJ: ',
                                          missao.cnpj,
                                          cnpjChecked,
                                          (val) => setState(
                                              () => cnpjChecked = val!)),
                                      buildDataItem(
                                          'Nome da empresa: ',
                                          missao.nomeDaEmpresa,
                                          nomeEmpresaChecked,
                                          (val) => setState(
                                              () => nomeEmpresaChecked = val!)),
                                      buildDataItem(
                                          'Local: ',
                                          missao.local ?? '',
                                          localChecked,
                                          (val) => setState(
                                              () => localChecked = val!)),
                                      buildDataItem(
                                          'Placa do cavalo: ',
                                          missao.placaCavalo ?? '',
                                          placaCavaloChecked,
                                          (val) => setState(
                                              () => placaCavaloChecked = val!)),
                                      buildDataItem(
                                          'Placa da carreta: ',
                                          missao.placaCarreta ?? '',
                                          placaCarretaChecked,
                                          (val) => setState(() =>
                                              placaCarretaChecked = val!)),
                                      buildDataItem(
                                          'Motorista: ',
                                          missao.motorista ?? '',
                                          motoristaChecked,
                                          (val) => setState(
                                              () => motoristaChecked = val!)),
                                      buildDataItem(
                                          'Cor do veículo: ',
                                          missao.corVeiculo ?? '',
                                          corVeiculoChecked,
                                          (val) => setState(
                                              () => corVeiculoChecked = val!)),
                                      buildDataItem(
                                          'Observação: ',
                                          missao.observacao ?? '',
                                          observacaoChecked,
                                          (val) => setState(
                                              () => observacaoChecked = val!)),
                                      buildDataItem(
                                          'Início: ',
                                          '${DateFormat('dd/MM/yyyy').format(missao.inicio!.toDate())} - ${DateFormat('HH:mm').format(missao.inicio!.toDate())}h',
                                          inicioChecked,
                                          (val) => setState(
                                              () => inicioChecked = val!)),
                                      buildDataItem(
                                          'Fim: ',
                                          '${DateFormat('dd/MM/yyyy').format(missao.fim!.toDate())} - ${DateFormat('HH:mm').format(missao.fim!.toDate())}h',
                                          fimChecked,
                                          (val) => setState(
                                              () => fimChecked = val!)),
                                      buildDataItem(
                                          'Fim no servidor: ',
                                          '${DateFormat('dd/MM/yyyy').format(missao.serverFim!.toDate())} - ${DateFormat('HH:mm').format(missao.serverFim!.toDate())}h',
                                          serverFimChecked,
                                          (val) => setState(
                                              () => serverFimChecked = val!)),
                                      buildDataItem(
                                          'Informações da missão: ',
                                          missao.infos ?? '',
                                          infosChecked,
                                          (val) => setState(
                                              () => infosChecked = val!)),
                                      buildDataItem(
                                          'Informações complementares: ',
                                          missao.infosComplementares ?? '',
                                          infosChecked,
                                          (val) => setState(
                                              () => infosChecked = val!)),
                                      // buildDataItem(
                                      //     'Distância estimada (início): ',
                                      //     state.distanciaIda != null
                                      //         ? '${state.distanciaIda!.toStringAsFixed(2)} km'
                                      //         : '',
                                      //     distanciaIdaChecked,
                                      //     (val) => setState(
                                      //         () => distanciaIdaChecked = val!)),
                                      // buildDataItem(
                                      //     'Distância estimada (fim): ',
                                      //     state.distanciaVolta != null
                                      //         ? '${state.distanciaVolta!.toStringAsFixed(2)} km'
                                      //         : '',
                                      //     distanciaVoltaChecked,
                                      //     (val) => setState(
                                      //         () => distanciaVoltaChecked = val!)),
                                      buildDataItem(
                                          'Distância percorrida estimada: ',
                                          state.distancia != null
                                              ? '${state.distancia!.toStringAsFixed(2)} km'
                                              : '',
                                          distanciaChecked,
                                          (val) => setState(
                                              () => distanciaChecked = val!)),
                                      buildDataItem(
                                          'Distância percorrida (odometro): ',
                                          distanciaOdometro != null
                                              ? '${distanciaOdometro!.toStringAsFixed(2)} km'
                                              : '',
                                          distanciaOdometroChecked,
                                          (val) => setState(() =>
                                              distanciaOdometroChecked = val!)),
                                    ],
                                  ),
                                ),
                                //Image(image: image),

                                Column(
                                  children: [
                                    state.locations == null
                                        ? const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 50,
                                              ),
                                              Text('Nenhum percurso feito'),
                                            ],
                                          )
                                        : Padding(
                                            padding: EdgeInsets.only(
                                                right: width * 0.15,
                                                top: 20,
                                                bottom: 20,
                                                left: width * 0.15),
                                            child: SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.7, // 70% da altura da tela, por exemplo
                                              child: Row(
                                                children: [
                                                  Checkbox(
                                                    checkColor: Colors.green,
                                                    activeColor: canvasColor,
                                                    side: const BorderSide(
                                                        color: canvasColor),
                                                    value: rotaChecked,
                                                    onChanged: (val) =>
                                                        setState(() =>
                                                            rotaChecked = val!),
                                                  ),
                                                  Expanded(
                                                    child: gmap.GoogleMap(
                                                      myLocationEnabled: true,
                                                      myLocationButtonEnabled:
                                                          true,
                                                      initialCameraPosition:
                                                          state
                                                              .initialPosition!,
                                                      markers: markers!,
                                                      polylines:
                                                          state.polylines!,
                                                      onMapCreated: (gmap
                                                          .GoogleMapController
                                                          controller) {
                                                        _controller.complete(
                                                            controller);
                                                      },
                                                    ),
                                                  ),
                                                  // gmap.GoogleMap(
                                                  //   myLocationEnabled: true,
                                                  //   myLocationButtonEnabled: true,
                                                  //   initialCameraPosition:
                                                  //       state.initialPosition!,
                                                  //   //markers: state.userMarkers,
                                                  //   polylines: state.polylines!,
                                                  //   onMapCreated:
                                                  //       (gmap.GoogleMapController
                                                  //           controller) {
                                                  //     _controller
                                                  //         .complete(controller);
                                                  //   },
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Odometro inicial',
                                        style: TextStyle(
                                          fontFamily: AutofillHints.jobTitle,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    state.odometroInicial == null
                                        ? const Center(
                                            child: Text('Nenhuma foto enviada'),
                                          )
                                        : Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Checkbox(
                                                    checkColor: Colors.green,
                                                    activeColor: canvasColor,
                                                    side: const BorderSide(
                                                        color: canvasColor),
                                                    value:
                                                        odometroInicialChecked,
                                                    onChanged: (val) =>
                                                        setState(() =>
                                                            odometroInicialChecked =
                                                                val!),
                                                  ),
                                                  SizedBox(
                                                    height: 150,
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: 1,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () => showImageDialog(
                                                                context,
                                                                state
                                                                    .odometroInicial!
                                                                    .url,
                                                                state
                                                                    .odometroInicial!
                                                                    .caption),
                                                            child: Container(
                                                              width: 150,
                                                              height: 150,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(
                                                                      state
                                                                          .odometroInicial!
                                                                          .url),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  !enableOdometroInicial
                                                      ? IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              enableOdometroInicial =
                                                                  !enableOdometroInicial;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            size: 18,
                                                            color: Colors.blue,
                                                          ),
                                                        )
                                                      : BlocBuilder<
                                                          ElevatedButtonBloc2,
                                                          ElevatedButtonBloc2State>(
                                                          builder: (context,
                                                              buttonState) {
                                                            if (buttonState
                                                                is ElevatedButtonBloc2Loading) {
                                                              return const Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              );
                                                            } else {
                                                              return IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  BlocProvider.of<
                                                                              ElevatedButtonBloc2>(
                                                                          context)
                                                                      .add(
                                                                    ElevatedButton2Pressed(),
                                                                  );
                                                                  if (odometroInicialFormKey
                                                                      .currentState!
                                                                      .validate()) {
                                                                    try {
                                                                      await relatorioServices.editarKmOdometro(
                                                                          state
                                                                              .missao
                                                                              .missaoId,
                                                                          state
                                                                              .missao
                                                                              .uid,
                                                                          odometroInicialController
                                                                              .text
                                                                              .trim(),
                                                                          'odometroInicial');

                                                                      BlocProvider.of<ElevatedButtonBloc2>(
                                                                              context)
                                                                          .add(
                                                                        ElevatedButton2Reset(),
                                                                      );
                                                                      setState(
                                                                          () {
                                                                        enableOdometroInicial =
                                                                            false;
                                                                      });
                                                                      if (odometroFinalController
                                                                              .text
                                                                              .isNotEmpty &&
                                                                          odometroInicialController
                                                                              .text
                                                                              .isNotEmpty) {
                                                                        setState(
                                                                            () {
                                                                          distanciaOdometro =
                                                                              double.parse(odometroFinalController.text) - double.parse(odometroInicialController.text);
                                                                        });
                                                                      }
                                                                      mensagemDeSucesso.showSuccessSnackbar(
                                                                          context,
                                                                          'Enviado com sucesso!');
                                                                    } catch (e) {
                                                                      debugPrint(
                                                                          e.toString());
                                                                    }
                                                                  }
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons.save,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),

                                                  // const SizedBox(
                                                  //   width: 10,
                                                  // ),
                                                  SizedBox(
                                                    width: 150,
                                                    //height: 55,
                                                    child: Form(
                                                      key:
                                                          odometroInicialFormKey,
                                                      child: TextFormField(
                                                        enabled:
                                                            enableOdometroInicial,
                                                        controller:
                                                            odometroInicialController,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                          LengthLimitingTextInputFormatter(
                                                              50),
                                                        ],
                                                        validator: (value) {
                                                          if (value == '' ||
                                                              value == null ||
                                                              value.isEmpty) {
                                                            return 'Preencha o campo corretamente';
                                                          } else if (int
                                                                  .tryParse(
                                                                      value) ==
                                                              null) {
                                                            return 'Insira apenas números';
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Km inicial',
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  Colors.grey),
                                                          // prefixIcon: Icon(
                                                          //   Icons.person,
                                                          //   color: Colors.grey,
                                                          // ),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Odometro final',
                                        style: TextStyle(
                                          fontFamily: AutofillHints.jobTitle,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: [
                                        state.odometroFinal == null
                                            ? const Center(
                                                child: Text(
                                                    'Nenhuma foto enviada'),
                                              )
                                            : Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Checkbox(
                                                        checkColor:
                                                            Colors.green,
                                                        activeColor:
                                                            canvasColor,
                                                        side: const BorderSide(
                                                            color: canvasColor),
                                                        value:
                                                            odometroFinalChecked,
                                                        onChanged: (val) =>
                                                            setState(() =>
                                                                odometroFinalChecked =
                                                                    val!),
                                                      ),
                                                      SizedBox(
                                                        height: 150,
                                                        child: ListView.builder(
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount: 1,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () => showImageDialog(
                                                                    context,
                                                                    state
                                                                        .odometroFinal!
                                                                        .url,
                                                                    state
                                                                        .odometroFinal!
                                                                        .caption),
                                                                child:
                                                                    Container(
                                                                  width: 150,
                                                                  height: 150,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      image: NetworkImage(state
                                                                          .odometroFinal!
                                                                          .url),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 3,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      !enableOdometroFinal
                                                          ? IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  enableOdometroFinal =
                                                                      !enableOdometroFinal;
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                Icons.edit,
                                                                size: 18,
                                                                color:
                                                                    Colors.blue,
                                                              ),
                                                            )
                                                          : BlocBuilder<
                                                              ElevatedButtonBloc3,
                                                              ElevatedButtonBloc3State>(
                                                              builder: (context,
                                                                  buttonState) {
                                                                if (buttonState
                                                                    is ElevatedButtonBloc3Loading) {
                                                                  return const Center(
                                                                    child:
                                                                        CircularProgressIndicator(),
                                                                  );
                                                                } else {
                                                                  return IconButton(
                                                                    onPressed:
                                                                        () async {
                                                                      BlocProvider.of<ElevatedButtonBloc3>(
                                                                              context)
                                                                          .add(
                                                                        ElevatedButton3Pressed(),
                                                                      );
                                                                      if (odometroFinalFormKey
                                                                          .currentState!
                                                                          .validate()) {
                                                                        try {
                                                                          await relatorioServices.editarKmOdometro(
                                                                              state.missao.missaoId,
                                                                              state.missao.uid,
                                                                              odometroFinalController.text.trim(),
                                                                              'odometroFinal');
                                                                          BlocProvider.of<ElevatedButtonBloc3>(context)
                                                                              .add(
                                                                            ElevatedButton3Reset(),
                                                                          );
                                                                          setState(
                                                                              () {
                                                                            enableOdometroFinal =
                                                                                false;
                                                                          });
                                                                          if (odometroFinalController.text.isNotEmpty &&
                                                                              odometroInicialController.text.isNotEmpty) {
                                                                            setState(() {
                                                                              distanciaOdometro = double.parse(odometroFinalController.text) - double.parse(odometroInicialController.text);
                                                                            });
                                                                          }
                                                                          mensagemDeSucesso.showSuccessSnackbar(
                                                                              context,
                                                                              'Enviado com sucesso!');
                                                                        } catch (e) {
                                                                          debugPrint(
                                                                              e.toString());
                                                                          tratamentoDeErros.showErrorSnackbar(
                                                                              context,
                                                                              'Erro, tente novamente!');
                                                                        }
                                                                      }
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .save,
                                                                      size: 18,
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                      // const SizedBox(
                                                      //   width: 10,
                                                      // ),
                                                      SizedBox(
                                                        width: 150,
                                                        //height: 55,
                                                        child: Form(
                                                          key:
                                                              odometroFinalFormKey,
                                                          child: TextFormField(
                                                            enabled:
                                                                enableOdometroFinal,
                                                            controller:
                                                                odometroFinalController,
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly,
                                                              LengthLimitingTextInputFormatter(
                                                                  50),
                                                            ],
                                                            validator: (value) {
                                                              if (value == '' ||
                                                                  value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Preencha o campo corretamente';
                                                              } else if (int
                                                                      .tryParse(
                                                                          value) ==
                                                                  null) {
                                                                return 'Insira apenas números';
                                                              } else {
                                                                return null;
                                                              }
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Km final',
                                                              labelStyle: TextStyle(
                                                                  color: Colors
                                                                      .grey),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Fotos da missão',
                                            style: TextStyle(
                                              fontFamily:
                                                  AutofillHints.jobTitle,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        missao.fotos == null
                                            ? const Center(
                                                child: Text(
                                                    'Nenhuma foto enviada'),
                                              )
                                            : SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                child: Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  runAlignment:
                                                      WrapAlignment.center,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  spacing:
                                                      8.0, // Espaçamento entre os itens horizontalmente
                                                  runSpacing:
                                                      8.0, // Espaçamento entre as linhas
                                                  children: List.generate(
                                                      missao.fotos!.length,
                                                      (index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: [
                                                          Checkbox(
                                                            checkColor:
                                                                Colors.green,
                                                            activeColor:
                                                                canvasColor,
                                                            side: const BorderSide(
                                                                color:
                                                                    canvasColor),
                                                            value:
                                                                fotosMissaoCheckList![
                                                                        index]
                                                                    .check,
                                                            onChanged: (val) =>
                                                                setState(() =>
                                                                    fotosMissaoCheckList![
                                                                            index]
                                                                        .check = val!),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () =>
                                                                showImageDialog(
                                                                    context,
                                                                    missao
                                                                        .fotos![
                                                                            index]
                                                                        .url,
                                                                    missao
                                                                        .fotos![
                                                                            index]
                                                                        .caption),
                                                            child: Container(
                                                              width: 150,
                                                              height: 150,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(missao
                                                                      .fotos![
                                                                          index]
                                                                      .url),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ),
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'Fotos após a missão',
                                            style: TextStyle(
                                              fontFamily:
                                                  AutofillHints.jobTitle,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        missao.fotosPosMissao == null
                                            ? const Center(
                                                child: Text(
                                                    'Nenhuma foto enviada'),
                                              )
                                            : SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                child: Wrap(
                                                  alignment:
                                                      WrapAlignment.center,
                                                  runAlignment:
                                                      WrapAlignment.center,
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  spacing:
                                                      8.0, // Espaçamento entre os itens horizontalmente
                                                  runSpacing:
                                                      8.0, // Espaçamento entre as linhas
                                                  children: List.generate(
                                                      missao.fotosPosMissao!
                                                          .length, (index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: [
                                                          Checkbox(
                                                            checkColor:
                                                                Colors.green,
                                                            activeColor:
                                                                canvasColor,
                                                            side: const BorderSide(
                                                                color:
                                                                    canvasColor),
                                                            value:
                                                                fotosPosMissaoCheckList![
                                                                        index]
                                                                    .check,
                                                            onChanged: (val) =>
                                                                setState(() =>
                                                                    fotosPosMissaoCheckList![
                                                                            index]
                                                                        .check = val!),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              showImageDialog(
                                                                  context,
                                                                  missao
                                                                      .fotosPosMissao![
                                                                          index]
                                                                      .url,
                                                                  missao
                                                                      .fotosPosMissao![
                                                                          index]
                                                                      .caption);
                                                            },
                                                            child: Container(
                                                              width: 150,
                                                              height: 150,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: NetworkImage(missao
                                                                      .fotosPosMissao![
                                                                          index]
                                                                      .url),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ),

                                        const SizedBox(
                                          height: 25,
                                        ),
                                        state.messages != null
                                            ? const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Chat',
                                                    style: TextStyle(
                                                      fontFamily: AutofillHints
                                                          .jobTitle,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox.shrink(),
                                        state.messages != null
                                            ? const SizedBox(
                                                height: 20,
                                              )
                                            : const SizedBox.shrink(),
                                        state.messages != null
                                            ? Card(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: LayoutBuilder(
                                                    builder:
                                                        (BuildContext context,
                                                            BoxConstraints
                                                                constraints) {
                                                      return ConstrainedBox(
                                                        constraints:
                                                            const BoxConstraints(
                                                          maxWidth:
                                                              800, // Use maxWidth como a largura máxima
                                                        ),
                                                        child: GroupedListView<
                                                            Message, String>(
                                                          shrinkWrap: true,
                                                          elements:
                                                              state.messages!,
                                                          groupBy: (element) =>
                                                              element.createdAt
                                                                  .getDateFromDateTime,
                                                          itemComparator: (message1,
                                                                  message2) =>
                                                              message1.createdAt
                                                                  .compareTo(
                                                                      message2
                                                                          .createdAt),
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          sort: true,
                                                          groupSeparatorBuilder: (separator) =>
                                                              featureActiveConfig
                                                                          ?.enableChatSeparator ??
                                                                      false
                                                                  ? _GroupSeparatorBuilder(
                                                                      separator:
                                                                          separator,
                                                                      defaultGroupSeparatorConfig:
                                                                          DefaultGroupSeparatorConfiguration(
                                                                        textStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              theme.chatHeaderColor,
                                                                          fontSize:
                                                                              17,
                                                                        ),
                                                                      ),
                                                                      groupSeparatorBuilder:
                                                                          const ChatBackgroundConfiguration()
                                                                              .groupSeparatorBuilder,
                                                                    )
                                                                  : const SizedBox
                                                                      .shrink(),
                                                          indexedItemBuilder:
                                                              (context, message,
                                                                  index) {
                                                            debugPrint(message
                                                                .message);
                                                            return ValueListenableBuilder<
                                                                String?>(
                                                              valueListenable:
                                                                  _replyId,
                                                              builder: (context,
                                                                  state,
                                                                  child) {
                                                                debugPrint(
                                                                    'replyId: ${_replyId.toString()}');
                                                                return RelatorioChatBubbleWidget(
                                                                  chatBubbleConfig:
                                                                      ChatBubbleConfiguration(
                                                                    outgoingChatBubbleConfig:
                                                                        ChatBubble(
                                                                      linkPreviewConfig:
                                                                          LinkPreviewConfiguration(
                                                                        backgroundColor:
                                                                            theme.linkPreviewOutgoingChatColor,
                                                                        bodyStyle:
                                                                            theme.outgoingChatLinkBodyStyle,
                                                                        titleStyle:
                                                                            theme.outgoingChatLinkTitleStyle,
                                                                      ),
                                                                      receiptsWidgetConfig:
                                                                          const ReceiptsWidgetConfig(
                                                                              showReceiptsIn: ShowReceiptsIn.all),
                                                                      color: theme
                                                                          .outgoingChatBubbleColor,
                                                                    ),
                                                                    inComingChatBubbleConfig:
                                                                        ChatBubble(
                                                                      linkPreviewConfig:
                                                                          LinkPreviewConfiguration(
                                                                        linkStyle:
                                                                            TextStyle(
                                                                          color:
                                                                              theme.inComingChatBubbleTextColor,
                                                                          decoration:
                                                                              TextDecoration.underline,
                                                                        ),
                                                                        backgroundColor:
                                                                            theme.linkPreviewIncomingChatColor,
                                                                        bodyStyle:
                                                                            theme.incomingChatLinkBodyStyle,
                                                                        titleStyle:
                                                                            theme.incomingChatLinkTitleStyle,
                                                                      ),
                                                                      textStyle:
                                                                          TextStyle(
                                                                              color: theme.inComingChatBubbleTextColor),
                                                                      onMessageRead:
                                                                          (message) {
                                                                        /// send your message reciepts to the other client
                                                                        debugPrint(
                                                                            'Message Read');
                                                                      },
                                                                      senderNameTextStyle:
                                                                          TextStyle(
                                                                              color: theme.inComingChatBubbleTextColor),
                                                                      color: theme
                                                                          .inComingChatBubbleColor,
                                                                    ),
                                                                  ),
                                                                  chatControllerParam:
                                                                      _chatController,
                                                                  messageTimeTextStyle:
                                                                      const ChatBackgroundConfiguration()
                                                                          .messageTimeTextStyle,
                                                                  messageTimeIconColor:
                                                                      const ChatBackgroundConfiguration()
                                                                          .messageTimeIconColor,
                                                                  message:
                                                                      message,
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),

                                        //     RelatorioChatView(
                                        //               currentUser: currentUser,
                                        //               chatController: _chatController,
                                        //               //onSendTap: _onSendTap,
                                        //               featureActiveConfig:
                                        //                   const FeatureActiveConfig(
                                        //                 lastSeenAgoBuilderVisibility:
                                        //                     false,
                                        //                 receiptsBuilderVisibility:
                                        //                     true,
                                        //                 enableDoubleTapToLike: false,
                                        //               ),
                                        //               chatViewState:
                                        //                   ChatViewState.hasMessages,
                                        //               chatViewStateConfig:
                                        //                   ChatViewStateConfiguration(
                                        //                 loadingWidgetConfig:
                                        //                     ChatViewStateWidgetConfiguration(
                                        //                   loadingIndicatorColor: theme
                                        //                       .outgoingChatBubbleColor,
                                        //                 ),
                                        //                 onReloadButtonTap: () {},
                                        //               ),
                                        //               typeIndicatorConfig:
                                        //                   TypeIndicatorConfiguration(
                                        //                 flashingCircleBrightColor: theme
                                        //                     .flashingCircleBrightColor,
                                        //                 flashingCircleDarkColor: theme
                                        //                     .flashingCircleDarkColor,
                                        //               ),
                                        //               // appBar:
                                        //               // ChatViewAppBar(
                                        //               //   padding: const EdgeInsets.only(
                                        //               //       top: 15, bottom: 10),
                                        //               //   elevation: theme.elevation,
                                        //               //   //backGroundColor: const Color.fromARGB(255, 14, 14, 14),
                                        //               //   backGroundColor:
                                        //               //       Color.fromARGB(255, 0, 6, 15),
                                        //               //   profilePicture: fotoUrl,
                                        //               //   backArrowColor:
                                        //               //       theme.backArrowColor,
                                        //               //   chatTitle: 'Agente',
                                        //               //   chatTitleTextStyle: TextStyle(
                                        //               //     color: theme.appBarTitleTextStyle,
                                        //               //     fontWeight: FontWeight.bold,
                                        //               //     fontSize: 18,
                                        //               //     letterSpacing: 0.25,
                                        //               //   ),
                                        //               // ),
                                        //               chatBackgroundConfig:
                                        //                   ChatBackgroundConfiguration(
                                        //                       messageTimeIconColor: theme
                                        //                           .messageTimeIconColor,
                                        //                       messageTimeTextStyle:
                                        //                           TextStyle(
                                        //                               color: theme
                                        //                                   .messageTimeTextColor),
                                        //                       defaultGroupSeparatorConfig:
                                        //                           DefaultGroupSeparatorConfiguration(
                                        //                         textStyle: TextStyle(
                                        //                           color: theme
                                        //                               .chatHeaderColor,
                                        //                           fontSize: 17,
                                        //                         ),
                                        //                       ),
                                        //                       //backgroundColor: const Color.fromARGB(255, 14, 14, 14),
                                        //                       backgroundColor:
                                        //                           Colors.transparent),
                                        //               sendMessageConfig:
                                        //                   SendMessageConfiguration(
                                        //                 imagePickerIconsConfig:
                                        //                     ImagePickerIconsConfiguration(
                                        //                   cameraIconColor: null,
                                        //                   galleryIconColor: null,
                                        //                 ),
                                        //                 replyMessageColor:
                                        //                     theme.replyMessageColor,
                                        //                 defaultSendButtonColor:
                                        //                     theme.sendButtonColor,
                                        //                 replyDialogColor:
                                        //                     theme.replyDialogColor,
                                        //                 replyTitleColor:
                                        //                     theme.replyTitleColor,
                                        //                 textFieldBackgroundColor: theme
                                        //                     .textFieldBackgroundColor,
                                        //                 closeIconColor:
                                        //                     theme.closeIconColor,
                                        //                 textFieldConfig:
                                        //                     TextFieldConfiguration(
                                        //                   onMessageTyping: (status) {
                                        //                     /// Do with status
                                        //                     debugPrint(
                                        //                         status.toString());
                                        //                   },
                                        //                   compositionThresholdTime:
                                        //                       const Duration(
                                        //                           seconds: 1),
                                        //                   textStyle: TextStyle(
                                        //                       color: theme
                                        //                           .textFieldTextColor),
                                        //                 ),
                                        //                 micIconColor:
                                        //                     theme.replyMicIconColor,
                                        //                 voiceRecordingConfiguration:
                                        //                     VoiceRecordingConfiguration(
                                        //                   backgroundColor: theme
                                        //                       .waveformBackgroundColor,
                                        //                   recorderIconColor:
                                        //                       theme.recordIconColor,
                                        //                   waveStyle: WaveStyle(
                                        //                     showMiddleLine: false,
                                        //                     waveColor:
                                        //                         theme.waveColor ??
                                        //                             Colors.white,
                                        //                     extendWaveform: true,
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //               chatBubbleConfig:
                                        //                   ChatBubbleConfiguration(
                                        //                 outgoingChatBubbleConfig:
                                        //                     ChatBubble(
                                        //                   linkPreviewConfig:
                                        //                       LinkPreviewConfiguration(
                                        //                     backgroundColor: theme
                                        //                         .linkPreviewOutgoingChatColor,
                                        //                     bodyStyle: theme
                                        //                         .outgoingChatLinkBodyStyle,
                                        //                     titleStyle: theme
                                        //                         .outgoingChatLinkTitleStyle,
                                        //                   ),
                                        //                   receiptsWidgetConfig:
                                        //                       const ReceiptsWidgetConfig(
                                        //                           showReceiptsIn:
                                        //                               ShowReceiptsIn
                                        //                                   .all),
                                        //                   color: theme
                                        //                       .outgoingChatBubbleColor,
                                        //                 ),
                                        //                 inComingChatBubbleConfig:
                                        //                     ChatBubble(
                                        //                   linkPreviewConfig:
                                        //                       LinkPreviewConfiguration(
                                        //                     linkStyle: TextStyle(
                                        //                       color: theme
                                        //                           .inComingChatBubbleTextColor,
                                        //                       decoration:
                                        //                           TextDecoration
                                        //                               .underline,
                                        //                     ),
                                        //                     backgroundColor: theme
                                        //                         .linkPreviewIncomingChatColor,
                                        //                     bodyStyle: theme
                                        //                         .incomingChatLinkBodyStyle,
                                        //                     titleStyle: theme
                                        //                         .incomingChatLinkTitleStyle,
                                        //                   ),
                                        //                   textStyle: TextStyle(
                                        //                       color: theme
                                        //                           .inComingChatBubbleTextColor),
                                        //                   onMessageRead: (message) {
                                        //                     /// send your message reciepts to the other client
                                        //                     debugPrint(
                                        //                         'Message Read');
                                        //                   },
                                        //                   senderNameTextStyle: TextStyle(
                                        //                       color: theme
                                        //                           .inComingChatBubbleTextColor),
                                        //                   color: theme
                                        //                       .inComingChatBubbleColor,
                                        //                 ),
                                        //               ),
                                        //               replyPopupConfig:
                                        //                   ReplyPopupConfiguration(
                                        //                 backgroundColor:
                                        //                     theme.replyPopupColor,
                                        //                 buttonTextStyle: TextStyle(
                                        //                     color: theme
                                        //                         .replyPopupButtonColor),
                                        //                 topBorderColor: theme
                                        //                     .replyPopupTopBorderColor,
                                        //               ),
                                        //               reactionPopupConfig:
                                        //                   ReactionPopupConfiguration(
                                        //                 shadow: BoxShadow(
                                        //                   color: isDarkTheme
                                        //                       ? Colors.black54
                                        //                       : Colors.grey.shade400,
                                        //                   blurRadius: 20,
                                        //                 ),
                                        //                 backgroundColor:
                                        //                     theme.reactionPopupColor,
                                        //               ),
                                        //               messageConfig:
                                        //                   MessageConfiguration(
                                        //                 messageReactionConfig:
                                        //                     MessageReactionConfiguration(
                                        //                   backgroundColor: theme
                                        //                       .messageReactionBackGroundColor,
                                        //                   borderColor: theme
                                        //                       .messageReactionBackGroundColor,
                                        //                   reactedUserCountTextStyle:
                                        //                       TextStyle(
                                        //                           color: theme
                                        //                               .inComingChatBubbleTextColor),
                                        //                   reactionCountTextStyle:
                                        //                       TextStyle(
                                        //                           color: theme
                                        //                               .inComingChatBubbleTextColor),
                                        //                   reactionsBottomSheetConfig:
                                        //                       ReactionsBottomSheetConfiguration(
                                        //                     backgroundColor:
                                        //                         theme.backgroundColor,
                                        //                     reactedUserTextStyle:
                                        //                         TextStyle(
                                        //                       color: theme
                                        //                           .inComingChatBubbleTextColor,
                                        //                     ),
                                        //                     reactionWidgetDecoration:
                                        //                         BoxDecoration(
                                        //                       color: theme
                                        //                           .inComingChatBubbleColor,
                                        //                       boxShadow: [
                                        //                         BoxShadow(
                                        //                           color: isDarkTheme
                                        //                               ? Colors.black12
                                        //                               : Colors.grey
                                        //                                   .shade200,
                                        //                           offset:
                                        //                               const Offset(
                                        //                                   0, 20),
                                        //                           blurRadius: 40,
                                        //                         )
                                        //                       ],
                                        //                       borderRadius:
                                        //                           BorderRadius
                                        //                               .circular(10),
                                        //                     ),
                                        //                   ),
                                        //                 ),
                                        //                 imageMessageConfig:
                                        //                     ImageMessageConfiguration(
                                        //                   margin: const EdgeInsets
                                        //                       .symmetric(
                                        //                       horizontal: 12,
                                        //                       vertical: 15),
                                        //                   shareIconConfig:
                                        //                       ShareIconConfiguration(
                                        //                     defaultIconBackgroundColor:
                                        //                         theme
                                        //                             .shareIconBackgroundColor,
                                        //                     defaultIconColor:
                                        //                         theme.shareIconColor,
                                        //                     onPressed: (p0) {},
                                        //                   ),
                                        //                 ),
                                        //               ),
                                        //               // profileCircleConfig: ProfileCircleConfiguration(
                                        //               //   profileImageUrl: fotoUrl,
                                        //               // ),
                                        //               repliedMessageConfig:
                                        //                   RepliedMessageConfiguration(
                                        //                 backgroundColor:
                                        //                     theme.repliedMessageColor,
                                        //                 verticalBarColor:
                                        //                     theme.verticalBarColor,
                                        //                 repliedMsgAutoScrollConfig:
                                        //                     RepliedMsgAutoScrollConfig(
                                        //                   enableHighlightRepliedMsg:
                                        //                       true,
                                        //                   highlightColor: Colors
                                        //                       .pinkAccent.shade100,
                                        //                   highlightScale: 1.1,
                                        //                 ),
                                        //                 textStyle: const TextStyle(
                                        //                   color: Colors.white,
                                        //                   fontWeight: FontWeight.bold,
                                        //                   letterSpacing: 0.25,
                                        //                 ),
                                        //                 replyTitleTextStyle: TextStyle(
                                        //                     color: theme
                                        //                         .repliedTitleTextColor),
                                        //               ),
                                        //               swipeToReplyConfig:
                                        //                   SwipeToReplyConfiguration(
                                        //                 replyIconColor: theme
                                        //                     .swipeToReplyIconColor,
                                        //               ),
                                        //             //),
                                        //           //),
                                        //         //],
                                        //       //),
                                        //     //);
                                        //  // },
                                        // ),
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            List<Foto> fotosPosMissaoFinalList =
                                                [];
                                            if (fotosPosMissaoCheckList!
                                                .isNotEmpty) {
                                              for (var foto
                                                  in fotosPosMissaoCheckList!) {
                                                if (foto.check!) {
                                                  fotosPosMissaoFinalList
                                                      .add(foto);
                                                }
                                              }
                                            }

                                            List<Foto> fotosMissaoFinalList =
                                                [];
                                            if (fotosMissaoCheckList!
                                                .isNotEmpty) {
                                              for (var foto
                                                  in fotosMissaoCheckList!) {
                                                if (foto.check!) {
                                                  fotosMissaoFinalList
                                                      .add(foto);
                                                }
                                              }
                                            }

                                            final sucesso =
                                                await relatorioServices
                                                    .enviarRelatorioCliente(
                                              RelatorioCliente(
                                                cnpj: missao.cnpj,
                                                missaoId: widget.missaoId,
                                                tipo: tipoChecked
                                                    ? missao.tipo
                                                    : null,
                                                nomeDaEmpresa:
                                                    nomeEmpresaChecked
                                                        ? missao.nomeDaEmpresa
                                                        : null,
                                                local: localChecked
                                                    ? missao.local
                                                    : null,
                                                placaCavalo: placaCavaloChecked
                                                    ? missao.placaCavalo
                                                    : null,
                                                placaCarreta:
                                                    placaCarretaChecked
                                                        ? missao.placaCarreta
                                                        : null,
                                                motorista: motoristaChecked
                                                    ? missao.motorista
                                                    : null,
                                                corVeiculo: corVeiculoChecked
                                                    ? missao.corVeiculo
                                                    : null,
                                                observacao: observacaoChecked
                                                    ? missao.observacao
                                                    : null,
                                                uidOperadorSombra: uid,
                                                uid: missao.uid,
                                                inicio: inicioChecked
                                                    ? missao.inicio
                                                    : null,
                                                fim: fimChecked
                                                    ? missao.fim
                                                    : null,
                                                serverFim: serverFimChecked
                                                    ? missao.serverFim
                                                    : null,
                                                // fotos: fotosChecked
                                                //     ? missao.fotos
                                                //     : null,
                                                fotos: fotosMissaoFinalList
                                                        .isNotEmpty
                                                    ? fotosMissaoFinalList
                                                    : null,
                                                // fotosPosMissao:
                                                //     fotosPosMissaoChecked
                                                //         ? missao.fotosPosMissao
                                                //         : null,
                                                fotosPosMissao:
                                                    fotosPosMissaoFinalList
                                                            .isNotEmpty
                                                        ? fotosPosMissaoFinalList
                                                        : null,
                                                odometroInicial:
                                                    odometroInicialChecked &&
                                                            state.odometroInicial !=
                                                                null
                                                        ? state.odometroInicial
                                                        : null,
                                                odometroFinal:
                                                    odometroFinalChecked &&
                                                            state.odometroFinal !=
                                                                null
                                                        ? state.odometroFinal
                                                        : null,
                                                messages: messagesChecked &&
                                                        state.messages != null
                                                    ? state.messages
                                                    : null,
                                                infos: infosChecked
                                                    ? missao.infos
                                                    : null,
                                                infosComplementares:
                                                    infosComplementaresChecked
                                                        ? missao
                                                            .infosComplementares
                                                        : null,
                                                distancia: distanciaChecked
                                                    ? state.distancia
                                                    : null,
                                                distanciaOdometro:
                                                    distanciaOdometroChecked
                                                        ? distanciaOdometro
                                                        : null,
                                                rota: rotaChecked
                                                    ? state.locations
                                                    : null,
                                              ),
                                            );
                                            if (sucesso.success) {
                                              if (context.mounted) {
                                                mensagemDeSucesso
                                                    .showSuccessSnackbar(
                                                        context,
                                                        'Relatório enviado com sucesso');
                                              }
                                            } else {
                                              if (context.mounted) {
                                                tratamentoDeErros.showErrorSnackbar(
                                                    context,
                                                    sucesso.message ??
                                                        'Erro ao enviar relatório');
                                              }
                                            }
                                          },
                                          child: const Text(
                                            'Enviar para cliente',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 25,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (state is MissionDetailsError) {
              return Center(child: Text('Erro: ${state.message}'));
            }
            return Container(); // Estado inicial ou desconhecido
          },
        ),
      ),
    );
  }

  void showImageDialog(BuildContext context, String imageUrl, String? caption) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width * 0.65,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(40),
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
              if (caption != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Legenda: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SelectableText(caption),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void showAllPhotosDialog(BuildContext context, List<Foto> fotos) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Número de colunas
                crossAxisSpacing: 4.0, // Espaçamento horizontal
                mainAxisSpacing: 4.0, // Espaçamento vertical
              ),
              itemCount: fotos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    //Navigator.of(context).pop(); // Fecha o diálogo
                    showImageDialog(context, fotos[index].url,
                        fotos[index].caption); // Mostra a foto selecionada
                  },
                  child: Image.network(
                    fotos[index].url,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }
}

Widget buildDataItem(
    String title, String data, bool isChecked, Function(bool?) onChanged) {
  return Row(
    //crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Checkbox(
        //mudar cor da borda
        activeColor: canvasColor,
        //overlayColor: MaterialStateProperty.all(Colors.white),
        //mudar cor da borda
        checkColor: Colors.green,
        //mudar cor de fora
        side: const BorderSide(color: canvasColor),
        value: isChecked,
        onChanged: onChanged,
      ),
      Expanded(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: data.isNotEmpty ? data : 'Não informado',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class RelatorioChatAppTheme {
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

  RelatorioChatAppTheme({
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

class RelatorioChatDarkTheme extends RelatorioChatAppTheme {
  RelatorioChatDarkTheme({
    Color super.flashingCircleDarkColor = Colors.grey,
    Color super.flashingCircleBrightColor = const Color(0xffeeeeee),
    TextStyle super.incomingChatLinkTitleStyle =
        const TextStyle(color: Colors.black),
    TextStyle super.outgoingChatLinkTitleStyle =
        const TextStyle(color: Colors.white),
    TextStyle super.outgoingChatLinkBodyStyle =
        const TextStyle(color: Colors.white),
    TextStyle super.incomingChatLinkBodyStyle =
        const TextStyle(color: Colors.white),
    double super.elevation = 1,
    Color super.repliedTitleTextColor = Colors.white,
    super.swipeToReplyIconColor = Colors.white,
    Color super.textFieldTextColor = Colors.white,
    Color super.appBarColor = const Color.fromARGB(255, 27, 31, 37),
    Color super.backArrowColor = Colors.white,
    Color super.backgroundColor = const Color.fromARGB(255, 35, 42, 54),
    Color super.replyDialogColor = const Color.fromARGB(255, 35, 43, 54),
    Color super.linkPreviewOutgoingChatColor =
        const Color.fromARGB(255, 35, 43, 54),
    Color super.linkPreviewIncomingChatColor =
        const Color.fromARGB(255, 133, 180, 255),
    TextStyle super.linkPreviewIncomingTitleStyle = const TextStyle(),
    TextStyle super.linkPreviewOutgoingTitleStyle = const TextStyle(),
    Color super.replyTitleColor = Colors.white,
    Color super.textFieldBackgroundColor =
        const Color.fromARGB(255, 36, 54, 102),
    Color super.outgoingChatBubbleColor = Colors.blue,
    Color super.inComingChatBubbleColor = const Color.fromARGB(255, 49, 64, 82),
    Color super.reactionPopupColor = const Color.fromARGB(255, 49, 63, 82),
    Color super.replyPopupColor = const Color.fromARGB(255, 49, 64, 82),
    Color super.replyPopupButtonColor = Colors.white,
    Color super.replyPopupTopBorderColor = Colors.black54,
    Color super.reactionPopupTitleColor = Colors.white,
    Color super.inComingChatBubbleTextColor = Colors.white,
    Color super.repliedMessageColor = const Color.fromARGB(255, 133, 178, 255),
    Color super.closeIconColor = Colors.white,
    Color super.shareIconBackgroundColor =
        const Color.fromARGB(255, 49, 60, 82),
    Color super.sendButtonColor = Colors.white,
    Color super.cameraIconColor = const Color(0xff757575),
    Color super.galleryIconColor = const Color(0xff757575),
    Color recorderIconColor = const Color(0xff757575),
    Color super.stopIconColor = const Color(0xff757575),
    Color super.replyMessageColor = Colors.grey,
    Color super.appBarTitleTextStyle = Colors.white,
    Color super.messageReactionBackGroundColor =
        const Color.fromARGB(255, 31, 45, 79),
    Color super.messageReactionBorderColor =
        const Color.fromARGB(255, 29, 52, 88),
    Color super.verticalBarColor = const Color.fromARGB(255, 34, 53, 87),
    Color super.chatHeaderColor = Colors.white,
    Color super.themeIconColor = Colors.white,
    Color super.shareIconColor = Colors.white,
    Color super.messageTimeIconColor = Colors.white,
    Color super.messageTimeTextColor = Colors.white,
    Color super.waveformBackgroundColor = const Color.fromARGB(255, 22, 36, 78),
    Color super.waveColor = Colors.white,
    Color super.replyMicIconColor = Colors.white,
  }) : super(
          recordIconColor: recorderIconColor,
        );
}

class RelatorioChatLightTheme extends RelatorioChatAppTheme {
  RelatorioChatLightTheme({
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

class _GroupSeparatorBuilder extends StatelessWidget {
  const _GroupSeparatorBuilder({
    required this.separator,
    this.groupSeparatorBuilder,
    this.defaultGroupSeparatorConfig,
  });
  final String separator;
  final StringWithReturnWidget? groupSeparatorBuilder;
  final DefaultGroupSeparatorConfiguration? defaultGroupSeparatorConfig;

  @override
  Widget build(BuildContext context) {
    return groupSeparatorBuilder != null
        ? groupSeparatorBuilder!(separator)
        : ChatGroupHeader(
            day: DateTime.parse(separator),
            groupSeparatorConfig: defaultGroupSeparatorConfig,
          );
  }
}
