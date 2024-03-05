import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sombra_testes/autenticacao/screens/tratamento/error_snackbar.dart';
import 'package:sombra_testes/missao/screens/criar_missao_screen.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import 'package:sombra_testes/widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import '../../missao/bloc/agente/agente_bloc.dart';
import '../../missao/bloc/agente/events.dart';
import '../../missao/bloc/agente/states.dart';
import '../../missao/model/missao_model.dart';
import '../../missao/screens/missao_screen.dart';
import '../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import '../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class SearchScreen extends StatefulWidget {
  final bool? missaoFinalizada;

  const SearchScreen({super.key, this.missaoFinalizada});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //final _endSearchFieldController = TextEditingController();
  String? currentFocusedField;
  MissaoServices missaoServices = MissaoServices();
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  List<AutocompletePrediction>? predictions;
  //Timer? _debounce;
  Place? selectedStartLocation;
  Place? selectedEndLocation;
  gmap.LatLng? currentLocation;
  final googlePlace =
      FlutterGooglePlacesSdk('AIzaSyBGozAuPStyTlmF22-zku_I-8gcX3EMfm4');
  late Future<bool> emMissao;
  late Future<Missao?> missionData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (context.mounted) {
        context.read<AgentMissionBloc>().add(FetchMission());
      }
      await getCurrentLocation();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      emMissao = missaoServices.emMissao(uid);
      missionData = missaoServices.fetchMissionData(uid);
    });
  }

  Future<void> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // Atualizando selectedStartLocation com a currentLocation
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
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid;
    final userName = user?.displayName;
    debugPrint('----------- tela criada --------------');

    return
        // Scaffold(
        //   backgroundColor: const Color.fromARGB(255, 14, 14, 14),
        //   resizeToAvoidBottomInset: false,
        //   appBar: AppBar(
        //     //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        //     title: const Text('Missão'),
        //     centerTitle: true,
        //   ),
        //   body:
        BlocBuilder<AgentMissionBloc, AgentState>(
      builder: (context, state) {
        if (state is FetchMissionLoading || state is LoadingAgentState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is IsNotAgent) {
          return Scaffold(
            backgroundColor: Color.fromARGB(255, 14, 14, 14),
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
              title: const Text(
                'MISSÃO',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
              ),
              centerTitle: true,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.red,
                  ),
                  Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'Você não é um agente, portanto não pode iniciar missões',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is Available) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 14, 14, 14),
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
              title: const Text('Missão'),
              centerTitle: true,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: 50,
                    color: Colors.yellow,
                  ),
                  Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'Você não está em missão no momento, mas fique atento e '
                      'mantenha seu status atualizado!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is MissaoNaoIniciada) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 14, 14, 14),
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
              title: const Text('Missão'),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning_amber_outlined,
                    size: 50,
                    color: Colors.yellow,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        top: 5, bottom: 25, left: 30, right: 30),
                    child: Text(
                      'Você está em missão, inicie-a!',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
                    builder: (context, buttonState) {
                      if (buttonState is ElevatedButtonBlocLoading) {
                        return const CircularProgressIndicator();
                      } else {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () async {
                            //enviar foto do odometro antes de iniciar a missão
                            // showDialog(
                            //     context: context,
                            //     builder: (context) {
                            //       return AlertDialog(
                            //         title: const Text('Odômetro'),
                            //         content: Column(
                            //           mainAxisSize: MainAxisSize.min,
                            //           children: [
                            //             const Text('Tire uma foto do odômetro'),
                            //             const SizedBox(height: 10),
                            //             ElevatedButton(
                            //               onPressed: () async {
                            //                 ImagePicker picker = ImagePicker();
                            //                 final XFile? image =
                            //                     await picker.pickImage(
                            //                         source: ImageSource.camera);

                            //                 if (image != null) {
                            //                   final imageBase64 =
                            //                       await missaoServices
                            //                           .imageToBase64(
                            //                               image.path);
                            //                   await missaoServices
                            //                       .enviarFotoRelatorio(
                            //                           state.uid,
                            //                           state.missaoId,
                            //                           imageBase64,
                            //                           'Odometro inicial');
                            //                   mensagemDeSucesso
                            //                       .showSuccessSnackbar(context,
                            //                           'Foto enviada com sucesso');
                            //                   Navigator.pop(context);
                            //                 }
                            //               },
                            //               child: const Text('Tirar foto'),
                            //             ),
                            //           ],
                            //         ),
                            //         actions: [
                            //           TextButton(
                            //             onPressed: () {
                            //               Navigator.pop(context);
                            //             },
                            //             child: const Text('Cancelar'),
                            //           ),
                            //         ],
                            //       );
                            //     });
                            context
                                .read<ElevatedButtonBloc>()
                                .add(ElevatedButtonPressed());
                            await missaoServices.iniciarMissaoCache(
                                state.uid,
                                state.missaoId,
                                state.currentLocation.latitude,
                                state.currentLocation.longitude,
                                state.local,
                                state.placaCavalo,
                                state.placaCarreta,
                                state.motorista,
                                state.corVeiculo,
                                state.tipo);
                            final sucesso = await missaoServices.iniciarMissao(
                                state.uid,
                                state.missaoId,
                                state.currentLocation);
                            if (context.mounted) {
                              context.read<ElevatedButtonBloc>().add(
                                    ElevatedButtonActionCompleted(),
                                  );
                            }
                            if (sucesso) {
                              if (context.mounted) {
                                context.read<AgentMissionBloc>().add(
                                      FetchMission(),
                                    );
                              }
                            } else {
                              if (context.mounted) {
                                tratamentoDeErros.showErrorSnackbar(context,
                                    'Erro ao iniciar missão, tente novamente');
                              }
                            }
                          },
                          child: const Text(
                            'Iniciar missão',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w400),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        } else if (state is OnMission) {
          Missao missionDetails = state.missionDetails;

          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 14, 14, 14),
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.transparent,
                    ),
                    onPressed: () {},
                  ),
                  const Text(
                    'MISSÃO',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.black,
                            title: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'DETALHES',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Placa cavalo: ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      missionDetails.placaCavalo == ''
                                          ? ' - '
                                          : missionDetails.placaCavalo!,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Placa carreta: ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      missionDetails.placaCarreta == ''
                                          ? ' - '
                                          : missionDetails.placaCarreta!,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Motorista: ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      missionDetails.motorista == ''
                                          ? ' - '
                                          : missionDetails.motorista!,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Cor do veículo: ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      missionDetails.corVeiculo == ''
                                          ? ' - '
                                          : missionDetails.corVeiculo!,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Fechar',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
            body: MissaoScreen(
              missao: missionDetails,
              startPosition: gmap.LatLng(selectedStartLocation!.latLng!.lat,
                  selectedStartLocation!.latLng!.lng),
              userUid: userUid!,
              userName: userName!,
            ),
          );

          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Center(
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         const Text('Missão em andamento'),
          //         const SizedBox(height: 25),
          //         ElevatedButton(
          //           onPressed: () {
          //             if (selectedStartLocation != null) {
          //               Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                   builder: (context) => MapScreen(
          //                     cnpj: missionDetails.cnpj,
          //                     nomeDaEmpresa: missionDetails.nomeDaEmpresa,
          //                     placaCavalo: missionDetails.placaCavalo,
          //                     placaCarreta: missionDetails.placaCarreta,
          //                     motorista: missionDetails.motorista,
          //                     corVeiculo: missionDetails.corVeiculo,
          //                     observacao: missionDetails.observacao,
          //                     startPosition: LatLng(
          //                         lat: selectedStartLocation!.latLng!.lat,
          //                         lng: selectedStartLocation!.latLng!.lng),
          //                     endPosition: LatLng(
          //                         lat: missionDetails.missaoLatitude,
          //                         lng: missionDetails.missaoLongitude),
          //                     missaoId: missionDetails.missaoId,
          //                     tipo: missionDetails.tipo,
          //                     inicio: missionDetails.inicio,
          //                   ),
          //                 ),
          //               );
          //             }
          //           },
          //           child: const Text("Ir para o Mapa"),
          //         )
          //       ],
          //     ),
          //   ),
          // );
        } else {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text('Erro ao tentar buscar missões, recarregue a tela'),
              ),
            ],
          );
        }
      },
    );
  }
}
