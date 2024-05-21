import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sombra_testes/agente/model/agente_model.dart';
import 'package:sombra_testes/autenticacao/screens/tratamento/error_snackbar.dart';
import 'package:sombra_testes/mapa/services/mapa_services.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../agente/services/agente_services.dart';
import '../../../autenticacao/services/user_services.dart';
import '../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../chat/services/chat_services.dart';
import '../../missao/camera/camera_screen.dart';

class MapScreen extends StatefulWidget {
  final String? cnpj;
  final String? nomeDaEmpresa;
  final String? placaCavalo;
  final String? placaCarreta;
  final String? motorista;
  final String? corVeiculo;
  final String? observacao;
  final LatLng? startPosition;
  final LatLng? endPosition;
  final String? local;
  final String? missaoId;
  final String? tipo;
  final Timestamp? inicio;

  const MapScreen(
      {super.key,
      this.cnpj,
      this.nomeDaEmpresa,
      this.placaCavalo,
      this.placaCarreta,
      this.motorista,
      this.corVeiculo,
      this.observacao,
      this.startPosition,
      this.endPosition,
      this.local,
      this.missaoId,
      this.tipo,
      this.inicio});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late gmap.CameraPosition _initialPosition;
  final Completer<gmap.GoogleMapController> _controller = Completer();
  final Set<gmap.Polyline> _polylines = <gmap.Polyline>{};
  UserServices userServices = UserServices();
  MapaServices mapaServices = MapaServices();
  List<Map<String, dynamic>> agentesMaisProximos = [];
  final Set<gmap.Marker> _markers = {};
  String? missionDistanceDisplay;
  MissaoServices missaoServices = MissaoServices();
  Place? selectedStartLocation;
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  late StreamSubscription<Position> positionStream;
  TextEditingController captionController = TextEditingController();
  final ChatServices chatServices = ChatServices();
  CameraDescription firstCamera = const CameraDescription(
      name: '', lensDirection: CameraLensDirection.back, sensorOrientation: 0);
  final HawkFabMenuController hawkFabMenuController = HawkFabMenuController();

  @override
  void initState() {
    super.initState();
    listarCameras();
    WakelockPlus.enable();
    _initialPosition = gmap.CameraPosition(
      target: gmap.LatLng(
        widget.startPosition!.lat,
        widget.startPosition!.lng,
      ),
      zoom: 14.4746,
    );

    if (widget.endPosition != null) {
      _markers.add(gmap.Marker(
        markerId: const gmap.MarkerId('endPosition'),
        position: gmap.LatLng(
          widget.endPosition!.lat,
          widget.endPosition!.lng,
        ),
        infoWindow: const gmap.InfoWindow(title: 'End Position'),
      ));
    }
    getCurrentLocation();
    _getInitialDistance();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    positionStream.cancel();
    super.dispose();
  }

  listarCameras() async {
    await requestCameraPermission();

    // Obtém uma lista de câmeras disponíveis no dispositivo.
    final cameras = await availableCameras();

    // Pega a primeira câmera da lista (geralmente a câmera traseira).
    firstCamera = cameras.first;
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

  Future<void> _getInitialDistance() async {
    double? missionStartDistance = await getDistanceBetweenPoints(
        widget.startPosition, widget.endPosition);

    if (missionStartDistance != null) {
      setState(() {
        missionDistanceDisplay =
            "Distância: ${missionStartDistance.toStringAsFixed(2)} km";
      });
    }

    debugPrint(
        "Distância entre o local da missão e o agente: ${missionStartDistance}km");
  }

  abrirCamera() {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: CameraScreen(
        camera: firstCamera,
        missaoId: widget.missaoId,
      ),
      withNavBar: false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MAPA',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
      ),
      body: HawkFabMenu(
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
            label: 'Informações',
            ontap: () {},
            icon: const Icon(
              Icons.info,
              color: Colors.blue,
            ),
            labelColor: Colors.black,
            color: Colors.white,
            //labelBackgroundColor: Colors.blue,
          ),
        ],
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       missionDistanceDisplay != null
              //           ? Text(
              //               missionDistanceDisplay!,
              //               style: const TextStyle(
              //                 fontSize: 16.0,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             )
              //           : const SizedBox.shrink(),
              //       ElevatedButton(
              //         onPressed: () async {
              //           Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //               builder: (context) => CameraScreen(
              //                 camera: firstCamera,
              //                 missaoId: widget.missaoId,
              //               ),
              //             ),
              //           );
              //           // final picker = ImagePicker();
              //           // final pickedFile =
              //           //     await picker.pickImage(source: ImageSource.camera);

              //           // if (pickedFile != null) {
              //           //   final File photo = File(pickedFile.path);

              //           //   // Capturando o horário atual.
              //           //   DateTime now = DateTime.now();
              //           //   debugPrint("A foto foi tirada em: $now");

              //           //   if (context.mounted) {
              //           //     showDialog(
              //           //       context: context,
              //           //       builder: (BuildContext context) {
              //           //         return AlertDialog(
              //           //           title: const Text('Adicione uma descrição'),
              //           //           content: SingleChildScrollView(
              //           //             child: Column(
              //           //               mainAxisSize: MainAxisSize.min,
              //           //               children: [
              //           //                 Image.file(
              //           //                   photo,
              //           //                   fit: BoxFit.cover,
              //           //                 ),
              //           //                 TextField(
              //           //                   controller: captionController,
              //           //                   decoration: const InputDecoration(
              //           //                       hintText:
              //           //                           'Digite uma descrição...'),
              //           //                 ),
              //           //               ],
              //           //             ),
              //           //           ),
              //           //           actions: [
              //           //             TextButton(
              //           //               onPressed: () async {
              //           //                 String caption = captionController.text;
              //           //                 // Agora você pode usar a variável 'caption' para a legenda e 'photo' para a foto
              //           //                 final url = await missaoServices
              //           //                     .uploadPhoto(photo, widget.missaoId!);
              //           //                 List<Map<String, dynamic>>
              //           //                     fotoComLegenda = [
              //           //                   {
              //           //                     'url': url,
              //           //                     'caption': caption,
              //           //                     'timestamp': now,
              //           //                   }
              //           //                 ];
              //           //                 //fotosComLegendas.add(fotoComLegenda);

              //           //                 final sucesso = await missaoServices
              //           //                     .fotoRelatorioMissao(uid,
              //           //                         widget.missaoId!, fotoComLegenda);
              //           //                 captionController.clear();
              //           //                 if (context.mounted) {
              //           //                   if (sucesso!) {
              //           //                     //Navigator.of(context).pop();
              //           //                   } else {
              //           //                     tratamentoDeErros.showErrorSnackbar(
              //           //                         context, 'Erro ao enviar foto');
              //           //                   }
              //           //                   Navigator.of(context)
              //           //                       .pop(); // Fechar o AlertDialog
              //           //                 }
              //           //               },
              //           //               child: const Text('Confirmar'),
              //           //             ),
              //           //           ],
              //           //         );
              //           //       },
              //           //     );
              //           //   }
              //           // } else {
              //           //   // O usuário não tirou uma foto.
              //           // }
              //         },
              //         child: const Text('Abrir câmera'),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: gmap.GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (gmap.GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       onPressed: () async {
              //         // final userFinal = getCurrentLocation();
              //         final userFinalLocation = await getFinalLocation();
              //         //final now = DateTime.now();
              //         final userFinalLatitude = userFinalLocation.lat;
              //         final userFinalLongitude = userFinalLocation.lng;
              //         final currentLocation = await Geolocator.getCurrentPosition(
              //             desiredAccuracy: LocationAccuracy.high);
              //         if (selectedStartLocation != null) {
              //           // await missaoServices.finalLocalMissao(
              //           //     uid, widget.missaoId, currentLocation);
              //           final finalLocal =
              //               await missaoServices.finalLocalMissaoSelectFunction(
              //                   uid,
              //                   widget.missaoId,
              //                   currentLocation.latitude,
              //                   currentLocation.longitude);
              //           final finalizar =
              //               await missaoServices.finalizarMissaoSelectFunction(
              //             widget.cnpj,
              //             widget.nomeDaEmpresa,
              //             widget.placaCavalo,
              //             widget.placaCarreta,
              //             widget.motorista,
              //             widget.corVeiculo,
              //             widget.observacao,
              //             uid,
              //             widget.startPosition!.lat,
              //             widget.startPosition!.lng,
              //             userFinalLatitude,
              //             userFinalLongitude,
              //             widget.endPosition!.lat,
              //             widget.endPosition!.lng,
              //             widget.local,
              //             widget.tipo,
              //             widget.missaoId,
              //             fim: DateTime.now().toIso8601String(),
              //           );
              //           final relatorio =
              //               await missaoServices.relatorioMissaoSelectFunction(
              //             widget.cnpj,
              //             widget.nomeDaEmpresa,
              //             widget.placaCavalo,
              //             widget.placaCarreta,
              //             widget.motorista,
              //             widget.corVeiculo,
              //             widget.observacao,
              //             uid,
              //             widget.missaoId,
              //             nomeDoAgente,
              //             widget.tipo,
              //             widget.startPosition!.lat,
              //             widget.startPosition!.lng,
              //             userFinalLatitude,
              //             userFinalLongitude,
              //             widget.endPosition!.lat,
              //             widget.endPosition!.lng,
              //             widget.local,
              //             fim: DateTime.now().toIso8601String(),
              //           );
              //           debugPrint("Final local: ${finalLocal.item2}");
              //           debugPrint("Finalizar: ${finalizar.item2}");
              //           debugPrint("Relatorio: ${relatorio.item2}");

              //           if (context.mounted) {
              //             finalLocal.item1
              //                 ? mensagemDeSucesso.showSuccessSnackbar(
              //                     context, finalLocal.item2)
              //                 : tratamentoDeErros.showErrorSnackbar(
              //                     context, finalLocal.item2);
              //             finalizar.item1
              //                 ? mensagemDeSucesso.showSuccessSnackbar(
              //                     context, finalizar.item2!)
              //                 : tratamentoDeErros.showErrorSnackbar(
              //                     context, finalizar.item2!);
              //             relatorio.item1
              //                 ? mensagemDeSucesso.showSuccessSnackbar(
              //                     context, relatorio.item2)
              //                 : tratamentoDeErros.showErrorSnackbar(
              //                     context, relatorio.item2);
              //             context.read<AgentMissionBloc>().add(FetchMission());
              //             Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (context) => AddRelatorioScreen(
              //                     uid: uid, missaoId: widget.missaoId!),
              //               ),
              //             );
              //           }
              //         }
              //       },
              //       child: const Text('Finalizar Missão'),
              //     ),
              //   ],
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       onPressed: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => MissaoChatScreen(
              //               missaoId: widget.missaoId!,
              //             ),
              //           ),
              //         );
              //       },
              //       child: Row(
              //         children: [
              //           const Text('Chat'),
              //           StreamBuilder<int>(
              //             stream: chatServices
              //                 .getUsersMissionConversationsUnreadCount(
              //                     widget.missaoId!),
              //             builder: (BuildContext context,
              //                 AsyncSnapshot<int> snapshot) {
              //               if (snapshot.hasData && snapshot.data! > 0) {
              //                 return Padding(
              //                   padding: const EdgeInsets.only(left: 2.0),
              //                   child: Text(
              //                     '(${snapshot.data})',
              //                     style: const TextStyle(
              //                         color: Colors.red,
              //                         fontWeight: FontWeight.bold),
              //                   ),
              //                 );
              //               } else {
              //                 return const SizedBox
              //                     .shrink();
              //               }
              //             },
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ),
    );
  }

  Future<double?> getDistanceBetweenPoints(
      LatLng? startPoint, LatLng? endPoint) async {
    try {
      debugPrint("Ponto de início: ${startPoint?.lat}, ${startPoint?.lng}");
      debugPrint("Ponto final: ${endPoint?.lat}, ${endPoint?.lng}");

      final Dio dio = Dio();

      // Substitua a URL pelo endpoint da sua Firebase Cloud Function
      const firebaseFunctionUrl =
          "https://us-central1-primeval-rune-309222.cloudfunctions.net/getDirections";

      final response = await dio.get(
        firebaseFunctionUrl,
        queryParameters: {
          "origin": "${startPoint!.lat},${startPoint.lng}",
          "destination": "${endPoint!.lat},${endPoint.lng}",
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
      debugPrint(distanceInKm.toString());
      return distanceInKm;
    } catch (e) {
      debugPrint("Erro ao obter direções: $e");
      return null;
    }
  }

  Future<String?> fetchAgentAddress(String uid) async {
    Agente? agente = await AgenteServices().getAgenteInfos(uid);
    return agente?.cidade;
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

  getCurrentLocation() {
    var locationOptions = const LocationSettings(
        accuracy: LocationAccuracy.high, distanceFilter: 10);

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationOptions).listen(
      (Position position) async {
        if (mounted) {
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

          final gmap.GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            gmap.CameraUpdate.newCameraPosition(
              gmap.CameraPosition(
                target: gmap.LatLng(position.latitude, position.longitude),
                zoom: 14.4746,
              ),
            ),
          );
        }
      },
    );
  }

  //funcao para captar a localizacao do usuario
  Future<LatLng> getFinalLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(lat: position.latitude, lng: position.longitude);
  }
}
