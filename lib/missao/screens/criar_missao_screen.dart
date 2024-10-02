
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:intl/intl.dart' as intl;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:sombra/agente/model/agente_model.dart';
import 'package:sombra/autenticacao/screens/tratamento/error_snackbar.dart';
import 'package:sombra/autenticacao/screens/tratamento/success_snackbar.dart';
import 'package:sombra/mapa/services/mapa_services.dart';
import 'package:sombra/missao/model/missao_solicitada.dart';
import 'package:sombra/missao/services/missao_services.dart';
import 'dart:ui' as ui;
import '../../../agente/services/agente_services.dart';
import '../../../autenticacao/services/user_services.dart';
import 'dart:math';
import '../../notificacoes/fcm.dart';
import '../../notificacoes/notificacoess.dart';
import '../../web/admin/services/admin_services.dart';
import '../../web/empresa/model/empresa_model.dart';
import '../../web/empresa/services/empresa_services.dart';
import '../../web/missoes/criar_missao/screens/components/solicitacao_card.dart';
import '../../widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import '../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import '../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';
import '../../widgets_comuns/elevated_button/elevated_button_2/elevated_button_bloc.dart';
import '../../widgets_comuns/elevated_button/elevated_button_2/elevated_button_bloc_event.dart';
import '../../widgets_comuns/elevated_button/elevated_button_2/elevated_button_bloc_state.dart';
import '../../widgets_comuns/elevated_button/elevated_button_bloc_3/elevated_button_bloc.dart';
import '../../widgets_comuns/elevated_button/elevated_button_bloc_3/elevated_button_bloc_event.dart';
import '../../widgets_comuns/elevated_button/elevated_button_bloc_3/elevated_button_bloc_state.dart';
import '../bloc/missao_solicitacao_card/missao_solicitacao_card_bloc.dart';
import '../bloc/missao_solicitacao_card/missao_solicitacao_card_event.dart';
import '../bloc/missao_solicitacao_card/missao_solicitacao_card_state.dart';
import '../bloc/missoes_pendentes/missoes_pendentes_bloc.dart';
import '../bloc/missoes_pendentes/missoes_pendentes_event.dart';
import '../bloc/missoes_solicitadas/missoes_solicitadas_bloc.dart';
import '../bloc/missoes_solicitadas/missoes_solicitadas_event.dart';
import '../bloc/missoes_solicitadas/missoes_solicitadas_state.dart';
import 'components/dialog_mission_details.dart';

class CriarMissaoScreen extends StatefulWidget {
  final String cargo;
  final String nome;
  const CriarMissaoScreen({super.key, required this.cargo, required this.nome});

  @override
  State<CriarMissaoScreen> createState() => _CriarMissaoScreenState();
}

enum ActiveField { start, end, mission, cnpj }

const canvasColor = Color.fromARGB(255, 0, 15, 42);

class _CriarMissaoScreenState extends State<CriarMissaoScreen> {
  AdminServices adminServices = AdminServices();
  FirebaseAuth auth = FirebaseAuth.instance;
  gmap.GoogleMapController? mapController;
  //String funcao = 'carregando...';
  //String nome = 'carregando...';
  TextEditingController searchController = TextEditingController();
  List<MissaoSolicitada> missoesSolicitadas = [];
  final places = FlutterGooglePlacesSdk(
    'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU',
    locale: const Locale('pt', 'BR'),
  );
  List<AutocompletePrediction>? _predictions;
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  // Place? startPosition;
  // Place? endPosition;
  final _missionController = TextEditingController();
  Place? missionPosition;
  String? _selectedPlaceId;
  //NotTesteService notTesteService = NotTesteService();
  String _botao = 'localizacao';
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();
  MissaoServices missaoServices = MissaoServices();
  String? _selectedOption;
  bool _isButtonEnabled = false;
  bool _isButtonAdressEnabled = false;
  bool _isButtonCoordenadasEnabled = false;
  bool _isButtonMapEnabled = false;
  ActiveField? _activeField;
  Timer? _debounce;
  final TextEditingController placaCavaloController = TextEditingController();
  final TextEditingController placaCarretaController = TextEditingController();
  final TextEditingController motoristaController = TextEditingController();
  final TextEditingController corController = TextEditingController();
  final TextEditingController observacaoController = TextEditingController();
  final TextEditingController cnpjController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  double? _selectedLatitude;
  double? _selectedLongitude;
  ValueNotifier<bool> isPlacaCavaloNotEmpty = ValueNotifier(false);
  ValueNotifier<bool> isMotoristaNotEmpty = ValueNotifier(false);
  GlobalKey<FormState> formPlacasKey = GlobalKey<FormState>();
  bool preservacaoIsChecked = false;
  bool acompanhamentoIsChecked = false;
  bool varreduraIsChecked = false;
  bool averiguacaoIsChecked = false;
  String? uid;
  final EmpresaServices empresaServices = EmpresaServices();

  @override
  void initState() {
    //nome = auth.currentUser!.displayName!;
    context.read<MissoesSolicitadasBloc>().add(BuscarMissoes());
    _updateButtonState();

    cnpjController.addListener(() {
      _updateButtonState();
    });

    _startController.addListener(() {
      _onTextChanged(_startController, ActiveField.start);
    });

    _endController.addListener(() {
      _onTextChanged(_endController, ActiveField.end);
    });

    _missionController.addListener(() {
      _onTextChanged(_missionController, ActiveField.mission);
    });
    //buscarFuncao();
    super.initState();
  }

  void _updateButtonState() async {
    bool cnpjField = cnpjController.text.isNotEmpty;
    //.length == 14;
    bool latField = latController.text.isNotEmpty;
    bool lngField = lngController.text.isNotEmpty;
    bool latLngField = latField && lngField;
    bool selectedlat = _selectedLatitude != null;
    bool selectedlng = _selectedLongitude != null;
    bool selectedlatLng = selectedlat && selectedlng;

    setState(() {
      _isButtonEnabled = _selectedOption != null;
      _isButtonAdressEnabled =
          missionPosition != null && _isButtonEnabled && cnpjField;
      _isButtonCoordenadasEnabled =
          latLngField && _isButtonEnabled && cnpjField;
      _isButtonMapEnabled = selectedlatLng && _isButtonEnabled && cnpjField;
    });
  }

  bool isValidPlaca(String placa) {
    if (placa.length == 7) {
      return true;
    } else {
      return false;
    }
  }

  void _onTextChanged(
      TextEditingController controller, ActiveField activeField) {
    if (controller.text.isEmpty) {
      setState(() {
        _predictions = null;
        // Aqui você reseta o estado da seleção do endereço, se houver.
        // Por exemplo:
        if (activeField == ActiveField.mission) {
          _selectedPlaceId = null; // Resetar o ID do lugar selecionado
          missionPosition = null; // Resetar a posição da missão se necessário
        }
        // Faça o mesmo para _startController e _endController se necessário.
        _updateButtonState();
      });
      return;
    }

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      performSearch(controller.text, activeField);
    });
  }

  void onSelectedOptionChanged(String? value) {
    setState(() {
      _selectedOption = value;
      _updateButtonState();
    });
  }

  performSearch(String query, ActiveField activeField) async {
    if (query.isNotEmpty) {
      final result = await places.findAutocompletePredictions(query);

      if (result.predictions.isNotEmpty) {
        setState(() {
          _predictions = result.predictions;
          _activeField = activeField;
        });
      } else {
        setState(() {
          _predictions = [];
        });
      }
    }
  }

  void _handleTap(gmap.LatLng tappedPoint) {
    debugPrint(
        "Coordenadas: ${tappedPoint.latitude}, ${tappedPoint.longitude}");
    setState(() {
      _selectedLatitude = tappedPoint.latitude;
      _selectedLongitude = tappedPoint.longitude;
      markers = {};
      markers.add(
        gmap.Marker(
          markerId: gmap.MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          infoWindow: gmap.InfoWindow(
              title:
                  'Lat: ${tappedPoint.latitude}, Lng: ${tappedPoint.longitude}'),
        ),
      );
      _updateButtonState();
    });
  }

  Set<gmap.Marker> markers = {};

  @override
  void dispose() {
    cnpjController.removeListener(() {
      setState(() {});
    });

    cnpjController.dispose();

    _startController.removeListener(() {
      _onTextChanged(_startController, ActiveField.start);
    });
    _startController.dispose();

    _endController.removeListener(() {
      _onTextChanged(_endController, ActiveField.end);
    });
    _endController.dispose();

    _missionController.removeListener(() {
      _onTextChanged(_missionController, ActiveField.mission);
    });
    _missionController.dispose();

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    super.dispose();
  }

  // Future<void> buscarFuncao() async {
  //   final getFunction = await adminServices.getUserRole();
  //   setState(() {
  //     funcao = getFunction;
  //   });
  // }

  List<MissaoSolicitada> filtrarRelatorios(
      List<MissaoSolicitada> missoesSolicitadas, String searchText) {
    searchText = searchText.toLowerCase();
    return missoesSolicitadas.where((missoesSolicitadas) {
      return missoesSolicitadas.missaoId.toLowerCase().contains(searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        //title: const Text('Solicitações de Missão'),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<MissoesSolicitadasBloc, MissoesSolicitadasState>(
          builder: (context, state) {
            if (state is MissoesSolicitadasLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MissoesSolicitadasEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                child: ExpansionTile(
                  collapsedBackgroundColor: canvasColor.withOpacity(0.4),
                  initiallyExpanded: false,
                  //cor do icone
                  collapsedIconColor: Colors.grey[300],
                  //cor do texto
                  collapsedTextColor: Colors.white,
                  //backgroundColor: canvasColor.withOpacity(0.4),
                  backgroundColor: canvasColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),

                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          //color: canvasColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: const Text(
                          'CRIAR SOLICITAÇÃO',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          _buttonsNav(),
                          const SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio<String>(
                                  value: 'Preservação',
                                  groupValue: _selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value;
                                      _updateButtonState();
                                    });
                                  },
                                ),
                                const Text('Preservação'),
                                const SizedBox(width: 10),
                                Radio<String>(
                                  value: 'Acompanhamento',
                                  groupValue: _selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value;
                                      _updateButtonState();
                                    });
                                  },
                                ),
                                const Text('Acompanhamento'),
                                Radio<String>(
                                  value: 'Varredura',
                                  groupValue: _selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value;
                                      _updateButtonState();
                                    });
                                  },
                                ),
                                const Text('Varredura'),
                                Radio<String>(
                                  value: 'Averiguação',
                                  groupValue: _selectedOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOption = value;
                                      _updateButtonState();
                                    });
                                  },
                                ),
                                const Text('Averiguação'),
                              ],
                            ),
                          ),
                          ResponsiveRowColumn(
                            layout: ResponsiveRowColumnType.COLUMN,
                            children: [
                              ResponsiveRowColumnItem(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.055, vertical: 0),
                                  child: Container(
                                      height: 150,
                                      constraints: const BoxConstraints(
                                          maxWidth: 600, maxHeight: 300),
                                      child: SearchableList<Empresa>.async(
                                        onPaginate: () async {},
                                        itemBuilder: (Empresa empresa) =>
                                            MouseRegion(
                                          cursor:
                                              WidgetStateMouseCursor.clickable,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                cnpjController.text =
                                                    empresa.cnpj;
                                              });
                                            },
                                            child: ActorItem(empresa: empresa),
                                          ),
                                        ),
                                        loadingWidget:
                                            //const SizedBox.shrink(),
                                            const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Text('Buscando empresas...')
                                          ],
                                        ),
                                        errorWidget: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error,
                                              color: Colors.red,
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text('Error ao buscar empresas')
                                          ],
                                        ),
                                        asyncListCallback: () async {
                                          List<Empresa> empresas =
                                              await empresaServices
                                                  .getAllEmpresas();
                                          return empresas;
                                        },
                                        asyncListFilter: (q, list) {
                                          List<Empresa> geral = [];
                                          List<Empresa> nome = list
                                              .where((element) => element
                                                  .nomeEmpresa
                                                  .contains(q))
                                              .toList();
                                          List<Empresa> cnpj = list
                                              .where((element) =>
                                                  element.cnpj.contains(q))
                                              .toList();
                                          geral.addAll(nome);
                                          cnpjController.text.isNotEmpty
                                              ? geral.addAll(cnpj)
                                              : null;
                                          return geral;
                                        },
                                        searchTextController: cnpjController,
                                        emptyWidget: const EmptyView(),
                                        onRefresh: () async {},
                                        // onItemSelected: (Empresa item) {
                                        //   setState(() {
                                        //     cnpjController.text = item.cnpj;
                                        //   });
                                        // },
                                        inputDecoration: const InputDecoration(
                                          labelText: 'Nome ou cnpj do cliente',
                                          labelStyle: TextStyle(
                                              fontSize: 13, color: Colors.grey),
                                          //suffixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                      )
                                      // TextFormField(
                                      //   inputFormatters: <TextInputFormatter>[
                                      //     //FilteringTextInputFormatter.digitsOnly,
                                      //     //limite de caracteres
                                      //     LengthLimitingTextInputFormatter(14),
                                      //   ],
                                      //   cursorHeight: 17,
                                      //   //focusNode: _focusNode,
                                      //   controller: cnpjController,
                                      //   //style: TextStyle(color: Colors.grey[200]),
                                      //   decoration: const InputDecoration(
                                      //     labelText: 'CNPJ do cliente',
                                      //     labelStyle: TextStyle(
                                      //         fontSize: 13, color: Colors.grey),
                                      //     suffixIcon: Icon(Icons.search),
                                      //     border: OutlineInputBorder(
                                      //       borderSide:
                                      //           BorderSide(color: Colors.grey),
                                      //     ),
                                      //     enabledBorder: OutlineInputBorder(
                                      //       borderSide:
                                      //           BorderSide(color: Colors.grey),
                                      //     ),
                                      //     focusedBorder: OutlineInputBorder(
                                      //       borderSide:
                                      //           BorderSide(color: Colors.grey),
                                      //     ),
                                      //   ),
                                      // ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _botao == 'localizacao'
                              ? ResponsiveRowColumn(
                                  layout: ResponsiveRowColumnType.COLUMN,
                                  children: [
                                    ResponsiveRowColumnItem(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.055,
                                            vertical: 0),
                                        child: Container(
                                          height: 55,
                                          constraints: const BoxConstraints(
                                              maxWidth: 600),
                                          child: TextField(
                                            //cursorHeight: 15,
                                            focusNode: _focusNode,
                                            controller: _missionController,
                                            //style: TextStyle(color: Colors.grey[200]),
                                            decoration: const InputDecoration(
                                              labelText: 'Local da missão',
                                              labelStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey),
                                              suffixIcon: Icon(Icons.search),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                   
                                    if (_focusNode.hasFocus &&
                                        _predictions != null &&
                                        _predictions!.isNotEmpty)
                                      ResponsiveRowColumnItem(
                                        child: SizedBox(
                                          height: 250,
                                          //width: width * 0.7,
                                          //child: Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.055,
                                                vertical: 15),
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 600),
                                              child: SizedBox(
                                                //width: width * 0.7,
                                                height: 260,
                                                child: ListView.builder(
                                                  itemCount:
                                                      _predictions!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final prediction =
                                                        _predictions![index];
                                                    bool isSelected =
                                                        prediction.placeId ==
                                                            _selectedPlaceId;
                                                    return ListTile(
                                                        title: Text(prediction
                                                            .fullText),
                                                        trailing: isSelected
                                                            ? const Icon(
                                                                Icons.check)
                                                            : null,
                                                        onTap: () async {
                                                          final fields = [
                                                            PlaceField.Name,
                                                            PlaceField.Address,
                                                            PlaceField
                                                                .Location, // Alterado de Location para LatLng
                                                          ];

                                                          final response =
                                                              await places
                                                                  .fetchPlace(
                                                                      prediction
                                                                          .placeId,
                                                                      fields:
                                                                          fields);
                                                          Place? details =
                                                              response.place;

                                                          setState(() {
                                                            _selectedPlaceId =
                                                                prediction
                                                                    .placeId;
                                                            if (_activeField ==
                                                                ActiveField
                                                                    .mission) {
                                                              missionPosition =
                                                                  details;
                                                              _missionController
                                                                      .text =
                                                                  details!
                                                                      .address!;
                                                              _missionController
                                                                      .selection =
                                                                  TextSelection
                                                                      .fromPosition(
                                                                TextPosition(
                                                                    offset: _missionController
                                                                        .text
                                                                        .length),
                                                              );
                                                            }

                                                            debugPrint(
                                                                missionPosition
                                                                    .toString()); // Adicionando o log para o missionPosition
                                                            _predictions = null;
                                                            _updateButtonState();
                                                          });
                                                        });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ResponsiveRowColumnItem(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 10,
                                            right: width * 0.055,
                                            left: width * 0.055,
                                            bottom: height * 0.0),
                                        child: Form(
                                          key: formPlacasKey,
                                          child: ResponsiveRowColumn(
                                            layout: ResponsiveBreakpoints.of(
                                                        context)
                                                    .smallerThan(DESKTOP)
                                                ? ResponsiveRowColumnType.COLUMN
                                                : ResponsiveRowColumnType.ROW,
                                            rowMainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ResponsiveRowColumnItem(
                                                child: Container(
                                                  height: 50,
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 200,
                                                          minWidth: 90),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width * 0.001,
                                                            vertical: 5),
                                                    child: SizedBox(
                                                      width: width * 0.33,
                                                      child: TextFormField(
                                                        cursorHeight: 14,
                                                        validator: (value) {
                                                          if (value != null &&
                                                              value
                                                                  .isNotEmpty) {
                                                            if (!isValidPlaca(value
                                                                .toUpperCase())) {
                                                              return 'Placa inválida';
                                                            }
                                                          }
                                                          return null;
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                          label: Text(
                                                              'Placa cavalo'),
                                                          labelStyle: TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.grey),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                        ),
                                                        controller:
                                                            placaCavaloController,
                                                        onChanged: (value) {
                                                          // Update the button state
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ResponsiveRowColumnItem(
                                                child: Container(
                                                  height: 50,
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 200,
                                                          minWidth: 60),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width * 0.01,
                                                            vertical: 5),
                                                    child: SizedBox(
                                                      width: width * 0.33,
                                                      child: TextFormField(
                                                        cursorHeight: 14,
                                                        validator: (value) {
                                                          if (value != null &&
                                                              value
                                                                  .isNotEmpty) {
                                                            if (!isValidPlaca(value
                                                                .toUpperCase())) {
                                                              return 'Placa inválida';
                                                            }
                                                          }
                                                          return null;
                                                        },
                                                        controller:
                                                            placaCarretaController,
                                                        onChanged: (value) {
                                                          // Update the button state
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                          label: Text(
                                                              'Placa carreta'),
                                                          labelStyle: TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.grey),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ResponsiveRowColumnItem(
                                                child: Container(
                                                  height: 50,
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 200,
                                                          minWidth: 100),
                                                  child: CustomTextFormField(
                                                    controller: corController,
                                                    label: 'Cor',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    ResponsiveRowColumnItem(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 0,
                                            right: width * 0.057,
                                            left: width * 0.059,
                                            bottom: 20),
                                        child: ResponsiveRowColumn(
                                          layout:
                                              ResponsiveBreakpoints.of(context)
                                                      .smallerThan(DESKTOP)
                                                  ? ResponsiveRowColumnType
                                                      .COLUMN
                                                  : ResponsiveRowColumnType.ROW,
                                          rowMainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ResponsiveRowColumnItem(
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 295,
                                                        minWidth: 100),
                                                child: CustomTextFormField(
                                                    controller:
                                                        motoristaController,
                                                    label: 'Motorista'),
                                              ),
                                            ),
                                            const ResponsiveRowColumnItem(
                                              child: SizedBox(
                                                width: 10,
                                              ),
                                            ),
                                            ResponsiveRowColumnItem(
                                              child: Container(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 295,
                                                        minWidth: 100),
                                                child: CustomTextFormField(
                                                  controller:
                                                      observacaoController,
                                                  label: 'Observação',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // ResponsiveRowColumnItem(
                                    //   child: Padding(
                                    //     padding: EdgeInsets.only(
                                    //         top: 0,
                                    //         right: width * 0.045,
                                    //         left: width * 0.045,
                                    //         bottom: height * 0.05),
                                    //     child: ResponsiveRowColumn(
                                    //       layout: ResponsiveBreakpoints
                                    //                   .of(context)
                                    //               .smallerThan(
                                    //                   DESKTOP)
                                    //           ? ResponsiveRowColumnType
                                    //               .COLUMN
                                    //           : ResponsiveRowColumnType
                                    //               .ROW,
                                    //       rowMainAxisAlignment:
                                    //           MainAxisAlignment
                                    //               .center,
                                    //       children: [
                                    //         ResponsiveRowColumnItem(
                                    //           child: CustomTextFormField(
                                    //               controller:
                                    //                   observacaoController,
                                    //               label:
                                    //                   'Observação'),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                    ResponsiveRowColumnItem(
                                      child: ElevatedButton(
                                        onPressed: (_isButtonAdressEnabled)
                                            ? () async {
                                                //verificar validador do form
                                                if (formPlacasKey.currentState!
                                                    .validate()) {
                                                  Empresa? empresa =
                                                      await empresaServices
                                                          .getEmpresa(
                                                              cnpjController
                                                                  .text
                                                                  .trim());

                                                  if (empresa == null &&
                                                      context.mounted) {
                                                    tratamentoDeErros
                                                        .showErrorSnackbar(
                                                            context,
                                                            'Insira o cnpj da empresa');
                                                    return;
                                                  } else {
                                                    final message = await missaoServices
                                                        .criarSolicitacao(
                                                            local:
                                                                missionPosition!
                                                                    .address,
                                                            empresa!.cnpj,
                                                            empresa.nomeEmpresa,
                                                            _selectedOption,
                                                            missionPosition!
                                                                .latLng!.lat,
                                                            missionPosition!
                                                                .latLng!.lng,
                                                            placaCavaloController
                                                                .text,
                                                            placaCarretaController
                                                                .text,
                                                            motoristaController
                                                                .text,
                                                            corController.text,
                                                            observacaoController
                                                                .text);

                                                    _selectedOption = null;
                                                    missionPosition = null;
                                                    cnpjController.clear();
                                                    _missionController.text =
                                                        '';
                                                    placaCavaloController.text =
                                                        '';
                                                    placaCarretaController
                                                        .text = '';
                                                    motoristaController.text =
                                                        '';
                                                    corController.text = '';
                                                    observacaoController.text =
                                                        '';

                                                    if (context.mounted) {
                                                      BlocProvider.of<
                                                                  MissoesSolicitadasBloc>(
                                                              context)
                                                          .add(BuscarMissoes());
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          duration:
                                                              const Duration(
                                                                  seconds: 4),
                                                          content:
                                                              Text(message),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      duration:
                                                          Duration(seconds: 4),
                                                      content: Text(
                                                          'Preencha os campos corretamente'),
                                                    ),
                                                  );
                                                }
                                              }
                                            : null,
                                        child: const Text('Solicitar agente'),
                                      ),
                                    ),
                                  ],
                                )
                              : _botao == 'coordenada'
                                  ? ResponsiveRowColumn(
                                      layout: ResponsiveRowColumnType.COLUMN,
                                      children: [
                                        ResponsiveRowColumnItem(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width * 0.0,
                                                vertical: 0),
                                            child: ResponsiveRowColumn(
                                              layout: ResponsiveBreakpoints.of(
                                                          context)
                                                      .smallerThan(DESKTOP)
                                                  ? ResponsiveRowColumnType
                                                      .COLUMN
                                                  : ResponsiveRowColumnType.ROW,
                                              rowMainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ResponsiveRowColumnItem(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width * 0.011,
                                                            vertical: 0),
                                                    child: SizedBox(
                                                      height: 40,
                                                      width: 282,
                                                      child: TextFormField(
                                                        cursorHeight: 14,
                                                        controller:
                                                            latController,
                                                        onChanged: (value) {
                                                          _updateButtonState();
                                                        },
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText: 'Latitude',
                                                          labelStyle: TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.grey),
                                                          suffixIcon: Icon(Icons
                                                              .location_pin),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                ResponsiveRowColumnItem(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                width * 0.011,
                                                            vertical: 0),
                                                    child: SizedBox(
                                                      height: 40,
                                                      width: 282,
                                                      child: TextFormField(
                                                        cursorHeight: 14,
                                                        controller:
                                                            lngController,
                                                        onChanged: (value) {
                                                          _updateButtonState();
                                                        },
                                                        //style: TextStyle(color: Colors.grey[200]),
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Longitude',
                                                          labelStyle: TextStyle(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors.grey),
                                                          suffixIcon: Icon(Icons
                                                              .location_pin),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          enabledBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ResponsiveRowColumnItem(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 10,
                                                right: width * 0.055,
                                                left: width * 0.055,
                                                bottom: height * 0.0),
                                            child: Form(
                                              key: formPlacasKey,
                                              child: ResponsiveRowColumn(
                                                layout: ResponsiveBreakpoints
                                                            .of(context)
                                                        .smallerThan(DESKTOP)
                                                    ? ResponsiveRowColumnType
                                                        .COLUMN
                                                    : ResponsiveRowColumnType
                                                        .ROW,
                                                rowMainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ResponsiveRowColumnItem(
                                                    child: Container(
                                                      height: 50,
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 200,
                                                              minWidth: 90),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    width *
                                                                        0.001,
                                                                vertical: 5),
                                                        child: SizedBox(
                                                          width: width * 0.33,
                                                          child: TextFormField(
                                                            cursorHeight: 14,
                                                            validator: (value) {
                                                              if (value !=
                                                                      null &&
                                                                  value
                                                                      .isNotEmpty) {
                                                                if (!isValidPlaca(
                                                                    value
                                                                        .toUpperCase())) {
                                                                  return 'Placa inválida';
                                                                }
                                                              }
                                                              return null;
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              label: Text(
                                                                  'Placa cavalo'),
                                                              labelStyle: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            ),
                                                            controller:
                                                                placaCavaloController,
                                                            onChanged: (value) {
                                                              // Update the button state
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  ResponsiveRowColumnItem(
                                                    child: Container(
                                                      height: 50,
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 200,
                                                              minWidth: 60),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    width *
                                                                        0.01,
                                                                vertical: 5),
                                                        child: SizedBox(
                                                          width: width * 0.33,
                                                          child: TextFormField(
                                                            cursorHeight: 14,
                                                            validator: (value) {
                                                              if (value !=
                                                                      null &&
                                                                  value
                                                                      .isNotEmpty) {
                                                                if (!isValidPlaca(
                                                                    value
                                                                        .toUpperCase())) {
                                                                  return 'Placa inválida';
                                                                }
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                placaCarretaController,
                                                            onChanged: (value) {
                                                              // Update the button state
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              label: Text(
                                                                  'Placa carreta'),
                                                              labelStyle: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  ResponsiveRowColumnItem(
                                                    child: Container(
                                                      height: 50,
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 200,
                                                              minWidth: 100),
                                                      child:
                                                          CustomTextFormField(
                                                              controller:
                                                                  corController,
                                                              label: 'Cor'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        ResponsiveRowColumnItem(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 0,
                                                right: width * 0.057,
                                                left: width * 0.059,
                                                bottom: 20),
                                            child: ResponsiveRowColumn(
                                              layout: ResponsiveBreakpoints.of(
                                                          context)
                                                      .smallerThan(DESKTOP)
                                                  ? ResponsiveRowColumnType
                                                      .COLUMN
                                                  : ResponsiveRowColumnType.ROW,
                                              rowMainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ResponsiveRowColumnItem(
                                                  child: Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 295,
                                                            minWidth: 100),
                                                    child: CustomTextFormField(
                                                        controller:
                                                            motoristaController,
                                                        label: 'Motorista'),
                                                  ),
                                                ),
                                                const ResponsiveRowColumnItem(
                                                  child: SizedBox(
                                                    width: 10,
                                                  ),
                                                ),
                                                ResponsiveRowColumnItem(
                                                  child: Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 295,
                                                            minWidth: 100),
                                                    child: CustomTextFormField(
                                                      controller:
                                                          observacaoController,
                                                      label: 'Observação',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ResponsiveRowColumnItem(
                                          child: ElevatedButton(
                                            onPressed:
                                                (_isButtonCoordenadasEnabled)
                                                    ? () async {
                                                        if (formPlacasKey
                                                            .currentState!
                                                            .validate()) {
                                                          Empresa? empresa =
                                                              await empresaServices
                                                                  .getEmpresa(
                                                                      cnpjController
                                                                          .text
                                                                          .trim());

                                                          if (empresa == null &&
                                                              context.mounted) {
                                                            tratamentoDeErros
                                                                .showErrorSnackbar(
                                                                    context,
                                                                    'Insira o cnpj da empresa');
                                                            return;
                                                          } else {
                                                            final message =
                                                                await missaoServices
                                                                    .criarSolicitacao(
                                                              empresa!.cnpj,
                                                              empresa
                                                                  .nomeEmpresa,
                                                              _selectedOption,
                                                              double.parse(
                                                                  latController
                                                                      .text),
                                                              double.parse(
                                                                lngController
                                                                    .text,
                                                              ),
                                                              placaCavaloController
                                                                  .text,
                                                              placaCarretaController
                                                                  .text,
                                                              motoristaController
                                                                  .text,
                                                              corController
                                                                  .text,
                                                              observacaoController
                                                                  .text,
                                                            );
                                                            _selectedOption =
                                                                null;
                                                            cnpjController
                                                                .clear();
                                                            latController.text =
                                                                '';
                                                            lngController.text =
                                                                '';
                                                            placaCavaloController
                                                                .text = '';
                                                            placaCarretaController
                                                                .text = '';
                                                            motoristaController
                                                                .text = '';
                                                            corController.text =
                                                                '';
                                                            observacaoController
                                                                .text = '';

                                                            if (context
                                                                .mounted) {
                                                              BlocProvider.of<
                                                                          MissoesSolicitadasBloc>(
                                                                      context)
                                                                  .add(
                                                                      BuscarMissoes());
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  duration:
                                                                      const Duration(
                                                                          seconds:
                                                                              4),
                                                                  content: Text(
                                                                      message),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          4),
                                                              content: Text(
                                                                  'Preencha os campos corretamente'),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    : null,
                                            child:
                                                const Text('Solicitar agente'),
                                          ),
                                        ),
                                      ],
                                    )
                                  : ResponsiveRowColumn(
                                      layout: ResponsiveRowColumnType.COLUMN,
                                      children: [
                                        ResponsiveRowColumnItem(
                                          child: Container(
                                            constraints: const BoxConstraints(
                                                maxWidth: 600),
                                            height: height * 0.4,
                                            width: width * 0.7,
                                            child: gmap.GoogleMap(
                                              initialCameraPosition:
                                                  const gmap.CameraPosition(
                                                target: gmap.LatLng(
                                                    -14.235004, -51.92528),
                                                zoom: 4.0,
                                              ),
                                              onTap: _handleTap,
                                              markers: Set.from(
                                                  markers), // Adiciona o conjunto de marcadores ao mapa
                                            ),
                                          ),
                                        ),
                                        ResponsiveRowColumnItem(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 10,
                                                right: width * 0.055,
                                                left: width * 0.055,
                                                bottom: height * 0.0),
                                            child: Form(
                                              key: formPlacasKey,
                                              child: ResponsiveRowColumn(
                                                layout: ResponsiveBreakpoints
                                                            .of(context)
                                                        .smallerThan(DESKTOP)
                                                    ? ResponsiveRowColumnType
                                                        .COLUMN
                                                    : ResponsiveRowColumnType
                                                        .ROW,
                                                rowMainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ResponsiveRowColumnItem(
                                                    child: Container(
                                                      height: 50,
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 200,
                                                              minWidth: 90),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    width *
                                                                        0.001,
                                                                vertical: 5),
                                                        child: SizedBox(
                                                          width: width * 0.33,
                                                          child: TextFormField(
                                                            cursorHeight: 14,
                                                            validator: (value) {
                                                              if (value !=
                                                                      null &&
                                                                  value
                                                                      .isNotEmpty) {
                                                                if (!isValidPlaca(
                                                                    value
                                                                        .toUpperCase())) {
                                                                  return 'Placa inválida';
                                                                }
                                                              }
                                                              return null;
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              label: Text(
                                                                  'Placa cavalo'),
                                                              labelStyle: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            ),
                                                            controller:
                                                                placaCavaloController,
                                                            onChanged: (value) {
                                                              // Update the button state
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  ResponsiveRowColumnItem(
                                                    child: Container(
                                                      height: 50,
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 200,
                                                              minWidth: 60),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    width *
                                                                        0.01,
                                                                vertical: 5),
                                                        child: SizedBox(
                                                          width: width * 0.33,
                                                          child: TextFormField(
                                                            cursorHeight: 14,
                                                            validator: (value) {
                                                              if (value !=
                                                                      null &&
                                                                  value
                                                                      .isNotEmpty) {
                                                                if (!isValidPlaca(
                                                                    value
                                                                        .toUpperCase())) {
                                                                  return 'Placa inválida';
                                                                }
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                placaCarretaController,
                                                            onChanged: (value) {
                                                              // Update the button state
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              label: Text(
                                                                  'Placa carreta'),
                                                              labelStyle: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                      .grey),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  ResponsiveRowColumnItem(
                                                    child: Container(
                                                      height: 50,
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 200,
                                                              minWidth: 100),
                                                      child:
                                                          CustomTextFormField(
                                                              controller:
                                                                  corController,
                                                              label: 'Cor'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        ResponsiveRowColumnItem(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 0,
                                                right: width * 0.057,
                                                left: width * 0.059,
                                                bottom: 20),
                                            child: ResponsiveRowColumn(
                                              layout: ResponsiveBreakpoints.of(
                                                          context)
                                                      .smallerThan(DESKTOP)
                                                  ? ResponsiveRowColumnType
                                                      .COLUMN
                                                  : ResponsiveRowColumnType.ROW,
                                              rowMainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                ResponsiveRowColumnItem(
                                                  child: Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 295,
                                                            minWidth: 100),
                                                    child: CustomTextFormField(
                                                        controller:
                                                            motoristaController,
                                                        label: 'Motorista'),
                                                  ),
                                                ),
                                                const ResponsiveRowColumnItem(
                                                  child: SizedBox(
                                                    width: 10,
                                                  ),
                                                ),
                                                ResponsiveRowColumnItem(
                                                  child: Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 295,
                                                            minWidth: 100),
                                                    child: CustomTextFormField(
                                                      controller:
                                                          observacaoController,
                                                      label: 'Observação',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ResponsiveRowColumnItem(
                                          child: ElevatedButton(
                                            onPressed: (_isButtonMapEnabled)
                                                ? () async {
                                                    if (formPlacasKey
                                                        .currentState!
                                                        .validate()) {
                                                      Empresa? empresa =
                                                          await empresaServices
                                                              .getEmpresa(
                                                                  cnpjController
                                                                      .text
                                                                      .trim());

                                                      if (empresa == null &&
                                                          context.mounted) {
                                                        tratamentoDeErros
                                                            .showErrorSnackbar(
                                                                context,
                                                                'Insira o cnpj da empresa');
                                                        return;
                                                      } else {
                                                        final message =
                                                            await missaoServices
                                                                .criarSolicitacao(
                                                          empresa!.cnpj,
                                                          empresa.nomeEmpresa,
                                                          _selectedOption,
                                                          _selectedLatitude!,
                                                          _selectedLongitude!,
                                                          placaCavaloController
                                                              .text,
                                                          placaCarretaController
                                                              .text,
                                                          motoristaController
                                                              .text,
                                                          corController.text,
                                                          observacaoController
                                                              .text,
                                                        );
                                                        _selectedOption = null;
                                                        _selectedLatitude =
                                                            null;
                                                        _selectedLongitude =
                                                            null;
                                                        cnpjController.clear();
                                                        placaCavaloController
                                                            .text = '';
                                                        placaCarretaController
                                                            .text = '';
                                                        motoristaController
                                                            .text = '';
                                                        corController.text = '';
                                                        observacaoController
                                                            .text = '';

                                                        if (context.mounted) {
                                                          BlocProvider.of<
                                                                      MissoesSolicitadasBloc>(
                                                                  context)
                                                              .add(
                                                                  BuscarMissoes());
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          4),
                                                              content:
                                                                  Text(message),
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          duration: Duration(
                                                              seconds: 4),
                                                          content: Text(
                                                              'Preencha os campos corretamente'),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                : null,
                                            child:
                                                const Text('Solicitar agente'),
                                          ),
                                        ),
                                      ],
                                    ),
                          SizedBox(
                            height: height * 0.1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              // const Center(
              //   child: Card(
              //     color: Colors.black,
              //     elevation: 1,
              //     margin: EdgeInsets.all(8.0),
              //     child: Padding(
              //       padding: EdgeInsets.all(20.0),
              //       child: Text('Nenhuma solicitação encontrada'),
              //     ),
              //   ),
              // );
            } else if (state is MissoesSolicitadasLoaded) {
              missoesSolicitadas = state.missoes;

              // Filtra a lista com base no texto atual no campo de pesquisa
              List<MissaoSolicitada> missoesFiltrados =
                  filtrarRelatorios(missoesSolicitadas, searchController.text);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.084,
                          right: MediaQuery.of(context).size.width * 0.08,
                          bottom: 20),
                      child: ResponsiveRowColumn(
                        layout: ResponsiveBreakpoints.of(context)
                                .smallerThan(DESKTOP)
                            ? ResponsiveRowColumnType.COLUMN
                            : ResponsiveRowColumnType.ROW,
                        rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //rowPadding: const EdgeInsets.symmetric(horizontal: 100),
                        children: [
                          ResponsiveRowColumnItem(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage(
                                      'assets/images/fotoDePerfilNull.jpg'),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.nome,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      widget.cargo,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          ResponsiveRowColumnItem(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: width * 0.2,
                                  height: 40,
                                  child: TextFormField(
                                    cursorHeight: 15,
                                    decoration: InputDecoration(
                                      labelText: 'Buscar missão pelo ID',
                                      labelStyle: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12),
                                      suffixIcon: Icon(
                                        Icons.search,
                                        size: 20,
                                        color: Colors.grey[500]!,
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[500]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[500]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey[500]!),
                                      ),
                                    ),
                                    controller: searchController,
                                    onChanged: (text) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.filter_list,
                                      color: Colors.grey[500]!,
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      // Coloque a lógica do filtro aqui
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.refresh_outlined,
                                      color: Colors.grey[500]!,
                                      size: 25,
                                    ),
                                    onPressed: () {
                                      context
                                          .read<MissoesSolicitadasBloc>()
                                          .add(BuscarMissoes());
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //const SizedBox(height: 10,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                      child: ExpansionTile(
                        //collapsedBackgroundColor: canvasColor.withOpacity(0.3),
                        collapsedBackgroundColor: canvasColor.withOpacity(0.4),
                        initiallyExpanded: false,
                        //borda
                        // collapsedShape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(20),
                        // ),
                        //cor do icone
                        collapsedIconColor: Colors.grey[300],
                        //cor do texto
                        collapsedTextColor: Colors.white,
                        //backgroundColor: canvasColor.withOpacity(0.4),
                        backgroundColor: canvasColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        // decoration: BoxDecoration(
                        //   //color: canvasColor.withOpacity(0.99),
                        //   borderRadius: BorderRadius.circular(20),
                        //   //cor da borda
                        //   border: Border.all(
                        //     color: canvasColor,
                        //     width: 2,
                        //   ),
                        // ),

                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                //color: canvasColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: const Text(
                                'CRIAR SOLICITAÇÃO',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                _buttonsNav(),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Checkbox(
                                      //   value: preservacaoIsChecked,
                                      //   onChanged: (bool? value) {
                                      //     setState(() {
                                      //       preservacaoIsChecked = value!;
                                      //       _selectedOption = 'Preservação';
                                      //     });
                                      //   },
                                      // ),
                                      // const Text(
                                      //   'Preservação',
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontSize: 14),
                                      // ),
                                      // const SizedBox(width: 10),
                                      // Checkbox(
                                      //   value: acompanhamentoIsChecked,
                                      //   onChanged: (bool? value) {
                                      //     setState(() {
                                      //       acompanhamentoIsChecked =
                                      //           value!;
                                      //       _selectedOption = 'Acompanhamento';
                                      //     });
                                      //   },
                                      // ),
                                      // const Text(
                                      //   'Acompanhamento',
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontSize: 14),
                                      // ),
                                      // const SizedBox(width: 10),
                                      // Checkbox(
                                      //   value: varreduraIsChecked,
                                      //   onChanged: (bool? value) {
                                      //     setState(() {
                                      //       varreduraIsChecked = value!;
                                      //       _selectedOption = 'Varredura';
                                      //     });
                                      //   },
                                      // ),
                                      // const Text(
                                      //   'Varredura',
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontSize: 14),
                                      // ),
                                      // const SizedBox(width: 10),
                                      // Checkbox(
                                      //   value: averiguacaoIsChecked,
                                      //   onChanged: (bool? value) {
                                      //     setState(() {
                                      //       averiguacaoIsChecked = value!;
                                      //       _selectedOption = 'Averiguação';
                                      //     });
                                      //   },
                                      // ),
                                      // const Text(
                                      //   'Averiguação',
                                      //   style: TextStyle(
                                      //       color: Colors.black,
                                      //       fontSize: 14),
                                      // ),

                                      Radio<String>(
                                        value: 'Preservação',
                                        groupValue: _selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedOption = value;
                                            _updateButtonState();
                                          });
                                        },
                                      ),
                                      const Text('Preservação'),
                                      const SizedBox(width: 10),
                                      Radio<String>(
                                        value: 'Acompanhamento',
                                        groupValue: _selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedOption = value;
                                            _updateButtonState();
                                          });
                                        },
                                      ),
                                      const Text('Acompanhamento'),
                                      Radio<String>(
                                        value: 'Varredura',
                                        groupValue: _selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedOption = value;
                                            _updateButtonState();
                                          });
                                        },
                                      ),
                                      const Text('Varredura'),
                                      Radio<String>(
                                        value: 'Averiguação',
                                        groupValue: _selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedOption = value;
                                            _updateButtonState();
                                          });
                                        },
                                      ),
                                      const Text('Averiguação'),
                                    ],
                                  ),
                                ),
                                ResponsiveRowColumn(
                                  layout: ResponsiveRowColumnType.COLUMN,
                                  children: [
                                    ResponsiveRowColumnItem(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: width * 0.055,
                                            vertical: 0),
                                        child: Container(
                                            height: 150,
                                            constraints: const BoxConstraints(
                                                maxWidth: 600, maxHeight: 300),
                                            child:
                                                SearchableList<Empresa>.async(
                                              onPaginate: () async {},
                                              itemBuilder: (Empresa empresa) =>
                                                  MouseRegion(
                                                cursor: WidgetStateMouseCursor
                                                    .clickable,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      cnpjController.text =
                                                          empresa.cnpj;
                                                    });
                                                  },
                                                  child: ActorItem(
                                                      empresa: empresa),
                                                ),
                                              ),
                                              loadingWidget:
                                                  //const SizedBox.shrink(),
                                                  const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircularProgressIndicator(),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text('Buscando empresas...')
                                                ],
                                              ),
                                              errorWidget: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text(
                                                      'Error ao buscar empresas')
                                                ],
                                              ),
                                              asyncListCallback: () async {
                                                List<Empresa> empresas =
                                                    await empresaServices
                                                        .getAllEmpresas();
                                                return empresas;
                                              },
                                              asyncListFilter: (q, list) {
                                                List<Empresa> geral = [];
                                                List<Empresa> nome = list
                                                    .where((element) => element
                                                        .nomeEmpresa
                                                        .contains(q))
                                                    .toList();
                                                List<Empresa> cnpj = list
                                                    .where((element) => element
                                                        .cnpj
                                                        .contains(q))
                                                    .toList();
                                                geral.addAll(nome);
                                                cnpjController.text.isNotEmpty
                                                    ? geral.addAll(cnpj)
                                                    : null;
                                                return geral;
                                              },
                                              searchTextController:
                                                  cnpjController,
                                              emptyWidget: const EmptyView(),
                                              onRefresh: () async {},
                                              // onItemSelected: (Empresa item) {
                                              //   setState(() {
                                              //     cnpjController.text =
                                              //         item.cnpj;
                                              //   });
                                              // },
                                              inputDecoration:
                                                  const InputDecoration(
                                                labelText:
                                                    'Nome ou cnpj do cliente',
                                                labelStyle: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey),
                                                //suffixIcon: Icon(Icons.search),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            )
                                            // TextFormField(
                                            //   inputFormatters: <TextInputFormatter>[
                                            //     //FilteringTextInputFormatter.digitsOnly,
                                            //     //limite de caracteres
                                            //     LengthLimitingTextInputFormatter(14),
                                            //   ],
                                            //   cursorHeight: 17,
                                            //   //focusNode: _focusNode,
                                            //   controller: cnpjController,
                                            //   //style: TextStyle(color: Colors.grey[200]),
                                            //   decoration: const InputDecoration(
                                            //     labelText: 'CNPJ do cliente',
                                            //     labelStyle: TextStyle(
                                            //         fontSize: 13, color: Colors.grey),
                                            //     suffixIcon: Icon(Icons.search),
                                            //     border: OutlineInputBorder(
                                            //       borderSide:
                                            //           BorderSide(color: Colors.grey),
                                            //     ),
                                            //     enabledBorder: OutlineInputBorder(
                                            //       borderSide:
                                            //           BorderSide(color: Colors.grey),
                                            //     ),
                                            //     focusedBorder: OutlineInputBorder(
                                            //       borderSide:
                                            //           BorderSide(color: Colors.grey),
                                            //     ),
                                            //   ),
                                            // ),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                _botao == 'localizacao'
                                    ? ResponsiveRowColumn(
                                        layout: ResponsiveRowColumnType.COLUMN,
                                        children: [
                                          ResponsiveRowColumnItem(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: width * 0.055,
                                                  vertical: 0),
                                              child: Container(
                                                height: 55,
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 600),
                                                child: TextFormField(
                                                  cursorHeight: 17,
                                                  focusNode: _focusNode,
                                                  controller:
                                                      _missionController,
                                                  //style: TextStyle(color: Colors.grey[200]),
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Local da missão',
                                                    labelStyle: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey),
                                                    suffixIcon:
                                                        Icon(Icons.search),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (_focusNode.hasFocus &&
                                              _predictions != null &&
                                              _predictions!.isNotEmpty)
                                            ResponsiveRowColumnItem(
                                              child: SizedBox(
                                                height: 250,
                                                //width: width * 0.7,
                                                //child: Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: width * 0.055,
                                                      vertical: 15),
                                                  child: Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            maxWidth: 600),
                                                    child: SizedBox(
                                                      //width: width * 0.7,
                                                      height: 260,
                                                      child: ListView.builder(
                                                        itemCount: _predictions!
                                                            .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          final prediction =
                                                              _predictions![
                                                                  index];
                                                          bool isSelected =
                                                              prediction
                                                                      .placeId ==
                                                                  _selectedPlaceId;
                                                          return ListTile(
                                                              title: Text(
                                                                  prediction
                                                                      .fullText),
                                                              trailing: isSelected
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check)
                                                                  : null,
                                                              onTap: () async {
                                                                final fields = [
                                                                  PlaceField
                                                                      .Name,
                                                                  PlaceField
                                                                      .Address,
                                                                  PlaceField
                                                                      .Location, // Alterado de Location para LatLng
                                                                ];

                                                                final response =
                                                                    await places.fetchPlace(
                                                                        prediction
                                                                            .placeId,
                                                                        fields:
                                                                            fields);
                                                                Place? details =
                                                                    response
                                                                        .place;

                                                                setState(() {
                                                                  _selectedPlaceId =
                                                                      prediction
                                                                          .placeId;
                                                                  if (_activeField ==
                                                                      ActiveField
                                                                          .mission) {
                                                                    missionPosition =
                                                                        details;
                                                                    _missionController
                                                                            .text =
                                                                        details!
                                                                            .address!;
                                                                    _missionController
                                                                            .selection =
                                                                        TextSelection
                                                                            .fromPosition(
                                                                      TextPosition(
                                                                          offset: _missionController
                                                                              .text
                                                                              .length),
                                                                    );
                                                                  }

                                                                  debugPrint(
                                                                      missionPosition
                                                                          .toString()); // Adicionando o log para o missionPosition
                                                                  _predictions =
                                                                      null;
                                                                  _updateButtonState();
                                                                });
                                                              });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ResponsiveRowColumnItem(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  top: 10,
                                                  right: width * 0.055,
                                                  left: width * 0.055,
                                                  bottom: height * 0.0),
                                              child: Form(
                                                key: formPlacasKey,
                                                child: ResponsiveRowColumn(
                                                  layout: ResponsiveBreakpoints
                                                              .of(context)
                                                          .smallerThan(DESKTOP)
                                                      ? ResponsiveRowColumnType
                                                          .COLUMN
                                                      : ResponsiveRowColumnType
                                                          .ROW,
                                                  rowMainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ResponsiveRowColumnItem(
                                                      child: Container(
                                                        height: 50,
                                                        constraints:
                                                            const BoxConstraints(
                                                                maxWidth: 200,
                                                                minWidth: 90),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      width *
                                                                          0.001,
                                                                  vertical: 5),
                                                          child: SizedBox(
                                                            width: width * 0.33,
                                                            child:
                                                                TextFormField(
                                                              cursorHeight: 14,
                                                              validator:
                                                                  (value) {
                                                                if (value !=
                                                                        null &&
                                                                    value
                                                                        .isNotEmpty) {
                                                                  if (!isValidPlaca(
                                                                      value
                                                                          .toUpperCase())) {
                                                                    return 'Placa inválida';
                                                                  }
                                                                }
                                                                return null;
                                                              },
                                                              decoration:
                                                                  const InputDecoration(
                                                                label: Text(
                                                                    'Placa cavalo'),
                                                                labelStyle: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                              ),
                                                              controller:
                                                                  placaCavaloController,
                                                              onChanged:
                                                                  (value) {
                                                                // Update the button state
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    ResponsiveRowColumnItem(
                                                      child: Container(
                                                        height: 50,
                                                        constraints:
                                                            const BoxConstraints(
                                                                maxWidth: 200,
                                                                minWidth: 60),
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      width *
                                                                          0.01,
                                                                  vertical: 5),
                                                          child: SizedBox(
                                                            width: width * 0.33,
                                                            child:
                                                                TextFormField(
                                                              cursorHeight: 14,
                                                              validator:
                                                                  (value) {
                                                                if (value !=
                                                                        null &&
                                                                    value
                                                                        .isNotEmpty) {
                                                                  if (!isValidPlaca(
                                                                      value
                                                                          .toUpperCase())) {
                                                                    return 'Placa inválida';
                                                                  }
                                                                }
                                                                return null;
                                                              },
                                                              controller:
                                                                  placaCarretaController,
                                                              onChanged:
                                                                  (value) {
                                                                // Update the button state
                                                              },
                                                              decoration:
                                                                  const InputDecoration(
                                                                label: Text(
                                                                    'Placa carreta'),
                                                                labelStyle: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    ResponsiveRowColumnItem(
                                                      child: Container(
                                                        height: 50,
                                                        constraints:
                                                            const BoxConstraints(
                                                                maxWidth: 200,
                                                                minWidth: 100),
                                                        child:
                                                            CustomTextFormField(
                                                          controller:
                                                              corController,
                                                          label: 'Cor',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          ResponsiveRowColumnItem(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  top: 0,
                                                  right: width * 0.057,
                                                  left: width * 0.059,
                                                  bottom: 20),
                                              child: ResponsiveRowColumn(
                                                layout: ResponsiveBreakpoints
                                                            .of(context)
                                                        .smallerThan(DESKTOP)
                                                    ? ResponsiveRowColumnType
                                                        .COLUMN
                                                    : ResponsiveRowColumnType
                                                        .ROW,
                                                rowMainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ResponsiveRowColumnItem(
                                                    child: Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 295,
                                                              minWidth: 100),
                                                      child: CustomTextFormField(
                                                          controller:
                                                              motoristaController,
                                                          label: 'Motorista'),
                                                    ),
                                                  ),
                                                  const ResponsiveRowColumnItem(
                                                    child: SizedBox(
                                                      width: 10,
                                                    ),
                                                  ),
                                                  ResponsiveRowColumnItem(
                                                    child: Container(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 295,
                                                              minWidth: 100),
                                                      child:
                                                          CustomTextFormField(
                                                        controller:
                                                            observacaoController,
                                                        label: 'Observação',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // ResponsiveRowColumnItem(
                                          //   child: Padding(
                                          //     padding: EdgeInsets.only(
                                          //         top: 0,
                                          //         right: width * 0.045,
                                          //         left: width * 0.045,
                                          //         bottom: height * 0.05),
                                          //     child: ResponsiveRowColumn(
                                          //       layout: ResponsiveBreakpoints
                                          //                   .of(context)
                                          //               .smallerThan(
                                          //                   DESKTOP)
                                          //           ? ResponsiveRowColumnType
                                          //               .COLUMN
                                          //           : ResponsiveRowColumnType
                                          //               .ROW,
                                          //       rowMainAxisAlignment:
                                          //           MainAxisAlignment
                                          //               .center,
                                          //       children: [
                                          //         ResponsiveRowColumnItem(
                                          //           child: CustomTextFormField(
                                          //               controller:
                                          //                   observacaoController,
                                          //               label:
                                          //                   'Observação'),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                          ResponsiveRowColumnItem(
                                            child: ElevatedButton(
                                              onPressed:
                                                  (_isButtonAdressEnabled)
                                                      ? () async {
                                                          //verificar validador do form
                                                          if (formPlacasKey
                                                              .currentState!
                                                              .validate()) {
                                                            Empresa? empresa =
                                                                await empresaServices
                                                                    .getEmpresa(
                                                                        cnpjController
                                                                            .text
                                                                            .trim());

                                                            if (empresa ==
                                                                    null &&
                                                                context
                                                                    .mounted) {
                                                              tratamentoDeErros
                                                                  .showErrorSnackbar(
                                                                      context,
                                                                      'Insira o cnpj da empresa');
                                                              return;
                                                            } else {
                                                              final message = await missaoServices.criarSolicitacao(
                                                                  local: missionPosition!
                                                                      .address,
                                                                  empresa!.cnpj,
                                                                  empresa
                                                                      .nomeEmpresa,
                                                                  _selectedOption,
                                                                  missionPosition!
                                                                      .latLng!
                                                                      .lat,
                                                                  missionPosition!
                                                                      .latLng!
                                                                      .lng,
                                                                  placaCavaloController
                                                                      .text,
                                                                  placaCarretaController
                                                                      .text,
                                                                  motoristaController
                                                                      .text,
                                                                  corController
                                                                      .text,
                                                                  observacaoController
                                                                      .text);

                                                              _selectedOption =
                                                                  null;
                                                              missionPosition =
                                                                  null;
                                                              cnpjController
                                                                  .clear();
                                                              _missionController
                                                                  .text = '';
                                                              placaCavaloController
                                                                  .text = '';
                                                              placaCarretaController
                                                                  .text = '';
                                                              motoristaController
                                                                  .text = '';
                                                              corController
                                                                  .text = '';
                                                              observacaoController
                                                                  .text = '';

                                                              if (context
                                                                  .mounted) {
                                                                BlocProvider.of<
                                                                            MissoesSolicitadasBloc>(
                                                                        context)
                                                                    .add(
                                                                        BuscarMissoes());
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    duration: const Duration(
                                                                        seconds:
                                                                            4),
                                                                    content: Text(
                                                                        message),
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            4),
                                                                content: Text(
                                                                    'Preencha os campos corretamente'),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      : null,
                                              child: const Text(
                                                  'Solicitar agente'),
                                            ),
                                          ),
                                        ],
                                      )
                                    : _botao == 'coordenada'
                                        ? ResponsiveRowColumn(
                                            layout:
                                                ResponsiveRowColumnType.COLUMN,
                                            children: [
                                              ResponsiveRowColumnItem(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: width * 0.0,
                                                      vertical: 0),
                                                  child: ResponsiveRowColumn(
                                                    layout: ResponsiveBreakpoints
                                                                .of(context)
                                                            .smallerThan(
                                                                DESKTOP)
                                                        ? ResponsiveRowColumnType
                                                            .COLUMN
                                                        : ResponsiveRowColumnType
                                                            .ROW,
                                                    rowMainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ResponsiveRowColumnItem(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      width *
                                                                          0.011,
                                                                  vertical: 0),
                                                          child: SizedBox(
                                                            height: 40,
                                                            width: 282,
                                                            child:
                                                                TextFormField(
                                                              cursorHeight: 14,
                                                              controller:
                                                                  latController,
                                                              onChanged:
                                                                  (value) {
                                                                _updateButtonState();
                                                              },
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'Latitude',
                                                                labelStyle: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .location_pin),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ResponsiveRowColumnItem(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      width *
                                                                          0.011,
                                                                  vertical: 0),
                                                          child: SizedBox(
                                                            height: 40,
                                                            width: 282,
                                                            child:
                                                                TextFormField(
                                                              cursorHeight: 14,
                                                              controller:
                                                                  lngController,
                                                              onChanged:
                                                                  (value) {
                                                                _updateButtonState();
                                                              },
                                                              //style: TextStyle(color: Colors.grey[200]),
                                                              decoration:
                                                                  const InputDecoration(
                                                                labelText:
                                                                    'Longitude',
                                                                labelStyle: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .grey),
                                                                suffixIcon:
                                                                    Icon(Icons
                                                                        .location_pin),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                enabledBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                          color:
                                                                              Colors.grey),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ResponsiveRowColumnItem(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10,
                                                      right: width * 0.055,
                                                      left: width * 0.055,
                                                      bottom: height * 0.0),
                                                  child: Form(
                                                    key: formPlacasKey,
                                                    child: ResponsiveRowColumn(
                                                      layout: ResponsiveBreakpoints
                                                                  .of(context)
                                                              .smallerThan(
                                                                  DESKTOP)
                                                          ? ResponsiveRowColumnType
                                                              .COLUMN
                                                          : ResponsiveRowColumnType
                                                              .ROW,
                                                      rowMainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        ResponsiveRowColumnItem(
                                                          child: Container(
                                                            height: 50,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        200,
                                                                    minWidth:
                                                                        90),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          width *
                                                                              0.001,
                                                                      vertical:
                                                                          5),
                                                              child: SizedBox(
                                                                width: width *
                                                                    0.33,
                                                                child:
                                                                    TextFormField(
                                                                  cursorHeight:
                                                                      14,
                                                                  validator:
                                                                      (value) {
                                                                    if (value !=
                                                                            null &&
                                                                        value
                                                                            .isNotEmpty) {
                                                                      if (!isValidPlaca(
                                                                          value
                                                                              .toUpperCase())) {
                                                                        return 'Placa inválida';
                                                                      }
                                                                    }
                                                                    return null;
                                                                  },
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    label: Text(
                                                                        'Placa cavalo'),
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .grey),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                  ),
                                                                  controller:
                                                                      placaCavaloController,
                                                                  onChanged:
                                                                      (value) {
                                                                    // Update the button state
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        ResponsiveRowColumnItem(
                                                          child: Container(
                                                            height: 50,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        200,
                                                                    minWidth:
                                                                        60),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          width *
                                                                              0.01,
                                                                      vertical:
                                                                          5),
                                                              child: SizedBox(
                                                                width: width *
                                                                    0.33,
                                                                child:
                                                                    TextFormField(
                                                                  cursorHeight:
                                                                      14,
                                                                  validator:
                                                                      (value) {
                                                                    if (value !=
                                                                            null &&
                                                                        value
                                                                            .isNotEmpty) {
                                                                      if (!isValidPlaca(
                                                                          value
                                                                              .toUpperCase())) {
                                                                        return 'Placa inválida';
                                                                      }
                                                                    }
                                                                    return null;
                                                                  },
                                                                  controller:
                                                                      placaCarretaController,
                                                                  onChanged:
                                                                      (value) {
                                                                    // Update the button state
                                                                  },
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    label: Text(
                                                                        'Placa carreta'),
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .grey),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        ResponsiveRowColumnItem(
                                                          child: Container(
                                                            height: 50,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        200,
                                                                    minWidth:
                                                                        100),
                                                            child: CustomTextFormField(
                                                                controller:
                                                                    corController,
                                                                label: 'Cor'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ResponsiveRowColumnItem(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 0,
                                                      right: width * 0.057,
                                                      left: width * 0.059,
                                                      bottom: 20),
                                                  child: ResponsiveRowColumn(
                                                    layout: ResponsiveBreakpoints
                                                                .of(context)
                                                            .smallerThan(
                                                                DESKTOP)
                                                        ? ResponsiveRowColumnType
                                                            .COLUMN
                                                        : ResponsiveRowColumnType
                                                            .ROW,
                                                    rowMainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ResponsiveRowColumnItem(
                                                        child: Container(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth: 295,
                                                                  minWidth:
                                                                      100),
                                                          child: CustomTextFormField(
                                                              controller:
                                                                  motoristaController,
                                                              label:
                                                                  'Motorista'),
                                                        ),
                                                      ),
                                                      const ResponsiveRowColumnItem(
                                                        child: SizedBox(
                                                          width: 10,
                                                        ),
                                                      ),
                                                      ResponsiveRowColumnItem(
                                                        child: Container(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth: 295,
                                                                  minWidth:
                                                                      100),
                                                          child:
                                                              CustomTextFormField(
                                                            controller:
                                                                observacaoController,
                                                            label: 'Observação',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ResponsiveRowColumnItem(
                                                child: ElevatedButton(
                                                  onPressed:
                                                      (_isButtonCoordenadasEnabled)
                                                          ? () async {
                                                              if (formPlacasKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                Empresa?
                                                                    empresa =
                                                                    await empresaServices.getEmpresa(
                                                                        cnpjController
                                                                            .text
                                                                            .trim());

                                                                if (empresa ==
                                                                        null &&
                                                                    context
                                                                        .mounted) {
                                                                  tratamentoDeErros
                                                                      .showErrorSnackbar(
                                                                          context,
                                                                          'Insira o cnpj da empresa');
                                                                  return;
                                                                } else {
                                                                  final message =
                                                                      await missaoServices
                                                                          .criarSolicitacao(
                                                                    empresa!
                                                                        .cnpj,
                                                                    empresa
                                                                        .nomeEmpresa,
                                                                    _selectedOption,
                                                                    double.parse(
                                                                        latController
                                                                            .text),
                                                                    double
                                                                        .parse(
                                                                      lngController
                                                                          .text,
                                                                    ),
                                                                    placaCavaloController
                                                                        .text,
                                                                    placaCarretaController
                                                                        .text,
                                                                    motoristaController
                                                                        .text,
                                                                    corController
                                                                        .text,
                                                                    observacaoController
                                                                        .text,
                                                                  );
                                                                  _selectedOption =
                                                                      null;
                                                                  cnpjController
                                                                      .clear();
                                                                  latController
                                                                      .text = '';
                                                                  lngController
                                                                      .text = '';
                                                                  placaCavaloController
                                                                      .text = '';
                                                                  placaCarretaController
                                                                      .text = '';
                                                                  motoristaController
                                                                      .text = '';
                                                                  corController
                                                                      .text = '';
                                                                  observacaoController
                                                                      .text = '';

                                                                  if (context
                                                                      .mounted) {
                                                                    BlocProvider.of<MissoesSolicitadasBloc>(
                                                                            context)
                                                                        .add(
                                                                            BuscarMissoes());
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        duration:
                                                                            const Duration(seconds: 4),
                                                                        content:
                                                                            Text(message),
                                                                      ),
                                                                    );
                                                                  }
                                                                }
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            4),
                                                                    content: Text(
                                                                        'Preencha os campos corretamente'),
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          : null,
                                                  child: const Text(
                                                      'Solicitar agente'),
                                                ),
                                              ),
                                            ],
                                          )
                                        : ResponsiveRowColumn(
                                            layout:
                                                ResponsiveRowColumnType.COLUMN,
                                            children: [
                                              ResponsiveRowColumnItem(
                                                child: Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 600),
                                                  height: height * 0.4,
                                                  width: width * 0.7,
                                                  child: gmap.GoogleMap(
                                                    initialCameraPosition:
                                                        const gmap
                                                            .CameraPosition(
                                                      target: gmap.LatLng(
                                                          -14.235004,
                                                          -51.92528),
                                                      zoom: 4.0,
                                                    ),
                                                    onTap: _handleTap,
                                                    markers: Set.from(
                                                        markers), // Adiciona o conjunto de marcadores ao mapa
                                                  ),
                                                ),
                                              ),
                                              ResponsiveRowColumnItem(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 10,
                                                      right: width * 0.055,
                                                      left: width * 0.055,
                                                      bottom: height * 0.0),
                                                  child: Form(
                                                    key: formPlacasKey,
                                                    child: ResponsiveRowColumn(
                                                      layout: ResponsiveBreakpoints
                                                                  .of(context)
                                                              .smallerThan(
                                                                  DESKTOP)
                                                          ? ResponsiveRowColumnType
                                                              .COLUMN
                                                          : ResponsiveRowColumnType
                                                              .ROW,
                                                      rowMainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        ResponsiveRowColumnItem(
                                                          child: Container(
                                                            height: 50,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        200,
                                                                    minWidth:
                                                                        90),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          width *
                                                                              0.001,
                                                                      vertical:
                                                                          5),
                                                              child: SizedBox(
                                                                width: width *
                                                                    0.33,
                                                                child:
                                                                    TextFormField(
                                                                  cursorHeight:
                                                                      14,
                                                                  validator:
                                                                      (value) {
                                                                    if (value !=
                                                                            null &&
                                                                        value
                                                                            .isNotEmpty) {
                                                                      if (!isValidPlaca(
                                                                          value
                                                                              .toUpperCase())) {
                                                                        return 'Placa inválida';
                                                                      }
                                                                    }
                                                                    return null;
                                                                  },
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    label: Text(
                                                                        'Placa cavalo'),
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .grey),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                  ),
                                                                  controller:
                                                                      placaCavaloController,
                                                                  onChanged:
                                                                      (value) {
                                                                    // Update the button state
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        ResponsiveRowColumnItem(
                                                          child: Container(
                                                            height: 50,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        200,
                                                                    minWidth:
                                                                        60),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          width *
                                                                              0.01,
                                                                      vertical:
                                                                          5),
                                                              child: SizedBox(
                                                                width: width *
                                                                    0.33,
                                                                child:
                                                                    TextFormField(
                                                                  cursorHeight:
                                                                      14,
                                                                  validator:
                                                                      (value) {
                                                                    if (value !=
                                                                            null &&
                                                                        value
                                                                            .isNotEmpty) {
                                                                      if (!isValidPlaca(
                                                                          value
                                                                              .toUpperCase())) {
                                                                        return 'Placa inválida';
                                                                      }
                                                                    }
                                                                    return null;
                                                                  },
                                                                  controller:
                                                                      placaCarretaController,
                                                                  onChanged:
                                                                      (value) {
                                                                    // Update the button state
                                                                  },
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    label: Text(
                                                                        'Placa carreta'),
                                                                    labelStyle: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Colors
                                                                            .grey),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                              color: Colors.grey),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        ResponsiveRowColumnItem(
                                                          child: Container(
                                                            height: 50,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    maxWidth:
                                                                        200,
                                                                    minWidth:
                                                                        100),
                                                            child: CustomTextFormField(
                                                                controller:
                                                                    corController,
                                                                label: 'Cor'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              ResponsiveRowColumnItem(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 0,
                                                      right: width * 0.057,
                                                      left: width * 0.059,
                                                      bottom: 20),
                                                  child: ResponsiveRowColumn(
                                                    layout: ResponsiveBreakpoints
                                                                .of(context)
                                                            .smallerThan(
                                                                DESKTOP)
                                                        ? ResponsiveRowColumnType
                                                            .COLUMN
                                                        : ResponsiveRowColumnType
                                                            .ROW,
                                                    rowMainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      ResponsiveRowColumnItem(
                                                        child: Container(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth: 295,
                                                                  minWidth:
                                                                      100),
                                                          child: CustomTextFormField(
                                                              controller:
                                                                  motoristaController,
                                                              label:
                                                                  'Motorista'),
                                                        ),
                                                      ),
                                                      const ResponsiveRowColumnItem(
                                                        child: SizedBox(
                                                          width: 10,
                                                        ),
                                                      ),
                                                      ResponsiveRowColumnItem(
                                                        child: Container(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth: 295,
                                                                  minWidth:
                                                                      100),
                                                          child:
                                                              CustomTextFormField(
                                                            controller:
                                                                observacaoController,
                                                            label: 'Observação',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ResponsiveRowColumnItem(
                                                child: ElevatedButton(
                                                  onPressed:
                                                      (_isButtonMapEnabled)
                                                          ? () async {
                                                              if (formPlacasKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                Empresa?
                                                                    empresa =
                                                                    await empresaServices.getEmpresa(
                                                                        cnpjController
                                                                            .text
                                                                            .trim());

                                                                if (empresa ==
                                                                        null &&
                                                                    context
                                                                        .mounted) {
                                                                  tratamentoDeErros
                                                                      .showErrorSnackbar(
                                                                          context,
                                                                          'Insira o cnpj da empresa');
                                                                  return;
                                                                } else {
                                                                  final message =
                                                                      await missaoServices
                                                                          .criarSolicitacao(
                                                                    empresa!
                                                                        .cnpj,
                                                                    empresa
                                                                        .nomeEmpresa,
                                                                    _selectedOption,
                                                                    _selectedLatitude!,
                                                                    _selectedLongitude!,
                                                                    placaCavaloController
                                                                        .text,
                                                                    placaCarretaController
                                                                        .text,
                                                                    motoristaController
                                                                        .text,
                                                                    corController
                                                                        .text,
                                                                    observacaoController
                                                                        .text,
                                                                  );
                                                                  _selectedOption =
                                                                      null;
                                                                  _selectedLatitude =
                                                                      null;
                                                                  _selectedLongitude =
                                                                      null;
                                                                  cnpjController
                                                                      .clear();
                                                                  placaCavaloController
                                                                      .text = '';
                                                                  placaCarretaController
                                                                      .text = '';
                                                                  motoristaController
                                                                      .text = '';
                                                                  corController
                                                                      .text = '';
                                                                  observacaoController
                                                                      .text = '';

                                                                  if (context
                                                                      .mounted) {
                                                                    BlocProvider.of<MissoesSolicitadasBloc>(
                                                                            context)
                                                                        .add(
                                                                            BuscarMissoes());
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        duration:
                                                                            const Duration(seconds: 4),
                                                                        content:
                                                                            Text(message),
                                                                      ),
                                                                    );
                                                                  }
                                                                }
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    duration: Duration(
                                                                        seconds:
                                                                            4),
                                                                    content: Text(
                                                                        'Preencha os campos corretamente'),
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          : null,
                                                  child: const Text(
                                                      'Solicitar agente'),
                                                ),
                                              ),
                                            ],
                                          ),
                                SizedBox(
                                  height: height * 0.1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.084,
                          right: MediaQuery.of(context).size.width * 0.08,
                          bottom: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 2600,
                              ),
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                debugPrint('maxWidth: ${constraints.maxWidth}');
                                int rowSegments = 12;
                                if (constraints.maxWidth < 600) {
                                  rowSegments = 2;
                                } else if (constraints.maxWidth < 800) {
                                  rowSegments = 4;
                                } else if (constraints.maxWidth < 1200) {
                                  rowSegments = 4;
                                } else if (constraints.maxWidth < 1400) {
                                  rowSegments = 6;
                                } else if (constraints.maxWidth < 1600) {
                                  rowSegments = 6;
                                } else if (constraints.maxWidth < 1800) {
                                  rowSegments = 8;
                                } else if (constraints.maxWidth < 2200) {
                                  rowSegments = 10;
                                } else if (constraints.maxWidth < 2600) {
                                  rowSegments = 12;
                                }
                                debugPrint('rowSegments: $rowSegments');
                                return BlocBuilder<MissaoSolicitacaoCardBloc,
                                    MissaoSolicitacaoCardState>(
                                  builder: (context, state) {
                                    return ResponsiveGridRow(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      rowSegments: rowSegments,
                                      children: [
                                        for (var missao in missoesFiltrados)
                                          ResponsiveGridCol(
                                            xs: 3,
                                            md: 2,
                                            child: state
                                                    is MissaoJaSolicitadaCard
                                                ? const SizedBox.shrink()
                                                : SolicitacaoMissaoCard(
                                                    key: ValueKey(
                                                        missao.missaoId),
                                                    missaoSolicitada: missao,
                                                    initialContext: context,
                                                  ),
                                          ),
                                      ],
                                    );
                                  },
                                );
                              }),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
              //  ResponsiveGridRow(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   rowSegments: 6,
              //   children: [
              //     //para cada missão solicitada, criar um card
              //     for (var missao in state.missoes)
              //       ResponsiveGridCol(
              //         xs: 3,
              //         md: 2,
              //         child: SolicitacaoMissaoCard(
              //           missaoSolicitada: missao,
              //         ),
              //       ),
              //   ],
              // ),
              //);
              // GridView.builder(
              //   padding: const EdgeInsets.all(12.0),
              //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: cardCount,
              //     crossAxisSpacing: 12.0,
              //     mainAxisSpacing: 12.0,
              //   ),
              //   itemCount: state.missoes.length,
              //   itemBuilder: (context, index) {
              //     return BlocProvider<MissaoSolicitacaoCardBloc>(
              //       create: (context) => MissaoSolicitacaoCardBloc(),
              //       child:
              //  SolicitacaoMissaoCard(
              //   missaoSolicitada: state.missoes[index],
              // ),
              //     );
              //   },
              // );
            }
            //else if (state is MissoesSolicitadasNotFound) {
            //   return const Center(
            //     child: Text(
            //       'Nenhuma solicitação encontrada',
            //       style: TextStyle(color: Colors.white),
            //     ),
            //   );
            // }
            else if (state is MissoesSolicitadasError) {
              return Center(
                  child: Text(
                'Erro: ${state.error}',
                style: const TextStyle(color: Colors.white),
              ));
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Algum erro ocorrreu, reinicie a página.',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buttonsNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        decoration: BoxDecoration(
          color: canvasColor.withOpacity(0.4),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 40),
                            decoration: BoxDecoration(
                                color: _botao == 'localizacao'
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: AutoSizeText(
                              'Localização',
                              maxLines: 1,
                              minFontSize: 10,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _botao != 'localizacao'
                                      ? Colors.grey
                                      : canvasColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _botao = 'localizacao';
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 40),
                            decoration: BoxDecoration(
                                color: _botao == 'coordenada'
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(30)),
                            child: AutoSizeText(
                              'Coordenada',
                              maxLines: 1,
                              minFontSize: 10,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _botao != 'coordenada'
                                      ? Colors.grey
                                      : canvasColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _botao = 'coordenada';
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 40),
                            decoration: BoxDecoration(
                              color: _botao == 'mapa'
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: AutoSizeText(
                              'Mapa',
                              maxLines: 1,
                              minFontSize: 10,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _botao != 'mapa'
                                      ? Colors.grey
                                      : canvasColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _botao = 'mapa';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SolicitacaoDeMissaoCard extends StatelessWidget {
  final MissaoSolicitada missaoSolicitada;
  final BuildContext initialContext;
  final MissaoServices missaoServices;
  const SolicitacaoDeMissaoCard(
      {super.key,
      required this.missaoSolicitada,
      required this.initialContext,
      required this.missaoServices});

  void mostrarListaAgentes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListaAgentesModal(
          missaoSolicitada: missaoSolicitada,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.read<MissaoSolicitacaoCardBloc>().add(
          BuscarMissao(
            missaoId: missaoSolicitada.missaoId,
          ),
        );
    return BlocBuilder<MissaoSolicitacaoCardBloc, MissaoSolicitacaoCardState>(
      builder: (context, state) {
        if (state is MissaoSolicitacaoCardLoading) {
          return Card(
            elevation: 1,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //texts
                  Text(missaoSolicitada.tipo),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  )
                ],
              ),
            ),
          );
        } else if (state is MissaoSolicitacaoCardError) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //texts
                  Text(missaoSolicitada.tipo),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                    ],
                  )
                ],
              ),
            ),
          );
        } else if (state is MissaoJaSolicitadaCard) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //texts
                  Text(missaoSolicitada.tipo),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          debugPrint('exibindo lista...');
                          mostrarListaAgentes(context);
                        },
                        child: const Text('Selecionar agente'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }
        return Card(
          elevation: 1,
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //texts
                Text('Empresa: ${missaoSolicitada.nomeDaEmpresa}'),
                const SizedBox(
                  height: 3,
                ),
                Text('Tipo: ${missaoSolicitada.tipo}'),
                const SizedBox(
                  height: 3,
                ),
                Text('Placa cavalo: ${missaoSolicitada.placaCavalo}'),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'Local: ${missaoSolicitada.local}',
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  'Em: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(missaoSolicitada.timestamp)}',
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.green),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapAddMissao(
                              cnpj: missaoSolicitada.cnpj,
                              nomeDaEmpresa: missaoSolicitada.nomeDaEmpresa,
                              placaCavalo: missaoSolicitada.placaCavalo,
                              placaCarreta: missaoSolicitada.placaCarreta,
                              motorista: missaoSolicitada.motorista,
                              corVeiculo: missaoSolicitada.corVeiculo,
                              observacao: missaoSolicitada.observacao,
                              latitude: missaoSolicitada.latitude,
                              longitude: missaoSolicitada.longitude,
                              local: missaoSolicitada.local,
                              tipo: missaoSolicitada.tipo,
                              missaoId: missaoSolicitada.missaoId,
                            ),
                          ),
                        );
                      },
                      child: const Text('Selecionar agente'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.red),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Atenção'),
                              content: const Column(
                                children: [
                                  Text(
                                      'Rejeitar missão? Esta ação não poderá ser desfeita!')
                                ],
                              ),
                              actions: <Widget>[
                                BlocBuilder<ElevatedButtonBloc,
                                    ElevatedButtonBlocState>(
                                  builder: (context, state) {
                                    if (state is ElevatedButtonBlocLoading) {
                                      return const CircularProgressIndicator();
                                    }
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          child: const Text('Rejeitar'),
                                          onPressed: () async {
                                            context
                                                .read<ElevatedButtonBloc>()
                                                .add(ElevatedButtonPressed());
                                            try {
                                              await missaoServices
                                                  .rejeitarSolicitacao(
                                                      missaoSolicitada.missaoId,
                                                      missaoSolicitada.cnpj,
                                                      missaoSolicitada.local,
                                                      missaoSolicitada
                                                          .timestamp);
                                              context
                                                  .read<ElevatedButtonBloc>()
                                                  .add(ElevatedButtonReset());
                                            } catch (e) {
                                              context
                                                  .read<ElevatedButtonBloc>()
                                                  .add(ElevatedButtonReset());
                                              debugPrint(
                                                  'erro ao rejeitar missao: ${e.toString()}');
                                              tratamentoDeErros
                                                  .showErrorSnackbar(context,
                                                      'Erro, tente novamente');
                                            }
                                          },
                                        ),
                                        TextButton(
                                          child: const Text(
                                            'Voltar',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                )
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Rejeitar missão'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class MapAddMissao extends StatefulWidget {
  // final Place? startPosition;
  // final Place? endPosition;
  //final Place? missionPosition;
  final String? cnpj;
  final String? nomeDaEmpresa;
  final String? placaCavalo;
  final String? placaCarreta;
  final String? motorista;
  final String? corVeiculo;
  final String? observacao;
  final double? latitude;
  final double? longitude;
  final String? local;
  final String? missaoId;
  final String tipo;

  const MapAddMissao({
    super.key,
    // this.startPosition,
    // this.endPosition,
    //this.missionPosition,
    this.cnpj,
    this.nomeDaEmpresa,
    this.placaCavalo,
    this.placaCarreta,
    this.motorista,
    this.corVeiculo,
    this.observacao,
    this.latitude,
    this.longitude,
    this.local,
    this.missaoId,
    required this.tipo,
  });

  @override
  _MapAddMissaoState createState() => _MapAddMissaoState();
}

class _MapAddMissaoState extends State<MapAddMissao> {
  late gmap.CameraPosition _initialPosition;
  final Completer<gmap.GoogleMapController> _controller = Completer();
  final Set<gmap.Polyline> _polylines = <gmap.Polyline>{};
  // ignore: unused_field
  Uint8List? _userIcon;
  UserServices userServices = UserServices();
  Set<gmap.Marker> userMarkers = {};
  MapaServices mapaServices = MapaServices();
  List<Map<String, dynamic>> agentesMaisProximos = [];
  Set<Map<String, dynamic>> agentesSelecionados = <Map<String, dynamic>>{};
  MissaoServices missaoServices = MissaoServices();
  bool scrollingEnabled = true;
  gmap.BitmapDescriptor? icon;

  @override
  void initState() {
    super.initState();
    _initialPosition = gmap.CameraPosition(
      target: gmap.LatLng(
        widget.latitude!,
        widget.longitude!,
      ),
      zoom: 14.4746,
    );
    _loadPhotoBytes();
    _loadUserLocations().then((_) {
      fetchNearestUsersToMission(gmap.LatLng(
        widget.latitude!,
        widget.longitude!,
      ));
    });
    _testGetPlaceFromLatLng();
    getIcon();
  }

  Future<void> getIcon() async {
    final icon = await gmap.BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/images/missionIcon.png');
    setState(
      () {
        this.icon = icon;
      },
    );
  }

  Future<void> _loadUserLocations() async {
    final locations = await mapaServices.fetchAllUsersLocations();
    debugPrint('Locations loaded: ${locations.length}');
    setState(() {
      for (var location in locations) {
        userMarkers.add(
          gmap.Marker(
            infoWindow: gmap.InfoWindow(
              title: location.nomeDoAgente,
              snippet: 'Nível do agente:',
              onTap: () {
                debugPrint('Marker tapped');
              },
            ),
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
      gmap.Marker(
        markerId: const gmap.MarkerId('mission'),
        position: gmap.LatLng(
          widget.latitude!,
          widget.longitude!,
        ),
        icon: icon ??
            gmap.BitmapDescriptor.defaultMarkerWithHue(
                gmap.BitmapDescriptor.hueBlue),
      ),
    };

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        title: const Text(
          'Enviar Chamado',
          //style: TextStyle(color: Colors.black),
        ),
        //backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        //   icon: const CircleAvatar(
        //     //backgroundColor: Colors.white,
        //     child: Icon(
        //       Icons.arrow_back,
        //       //color: Colors.black,
        //     ),
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        physics: scrollingEnabled
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            MouseRegion(
              onEnter: (_) => setState(() => scrollingEnabled = false),
              onExit: (_) => setState(() => scrollingEnabled = true),
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.6, // 60% da altura da tela
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
            ),
            const SizedBox(
              height: 5,
            ),
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const Padding(
            //       padding: EdgeInsets.all(10),
            //       child: Text('Dados da missão'),
            //     ),
            //     ResponsiveRowColumn(
            //       layout: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
            //           ? ResponsiveRowColumnType.COLUMN
            //           : ResponsiveRowColumnType.ROW,
            //       children: [
            //         ResponsiveRowColumnItem(
            //           child: Padding(
            //             padding: const EdgeInsets.all(10),
            //             child: Text('Empresa: ${widget.nomeDaEmpresa}'),
            //           ),
            //         ),
            //         ResponsiveRowColumnItem(
            //           child: Padding(
            //             padding: const EdgeInsets.all(10),
            //             child: Text('Local: ${widget.local}'),
            //           ),
            //         ),
            //         ResponsiveRowColumnItem(
            //           child: Padding(
            //             padding: const EdgeInsets.all(10),
            //             child: Text('Placa cavalo: ${widget.placaCavalo}'),
            //           ),
            //         ),
            //         ResponsiveRowColumnItem(
            //           child: Padding(
            //             padding: const EdgeInsets.all(10),
            //             child: Text('Placa carreta: ${widget.placaCarreta}'),
            //           ),
            //         ),
            //         ResponsiveRowColumnItem(
            //           child: Padding(
            //             padding: const EdgeInsets.all(10),
            //             child: Text('Motorista: ${widget.motorista}'),
            //           ),
            //         ),
            //         ResponsiveRowColumnItem(
            //           child: Padding(
            //             padding: const EdgeInsets.all(10),
            //             child: Text('Cor do veículo: ${widget.corVeiculo}'),
            //           ),
            //         ),
            //         ResponsiveRowColumnItem(
            //           child: Padding(
            //             padding: const EdgeInsets.all(10),
            //             child: Text('Observação: ${widget.observacao}'),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            const SizedBox(
              height: 5,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'SELECIONE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double maxWidth = constraints.maxWidth * 0.6;

                return agentesMaisProximos.isEmpty
                    ? const Center(
                        child: Text(
                            'Nenhum agente encontrado, aguarde e tente novamente.'),
                      )
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              maxWidth, // Use maxWidth como a largura máxima
                        ),
                        child: Column(
                          children: agentesMaisProximos
                              .asMap()
                              .entries
                              .map(
                                (entry) => Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${entry.key + 1}. ',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Expanded(
                                              child: Text(
                                                '${entry.value['nome']} - ${entry.value['distance'].toStringAsFixed(2)} km',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Checkbox(
                                              checkColor: Colors.green,
                                              //cor de fundo do checkbox
                                              activeColor: Colors.transparent,
                                              //cor da borda do checkbox quando selecionado
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                side: const BorderSide(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              value: agentesSelecionados.any(
                                                  (agente) =>
                                                      agente['uid'] ==
                                                      entry.value['uid']),
                                              onChanged: (bool? value) {
                                                setState(
                                                  () {
                                                    if (value == true) {
                                                      agentesSelecionados.add({
                                                        'uid':
                                                            entry.value['uid'],
                                                        'latitude': entry
                                                            .value['latitude'],
                                                        'longitude': entry
                                                            .value['longitude']
                                                      });
                                                    } else {
                                                      agentesSelecionados
                                                          .removeWhere(
                                                              (agente) =>
                                                                  agente[
                                                                      'uid'] ==
                                                                  entry.value[
                                                                      'uid']);
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                    'Endereço do agente: ${entry.value['endereco']}'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    'Uid do agente: ${entry.value['uid']}'),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    'Atualizado em: ${intl.DateFormat('dd/MM/yyyy HH:mm').format(
                                                  entry.value['timestamp'],
                                                )}'),
                                              ],
                                            ),
                                            entry.value['rejeitou'] == true
                                                ? const Row(
                                                    children: [
                                                      Text(
                                                        ' - Agente rejeitou o chamado',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  )
                                                : const SizedBox.shrink()
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            BlocBuilder<ElevatedButtonBloc2, ElevatedButtonBloc2State>(
              builder: (context, buttonState) {
                return agentesMaisProximos.isEmpty
                    ? const SizedBox.shrink()
                    : ElevatedButton(
                        // style: ElevatedButton.styleFrom(
                        //   backgroundColor: Colors.blue.withOpacity(0.3),
                        // ),
                        onPressed: () async {
                          if (agentesSelecionados.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Aviso'),
                                  content: const Text(
                                      'Selecione pelo menos um agente para enviar a missão'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Ok'),
                                    ),
                                  ],
                                );
                              },
                            );
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmação'),
                                content: const Text('Deseja enviar a missão?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancelar'),
                                  ),
                                  buttonState is ElevatedButtonBloc2Loading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : TextButton(
                                          onPressed: () async {
                                            BlocProvider.of<
                                                        ElevatedButtonBloc2>(
                                                    context)
                                                .add(ElevatedButton2Pressed());
                                            for (var agenteSelecionado
                                                in agentesSelecionados) {
                                              try {
                                                await missaoServices
                                                    .criarChamado(
                                                  widget.cnpj!,
                                                  widget.nomeDaEmpresa!,
                                                  widget.placaCavalo!,
                                                  widget.placaCarreta!,
                                                  widget.motorista!,
                                                  widget.corVeiculo!,
                                                  widget.observacao!,
                                                  widget.missaoId!,
                                                  agenteSelecionado['uid'],
                                                  widget.tipo,
                                                  agenteSelecionado['latitude'],
                                                  agenteSelecionado[
                                                      'longitude'],
                                                  widget.latitude!,
                                                  widget.longitude!,
                                                  widget.local!,
                                                );
                                                await missaoServices
                                                    .criarMissaoPendente(
                                                  widget.cnpj!,
                                                  widget.nomeDaEmpresa!,
                                                  widget.placaCavalo!,
                                                  widget.placaCarreta!,
                                                  widget.motorista!,
                                                  widget.corVeiculo!,
                                                  widget.observacao!,
                                                  widget.missaoId!,
                                                  agenteSelecionado['uid'],
                                                  widget.tipo,
                                                  agenteSelecionado['latitude'],
                                                  agenteSelecionado[
                                                      'longitude'],
                                                  widget.latitude!,
                                                  widget.longitude!,
                                                  widget.local!,
                                                );
                                                await missaoServices
                                                    .excluirMissaoSolicitada(
                                                        widget.missaoId!,
                                                        widget.cnpj!);
                                                if (context.mounted) {
                                                  context
                                                      .read<
                                                          MissoesSolicitadasBloc>()
                                                      .add(BuscarMissoes());
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                }
                                                BlocProvider.of<
                                                            ElevatedButtonBloc2>(
                                                        context)
                                                    .add(
                                                        ElevatedButton2Reset());
                                                mensagemDeSucesso
                                                    .showSuccessSnackbar(
                                                        context,
                                                        'Chamado enviado com sucesso');
                                              } catch (e) {
                                                BlocProvider.of<
                                                            ElevatedButtonBloc2>(
                                                        context)
                                                    .add(
                                                        ElevatedButton2Reset());
                                                tratamentoDeErros.showErrorSnackbar(
                                                    context,
                                                    'Erro ao enviar chamado, tente novamente');
                                                debugPrint(
                                                    'Erro ao criar chamado: $e');
                                              }
                                              List<String> userTokens =
                                                  await firebaseMessagingService
                                                      .fetchUserTokens(
                                                          agenteSelecionado[
                                                              'uid']);

                                              debugPrint('Tokens: $userTokens');

                                              for (String token in userTokens) {
                                                debugPrint('FCM Token: $token');
                                                try {
                                                  await firebaseMessagingService
                                                      .sendNotification(
                                                          token,
                                                          'ATENÇÃO',
                                                          'Você recebeu um chamado de missão!',
                                                          'cadastro');
                                                  debugPrint(
                                                      'Notificação enviada');
                                                } catch (e) {
                                                  debugPrint(
                                                      'Erro ao enviar notificação: $e');
                                                }
                                              }
                                            }
                                          },
                                          child: const Text("Enviar Missão"),
                                        ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text("Enviar Missão"),
                      );
              },
            ),
            const SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.withOpacity(0.3),
        child: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return MissionDetailsDialog(
                  cnpj: widget.cnpj,
                  nomeDaEmpresa: widget.nomeDaEmpresa,
                  placaCavalo: widget.placaCavalo,
                  placaCarreta: widget.placaCarreta,
                  motorista: widget.motorista,
                  corVeiculo: widget.corVeiculo,
                  observacao: widget.observacao,
                  latitude: widget.latitude,
                  longitude: widget.longitude,
                  local: widget.local,
                  missaoId: widget.missaoId,
                  tipo: widget.tipo,
                );
              });
        },
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

  Future<void> fetchNearestUsersToMission(missionPosition) async {
    debugPrint('Fetching nearest users...');
    debugPrint("Lat: ${widget.latitude!}, Lng: ${widget.longitude!}");

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

    // Exibe os nomes dos dez usuários mais próximos
    for (var entry in distances.take(10)) {
      bool emMissaoResult =
          await missaoServices.emMissao((entry['user'] as UserLocation).uid);
      bool jaTemChamado = await missaoServices
          .verificarSeAgenteTemChamado((entry['user'] as UserLocation).uid);

      bool agenteEstaDisponivel = await missaoServices
          .verificarSeAgenteEstaDisponivel((entry['user'] as UserLocation).uid);
      debugPrint('Em missão: $emMissaoResult');
      debugPrint('Já tem chamado: $jaTemChamado');
      debugPrint('========Agente disponível: $agenteEstaDisponivel=======');

      bool? agenteJaRejeitouChamado =
          await missaoServices.verificarSeAgenteRejeitou(
              (entry['user'] as UserLocation).uid, widget.missaoId);

      if (!emMissaoResult && !jaTemChamado && agenteEstaDisponivel) {
        String? enderecoAgente =
            await fetchAgentAddress((entry['user'] as UserLocation).uid);

        agentesMaisProximos.add({
          'nome': (entry['user'] as UserLocation).nomeDoAgente,
          'uid': (entry['user'] as UserLocation).uid,
          'latitude': (entry['user'] as UserLocation).latitude,
          'longitude': (entry['user'] as UserLocation).longitude,
          'distance': entry['distance'],
          'endereco': enderecoAgente,
          'timestamp': (entry['user'] as UserLocation).timestamp.toDate(),
          'rejeitou': agenteJaRejeitouChamado,
        });
      }
    }
    setState(() {});
  }

  Future<String?> fetchAgentAddress(String uid) async {
    Agente? agente = await AgenteServices().getAgenteInfos(uid);
    final logradouro = agente?.logradouro;
    final numero = agente?.numero;
    final bairro = agente?.bairro;
    final cidade = agente?.cidade;
    final estado = agente?.estado;
    final endereco = '$logradouro, $numero, $bairro - $cidade/$estado';
    return endereco;
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

  Future<void> _testGetPlaceFromLatLng() async {
    LatLng rioCoord = const LatLng(lat: -22.9519, lng: -43.2105);
    Place? place = await getPlaceFromLatLng(rioCoord);
    if (place != null) {
      debugPrint('Endereço encontrado: ${place.address}');
    } else {
      debugPrint(
          'Nenhum endereço foi encontrado para as coordenadas fornecidas.');
    }
  }
}

class ListaAgentesModal extends StatefulWidget {
  final MissaoSolicitada missaoSolicitada;
  const ListaAgentesModal({
    super.key,
    required this.missaoSolicitada,
  });

  @override
  State<ListaAgentesModal> createState() => _ListaAgentesModalState();
}

final NotificationService notificationService = NotificationService();
final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

final FirebaseMessagingService firebaseMessagingService =
    FirebaseMessagingService(notificationService);

class _ListaAgentesModalState extends State<ListaAgentesModal> {
  String? _selectedAgentUid;
  String? _selectedAgentNome;
  double? _selectedAgentLatitude;
  double? _selectedAgentLongitude;
  MissaoServices missaoServices = MissaoServices();
  List<Map<String, dynamic>> agentes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    carregarAgentes();
  }

  void carregarAgentes() async {
    var agentesObtidos = await missaoServices
        .buscarAgentesQueAceitaram(widget.missaoSolicitada.missaoId);
    for (var agente in agentesObtidos) {
      String uid = agente['userUid'];
      var agenteInfos = await AgenteServices().getAgenteInfos(uid);
      //adicionar o endereço do agente
      agente['endereco'] = agenteInfos?.cidade;
    }
    setState(
      () {
        agentes = agentesObtidos;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: agentes.isEmpty
              ? const Center(
                  child: Text('Nenhum agente disponível, aguarde'),
                )
              : ListView.builder(
                  itemCount: agentes.length,
                  itemBuilder: (context, index) {
                    var agente = agentes[index];
                    String nomeAgente = agente['nome'] ?? 'Nome não disponível';
                    String uidAgente =
                        agente['userUid'] ?? 'UID não disponível';
                    double agenteLatitude = agente['userLatitude'];
                    double agenteLongitude = agente['userLongitude'];
                    String? endereco = agente['endereco'];
                    return ListTile(
                      title: Text(nomeAgente),
                      subtitle: Text(endereco ?? 'Endereço não disponível'),
                      leading: Radio<String>(
                        value: uidAgente,
                        groupValue: _selectedAgentUid,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedAgentUid = value;
                            _selectedAgentNome = nomeAgente;
                            _selectedAgentLatitude = agenteLatitude;
                            _selectedAgentLongitude = agenteLongitude;
                          });
                        },
                      ),
                    );
                  },
                ),
        ),
        BlocBuilder<ElevatedButtonBloc3, ElevatedButtonBloc3State>(
          builder: (context, state) {
            if (state is ElevatedButtonBloc3Loading) {
              return const CircularProgressIndicator();
            } else {
              return agentes.isNotEmpty
                  ? ElevatedButton(
                      onPressed: !isLoading
                          ? () async {
                              BlocProvider.of<ElevatedButtonBloc3>(context)
                                  .add(ElevatedButton3Pressed());
                              // Enviar a missão para o agente selecionado
                              setState(() {
                                isLoading = true;
                              });

                              bool sucesso = false;
                              if (_selectedAgentUid != null) {
                                try {
                                  sucesso = await missaoServices.criarMissao(
                                    widget.missaoSolicitada.cnpj,
                                    widget.missaoSolicitada.nomeDaEmpresa,
                                    widget.missaoSolicitada.placaCavalo,
                                    widget.missaoSolicitada.placaCarreta,
                                    widget.missaoSolicitada.motorista,
                                    widget.missaoSolicitada.corVeiculo,
                                    widget.missaoSolicitada.observacao,
                                    _selectedAgentUid!,
                                    _selectedAgentLatitude,
                                    _selectedAgentLongitude,
                                    widget.missaoSolicitada.latitude,
                                    widget.missaoSolicitada.longitude,
                                    widget.missaoSolicitada.local,
                                    widget.missaoSolicitada.tipo,
                                    widget.missaoSolicitada.missaoId,
                                    _selectedAgentNome,
                                  );
                                  await missaoServices.excluirMissaoPendente(
                                      widget.missaoSolicitada.missaoId,
                                      widget.missaoSolicitada.cnpj);

                                  debugPrint(
                                      'Missão enviada para o agente UID: $_selectedAgentUid');
                                  context.mounted
                                      ? mensagemDeSucesso.showSuccessSnackbar(
                                          context, 'Missão enviada com sucesso')
                                      : null;

                                  BlocProvider.of<ElevatedButtonBloc3>(context)
                                      .add(ElevatedButton3Reset());
                                } catch (e) {
                                  debugPrint('Erro ao enviar missão: $e');
                                  context.mounted
                                      ? tratamentoDeErros.showErrorSnackbar(
                                          context,
                                          'Erro ao enviar missão, tente novamente')
                                      : null;
                                  BlocProvider.of<ElevatedButtonBloc3>(context)
                                      .add(ElevatedButton3Reset());
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                              // Realizar a ação com os agentes não selecionados
                              if (sucesso == true) {
                                List<String> userTokens =
                                    await firebaseMessagingService
                                        .fetchUserTokens(_selectedAgentUid!);

                                debugPrint('Tokens: $userTokens');

                                for (String token in userTokens) {
                                  debugPrint('FCM Token: $token');
                                  try {
                                    await firebaseMessagingService
                                        .sendNotification(token, 'ATENÇÃO',
                                            'Você está em missão', 'Missão');
                                    debugPrint('Notificação enviada');
                                  } catch (e) {
                                    debugPrint(
                                        'Erro ao enviar notificação: $e');
                                  }
                                }
                                for (var agente in agentes) {
                                  if (agente['userUid'] != _selectedAgentUid) {
                                    await missaoServices
                                        .recusadoPelaCentral(agente['userUid']);
                                    debugPrint(
                                        'Ação realizada com o agente UID: ${agente['userUid']}');
                                  }
                                  if (context.mounted) {
                                    BlocProvider.of<MissoesPendentesBloc>(
                                            context)
                                        .add(BuscarMissoesPendentes());
                                    setState(() {
                                      isLoading = false;
                                    });
                                    //MissoesPendentesBloc().add(BuscarMissoesPendentes());
                                    Navigator.pop(context);
                                  }
                                }
                              }
                            }
                          : null,
                      child: const Text('Enviar missão'),
                    )
                  : const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: SizedBox(
        height: 40,
        width: width * 0.33,
        child: TextFormField(
          cursorHeight: 14,
          controller: controller,
          onChanged: (value) {
            // Update the button state or any other logic needed here
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

class ActorItem extends StatelessWidget {
  final Empresa empresa;

  const ActorItem({
    super.key,
    required this.empresa,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const Icon(
                Icons.business_center,
                color: Colors.black,
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Empresa: ${empresa.nomeEmpresa}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'CNPJ: ${empresa.cnpj}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text('Nenhuma empresa encontrada'),
      ],
    );
  }
}

class Actor {
  int age;
  String name;
  String lastName;

  Actor({
    required this.age,
    required this.name,
    required this.lastName,
  });
}
