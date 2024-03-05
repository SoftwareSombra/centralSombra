import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_static_maps_controller/google_static_maps_controller.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_view/photo_view.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra_testes/autenticacao/screens/tratamento/error_snackbar.dart';
import 'package:sombra_testes/autenticacao/screens/tratamento/success_snackbar.dart';
import 'package:sombra_testes/web/home/screens/mapa_teste.dart';
import 'package:sombra_testes/web/relatorios/models/relatorio_cliente.dart';
import 'package:sombra_testes/web/relatorios/services/relatorio_services.dart';
import '../../../missao/model/missao_model.dart';
import '../bloc/mission_details_bloc.dart';
import '../bloc/mission_details_event.dart';
import '../bloc/mission_details_state.dart';
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
  bool fotosChecked = true;
  bool fotosPosMissaoChecked = true;
  bool rotaChecked = true;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  gmap.BitmapDescriptor? icon;

  @override
  void initState() {
    context
        .read<MissionDetailsBloc>()
        .add(FetchMissionDetails(widget.agenteId, widget.missaoId));
    getIcon();
    super.initState();
  }

  Future<void> getIcon() async {
    final icon = await gmap.BitmapDescriptor.fromAssetImage(
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
    Set<gmap.Marker> markers = Set();

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
    final uid = firebaseAuth.currentUser!.uid;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        title: const Text('Detalhes da missão'),
        backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: RepaintBoundary(
                key: _repaintBoundaryKey,
                child: Column(
                  children: [
                    ResponsiveRowColumn(
                      layout:
                          ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                      rowMainAxisAlignment: MainAxisAlignment.start,
                      rowPadding: EdgeInsets.only(
                          left: width * 0.1,
                          top: 10,
                          bottom: 20,
                          right: width * 0.1),
                      columnPadding: const EdgeInsets.all(8.0),
                      columnSpacing: 20.0,
                      children: [
                        ResponsiveRowColumnItem(
                          child: SizedBox(
                            height: 100,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset('assets/images/escudo.png'),
                            ),
                          ),
                        ),
                        ResponsiveRowColumnItem(
                          rowFlex: 1,
                          rowFit: FlexFit.tight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Relatório de missão',
                                style: TextStyle(
                                    fontFamily: AutofillHints.jobTitle,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SelectableText(
                                'Id: ${widget.missaoId}',
                                style: const TextStyle(
                                    fontFamily: AutofillHints.jobTitle,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),

                        if (ResponsiveBreakpoints.of(context)
                            .largerThan(MOBILE))
                          const ResponsiveRowColumnItem(
                            child: Spacer(),
                          ),
                        // Botão no final
                        ResponsiveRowColumnItem(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfScreen(
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
                                      mapa: rotaChecked),
                                ),
                              );
                            },
                            child: const Text(
                              'PDF',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    BlocBuilder<MissionDetailsBloc, MissionDetailsState>(
                      builder: (context, state) {
                        debugPrint(state.toString());
                        if (state is MissionDetailsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is MissionDetailsNoRouteFound) {
                          return const Center(
                              child: Text('Nenhum percurso feito'));
                        }
                        if (state is MissionDetailsLoaded) {
                          // Acessando a missão carregada
                          MissaoRelatorio missao = state.missoes;
                          Set<gmap.Marker> markers =
                              _createMarkersFromLocations(
                                  state.locations!,
                                  state.missoes.missaoLatitude,
                                  state.missoes.missaoLongitude);
                          int limiteDeFotos = 4;

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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: width * 0.15, right: width * 0.15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Dados:',
                                      style: TextStyle(
                                          fontFamily: AutofillHints.jobTitle,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    buildDataItem(
                                        'Tipo: ',
                                        missao.tipo,
                                        tipoChecked,
                                        (val) =>
                                            setState(() => tipoChecked = val!)),
                                    buildDataItem(
                                        'CNPJ: ',
                                        missao.cnpj,
                                        cnpjChecked,
                                        (val) =>
                                            setState(() => cnpjChecked = val!)),
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
                                        (val) => setState(
                                            () => placaCarretaChecked = val!)),
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
                                        DateFormat('dd/MM/yyyy HH:mm')
                                            .format(missao.inicio!.toDate()),
                                        inicioChecked,
                                        (val) => setState(
                                            () => inicioChecked = val!)),
                                    buildDataItem(
                                        'Fim: ',
                                        DateFormat('dd/MM/yyyy HH:mm')
                                            .format(missao.fim!.toDate()),
                                        fimChecked,
                                        (val) =>
                                            setState(() => fimChecked = val!)),
                                    buildDataItem(
                                        'Fim no servidor: ',
                                        DateFormat('dd/MM/yyyy HH:mm')
                                            .format(missao.serverFim!.toDate()),
                                        serverFimChecked,
                                        (val) => setState(
                                            () => serverFimChecked = val!)),
                                    buildDataItem(
                                        'Informações: ',
                                        missao.infos ?? '',
                                        infosChecked,
                                        (val) => setState(
                                            () => infosChecked = val!)),
                                    buildDataItem(
                                        'Distância percorrida: ',
                                        state.distancia != null
                                            ? '${state.distancia} km'
                                            : '',
                                        distanciaChecked,
                                        (val) => setState(
                                            () => distanciaChecked = val!)),
                                  ],
                                ),
                              ),
                              //Image(image: image),

                              Column(
                                children: [
                                  state.locations!.isEmpty
                                      ? const Center(
                                          child: Text('Nenhum percurso feito'),
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
                                                  activeColor: Colors.white,
                                                  side: const BorderSide(
                                                      color: Colors.white),
                                                  value: rotaChecked,
                                                  onChanged: (val) => setState(
                                                      () => rotaChecked = val!),
                                                ),
                                                Expanded(
                                                  child: gmap.GoogleMap(
                                                    myLocationEnabled: true,
                                                    myLocationButtonEnabled:
                                                        true,
                                                    initialCameraPosition:
                                                        state.initialPosition!,
                                                    markers: markers,
                                                    //polylines: state.polylines!,
                                                    onMapCreated: (gmap
                                                        .GoogleMapController
                                                        controller) {
                                                      _controller
                                                          .complete(controller);
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
                                      'Fotos da missão',
                                      style: TextStyle(
                                          fontFamily: AutofillHints.jobTitle,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  missao.fotos == null
                                      ? const Center(
                                          child: Text('Nenhuma foto enviada'),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              checkColor: Colors.green,
                                              activeColor: Colors.white,
                                              side: const BorderSide(
                                                  color: Colors.white),
                                              value: fotosChecked,
                                              onChanged: (val) => setState(
                                                  () => fotosChecked = val!),
                                            ),
                                            SizedBox(
                                              height: 150,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: min(
                                                    missao.fotos!.length,
                                                    limiteDeFotos),
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          showImageDialog(
                                                              context,
                                                              missao
                                                                  .fotos![index]
                                                                  .url,
                                                              missao
                                                                  .fotos![index]
                                                                  .caption),
                                                      child: Container(
                                                        width: 150,
                                                        height: 150,
                                                        decoration:
                                                            BoxDecoration(
                                                          image:
                                                              DecorationImage(
                                                            image: NetworkImage(
                                                                missao
                                                                    .fotos![
                                                                        index]
                                                                    .url),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            if (missao.fotos!.length >
                                                limiteDeFotos)
                                              TextButton(
                                                onPressed: () {
                                                  showAllPhotosDialog(
                                                      context, missao.fotos!);
                                                },
                                                child: const Text(
                                                  'Ver todas as fotos',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'Fotos após a missão',
                                      style: TextStyle(
                                          fontFamily: AutofillHints.jobTitle,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  missao.fotosPosMissao == null
                                      ? const Center(
                                          child: Text('Nenhuma foto enviada'),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              checkColor: Colors.green,
                                              activeColor: Colors.white,
                                              side: const BorderSide(
                                                  color: Colors.white),
                                              value: fotosPosMissaoChecked,
                                              onChanged: (val) => setState(() =>
                                                  fotosPosMissaoChecked = val!),
                                            ),
                                            SizedBox(
                                              height: 150,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: min(
                                                    missao
                                                        .fotosPosMissao!.length,
                                                    limiteDeFotos),
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: GestureDetector(
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
                                                            image: NetworkImage(
                                                                missao
                                                                    .fotosPosMissao![
                                                                        index]
                                                                    .url),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            if (missao.fotosPosMissao!.length >
                                                limiteDeFotos)
                                              TextButton(
                                                onPressed: () {
                                                  showAllPhotosDialog(context,
                                                      missao.fotosPosMissao!);
                                                },
                                                child: const Text(
                                                  'Ver todas as fotos',
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                          ],
                                        ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final sucesso = await relatorioServices
                                          .enviarRelatorioCliente(
                                        RelatorioCliente(
                                          cnpj: missao.cnpj,
                                          missaoId: widget.missaoId,
                                          tipo:
                                              tipoChecked ? missao.tipo : null,
                                          nomeDaEmpresa: nomeEmpresaChecked
                                              ? missao.nomeDaEmpresa
                                              : null,
                                          local: localChecked
                                              ? missao.local
                                              : null,
                                          placaCavalo: placaCavaloChecked
                                              ? missao.placaCavalo
                                              : null,
                                          placaCarreta: placaCarretaChecked
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
                                          fim: fimChecked ? missao.fim : null,
                                          serverFim: serverFimChecked
                                              ? missao.serverFim
                                              : null,
                                          fotos: fotosChecked
                                              ? missao.fotos
                                              : null,
                                          fotosPosMissao: fotosPosMissaoChecked
                                              ? missao.fotosPosMissao
                                              : null,
                                          infos: infosChecked
                                              ? missao.infos
                                              : null,
                                          distancia: distanciaChecked
                                              ? state.distancia
                                              : null,
                                          rota: rotaChecked
                                              ? state.locations
                                              : null,
                                        ),
                                      );
                                      if (sucesso.success) {
                                        if (context.mounted) {
                                          mensagemDeSucesso.showSuccessSnackbar(
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
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                            ],
                          );
                        }
                        if (state is MissionDetailsError) {
                          return Center(child: Text('Erro: ${state.message}'));
                        }
                        return Container(); // Estado inicial ou desconhecido
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Número de colunas
                crossAxisSpacing: 4.0, // Espaçamento horizontal
                mainAxisSpacing: 4.0, // Espaçamento vertical
              ),
              itemCount: fotos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Fecha o diálogo
                    showImageDialog(context, fotos[index].url,
                        fotos[index].url); // Mostra a foto selecionada
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
              child: Text('Fechar'),
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
    children: [
      Checkbox(
        //mudar cor da borda
        activeColor: Colors.white,
        //overlayColor: MaterialStateProperty.all(Colors.white),
        //mudar cor da borda
        checkColor: Colors.green,
        //mudar cor de fora
        side: const BorderSide(color: Colors.white),
        value: isChecked,
        onChanged: onChanged,
      ),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: data.isNotEmpty ? data : 'Não informado',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
