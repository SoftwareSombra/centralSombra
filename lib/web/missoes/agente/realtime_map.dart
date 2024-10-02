import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../autenticacao/services/user_services.dart';
import '../../../missao/services/missao_services.dart';
import '../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';

class RealTimeMapScreen extends StatefulWidget {
  final String missaoId;
  final double missaoLatitude;
  final double missaoLongitude;
  final Map<String, dynamic> missionData;
  const RealTimeMapScreen(
      {super.key,
      required this.missaoId,
      required this.missaoLatitude,
      required this.missaoLongitude,
      required this.missionData});

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
  MissaoServices missaoServices = MissaoServices();
  double? newLat;
  double? newLng;
  MensagemDeSucesso msgDeSucesso = MensagemDeSucesso();
  TratamentoDeErros tratamento = TratamentoDeErros();

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
            newLat = data['latitude'];
            newLng = data['longitude'];
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

  void encerrarMissaoDialog() {
    showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: const Text('Atenção'),
            content: const Text('Deseja realmente encerrar a missão?'),
            actions: [
              BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
                builder: (context, state) {
                  if (state is ElevatedButtonBlocLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            context
                                .read<ElevatedButtonBloc>()
                                .add(ElevatedButtonPressed());
                            debugPrint(widget.missionData.toString());

                            // final initialCordinates =
                            //    await missaoServices.getPrimeiroPontoRota(
                            //         widget.missionData['missaoID']);

                            bool sucesso =
                                await missaoServices.forcarEncerrarMissao(
                              widget.missionData['cnpj'],
                              widget.missionData['nome da empresa'],
                              widget.missionData['placaCavalo'],
                              widget.missionData['placaCarreta'],
                              widget.missionData['motorista'],
                              widget.missionData['corVeiculo'],
                              widget.missionData['observacao'],
                              widget.missionData['agenteUid'],
                              widget.missionData['userLatitude'],
                              widget.missionData['userLongitude'],
                              //widget.data['userFinalLatitude'],
                              //widget.data['userFinalLongitude'],
                              newLat ?? 0,
                              newLng ?? 0,
                              widget.missionData['missaoLatitude'],
                              widget.missionData['missaoLongitude'],
                              widget.missionData['tipo'],
                              widget.missionData['missaoID'],
                              widget.missionData['local'],
                              widget.missionData['nome'] ?? 'Não informado',
                            );
                            if (sucesso && context.mounted) {
                              context
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonActionCompleted());
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              msgDeSucesso.showSuccessSnackbar(
                                  context, 'Missão finalizada com sucesso');
                              //BlocProvider.of<>(context).add(());
                            } else if (!sucesso && context.mounted) {
                              context
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonActionCompleted());
                              tratamento.showErrorSnackbar(
                                  context, 'Erro, tente novamente');
                            }
                          },
                          child: const Text('Sim'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          )),
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
        title: const Text(
          'POSIÇÃO DO AGENTE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  encerrarMissaoDialog();
                },
                child: const Text(
                  'Encerrar missão',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
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
