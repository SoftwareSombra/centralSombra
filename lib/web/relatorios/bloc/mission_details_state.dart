import 'package:google_static_maps_controller/google_static_maps_controller.dart';
import '../../../missao/model/missao_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

sealed class MissionDetailsState {}

final class MissionDetailsInitial extends MissionDetailsState {}

final class MissionDetailsLoading extends MissionDetailsState {}

final class MissionDetailsLoaded extends MissionDetailsState {
  final MissaoRelatorio missoes;
  final gmap.CameraPosition? initialPosition;
  final Set<gmap.Marker>? userMarkers;
  final Set<gmap.Polyline>? polylines;
  final gmap.LatLng? pontoInicial;
  final List<Location>? locations;
  final Location? middleLocation;
  final double? distancia;
  MissionDetailsLoaded(
      this.missoes,
      this.initialPosition,
      this.userMarkers,
      this.polylines,
      this.pontoInicial,
      this.locations,
      this.middleLocation,
      this.distancia);
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
