import 'dart:async';
import 'dart:math';
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
import 'package:sombra_testes/web/relatorios/models/relatorio_cliente.dart';
import 'package:sombra_testes/web/relatorios/services/relatorio_services.dart';
import '../../../missao/model/missao_model.dart';
import '../bloc/mission_details_bloc.dart';
import '../bloc/mission_details_event.dart';
import '../bloc/mission_details_state.dart';
import 'pdf_screen.dart';

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
  bool tipoChecked = false;
  bool cnpjChecked = false;
  bool nomeEmpresaChecked = false;
  bool placaCavaloChecked = false;
  bool placaCarretaChecked = false;
  bool motoristaChecked = false;
  bool corVeiculoChecked = false;
  bool observacaoChecked = false;
  bool inicioChecked = false;
  bool fimChecked = false;
  bool serverFimChecked = false;
  bool infosChecked = false;
  bool distanciaChecked = false;
  bool fotosChecked = false;
  bool fotosPosMissaoChecked = false;
  bool rotaChecked = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  @override
  void initState() {
    context
        .read<MissionDetailsBloc>()
        .add(FetchMissionDetails(widget.agenteId, widget.missaoId));
    super.initState();
  }

  Set<gmap.Marker> _createMarkersFromLocations(List<Location> locations) {
    Set<gmap.Marker> markers = Set();

    for (var location in locations) {
      final marker = gmap.Marker(
        markerId: gmap.MarkerId(
            'lat: ${location.latitude.toString()}, lng: ${location.longitude}'),
        position: gmap.LatLng(location.latitude, location.longitude),
        infoWindow: gmap.InfoWindow(),
      );
      markers.add(marker);
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final uid = firebaseAuth.currentUser!.uid;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalhes da missão'),
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
                                    color: canvasColor),
                              ),
                              SelectableText(
                                'Id: ${widget.missaoId}',
                                style: const TextStyle(
                                    fontFamily: AutofillHints.jobTitle,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: canvasColor),
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
                            child: const Text('PDF'),
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
                              _createMarkersFromLocations(state.locations!);
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
                                          color: canvasColor),
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
                                                  side: const BorderSide(
                                                      color: canvasColor),
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
                                                    polylines: state.polylines!,
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
                                          color: canvasColor),
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
                                              side: const BorderSide(
                                                  color: canvasColor),
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
                                                                  .url),
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
                                          color: canvasColor),
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
                                              side: const BorderSide(
                                                  color: canvasColor),
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
                                                      onTap: () => showImageDialog(
                                                          context,
                                                          missao
                                                              .fotosPosMissao![
                                                                  index]
                                                              .url),
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
                                    child: const Text('Enviar para cliente'),
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

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
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
                    showImageDialog(
                        context, fotos[index].url); // Mostra a foto selecionada
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
        //activeColor: canvasColor,
        //mudar cor da borda
        checkColor: Colors.green,
        //mudar cor de fora
        side: const BorderSide(color: canvasColor),
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
                color: canvasColor,
              ),
            ),
            TextSpan(
              text: data.isNotEmpty ? data : 'Não informado',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: canvasColor,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
