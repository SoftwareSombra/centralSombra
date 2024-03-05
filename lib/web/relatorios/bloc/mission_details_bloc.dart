import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../missao/model/missao_model.dart';
import '../../../missao/services/missao_services.dart';
import '../../home/screens/mapa_teste.dart';
import 'mission_details_event.dart';
import 'mission_details_state.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_static_maps_controller/google_static_maps_controller.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class MissionDetailsBloc
    extends Bloc<MissionDetailsEvent, MissionDetailsState> {
  MissionDetailsBloc() : super(MissionDetailsInitial()) {
    MissaoServices missaoServices = MissaoServices();
    on<FetchMissionDetails>(
      (event, emit) async {
        debugPrint('entrou no fetchMissionDetails');
        emit(MissionDetailsLoading());
        try {
          Set<gmap.Marker> userMarkers = {};
          final Set<gmap.Polyline> polylines = <gmap.Polyline>{};
          //List<CoordenadaComTimestamp> route = [];

          final route = await missaoServices.fetchCoordinates(event.missaoId);
          if (route.isEmpty) {
            emit(MissionDetailsNoRouteFound());
            return;
          }

          final routeOrdenada =
              ordenarPorTimestamp(route);

          List<Location> rotaLocations = convertToLocations(routeOrdenada);

          List<CoordenadaComTimestamp> routeFiltrada =
              ordenarPorTimestampEManterPrimeiroPorMinuto(route);

          List<Location> locations = convertToLocations(routeFiltrada);

          final distancia =
              await calcularDistanciaComFirebaseFunction(locations);

          final int middleIndex = locations.length ~/ 2;
          final Location middleLocation = locations[middleIndex];
          final initialPosition = gmap.CameraPosition(
            target: route[0].ponto,
            zoom: 14.4746,
          );
          final rota = await rotaComFirebaseFunction(route);
          debugPrint('Rota: $rota');
          debugPrint(route.toString());
          _addRouteToMap(rota, userMarkers, polylines);
          MissaoRelatorio? missao;
          missao =
              await missaoServices.buscarRelatorio(event.uid, event.missaoId);

          //print de cada campo da missao

          if (missao != null) {
            print('missao: ${missao.toMap()}');
            emit(MissionDetailsLoaded(
                missao,
                initialPosition,
                userMarkers,
                polylines,
                route[0].ponto,
                routeFiltrada,
                middleLocation,
                distancia!));
          } else {
            emit(RelatorioNaoEncontrado('Relatório não encontrado'));
          }
        } catch (e) {
          emit(
            MissionDetailsError(
              e.toString(),
            ),
          );
        }
      },
    );
  }
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

  // List<CoordenadaComTimestamp> ordenarPontosPorTimestamp(
  //     List<CoordenadaComTimestamp> pontos) {
  //   // Ordena a lista de pontos baseando-se no timestamp.
  //   pontos.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  //   return pontos;
  // }

  List<CoordenadaComTimestamp> filtrarPontosProximos(
      List<CoordenadaComTimestamp> locations) {
    List<CoordenadaComTimestamp> pontosFiltrados = [];
    final Distance distancia = Distance();

    // Adicionar o primeiro ponto
    if (locations.isNotEmpty) {
      pontosFiltrados.add(locations.first);
    }

    for (int i = 0; i < locations.length - 1; i++) {
      final double dist = distancia(
        LatLng(locations[i].ponto.latitude, locations[i].ponto.longitude),
        LatLng(
            locations[i + 1].ponto.latitude, locations[i + 1].ponto.longitude),
      );

      // Se a distância for maior que 200 metros, adicionar o ponto
      if (dist > 100) {
        pontosFiltrados.add(locations[i + 1]);
      }
    }

    return pontosFiltrados;
  }

  Future<List<CoordenadaComTimestamp>?> rotaComFirebaseFunction(
      List<CoordenadaComTimestamp> locations) async {
    debugPrint('entrou no rotaComFirebaseFunction');

    List<CoordenadaComTimestamp> filteredLocations = [];
    filteredLocations.addAll(locations);
    //filtrar caso existam mais de 24 pontos
    if (locations.length > 24) {
      List<CoordenadaComTimestamp> pontosFiltrados =
          filtrarPontosProximos(locations);

      // Filtrar a lista de waypoints, pulando cada segundo ponto

      for (int i = 0; i < pontosFiltrados.length; i += 2) {
        filteredLocations.add(pontosFiltrados[i]);
      }
    }
    // Agora, divida 'filteredLocations' em subconjuntos de no máximo 25
    List<List<CoordenadaComTimestamp>> splitLocations = [];
    for (int i = 0; i < filteredLocations.length; i += 25) {
      int endRange = i + 25;
      if (i != 0) {
        endRange += 1;
      }
      splitLocations.add(filteredLocations.sublist(
          i,
          endRange > filteredLocations.length
              ? filteredLocations.length
              : endRange));
    }

    List<CoordenadaComTimestamp> combinedRoute = [];
    const firebaseFunctionUrl =
        "https://us-central1-primeval-rune-309222.cloudfunctions.net/getDirections";
    final Dio dio = Dio();

    for (var splitLoc in splitLocations) {
      String waypoints = splitLoc
          .skip(1)
          .take(splitLoc.length - 2)
          .map((location) =>
              '${location.ponto.latitude},${location.ponto.longitude}')
          .join('|');

      try {
        final response = await dio.get(
          firebaseFunctionUrl,
          queryParameters: {
            "origin":
                "${splitLoc.first.ponto.latitude},${splitLoc.first.ponto.longitude}",
            "destination":
                "${splitLoc.last.ponto.latitude},${splitLoc.last.ponto.longitude}",
            "intermediates": waypoints,
            "travelMode": "driving",
            "key": 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU',
            "languageCode": "pt_BR"
          },
        );

        final data = response.data;
        if (data['routes'].isNotEmpty) {
          var points = data['routes'][0]['overview_polyline']['points'];
          var decoded = PolylinePoints()
              .decodePolyline(points)
              .map((point) => CoordenadaComTimestamp(
                  gmap.LatLng(point.latitude, point.longitude), DateTime.now()))
              .toList();

          if (combinedRoute.isNotEmpty) {
            decoded = decoded
                .skip(1)
                .toList();
          }
          combinedRoute.addAll(decoded);
        } else {
          debugPrint(
              "Erro ao buscar a rota: Status code ${response.statusCode} ---- ${response.data}");
          return null; // Ou trate o erro conforme necessário
        }
      } catch (e) {
        debugPrint("Erro ao obter direções: $e");
        return null; // Ou trate o erro conforme necessário
      }
    }

    return combinedRoute;
  }

  void _addRouteToMap(route, userMarkers, polylines) {
    List<CoordenadaComTimestamp> pontosComTimestamps = route;

    // Filtra os pontos para remover duplicatas.
    // List<CoordenadaComTimestamp> pontosSemDuplicatas =
    //     filtrarDuplicatas(pontosComTimestamps);

    // Ordena os pontos filtrados.
    // List<CoordenadaComTimestamp> coordenadasOrdenadas =
    //     ordenarPontosPorTimestamp(pontosComTimestamps);

    // Converta CoordenadaComTimestamp de volta para gmap.LatLng para uso na polilinha.
    // List<gmap.LatLng> pontosOrdenados =
    //     coordenadasOrdenadas.map((coord) => coord.ponto).toList();

    List<gmap.LatLng> pontosOrdenados =
        pontosComTimestamps.map((coord) => coord.ponto).toList();

    // Adicionando pontos (Markers) ao mapa
    for (var coordenada in pontosComTimestamps) {
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
    polylines.add(
      gmap.Polyline(
        polylineId: const gmap.PolylineId('portoRealRoute'),
        color: Colors.blue,
        points: pontosOrdenados,
      ),
    );
  }

  List<CoordenadaComTimestamp> ordenarPorTimestamp(
      List<CoordenadaComTimestamp> route) {
    route.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return route;
  }

  List<CoordenadaComTimestamp> ordenarPorTimestampEManterPrimeiroPorMinuto(
      List<CoordenadaComTimestamp> route) {
    // Ordena a lista por timestamp
    route.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    List<CoordenadaComTimestamp> filtrado = [];

    // Inicializa com valores que não interferem na comparação inicial
    int ultimoAno = -1,
        ultimoMes = -1,
        ultimoDia = -1,
        ultimaHora = -1,
        ultimoMinuto = -1;

    for (var coord in route) {
      DateTime ts = coord.timestamp;
      // Verifica se o ano, mês, dia, hora e minuto são iguais aos últimos vistos
      if (ts.year != ultimoAno ||
          ts.month != ultimoMes ||
          ts.day != ultimoDia ||
          ts.hour != ultimaHora ||
          ts.minute != ultimoMinuto) {
        // Atualiza os últimos valores vistos
        ultimoAno = ts.year;
        ultimoMes = ts.month;
        ultimoDia = ts.day;
        ultimaHora = ts.hour;
        ultimoMinuto = ts.minute;

        // Adiciona a coordenada atual à lista filtrada
        filtrado.add(coord);
      }
    }

    return filtrado;
  }

  List<Location> convertToLocations(List<CoordenadaComTimestamp> route) {
    return route
        .map((coord) => Location(coord.ponto.latitude, coord.ponto.longitude))
        .toList();
  }

  double calcularDistancia(List<Location> locations) {
    double totalDistance = 0.0;

    for (int i = 0; i < locations.length - 1; i++) {
      totalDistance += distanciaHaversine(
        locations[i].latitude,
        locations[i].longitude,
        locations[i + 1].latitude,
        locations[i + 1].longitude,
      );
    }

    return totalDistance;
  }

  String generateWaypoints(List<Location> locations) {
    final waypoints =
        locations.skip(1).take(locations.length - 2).map((location) {
      return "${location.latitude},${location.longitude}";
    }).join('|');

    return waypoints;
  }

  Future<double?> calcularDistanciaComFirebaseFunction(
    List<Location> locations) async {
  const firebaseFunctionUrl =
      "https://southamerica-east1-sombratestes.cloudfunctions.net/getDistanceBetweenWaypoints";

  // Verifica se a lista precisa ser dividida
  if (locations.length <= 24) {
    // Se não precisar ser dividida, faz a requisição única com todas as localizações
    return await requestDistance(firebaseFunctionUrl, locations);
  } else {
    // Divide a lista em subconjuntos de no máximo 24 localizações (preservando o primeiro e o último ponto para continuidade)
    List<List<Location>> splitLocations = [];
    for (int i = 0; i < locations.length; i += 23) {
      int endRange = (i + 23 < locations.length) ? i + 23 : locations.length;
      splitLocations.add(locations.sublist(i, endRange));
    }

    double totalDistance = 0.0;
    for (var locationSubset in splitLocations) {
      double? distance = await requestDistance(firebaseFunctionUrl, locationSubset);
      if (distance != null) {
        totalDistance += distance;
      } else {
        return null;
      }
    }
    return totalDistance;
  }
}

Future<double?> requestDistance(String url, List<Location> locations) async {
  final Dio dio = Dio();
  final String waypoints = generateWaypoints(locations);

  try {
    final response = await dio.get(
      url,
      queryParameters: {
        "origin": "${locations.first.latitude},${locations.first.longitude}",
        "destination":
            "${locations.last.latitude},${locations.last.longitude}",
        "waypoints": waypoints,
        "mode": "driving",
        "key": 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU',
        "language": "pt_BR"
      },
    );

    if (response.statusCode == 200) {
      final data = response.data;
      int distanceInMeters = 0;
      for (var leg in data["routes"][0]["legs"]) {
        distanceInMeters += leg["distance"]["value"] as int;
      }
      return distanceInMeters / 1000.0; // Convertendo para quilômetros
    } else {
      debugPrint("Erro ao buscar a rota: Status code ${response.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint("Erro ao obter direções: $e");
    return null;
  }
}

  double distanciaHaversine(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Raio da Terra em Km
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);
    lat1 = _toRadians(lat1);
    lat2 = _toRadians(lat2);

    var a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // Distância em Km
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }
}
