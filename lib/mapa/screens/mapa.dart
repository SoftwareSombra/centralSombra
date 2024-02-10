import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sombra_testes/autenticacao/screens/tratamento/error_snackbar.dart';
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: BlocBuilder<AgentMissionBloc, AgentState>(
          builder: (context, state) {
            if (state is FetchMissionLoading || state is LoadingAgentState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is Available) {
              return const Center(child: Text('Não está em missão'));
            } else if (state is MissaoNaoIniciada) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Você está em missão, inicie-a!'),
                    const SizedBox(
                      height: 15,
                    ),
                    BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
                      builder: (context, buttonState) {
                        if (buttonState is ElevatedButtonBlocLoading) {
                          return const CircularProgressIndicator();
                        } else {
                          return ElevatedButton(
                            onPressed: () async {
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
                              final sucesso =
                                  await missaoServices.iniciarMissao(state.uid,
                                      state.missaoId, state.currentLocation);
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
                            child: const Text('Iniciar missão'),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            } else if (state is OnMission) {
              Missao missionDetails = state.missionDetails;

              return MissaoScreen(
                missao: missionDetails,
                startPosition: gmap.LatLng(selectedStartLocation!.latLng!.lat,
                    selectedStartLocation!.latLng!.lng),
                userUid: userUid!,
                userName: userName!,
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
                    child: Text(
                        'Erro ao tentar buscar missões, recarregue a tela'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
