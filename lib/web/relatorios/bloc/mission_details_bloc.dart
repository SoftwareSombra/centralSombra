import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../../../chat/services/chat_services.dart';
import '../../../chat_view/src/models/message.dart';
import '../../../missao/model/missao_model.dart';
import '../../../missao/services/missao_services.dart';
import '../../home/screens/mapa_teste.dart';
import '../services/relatorio_services.dart';
import 'mission_details_event.dart';
import 'mission_details_state.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_static_maps_controller/google_static_maps_controller.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'dart:convert';

class MissionDetailsBloc
    extends Bloc<MissionDetailsEvent, MissionDetailsState> {
  MissionDetailsBloc() : super(MissionDetailsInitial()) {
    MissaoServices missaoServices = MissaoServices();
    ChatServices chatServices = ChatServices();
    RelatorioServices relatorioServices = RelatorioServices();
    on<FetchMissionDetails>(
      (event, emit) async {
        debugPrint('entrou no fetchMissionDetails');
        emit(MissionDetailsLoading());
        try {
          Set<gmap.Marker> userMarkers = {};
          Set<gmap.Polyline>? polylines = {};
          Set<gmap.Polyline>? newPolylines = {};
          double? distancia;
          double? distanciaIda;
          double? distanciaVolta;
          gmap.CameraPosition? initialPosition;
          List<CoordenadaComTimestamp>? routeFiltrada;
          Location? middleLocation;

          MissaoRelatorio? missao;
          missao =
              await missaoServices.buscarRelatorio(event.uid, event.missaoId);

          final route = await missaoServices.fetchCoordinates(event.missaoId);
          if (route.isNotEmpty) {
            // emit(MissionDetailsNoRouteFound());
            // return;

            final routeOrdenada = ordenarPorTimestamp(route);

            List<Location> rotaLocations = convertToLocations(routeOrdenada);

            debugPrint('rotaLocations: ${rotaLocations.length}');

            List<CoordenadaComTimestamp> rotaFiltradaPorVelocidadeMax =
                filtrarPorVelocidadeMaxima(routeOrdenada, 200);

            debugPrint(
                'rotaFiltradaPorVelocidadeMax: ${rotaFiltradaPorVelocidadeMax.length}');

            List<CoordenadaComTimestamp> routeFiltradaPorMinuto =
                ordenarPorTimestampEManterPrimeiroPorMinuto(
                    rotaFiltradaPorVelocidadeMax);

            debugPrint('routeFiltrada: ${routeFiltradaPorMinuto.length}');

            routeFiltrada = filtrarPontosPorVelocidadeMinima(route);

            //List<Location> locations = convertToLocations(routeFiltrada);
            List<Location> locations = convertToLocations(routeFiltrada);

            debugPrint('locations: ${locations.length}');

            calcularDistanciaComLatLong2(locations);
            calcularDistanciaComLatLong2(rotaLocations);

            if (locations.length > 3) {
              final firstAndLastCoordinates =
                  getFirstAndLastCoordinates(locations);
              String firstCoordinate = firstAndLastCoordinates['first']!;
              String lastCoordinate = firstAndLastCoordinates['last']!;

              String missionCoordinates =
                  '${missao!.missaoLatitude.toString()},${missao.missaoLongitude.toString()}';

              distanciaIda = await getDistanceWithMatrix(
                  firstCoordinate, missionCoordinates);
              distanciaVolta = await getDistanceWithMatrix(
                  missionCoordinates, lastCoordinate);

              distancia = distanciaIda! + distanciaVolta!;

              // Dividir as coordenadas em segmentos online e offline
              List<gmap.LatLng> onlinePoints = [];
              List<gmap.LatLng> offlinePoints = [];
              bool? lastStatus;

              List<gmap.LatLng> locationsToLatLng = locations
                  .map((location) =>
                      gmap.LatLng(location.latitude, location.longitude))
                  .toList();

              // newPolylines.add(
              //   gmap.Polyline(
              //       polylineId: const gmap.PolylineId('newPolyline'),
              //       points: locationsToLatLng,
              //       color: Colors.blue,
              //       width: 2),
              // );

              for (int i = 0; i < routeFiltrada.length - 1; i++) {
                final currentCoord = locations[i];
                final nextCoord = locations[i + 1];

                // Converter para LatLng do Google Maps
                final currentPoint =
                    gmap.LatLng(currentCoord.latitude, currentCoord.longitude);
                final nextPoint =
                    gmap.LatLng(nextCoord.latitude, nextCoord.longitude);

                // Verificar se o ponto atual é online ou offline
                final isCurrentOnline = routeFiltrada[i]
                    .online; // Supondo que `routeFiltrada` tenha esse status

                // Cria uma polyline entre o ponto atual e o próximo
                newPolylines.add(
                  gmap.Polyline(
                    polylineId: gmap.PolylineId('segment_$i'),
                    points: [currentPoint, nextPoint],
                    color: isCurrentOnline!
                        ? Colors.blue
                        : Colors.red, // Azul para online, vermelho para offline
                    width: 2,
                  ),
                );
              }

              debugPrint('polylines: $newPolylines');

              debugPrint('polylines: $polylines');
            } else {
              distancia = calcularDistanciaComLatLong2(locations);
            }

            final int middleIndex = locations.length ~/ 2;
            middleLocation = locations[middleIndex];
            initialPosition = gmap.CameraPosition(
              target: route[0].ponto,
              zoom: 14.4746,
            );
          } else {
            initialPosition = null;
            middleLocation = null;
            routeFiltrada = null;
          }

          // final rota = await rotaComFirebaseFunction(route);
          // debugPrint('Rota: $rota');
          // debugPrint(route.toString());
          // _addRouteToMap(rota, userMarkers, polylines);

          missao != null
              ? debugPrint(' ---------> MISSAO encontrada com sucesso !!!!!!!')
              : null;

          List<Message>? messages =
              await chatServices.buscarChatMissao(event.missaoId);

          messages != null
              ? debugPrint(' ---------> CHAT encontrado com sucesso !!!!!!!')
              : null;

          Foto? odometroInicial = await relatorioServices
              .buscarFotoOdometroInicial(event.uid, event.missaoId);

          Foto? odometroFinal = await relatorioServices.buscarFotoOdometroFinal(
              event.uid, event.missaoId);

          if (missao != null) {
            debugPrint('missao: ${missao.toMap()}');
            emit(
              MissionDetailsLoaded(
                  missao,
                  initialPosition,
                  userMarkers,
                  newPolylines,
                  route.isNotEmpty ? route[0].ponto : null,
                  routeFiltrada,
                  //route,
                  middleLocation,
                  distancia,
                  distanciaIda,
                  distanciaVolta,
                  messages,
                  odometroInicial,
                  odometroFinal),
            );
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
    on<ResetMissionDetails>(_onResetMissionDetails);
  }

  Set<gmap.Polyline> createPolylinesFromEncodedString(String encodedPolyline) {
    // Decodifica a polyline
    List<PointLatLng> decodedPoints =
        PolylinePoints().decodePolyline(encodedPolyline);

    // Cria uma lista de LatLng
    List<gmap.LatLng> polylineCoordinates = decodedPoints
        .map((point) => gmap.LatLng(point.latitude, point.longitude))
        .toList();

    // Cria um Polyline
    gmap.Polyline polyline = gmap.Polyline(
      polylineId: const gmap.PolylineId("polyline_id"),
      points: polylineCoordinates,
      color: Colors.red,
      width: 5,
    );

    // Retorna um Set contendo o Polyline criado
    return {polyline};
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
    const latlong.Distance distancia = latlong.Distance();

    // Adicionar o primeiro ponto
    if (locations.isNotEmpty) {
      pontosFiltrados.add(locations.first);
    }

    for (int i = 0; i < locations.length - 1; i++) {
      final double dist = distancia(
        latlong.LatLng(
            locations[i].ponto.latitude, locations[i].ponto.longitude),
        latlong.LatLng(
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
              .map(
                (point) => CoordenadaComTimestamp(
                    gmap.LatLng(point.latitude, point.longitude),
                    DateTime.now(),
                    true),
              )
              .toList();

          if (combinedRoute.isNotEmpty) {
            decoded = decoded.skip(1).toList();
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
    route.sort(
      (a, b) => a.timestamp.compareTo(b.timestamp),
    );
    //retirar as duas primeiras coordenadas
    debugPrint('route: ${route.length}');

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    if (route.length > 3) {
      route.removeAt(0);
      //route.removeAt(0);
    }
    debugPrint('route2: ${route.length}');
    return route;
  }

  List<CoordenadaComTimestamp> filtrarPorVelocidadeMaxima(
      List<CoordenadaComTimestamp> coordenadas, double velocidadeMaximaKmH) {
    debugPrint('coordenadas: ${coordenadas.length}');
    if (coordenadas.length <= 3) {
      return coordenadas;
    }

    List<CoordenadaComTimestamp> resultado = [];
    const latlong.Distance calculadoraDistancia = latlong.Distance();

    for (int i = 1; i < coordenadas.length; i++) {
      final coordenadaAtual = coordenadas[i];
      final coordenadaAnterior = coordenadas[i - 1];

      final distancia = calculadoraDistancia(
        latlong.LatLng(coordenadaAnterior.ponto.latitude,
            coordenadaAnterior.ponto.longitude),
        latlong.LatLng(
            coordenadaAtual.ponto.latitude, coordenadaAtual.ponto.longitude),
      );

      final duracaoSegundos = coordenadaAtual.timestamp
          .difference(coordenadaAnterior.timestamp)
          .inSeconds;

      if (duracaoSegundos > 0) {
        final velocidadeKmH = (distancia / 1000) / (duracaoSegundos / 3600);
        final velocidade = double.parse(velocidadeKmH.toStringAsFixed(2));
        debugPrint('velocidadeKmH: $velocidade');

        if (velocidade <= velocidadeMaximaKmH) {
          debugPrint('Adicionando coordenada com velocidade $velocidade');
          resultado.add(coordenadaAtual);
        } else {
          debugPrint('velocidade maior que 200km/h removida');
        }
      } else {
        // Aqui você decide o que fazer se duracaoSegundos for 0.
        // Por exemplo, você pode querer adicionar a coordenada atual ao resultado,
        // assumindo que o ponto estacionário ainda é relevante para sua análise.
        debugPrint('duracaoSegundos é 0, adicionando coordenada por padrão');
        resultado.add(coordenadaAtual);
      }
    }

    debugPrint('resultado: ${resultado.length}');
    return resultado;
  }

  Future<List<CoordenadaComTimestamp>> filtrarPorVelocidade(
      List<CoordenadaComTimestamp> coordenadas) async {
    const apiKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';

    // Converter a lista de coordenadas para o formato necessário para a API
    final path = coordenadas
        .map((coord) => '${coord.ponto.latitude},${coord.ponto.longitude}')
        .join('|');

    final url =
        'https://roads.googleapis.com/v1/speedLimits?path=$path&key=$apiKey';

    final response = await Dio().get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load speed limits: ${response.statusCode}');
    }

    final data = jsonDecode(response.data);
    final speedLimits = data['speedLimits'];

    List<CoordenadaComTimestamp> resultado = [];

    for (int i = 1; i < coordenadas.length; i++) {
      final coordenadaAtual = coordenadas[i];
      final coordenadaAnterior = coordenadas[i - 1];

      final distancia = _calculateDistance(
        coordenadaAnterior.ponto.latitude,
        coordenadaAnterior.ponto.longitude,
        coordenadaAtual.ponto.latitude,
        coordenadaAtual.ponto.longitude,
      );

      final duracaoSegundos = coordenadaAtual.timestamp
          .difference(coordenadaAnterior.timestamp)
          .inSeconds;

      if (duracaoSegundos > 0) {
        final velocidadeKmH = (distancia / 1000) / (duracaoSegundos / 3600);
        final velocidade = double.parse(velocidadeKmH.toStringAsFixed(2));

        final limiteVelocidade = speedLimits[i - 1]['speedLimit'] as int;
        final velocidadePermitida = limiteVelocidade * 2;

        if (velocidade <= velocidadePermitida) {
          resultado.add(coordenadaAtual);
        }
      }
    }

    return resultado;
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Pi/180
    const double Function(num radians) c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000; // 2*R*asin...
  }

  // List<CoordenadaComTimestamp> filtrarPorVelocidadeMaxima(
  //     List<CoordenadaComTimestamp> coordenadas, double velocidadeMaximaKmH) {
  //   debugPrint('coordenadas: ${coordenadas.length}');
  //   if (coordenadas.length <= 3) {
  //     return coordenadas;
  //   }

  //   coordenadas.sort(
  //     (a, b) => a.timestamp.compareTo(b.timestamp),
  //   );

  //   List<CoordenadaComTimestamp> resultado = [];
  //   const Distance calculadoraDistancia = Distance();
  //   double ultimaVelocidade = 0;

  //   for (int i = 1; i < coordenadas.length; i++) {
  //     final coordenadaAtual = coordenadas[i];
  //     final coordenadaAnterior = coordenadas[i - 1];

  //     final distancia = calculadoraDistancia(
  //       LatLng(coordenadaAnterior.ponto.latitude,
  //           coordenadaAnterior.ponto.longitude),
  //       LatLng(coordenadaAtual.ponto.latitude, coordenadaAtual.ponto.longitude),
  //     );

  //     final duracaoSegundos = coordenadaAtual.timestamp
  //         .difference(coordenadaAnterior.timestamp)
  //         .inSeconds;

  //     if (duracaoSegundos > 0) {
  //       final velocidadeKmH = (distancia / 1000) / (duracaoSegundos / 3600);
  //       final velocidade = double.parse(velocidadeKmH.toStringAsFixed(2));
  //       debugPrint('velocidadeKmH: $velocidade');

  //       // Adicionar ao resultado somente se a velocidade estiver dentro do intervalo permitido
  //       if (velocidade <= velocidadeMaximaKmH && velocidade <= 290) {
  //         if (velocidade >= 4) {
  //           debugPrint('Adicionando coordenada com velocidade $velocidade');
  //           resultado.add(coordenadaAtual);
  //           ultimaVelocidade = velocidade;
  //         } else {
  //           // Verificar a última velocidade armazenada
  //           if (ultimaVelocidade >= 4) {
  //             debugPrint(
  //                 'Adicionando coordenada com velocidade menor que 10 km/h, pois a última velocidade armazenada é maior que 10 km/h');
  //             resultado.add(coordenadaAtual);
  //             ultimaVelocidade = velocidade;
  //           } else {
  //             debugPrint(
  //                 'Não adicionando coordenada com velocidade menor que 10 km/h, pois a última velocidade armazenada também é menor que 10 km/h');
  //           }
  //         }
  //       }
  //     } else {
  //       // Adicionar a coordenada atual ao resultado se duracaoSegundos for 0
  //       debugPrint('duracaoSegundos é 0, adicionando coordenada por padrão');
  //       resultado.add(coordenadaAtual);
  //       ultimaVelocidade = 0; // Resetar a última velocidade
  //     }
  //   }

  //   debugPrint('resultado: ${resultado.length}');
  //   return resultado;
  // }

//   List<CoordenadaComTimestamp> ordenarPorTimestampEManterPrimeiroPorMinuto(
//     List<CoordenadaComTimestamp> route) {
//   // Ordena a lista por timestamp
//   route.sort((a, b) => a.timestamp.compareTo(b.timestamp));

//   debugPrint('route: ${route.length}');
//   if (route.length <= 3) {
//     return route;
//   }

//   List<CoordenadaComTimestamp> filtrado = [];

//   // Inicializa com o primeiro ponto para comparações iniciais
//   DateTime ultimoTimestampValido = route.first.timestamp.subtract(const Duration(minutes: 1));
//   final Distance distancia = Distance();

//   for (var coord in route) {
//     DateTime ts = coord.timestamp;

//     // Verifica se está no mesmo minuto do último timestamp válido
//     if (ts.year == ultimoTimestampValido.year &&
//         ts.month == ultimoTimestampValido.month &&
//         ts.day == ultimoTimestampValido.day &&
//         ts.hour == ultimoTimestampValido.hour &&
//         ts.minute == ultimoTimestampValido.minute) {
//           debugPrint('Ponto no mesmo minuto');
//       continue; // Pula para o próximo ponto se estiver no mesmo minuto
//     }

//     // Para o primeiro ponto ou quando muda o minuto, verifica a distância
//     if (filtrado.isNotEmpty) {
//       double dist = distancia(
//         LatLng(filtrado.last.ponto.latitude, filtrado.last.ponto.longitude),
//         LatLng(coord.ponto.latitude, coord.ponto.longitude),
//       );

//       debugPrint('distância: $dist');

//       // Se a distância for menor que 20 metros e não for a mudança de minuto, pula
//       if (dist < 20) {
//         continue;
//       }
//     }

//     // Atualiza o último timestamp válido e adiciona o ponto à lista filtrada
//     ultimoTimestampValido = ts;
//     filtrado.add(coord);
//   }

//   //debugPrint do timestamp de cada ponto
//   for (var coord in filtrado) {
//     debugPrint('timestamp do ponto: ${coord.timestamp}');
//   }

//   return filtrado;
// }

  List<CoordenadaComTimestamp> ordenarPorTimestampEManterPrimeiroPorMinuto(
      List<CoordenadaComTimestamp> route) {
    // Ordena a lista por timestamp
    route.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    debugPrint('route: ${route.length}');
    if (route.length <= 3) {
      return route;
    }

    // Um Set para armazenar as combinações únicas de ano, mês, dia, hora e minuto já adicionadas
    final Set<String> minutosAdicionados = {};

    List<CoordenadaComTimestamp> filtrado = [];

    for (var coord in route) {
      String key =
          "${coord.timestamp.year}-${coord.timestamp.month}-${coord.timestamp.day}-${coord.timestamp.hour}-${coord.timestamp.minute}";

      // Adiciona ao `filtrado` apenas o **primeiro ponto** de cada minuto
      if (!minutosAdicionados.contains(key)) {
        filtrado.add(coord); // Adiciona o ponto atual à lista filtrada
        minutosAdicionados.add(key); // Marca o minuto como já adicionado
      }
    }

    // debugPrint do timestamp de cada ponto da lista 'route'
    for (var coord in route) {
      debugPrint('timestamp do ponto da lista route: ${coord.timestamp}');
    }

    // debugPrint do timestamp de cada ponto filtrado
    for (var coord in filtrado) {
      debugPrint('timestamp do ponto: ${coord.timestamp}');
    }

    return filtrado;
  }

  double calcularDistancia2(
      CoordenadaComTimestamp p1, CoordenadaComTimestamp p2) {
    const R = 6371.0; // Raio da Terra em km
    double lat1 = p1.ponto.latitude * pi / 180; // Converter para radianos
    double lat2 = p2.ponto.latitude * pi / 180; // Converter para radianos
    double lon1 = p1.ponto.longitude * pi / 180; // Converter para radianos
    double lon2 = p2.ponto.longitude * pi / 180; // Converter para radianos

    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distancia = R * c; // Distância em km

    return distancia;
  }

// Função para calcular a velocidade entre dois pontos em km/h
  double calcularVelocidade(
      CoordenadaComTimestamp p1, CoordenadaComTimestamp p2) {
    double distancia = calcularDistancia2(p1, p2); // Distância em km
    Duration diferencaTempo = p2.timestamp
        .difference(p1.timestamp); // Diferença de tempo entre os dois pontos

    // Converter a diferença de tempo para horas
    double horas = diferencaTempo.inSeconds / 3600.0;

    // Evitar divisão por zero
    if (horas == 0) {
      return 0;
    }

    // Velocidade em km/h
    double velocidade = distancia / horas;

    return velocidade;
  }

// Função para filtrar os pontos com velocidade menor que 10 km/h
  List<CoordenadaComTimestamp> filtrarPontosPorVelocidadeMinima(
      List<CoordenadaComTimestamp> route) {
    if (route.length <= 1) {
      return route;
    }

    List<CoordenadaComTimestamp> filtrado = [
      route.first
    ]; // Adicionar o primeiro ponto

    for (int i = 1; i < route.length; i++) {
      double velocidade = calcularVelocidade(route[i - 1], route[i]);

      // Apenas adicionar o ponto se a velocidade for >= 10 km/h
      if (velocidade >= 10) {
        filtrado.add(route[i]);
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

  String getCoordinatesString(Location location) {
    return '${location.latitude},${location.longitude}';
  }

  Map<String, String> getFirstAndLastCoordinates(List<Location> locations) {
    if (locations.isEmpty) {
      return {
        'first': '',
        'last': '',
      };
    }

    String firstLocation = getCoordinatesString(locations.first);
    String lastLocation = getCoordinatesString(locations.last);

    return {
      'first': firstLocation,
      'last': lastLocation,
    };
  }

  Future<double?> getDistanceWithMatrix(
      String origins, String destinations) async {
    const url =
        //'https://southamerica-east1-sombratestes.cloudfunctions.net/getDistance';
        'https://southamerica-east1-sombratestes.cloudfunctions.net/getDistance';

    try {
      final response = await Dio().post(url,
          options: Options(headers: {
            'Content-Type': 'application/json',
          }),
          data: {
            'origins': origins,
            'destinations': destinations,
          });

      if (response.statusCode == 200) {
        final data = response.data;
        final elements = data['rows'][0]['elements'][0];
        if (elements['status'] == 'OK') {
          final distance = elements['distance']['value']; // Distância em metros
          return distance / 1000; // Convertendo para quilômetros
        } else {
          debugPrint('Erro na resposta: ${elements['status']}');
          return null;
        }
      } else {
        debugPrint('Erro na requisição: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Erro na requisição: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> calcularDistanciaComFirebaseFunction(
      List<Location> locations) async {
    // const firebaseFunctionUrl =
    //     "https://southamerica-east1-sombratestes.cloudfunctions.net/getDistanceBetweenWaypoints";
    const firebaseFunctionUrl =
        "https://southamerica-east1-sombratestes.cloudfunctions.net/getDistanceAndPolylineBetweenWaypoints";
    //"http://127.0.0.1:5001/sombratestes/southamerica-east1/getDistanceAndPolylineBetweenWaypoints";
    // Verifica se a lista precisa ser dividida
    //if (locations.length <= 24) {
    // Se não precisar ser dividida, faz a requisição única com todas as localizações
    return await requestDistance2(firebaseFunctionUrl, locations);
    // } else {
    //   // Divide a lista em subconjuntos de no máximo 24 localizações (preservando o primeiro e o último ponto para continuidade)
    //   List<List<Location>> splitLocations = [];
    //   for (int i = 0; i < locations.length; i += 23) {
    //     int endRange = (i + 23 < locations.length) ? i + 23 : locations.length;
    //     splitLocations.add(locations.sublist(i, endRange));
    //   }

    //   double totalDistance = 0.0;
    //   for (var locationSubset in splitLocations) {
    //     double? distance = await requestDistance2(firebaseFunctionUrl, locationSubset);
    //     if (distance != null) {
    //       totalDistance += distance;
    //     } else {
    //       return null;
    //     }
    //   }
    //   return totalDistance;
    // }
  }

  // Future<double?> requestDistance(String url, List<Location> locations) async {
  //   final Dio dio = Dio();
  //   final String waypoints = generateWaypoints(locations);

  //   try {
  //     final response = await dio.get(
  //       url,
  //       queryParameters: {
  //         "origin": "${locations.first.latitude},${locations.first.longitude}",
  //         "destination":
  //             "${locations.last.latitude},${locations.last.longitude}",
  //         "waypoints": waypoints,
  //         "mode": "driving",
  //         "key": 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU',
  //         "language": "pt_BR"
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       int distanceInMeters = 0;
  //       for (var leg in data["routes"][0]["legs"]) {
  //         distanceInMeters += leg["distance"]["value"] as int;
  //       }
  //       return distanceInMeters / 1000.0; // Convertendo para quilômetros
  //     } else {
  //       debugPrint("Erro ao buscar a rota: Status code ${response.statusCode}");
  //       return null;
  //     }
  //   } catch (e) {
  //     debugPrint("Erro ao obter direções: $e");
  //     return null;
  //   }
  // }

  Future<Map<String, dynamic>?> requestDistance2(
      String url, List<Location> locations) async {
    final Dio dio = Dio();
    //final String waypoints = generateWaypoints(locations);
    //transformando a lista de locations em uma lista de strings para enviar para a função firebase
    // List<String> locationsString = [];

    // for (var location in locations) {
    //   locationsString.add("${location.latitude},${location.longitude}");
    // }

    // String waypoints = locationsString.join('|');

    // debugPrint('waypoints: $waypoints');

    //transformar as locations em json que será o 'waypoints' com uma lista de coordenadas
    List<Map<String, double>> waypoints = [];

    for (var location in locations) {
      waypoints.add({
        'latitude': location.latitude,
        'longitude': location.longitude,
      });
    }

    try {
      final response = await dio.post(url, data: {
        'waypoints': waypoints,
      });

      debugPrint('response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        // int distanceInMeters = 0;
        // for (var leg in data["routes"][0]["legs"]) {
        //   distanceInMeters += leg["distance"]["value"] as int;
        // }
        //converter String para double
        return data;
        //double.parse(data['totalDistanceKm']);
        //distanceInMeters / 1000.0; // Convertendo para quilômetros
      } else {
        debugPrint(
            "Erro ao buscar a rota2: Status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint(
          "Erro ao obter rota2: $e ------------ ${e.toString()} -------------- ");
      return null;
    }
  }

  Future<Map<String, dynamic>?> obterPontosComSnapToRoads(
      List<Location> locations) async {
    final Dio dio = Dio();

    const url =
        'https://southamerica-east1-sombratestes.cloudfunctions.net/obterPontos';
    //"http://127.0.0.1:5001/sombratestes/southamerica-east1/obterPontos";

    List<Map<String, double>> waypoints = [];

    for (var location in locations) {
      waypoints.add({
        'latitude': location.latitude,
        'longitude': location.longitude,
      });
    }

    debugPrint('waypoints: $waypoints');

    try {
      final response = await dio.post(url, data: {
        'path': waypoints,
      });

      debugPrint('response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        // int distanceInMeters = 0;
        // for (var leg in data["routes"][0]["legs"]) {
        //   distanceInMeters += leg["distance"]["value"] as int;
        // }
        //converter String para double
        return data;
        //double.parse(data['totalDistanceKm']);
        //distanceInMeters / 1000.0; // Convertendo para quilômetros
      } else {
        debugPrint(
            "Erro ao buscar a pontos: Status code ${response.statusCode}");
        return null;
      }
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      //return [];
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      //return [];
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      //return [];
    }
    return null;
  }

  //funcao com o package latlong2 para calcular a distancia de uma rota em km, somando um ponto ao próximo
  double calcularDistanciaComLatLong2(List<Location> locations) {
    double totalDistance = 0.0;

    for (int i = 0; i < locations.length - 1; i++) {
      totalDistance += const latlong.Distance().as(
        latlong.LengthUnit.Kilometer,
        latlong.LatLng(locations[i].latitude, locations[i].longitude),
        latlong.LatLng(locations[i + 1].latitude, locations[i + 1].longitude),
      );
    }

    debugPrint(' !!!!! totalDistance: $totalDistance !!!!!!');
    return totalDistance;
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

  void _onResetMissionDetails(
      ResetMissionDetails event, Emitter<MissionDetailsState> emit) {
    // Reseta o estado para o inicial
    emit(MissionDetailsInitial());
  }
}
