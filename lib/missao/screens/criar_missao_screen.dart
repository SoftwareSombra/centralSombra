import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra_testes/agente/model/agente_model.dart';
import 'package:sombra_testes/mapa/services/mapa_services.dart';
import 'package:sombra_testes/missao/model/missao_solicitada.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import 'dart:ui' as ui;
import '../../../agente/services/agente_services.dart';
import '../../../autenticacao/services/user_services.dart';
import 'dart:math';
import '../bloc/missao_solicitacao_card/missao_solicitacao_card_bloc.dart';
import '../bloc/missao_solicitacao_card/missao_solicitacao_card_event.dart';
import '../bloc/missao_solicitacao_card/missao_solicitacao_card_state.dart';
import '../bloc/missoes_solicitadas/missoes_solicitadas_bloc.dart';
import '../bloc/missoes_solicitadas/missoes_solicitadas_event.dart';
import '../bloc/missoes_solicitadas/missoes_solicitadas_state.dart';

class CriarMissaoScreen extends StatelessWidget {
  const CriarMissaoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const cardWidth = 320.0;
    final cardCount = (width / cardWidth).floor();
    context.read<MissoesSolicitadasBloc>().add(BuscarMissoes());

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Solicitações de Missão'),
      ),
      body: BlocBuilder<MissoesSolicitadasBloc, MissoesSolicitadasState>(
        builder: (context, state) {
          if (state is MissoesSolicitadasLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MissoesSolicitadasLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cardCount,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: state.missoes.length,
              itemBuilder: (context, index) {
                return BlocProvider<MissaoSolicitacaoCardBloc>(
                  create: (context) => MissaoSolicitacaoCardBloc(),
                  child: SolicitacaoDeMissaoCard(
                      missaoSolicitada: state.missoes[index]),
                );
              },
            );
          }
          //else if (state is MissoesSolicitadasNotFound) {
          //   return const Center(
          //     child: Text(
          //       'Nenhuma solicitação encontrada',
          //       style: TextStyle(color: Colors.white),
          //     ),
          //   );
          // }
          else if (state is MissoesSolicitadasError) {
            return Center(
                child: Text(
              'Erro: ${state.error}',
              style: const TextStyle(color: Colors.white),
            ));
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Algum erro ocorrreu, reinicie a página.',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SolicitacaoDeMissaoCard extends StatelessWidget {
  final MissaoSolicitada missaoSolicitada;
  const SolicitacaoDeMissaoCard({super.key, required this.missaoSolicitada});

  void mostrarListaAgentes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListaAgentesModal(
          missaoSolicitada: missaoSolicitada,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<MissaoSolicitacaoCardBloc>().add(
          BuscarMissao(
            missaoId: missaoSolicitada.missaoId,
          ),
        );
    return BlocBuilder<MissaoSolicitacaoCardBloc, MissaoSolicitacaoCardState>(
      builder: (context, state) {
        if (state is MissaoSolicitacaoCardLoading) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //texts
                  Text(missaoSolicitada.tipo),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  )
                ],
              ),
            ),
          );
        } else if (state is MissaoSolicitacaoCardError) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //texts
                  Text(missaoSolicitada.tipo),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                    ],
                  )
                ],
              ),
            ),
          );
        } else if (state is MissaoJaSolicitacaoCard) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //texts
                  Text(missaoSolicitada.tipo),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('exibindo lista...');
                          mostrarListaAgentes(context);
                        },
                        child: const Text('Selecionar agente'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //texts
                Text('Empresa: ${missaoSolicitada.nomeDaEmpresa}'),
                const SizedBox(
                  height: 3,
                ),
                Text('Tipo: ${missaoSolicitada.tipo}'),
                const SizedBox(
                  height: 3,
                ),
                Text('Placa cavalo: ${missaoSolicitada.placaCavalo}'),
                const SizedBox(
                  height: 3,
                ),
                Text('Local: ${missaoSolicitada.local}'),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'Em: ${DateFormat('dd/MM/yyyy HH:mm').format(missaoSolicitada.timestamp)}',
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.green),
                      ),
                      onPressed: () async {
                        //dialogo de confirmação antes de criar a missão
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Aviso'),
                              content: const SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('Deseja criar a missão?'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('Sim'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapAddMissao(
                                          cnpj: missaoSolicitada.cnpj,
                                          nomeDaEmpresa:
                                              missaoSolicitada.nomeDaEmpresa,
                                          placaCavalo:
                                              missaoSolicitada.placaCavalo,
                                          placaCarreta:
                                              missaoSolicitada.placaCarreta,
                                          motorista: missaoSolicitada.motorista,
                                          corVeiculo:
                                              missaoSolicitada.corVeiculo,
                                          observacao:
                                              missaoSolicitada.observacao,
                                          latitude: missaoSolicitada.latitude,
                                          longitude: missaoSolicitada.longitude,
                                          local: missaoSolicitada.local,
                                          tipo: missaoSolicitada.tipo,
                                          missaoId: missaoSolicitada.missaoId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Criar missão'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.red),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Aviso'),
                              content: const SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text('Em desenvolvimento'),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Ok'),
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Rejeitar missão'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class MapAddMissao extends StatefulWidget {
  // final Place? startPosition;
  // final Place? endPosition;
  //final Place? missionPosition;
  final String? cnpj;
  final String? nomeDaEmpresa;
  final String? placaCavalo;
  final String? placaCarreta;
  final String? motorista;
  final String? corVeiculo;
  final String? observacao;
  final double? latitude;
  final double? longitude;
  final String? local;
  final String? missaoId;
  final String tipo;

  const MapAddMissao(
      {Key? key,
      // this.startPosition,
      // this.endPosition,
      //this.missionPosition,
      this.cnpj,
      this.nomeDaEmpresa,
      this.placaCavalo,
      this.placaCarreta,
      this.motorista,
      this.corVeiculo,
      this.observacao,
      this.latitude,
      this.longitude,
      this.local,
      this.missaoId,
      required this.tipo})
      : super(key: key);

  @override
  _MapAddMissaoState createState() => _MapAddMissaoState();
}

class _MapAddMissaoState extends State<MapAddMissao> {
  late gmap.CameraPosition _initialPosition;
  final Completer<gmap.GoogleMapController> _controller = Completer();
  final Set<gmap.Polyline> _polylines = <gmap.Polyline>{};
  // ignore: unused_field
  Uint8List? _userIcon;
  UserServices userServices = UserServices();
  Set<gmap.Marker> userMarkers = {};
  MapaServices mapaServices = MapaServices();
  List<Map<String, dynamic>> agentesMaisProximos = [];
  Set<Map<String, dynamic>> agentesSelecionados = <Map<String, dynamic>>{};
  MissaoServices missaoServices = MissaoServices();
  bool scrollingEnabled = true;
  gmap.BitmapDescriptor? icon;

  @override
  void initState() {
    super.initState();
    _initialPosition = gmap.CameraPosition(
      target: gmap.LatLng(
        widget.latitude!,
        widget.longitude!,
      ),
      zoom: 14.4746,
    );
    _loadPhotoBytes();
    _loadUserLocations().then((_) {
      fetchNearestUsersToMission(gmap.LatLng(
        widget.latitude!,
        widget.longitude!,
      ));
    });
    _testGetPlaceFromLatLng();
    getIcon();
  }

  Future<void> getIcon() async {
    final icon = await gmap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/images/escudo.png');
    setState(() {
      this.icon = icon;
    });
  }

  Future<void> _loadUserLocations() async {
    final locations = await mapaServices.fetchAllUsersLocations();
    debugPrint('Locations loaded: ${locations.length}');
    setState(() {
      for (var location in locations) {
        userMarkers.add(
          gmap.Marker(
            infoWindow: gmap.InfoWindow(
              title: location.nomeDoAgente,
              snippet: 'Nível do agente:',
              onTap: () {
                debugPrint('Marker tapped');
              },
            ),
            markerId: gmap.MarkerId(location.nomeDoAgente),
            position: gmap.LatLng(location.latitude, location.longitude),
            icon: gmap.BitmapDescriptor.defaultMarker,
          ),
        );
      }
    });
  }

  Future<void> _loadPhotoBytes() async {
    try {
      final originalBytes = await userServices.getPhotoBytes();
      if (originalBytes != null) {
        final resizedBytes = await resizeImage(originalBytes, 40);
        setState(() {
          _userIcon = resizedBytes;
        });
      }
    } catch (e) {
      debugPrint('Error loading photo: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    Set<gmap.Marker> markers = {
      ...userMarkers,
      gmap.Marker(
        markerId: const gmap.MarkerId('mission'),
        position: gmap.LatLng(
          widget.latitude!,
          widget.longitude!,
        ),
        icon: icon ??
            gmap.BitmapDescriptor.defaultMarkerWithHue(
                gmap.BitmapDescriptor.hueBlue),
      ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Criar missão',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: scrollingEnabled
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            MouseRegion(
              onEnter: (_) => setState(() => scrollingEnabled = false),
              onExit: (_) => setState(() => scrollingEnabled = true),
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.6, // 60% da altura da tela
                child: gmap.GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: _initialPosition,
                  markers: markers,
                  polylines: _polylines,
                  onMapCreated: (gmap.GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('Dados da missão'),
                ),
                ResponsiveRowColumn(
                  layout: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                      ? ResponsiveRowColumnType.COLUMN
                      : ResponsiveRowColumnType.ROW,
                  children: [
                    ResponsiveRowColumnItem(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Empresa: ${widget.nomeDaEmpresa}'),
                      ),
                    ),
                    ResponsiveRowColumnItem(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Local: ${widget.local}'),
                      ),
                    ),
                    ResponsiveRowColumnItem(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Placa cavalo: ${widget.placaCavalo}'),
                      ),
                    ),
                    ResponsiveRowColumnItem(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Placa carreta: ${widget.placaCarreta}'),
                      ),
                    ),
                    ResponsiveRowColumnItem(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Motorista: ${widget.motorista}'),
                      ),
                    ),
                    ResponsiveRowColumnItem(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Cor do veículo: ${widget.corVeiculo}'),
                      ),
                    ),
                    ResponsiveRowColumnItem(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text('Observação: ${widget.observacao}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            const Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Agentes mais próximos',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Column(
              children: agentesMaisProximos
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '${entry.key + 1}. ',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                child: Text(
                                  '${entry.value['nome']} - ${entry.value['distance'].toStringAsFixed(2)} km',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Checkbox(
                                value: agentesSelecionados.any((agente) =>
                                    agente['uid'] == entry.value['uid']),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      agentesSelecionados.add({
                                        'uid': entry.value['uid'],
                                        'latitude': entry.value['latitude'],
                                        'longitude': entry.value['longitude']
                                      });
                                    } else {
                                      agentesSelecionados.removeWhere(
                                          (agente) =>
                                              agente['uid'] ==
                                              entry.value['uid']);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                      'Endereço do agente: ${entry.value['endereco']}'),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('Uid do agente: ${entry.value['uid']}'),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                      'Atualizado em: ${DateFormat('dd/MM/yyyy HH:mm').format(
                                    entry.value['timestamp'],
                                  )}'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                for (var agenteSelecionado in agentesSelecionados) {
                  await missaoServices.criarChamado(
                    widget.cnpj!,
                    widget.nomeDaEmpresa!,
                    widget.placaCavalo!,
                    widget.placaCarreta!,
                    widget.motorista!,
                    widget.corVeiculo!,
                    widget.observacao!,
                    widget.missaoId!,
                    agenteSelecionado['uid'],
                    widget.tipo,
                    agenteSelecionado['latitude'],
                    agenteSelecionado['longitude'],
                    widget.latitude!,
                    widget.longitude!,
                    widget.local!,
                  );
                  if (context.mounted) {
                    context.read<MissoesSolicitadasBloc>().add(BuscarMissoes());
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Enviar Missão"),
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }

  Future<double?> getDistanceBetweenPoints(
      Place? startPoint, Place? endPoint) async {
    try {
      debugPrint(
          "Ponto de início: ${startPoint?.latLng?.lat}, ${startPoint?.latLng?.lng}");
      debugPrint(
          "Ponto final: ${endPoint?.latLng?.lat}, ${endPoint?.latLng?.lng}");

      final Dio dio = Dio();

      // Substitua a URL pelo endpoint da sua Firebase Cloud Function
      const firebaseFunctionUrl =
          "https://us-central1-primeval-rune-309222.cloudfunctions.net/getDirections";

      final response = await dio.get(
        firebaseFunctionUrl,
        queryParameters: {
          "origin": "${startPoint!.latLng!.lat},${startPoint.latLng!.lng}",
          "destination": "${endPoint!.latLng!.lat},${endPoint.latLng!.lng}",
          "mode": "driving",
          "key": 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU',
          "language": "pt_BR"
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            "API call failed with status code ${response.statusCode}");
      }

      final Map<String, dynamic> data = response.data;

      final String encodedPolyline =
          data["routes"][0]["overview_polyline"]["points"];

      List<gmap.LatLng> latLngList = PolylinePoints()
          .decodePolyline(encodedPolyline)
          .map((point) => gmap.LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines.add(
          gmap.Polyline(
            polylineId: const gmap.PolylineId("route"),
            color: Colors.blue,
            points: latLngList,
          ),
        );
      });

      final int distanceInMeters =
          data["routes"][0]["legs"][0]["distance"]["value"];
      double distanceInKm = distanceInMeters / 1000;
      return distanceInKm;
    } catch (e) {
      debugPrint("Erro ao obter direções: $e");
      return null;
    }
  }

  double radians(double degree) {
    return degree * (pi / 180.0);
  }

  double calculateDistance(gmap.LatLng point1, gmap.LatLng point2) {
    const R = 6371.0; // Raio da Terra em km

    var lat1 = radians(point1.latitude);
    var lon1 = radians(point1.longitude);
    var lat2 = radians(point2.latitude);
    var lon2 = radians(point2.longitude);

    var dLat = lat2 - lat1;
    var dLon = lon2 - lon1;

    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));

    var distance = R * c;

    return distance; // Distância em km
  }

  Future<void> fetchNearestUsersToMission(missionPosition) async {
    debugPrint('Fetching nearest users...');
    debugPrint("Lat: ${widget.latitude!}, Lng: ${widget.longitude!}");

    final List<UserLocation> userLocations =
        await MapaServices().fetchAllUsersLocations();

    // Calcula a distância de cada usuário até o local da missão
    var distances = userLocations.map((UserLocation user) {
      return {
        'user': user,
        'distance': calculateDistance(
            missionPosition, gmap.LatLng(user.latitude, user.longitude))
      };
    }).toList();

    // Ordena a lista de distâncias em ordem crescente
    distances.sort(
        (a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    // Exibe os nomes dos três usuários mais próximos
    for (var entry in distances.take(10)) {
      bool emMissaoResult =
          await missaoServices.emMissao((entry['user'] as UserLocation).uid);
      bool jaTemChamado = await missaoServices
          .verificarSeAgenteTemChamado((entry['user'] as UserLocation).uid);
      debugPrint('Em missão: $emMissaoResult');
      debugPrint('Já tem chamado: $jaTemChamado');
      if (!emMissaoResult && !jaTemChamado) {
        String? enderecoAgente =
            await fetchAgentAddress((entry['user'] as UserLocation).uid);

        agentesMaisProximos.add({
          'nome': (entry['user'] as UserLocation).nomeDoAgente,
          'uid': (entry['user'] as UserLocation).uid,
          'latitude': (entry['user'] as UserLocation).latitude,
          'longitude': (entry['user'] as UserLocation).longitude,
          'distance': entry['distance'],
          'endereco': enderecoAgente,
          'timestamp': (entry['user'] as UserLocation).timestamp.toDate(),
        });
      }
    }
    setState(() {});
  }

  Future<String?> fetchAgentAddress(String uid) async {
    Agente? agente = await AgenteServices().getAgenteInfos(uid);
    return agente?.endereco;
  }

  Future<Place?> getPlaceFromLatLng(LatLng latLng) async {
    const apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
    final dio = Dio();
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.lat},${latLng.lng}&key=$apiKey';

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['results'] != null && data['results'].length > 0) {
          final firstResult = data['results'][0];
          final formattedAddress = firstResult['formatted_address'];

          return Place(
            address: formattedAddress,
            latLng: latLng,
            name: formattedAddress,
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
        }
      }
    } catch (error) {
      debugPrint('Erro ao buscar o local: $error');
    }

    return null;
  }

  Future<void> _testGetPlaceFromLatLng() async {
    LatLng rioCoord = const LatLng(lat: -22.9519, lng: -43.2105);
    Place? place = await getPlaceFromLatLng(rioCoord);
    if (place != null) {
      debugPrint('Endereço encontrado: ${place.address}');
    } else {
      debugPrint(
          'Nenhum endereço foi encontrado para as coordenadas fornecidas.');
    }
  }
}

class ListaAgentesModal extends StatefulWidget {
  //final List<AgenteSelecionado> agentes;
  final MissaoSolicitada missaoSolicitada;

  ListaAgentesModal({
    Key? key,
    //required this.agentes
    required this.missaoSolicitada,
  }) : super(key: key);

  @override
  _ListaAgentesModalState createState() => _ListaAgentesModalState();
}

class _ListaAgentesModalState extends State<ListaAgentesModal> {
  String? _selectedAgentUid;
  String? _selectedAgentNome;
  double? _selectedAgentLatitude;
  double? _selectedAgentLongitude;
  MissaoServices missaoServices = MissaoServices();
  List<Map<String, dynamic>> agentes = [];

  @override
  void initState() {
    super.initState();
    carregarAgentes();
  }

  void carregarAgentes() async {
    var agentesObtidos = await missaoServices
        .buscarAgentesQueAceitaram(widget.missaoSolicitada.missaoId);
    for (var agente in agentesObtidos) {
      String uid = agente['userUid'];
      var agenteInfos = await AgenteServices().getAgenteInfos(uid);
      //adicionar o endereço do agente
      agente['endereco'] = agenteInfos?.endereco;
    }
    setState(
      () {
        agentes = agentesObtidos;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: agentes.isEmpty
              ? const Center(
                  child: Text('Nenhum agente disponível, aguarde'),
                )
              : ListView.builder(
                  itemCount: agentes.length,
                  itemBuilder: (context, index) {
                    var agente = agentes[index];
                    String nomeAgente = agente['nome'] ?? 'Nome não disponível';
                    String uidAgente =
                        agente['userUid'] ?? 'UID não disponível';
                    double agenteLatitude = agente['userLatitude'];
                    double agenteLongitude = agente['userLongitude'];
                    String? endereco = agente['endereco'];
                    return ListTile(
                      title: Text(nomeAgente),
                      subtitle: Text(endereco ?? 'Endereço não disponível'),
                      leading: Radio<String>(
                        value: uidAgente,
                        groupValue: _selectedAgentUid,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedAgentUid = value;
                            _selectedAgentNome = nomeAgente;
                            _selectedAgentLatitude = agenteLatitude;
                            _selectedAgentLongitude = agenteLongitude;
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
        ElevatedButton(
          onPressed: () async {
            // Enviar a missão para o agente selecionado
            if (_selectedAgentUid != null) {
              await missaoServices.criarMissao(
                widget.missaoSolicitada.cnpj,
                widget.missaoSolicitada.nomeDaEmpresa,
                widget.missaoSolicitada.placaCavalo,
                widget.missaoSolicitada.placaCarreta,
                widget.missaoSolicitada.motorista,
                widget.missaoSolicitada.corVeiculo,
                widget.missaoSolicitada.observacao,
                _selectedAgentUid!,
                _selectedAgentLatitude,
                _selectedAgentLongitude,
                widget.missaoSolicitada.latitude,
                widget.missaoSolicitada.longitude,
                widget.missaoSolicitada.local,
                widget.missaoSolicitada.tipo,
                widget.missaoSolicitada.missaoId,
                _selectedAgentNome,
              );
              debugPrint(
                  'Missão enviada para o agente UID: $_selectedAgentUid');
            }

            // Realizar a ação com os agentes não selecionados
            for (var agente in agentes) {
              if (agente['userUid'] != _selectedAgentUid) {
                await missaoServices.recusadoPelaCentral(agente['userUid']);
                debugPrint(
                    'Ação realizada com o agente UID: ${agente['userUid']}');
              }
              if (context.mounted) {
                context.read<MissoesSolicitadasBloc>().add(BuscarMissoes());
                Navigator.pop(context);
              }
            }
          },
          child: const Text('Enviar missão'),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
