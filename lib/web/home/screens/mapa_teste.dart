import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:intl/intl.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import 'dart:math';

class MapaRotaTeste extends StatefulWidget {
  final Place? missionPosition;
  final portoRealRoute;

  const MapaRotaTeste(
      {Key? key, this.missionPosition, required this.portoRealRoute})
      : super(key: key);

  @override
  _MapaRotaTesteState createState() => _MapaRotaTesteState();
}

class _MapaRotaTesteState extends State<MapaRotaTeste> {
  late gmap.CameraPosition _initialPosition;
  final Completer<gmap.GoogleMapController> _controller = Completer();
  final Set<gmap.Polyline> _polylines = <gmap.Polyline>{};
  Uint8List? _userIcon;
  //UserServices userServices = UserServices();
  Set<gmap.Marker> userMarkers = {};
  //MapaServices mapaServices = MapaServices();
  List<Map<String, dynamic>> agentesMaisProximos = [];
  Set<Map<String, dynamic>> agentesSelecionados = <Map<String, dynamic>>{};
  MissaoServices missaoServices = MissaoServices();

  @override
  void initState() {
    super.initState();
    _initialPosition = gmap.CameraPosition(
      target: widget.portoRealRoute[0].ponto,
      zoom: 14.4746,
    );
    _getInitialDistance();
    _addPortoRealRouteToMap();
  }

//   void _addPortoRealRouteToMap() {
//     List<CoordenadaComTimestamp> pontosComTimestamps = widget.portoRealRoute;

//     // Adicionando pontos (Markers) ao mapa
//     for (var coordenada in pontosComTimestamps) {
//       String formattedTimestamp = DateFormat('yMd Hms').format(coordenada.timestamp);

//       userMarkers.add(
//         gmap.Marker(
//           markerId: gmap.MarkerId(coordenada.ponto.toString()),
//           position: coordenada.ponto,
//           icon: gmap.BitmapDescriptor.defaultMarker,
//           infoWindow: gmap.InfoWindow(title: formattedTimestamp),
//         ),
//       );
//     }

//     // Ordena os pontos por distância
//     List<CoordenadaComTimestamp> coordenadasOrdenadas = ordenarPontosPorDistancia(pontosComTimestamps);

//     // Mapeia as coordenadas ordenadas para uma lista de gmap.LatLng
//     List<gmap.LatLng> pontosOrdenados = coordenadasOrdenadas.map((c) => c.ponto).toList();

//     // Adicionando a rota (Polyline) ao mapa
//     _polylines.add(
//       gmap.Polyline(
//         polylineId: const gmap.PolylineId('portoRealRoute'),
//         color: Colors.blue,
//         points: pontosOrdenados,
//       ),
//     );
// }

  List<CoordenadaComTimestamp> filtrarDuplicatas(
      List<CoordenadaComTimestamp> pontos) {
    Set<DateTime> timestampsUnicos = {};
    List<CoordenadaComTimestamp> pontosFiltrados = [];

    for (var coordenada in pontos) {
      if (timestampsUnicos.contains(coordenada.timestamp)) {
        continue;
      }
      timestampsUnicos.add(coordenada.timestamp);
      pontosFiltrados.add(coordenada);
    }

    return pontosFiltrados;
  }

  void _addPortoRealRouteToMap() {
    List<CoordenadaComTimestamp> pontosComTimestamps = widget.portoRealRoute;

    // Filtra os pontos para remover duplicatas.
    List<CoordenadaComTimestamp> pontosSemDuplicatas =
        filtrarDuplicatas(pontosComTimestamps);

    // Ordena os pontos filtrados.
    List<CoordenadaComTimestamp> coordenadasOrdenadas =
        ordenarPontosPorTimestamp(pontosSemDuplicatas);

    // Converta CoordenadaComTimestamp de volta para gmap.LatLng para uso na polilinha.
    List<gmap.LatLng> pontosOrdenados =
        coordenadasOrdenadas.map((coord) => coord.ponto).toList();

    // Adicionando pontos (Markers) ao mapa
    for (var coordenada in pontosSemDuplicatas) {
      String formattedTimestamp =
          DateFormat('yMd Hms').format(coordenada.timestamp);

      userMarkers.add(
        gmap.Marker(
          markerId: gmap.MarkerId(coordenada.ponto.toString()),
          position: coordenada.ponto,
          icon: gmap.BitmapDescriptor.defaultMarker,
          infoWindow: gmap.InfoWindow(title: formattedTimestamp),
        ),
      );
    }

    // Adicionando a rota (Polyline) ao mapa.
    _polylines.add(
      gmap.Polyline(
        polylineId: const gmap.PolylineId('portoRealRoute'),
        color: Colors.blue,
        points: pontosOrdenados,
      ),
    );
  }

  Future<void> _getInitialDistance() async {
    // double? missionStartDistance = await getDistanceBetweenPoints(
    //     widget.missionPosition, widget.startPosition);
    // double? missionEndDistance = await getDistanceBetweenPoints(
    //     widget.missionPosition, widget.endPosition);

    // debugPrint(
    //     "Distância entre o local da corrida e o motorista 1: ${missionStartDistance}km");
    // debugPrint(
    //     "Distância entre o local da corrida e o motorista 2: ${missionEndDistance}km");
  }

  @override
  Widget build(BuildContext context) {
    Set<gmap.Marker> markers = {
      ...userMarkers,
      if (_userIcon != null)
        gmap.Marker(
          markerId: const gmap.MarkerId('mission'),
          position: gmap.LatLng(
            widget.missionPosition!.latLng!.lat,
            widget.missionPosition!.latLng!.lng,
          ),
          //icon: gmap.BitmapDescriptor.fromBytes(_userIcon!),
        )
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
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.9, // 70% da altura da tela, por exemplo
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

  List<CoordenadaComTimestamp> ordenarPontosPorDistancia(
      List<CoordenadaComTimestamp> pontos) {
    CoordenadaComTimestamp coordenadaDePartida = pontos[0];
    List<CoordenadaComTimestamp> pontosOrdenados = [coordenadaDePartida];
    pontos.remove(coordenadaDePartida);

    while (pontos.isNotEmpty) {
      CoordenadaComTimestamp proximaCoordenada =
          encontrarCoordenadaMaisProxima(coordenadaDePartida, pontos);
      pontosOrdenados.add(proximaCoordenada);
      pontos.remove(proximaCoordenada);
      coordenadaDePartida = proximaCoordenada;
    }

    return pontosOrdenados;
  }

  CoordenadaComTimestamp encontrarCoordenadaMaisProxima(
      CoordenadaComTimestamp coordenadaDeReferencia,
      List<CoordenadaComTimestamp> listaDeCoordenadas) {
    CoordenadaComTimestamp coordenadaMaisProxima = listaDeCoordenadas[0];
    double menorDistancia = calculateDistance(
        coordenadaDeReferencia.ponto, coordenadaMaisProxima.ponto);

    for (var coordenada in listaDeCoordenadas) {
      double distancia =
          calculateDistance(coordenadaDeReferencia.ponto, coordenada.ponto);
      if (distancia < menorDistancia) {
        menorDistancia = distancia;
        coordenadaMaisProxima = coordenada;
      }
    }

    return coordenadaMaisProxima;
  }

  // List<gmap.LatLng> ordenarPontosPorTimestamp(List<CoordenadaComTimestamp> pontos) {
  //   pontos.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  //   return pontos.map((p) => p.ponto).toList();
  // }
  List<CoordenadaComTimestamp> ordenarPontosPorTimestamp(
      List<CoordenadaComTimestamp> pontos) {
    // Ordena a lista de pontos baseando-se no timestamp.
    pontos.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return pontos;
  }
}

class CoordenadaComTimestamp {
  final gmap.LatLng ponto;
  final DateTime timestamp;

  CoordenadaComTimestamp(this.ponto, this.timestamp);
}
