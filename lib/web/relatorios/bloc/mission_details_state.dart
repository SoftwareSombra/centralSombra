import 'package:google_static_maps_controller/google_static_maps_controller.dart';
import '../../../chat_view/src/models/message.dart';
import '../../../missao/model/missao_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../../home/screens/mapa_teste.dart';

sealed class MissionDetailsState {}

final class MissionDetailsInitial extends MissionDetailsState {}

final class MissionDetailsLoading extends MissionDetailsState {}

final class MissionDetailsLoaded extends MissionDetailsState {
  final MissaoRelatorio missao;
  final gmap.CameraPosition? initialPosition;
  final Set<gmap.Marker>? userMarkers;
  final Set<gmap.Polyline>? polylines;
  final gmap.LatLng? pontoInicial;
  final List<CoordenadaComTimestamp>? locations;
  final Location? middleLocation;
  final double? distancia;
  final double? distanciaIda;
  final double? distanciaVolta;
  List<Message>? messages;
  Foto? odometroInicial;
  Foto? odometroFinal;
  MissionDetailsLoaded(
      this.missao,
      this.initialPosition,
      this.userMarkers,
      this.polylines,
      this.pontoInicial,
      this.locations,
      this.middleLocation,
      this.distancia,
      this.distanciaIda,
      this.distanciaVolta,
      this.messages,
      this.odometroInicial,
      this.odometroFinal);
}

final class MissionDetailsNoRouteFound extends MissionDetailsState {}

final class RelatorioNaoEncontrado extends MissionDetailsState {
  final String message;
  RelatorioNaoEncontrado(this.message);
}

final class MissionDetailsError extends MissionDetailsState {
  final String message;
  MissionDetailsError(this.message);
}
