import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:sombra/agente/model/agente_model.dart';
import 'package:sombra/mapa/services/mapa_services.dart';
import 'package:sombra/web/home/notificacao/not_teste.dart';
import 'dart:ui' as ui;
import '../../../agente/services/agente_services.dart';
import '../../../autenticacao/services/user_services.dart';
import 'dart:math';

import 'mapa_teste.dart';

class SearchAdminScreen extends StatefulWidget {
  const SearchAdminScreen({super.key});

  @override
  State<SearchAdminScreen> createState() => _SearchAdminScreenState();
}

enum ActiveField { start, end, mission }

class _SearchAdminScreenState extends State<SearchAdminScreen> {
  // final places = places_sdk.FlutterGooglePlacesSdk(
  //   'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU',
  //   locale: const Locale('pt', 'BR'),
  // );
  // List<places_sdk.AutocompletePrediction>? _predictions;
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  // Place? startPosition;
  // Place? endPosition;
  final _missionController = TextEditingController();
  //places_sdk.Place? missionPosition;
  String? _selectedPlaceId;
  NotTesteService notTesteService = NotTesteService();

  ActiveField? _activeField;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    // _startController.addListener(() {
    //   _onTextChanged(_startController, ActiveField.start);
    // });

    // _endController.addListener(() {
    //   _onTextChanged(_endController, ActiveField.end);
    // });

    // _missionController.addListener(() {
    //   _onTextChanged(_missionController, ActiveField.mission);
    // });
  }

  // _onTextChanged(TextEditingController controller, ActiveField activeField) {
  //   if (controller.text.isEmpty) {
  //     setState(() {
  //       _predictions = null;
  //     });
  //     return;
  //   }

  //   if (_debounce?.isActive ?? false) _debounce?.cancel();

  //   _debounce = Timer(const Duration(milliseconds: 500), () {
  //     performSearch(controller.text, activeField);
  //   });
  // }

  // performSearch(String query, ActiveField activeField) async {
  //   if (query.isNotEmpty) {
  //     final result = await places.findAutocompletePredictions(query);

  //     if (result.predictions.isNotEmpty) {
  //       setState(() {
  //         _predictions = result.predictions;
  //         _activeField = activeField;
  //       });
  //     }
  //   }
  // }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Places Autocomplete')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () async {
                      await notTesteService.sendPushNotificationWithDio();
                    },
                    child: const Text('Enviar notificação'),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _missionController,
              style: TextStyle(color: Colors.grey[200]),
              decoration: const InputDecoration(
                labelText: 'Local da Corrida',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            // if (_predictions != null && _predictions!.isNotEmpty)
            //   Expanded(
            //     child: ListView.builder(
            //       itemCount: _predictions!.length,
            //       itemBuilder: (context, index) {
            //         final prediction = _predictions![index];
            //         bool isSelected = prediction.placeId == _selectedPlaceId;

            //         return ListTile(
            //             title: Text(prediction.fullText),
            //             trailing: isSelected ? const Icon(Icons.check) : null,
            //             onTap: () async {
            //               final fields = [
            //                 places_sdk.PlaceField.Name,
            //                 places_sdk.PlaceField.Address,
            //                 places_sdk.PlaceField
            //                     .Location, // Alterado de Location para LatLng
            //               ];

            //               final response = await places
            //                   .fetchPlace(prediction.placeId, fields: fields);
            //               places_sdk.Place? details = response.place;

            //               setState(() {
            //                 _selectedPlaceId = prediction.placeId;
            //                 if (_activeField == ActiveField.mission) {
            //                   missionPosition = details;
            //                   _missionController.text = details!.address!;
            //                   _missionController.selection =
            //                       TextSelection.fromPosition(
            //                     TextPosition(
            //                         offset: _missionController.text.length),
            //                   );
            //                 }

            //                 debugPrint(missionPosition
            //                     .toString()); // Adicionando o log para o missionPosition
            //                 _predictions = null;
            //               });
            //             });
            //       },
            //     ),
            //   ),
            // ElevatedButton(
            //   onPressed: (missionPosition != null)
            //       ? () {
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (context) => MapAdminScreen(
            //                 // startPosition: startPosition,
            //                 // endPosition: endPosition,
            //                 missionPosition: missionPosition,
            //               ),
            //             ),
            //           );
            //         }
            //       : null,
            //   child: const Text('Open Map'),
            // )
          ],
        ),
      ),
    );
  }
}

class MapAdminScreen extends StatefulWidget {
  // final Place? startPosition;
  // final Place? endPosition;
  final Place? missionPosition;

  const MapAdminScreen({
    super.key,
    // this.startPosition,
    // this.endPosition,
    this.missionPosition,
  });

  @override
  _MapAdminScreenState createState() => _MapAdminScreenState();
}

class _MapAdminScreenState extends State<MapAdminScreen> {
  late gmap.CameraPosition _initialPosition;
  final Completer<gmap.GoogleMapController> _controller = Completer();
  final Set<gmap.Polyline> _polylines = <gmap.Polyline>{};
  Uint8List? _userIcon;
  UserServices userServices = UserServices();
  Set<gmap.Marker> userMarkers = {};
  MapaServices mapaServices = MapaServices();
  List<Map<String, dynamic>> agentesMaisProximos = [];

  @override
  void initState() {
    super.initState();
    _initialPosition = gmap.CameraPosition(
      target: gmap.LatLng(
        widget.missionPosition!.latLng!.latitude,
        widget.missionPosition!.latLng!.longitude,
      ),
      zoom: 14.4746,
    );
    _loadPhotoBytes();
    _loadUserLocations().then((_) {
      fetchNearestUsersToMission(gmap.LatLng(
        widget.missionPosition!.latLng!.latitude,
        widget.missionPosition!.latLng!.longitude,
      ));
    });
    _testGetPlaceFromLatLng();
  }

  Future<void> _loadUserLocations() async {
    final locations = await mapaServices.fetchAllUsersLocations();
    debugPrint('Locations loaded: ${locations.length}');
    setState(() {
      for (var location in locations) {
        userMarkers.add(
          gmap.Marker(
            infoWindow: gmap.InfoWindow(title: location.nomeDoAgente),
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
      if (_userIcon != null)
        gmap.Marker(
          markerId: const gmap.MarkerId('mission'),
          position: gmap.LatLng(
            widget.missionPosition!.latLng!.latitude,
            widget.missionPosition!.latLng!.longitude,
          ),
          icon: gmap.BitmapDescriptor.fromBytes(_userIcon!),
        )
    };

    return Scaffold(
      appBar: AppBar(
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
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.6, // 70% da altura da tela, por exemplo
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
          const SizedBox(
            height: 25,
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
            height: 15,
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
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                'Endereço do agente: ${entry.value['endereco']}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Future<double?> getDistanceBetweenPoints(
      Place? startPoint, Place? endPoint) async {
    try {
      debugPrint(
          "Ponto de início: ${startPoint?.latLng?.latitude}, ${startPoint?.latLng?.longitude}");
      debugPrint(
          "Ponto final: ${endPoint?.latLng?.latitude}, ${endPoint?.latLng?.longitude}");

      final Dio dio = Dio();

      // Substitua a URL pelo endpoint da sua Firebase Cloud Function
      const firebaseFunctionUrl =
          "https://us-central1-primeval-rune-309222.cloudfunctions.net/getDirections";

      final response = await dio.get(
        firebaseFunctionUrl,
        queryParameters: {
          "origin": "${startPoint!.latLng!.latitude},${startPoint.latLng!.longitude}",
          "destination": "${endPoint!.latLng!.latitude},${endPoint.latLng!.longitude}",
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
    debugPrint(
        "Lat: ${widget.missionPosition!.latLng!.latitude}, Lng: ${widget.missionPosition!.latLng!.longitude}");

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

    // Exibe os nomes dos três usuários mais próximos no log
    for (var entry in distances.take(10)) {
      String? enderecoAgente =
          await fetchAgentAddress((entry['user'] as UserLocation).uid);
      agentesMaisProximos.add({
        'nome': (entry['user'] as UserLocation).nomeDoAgente,
        'uid': (entry['user'] as UserLocation).uid,
        'distance': entry['distance'],
        'endereco': enderecoAgente,
      });
    }
    setState(() {});
  }

  Future<String?> fetchAgentAddress(String uid) async {
    Agente? agente = await AgenteServices().getAgenteInfos(uid);
    return agente?.cidade;
  }

  Future<Place?> getPlaceFromLatLng(LatLng latLng) async {
    const apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
    final dio = Dio();
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latLng.latitude},${latLng.longitude}&key=$apiKey';

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
    LatLng rioCoord = LatLng(-22.9519, -43.2105);
    Place? place = await getPlaceFromLatLng(rioCoord);
    if (place != null) {
      debugPrint('Endereço encontrado: ${place.address}');
    } else {
      debugPrint(
          'Nenhum endereço foi encontrado para as coordenadas fornecidas.');
    }
  }
}

class Place {
  final String? address;
  final LatLng? latLng;
  final String? name;
  final List<String>? addressComponents;
  final String? businessStatus;
  final List<String>? attributions;
  final String? openingHours;
  final String? phoneNumber;
  final List<String>? photoMetadatas;
  final String? plusCode;
  final int? priceLevel;
  final double? rating;
  final List<String>? types;
  final int? userRatingsTotal;
  final int? utcOffsetMinutes;
  final Viewport? viewport;
  final Uri? websiteUri;
  final String? id;

  Place({
    required this.address,
    required this.latLng,
    required this.name,
    this.addressComponents,
    this.businessStatus,
    this.attributions,
    this.openingHours,
    this.phoneNumber,
    this.photoMetadatas,
    this.plusCode,
    this.priceLevel,
    this.rating,
    this.types,
    this.userRatingsTotal,
    this.utcOffsetMinutes,
    this.viewport,
    this.websiteUri,
    this.id,
  });
}

// Classes auxiliares LatLng e Viewport
class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}

class Viewport {
  final LatLng northeast;
  final LatLng southwest;

  Viewport(this.northeast, this.southwest);
}
