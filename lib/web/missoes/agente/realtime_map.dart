import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../autenticacao/services/user_services.dart';

class RealTimeMapScreen extends StatefulWidget {
  final String missaoId;
  final double missaoLatitude;
  final double missaoLongitude;
  const RealTimeMapScreen(
      {super.key,
      required this.missaoId,
      required this.missaoLatitude,
      required this.missaoLongitude});

  @override
  State<RealTimeMapScreen> createState() => _RealTimeMapScreenState();
}

class _RealTimeMapScreenState extends State<RealTimeMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Set<Marker> _markers = {};
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> positionStream;
  BitmapDescriptor? icon;
  // ignore: unused_field
  Uint8List? _userIcon;
  UserServices userServices = UserServices();

  @override
  void initState() {
    super.initState();
    _loadPhotoBytes();
    //_addMissionLocationMarker();
    _updateMap();
    getIcon();
  }

  // void _addMissionLocationMarker() {
  //   final missionMarker = Marker(
  //     markerId: const MarkerId('mission_location'),
  //     position: LatLng(widget.missaoLatitude, widget.missaoLongitude),
  //     infoWindow: const InfoWindow(
  //       title: 'Local da Missão',
  //       snippet: 'Local fixo da missão',
  //     ),
  //     icon: BitmapDescriptor.defaultMarker, // Ou outro ícone personalizado
  //   );

  //   // Como estamos modificando o estado antes de o widget ser construído, verifique se o contexto existe

  //   setState(() {
  //     _markers.add(missionMarker);
  //   });
  // }

  Future<void> getIcon() async {
    final icon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/images/escudo.png');
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

  void _updateMap() {
    positionStream = _firestore
        .collection('Rotas')
        .doc(widget.missaoId)
        .collection('Rota')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) async {
        final GoogleMapController controller = await _controller.future;
        if (snapshot.docs.isNotEmpty) {
          var data = snapshot.docs.first.data();
          final Timestamp timestamp = data['timestamp'];
          final DateTime dateTime = timestamp.toDate();

          final formattedDate =
              DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);

          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(data['latitude'], data['longitude']),
                zoom: 12.0,
              ),
            ),
          );
          setState(() {
            // Adicionando um marcador para a nova localização
            var agentMarker = Marker(
              icon: icon ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: 'Agente Sombra',
                snippet: 'Att em: $formattedDate',
                // onTap: () {
                //   debugPrint('Marker tapped');
                // },
              ),
              markerId: const MarkerId('current_location'),
              position: LatLng(data['latitude'], data['longitude']),
            );
            var missionMarker = Marker(
              infoWindow: const InfoWindow(title: 'Local da Missão'),
                markerId: const MarkerId('mission_location'),
                position:
                    LatLng(widget.missaoLatitude, widget.missaoLongitude));
            _markers.clear();
            _markers.add(missionMarker);
            _markers.add(agentMarker);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posição do agente'),
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 2.0,
        ),
        markers: _markers,
      ),
    );
  }
}
