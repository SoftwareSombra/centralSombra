import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra/widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import '../../../../../missao/model/missao_model.dart';
import '../../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';
import '../bloc/mission_details_bloc.dart';
import '../bloc/mission_details_event.dart';
import '../services/relatorio_services.dart';

class EditRelatorioDialog extends StatefulWidget {
  final MissaoRelatorio relatorio;
  const EditRelatorioDialog({super.key, required this.relatorio});

  @override
  State<EditRelatorioDialog> createState() => _EditRelatorioDialogState();
}

TextEditingController? cnpjController;
TextEditingController? nomeDaEmpresaController;
TextEditingController? placaCavaloController;
TextEditingController? placaCarretaController;
TextEditingController? motoristaController;
TextEditingController? corVeiculoController;
TextEditingController? observacaoController;
TextEditingController? tipoController;
TextEditingController? missaoIdController;
TextEditingController? uidController;
TextEditingController? localController;
TextEditingController? infosController;
TextEditingController? nomeController;
TextEditingController? infosComplementaresController;
final RelatorioServices relatorioServices = RelatorioServices();
final TratamentoDeErros tratamento = TratamentoDeErros();
final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

class _EditRelatorioDialogState extends State<EditRelatorioDialog> {
  @override
  void initState() {
    initControllers();
    super.initState();
  }

  @override
  void dispose() {
    cnpjController?.dispose();
    nomeDaEmpresaController?.dispose();
    placaCavaloController?.dispose();
    placaCarretaController?.dispose();
    motoristaController?.dispose();
    corVeiculoController?.dispose();
    observacaoController?.dispose();
    tipoController?.dispose();
    missaoIdController?.dispose();
    uidController?.dispose();
    localController?.dispose();
    infosController?.dispose();
    nomeController?.dispose();
    infosComplementaresController?.dispose();
    super.dispose();
  }

  void initControllers() {
    cnpjController = TextEditingController(text: widget.relatorio.cnpj);
    nomeDaEmpresaController =
        TextEditingController(text: widget.relatorio.nomeDaEmpresa);
    placaCavaloController =
        TextEditingController(text: widget.relatorio.placaCavalo);
    placaCarretaController =
        TextEditingController(text: widget.relatorio.placaCarreta);
    motoristaController =
        TextEditingController(text: widget.relatorio.motorista);
    corVeiculoController =
        TextEditingController(text: widget.relatorio.corVeiculo);
    observacaoController =
        TextEditingController(text: widget.relatorio.observacao);
    tipoController = TextEditingController(text: widget.relatorio.tipo);
    missaoIdController = TextEditingController(text: widget.relatorio.missaoId);
    uidController = TextEditingController(text: widget.relatorio.uid);
    localController = TextEditingController(text: widget.relatorio.local);
    infosController = TextEditingController(text: widget.relatorio.infos);
    nomeController = TextEditingController(text: widget.relatorio.nome);
    infosComplementaresController =
        TextEditingController(text: widget.relatorio.infosComplementares);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'EDITAR CAMPOS',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      content: Container(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ResponsiveRowColumn(
                      layout:
                          ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                      rowMainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.3,
                              child: TextFormField(
                                controller: placaCavaloController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Placa Cavalo',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? const ResponsiveRowColumnItem(
                                child: SizedBox(height: 10),
                              )
                            : const ResponsiveRowColumnItem(
                                child: SizedBox(width: 10),
                              ),
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.3,
                              child: TextFormField(
                                controller: placaCarretaController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Placa Carreta',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ResponsiveRowColumn(
                      layout:
                          ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                      rowMainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.3,
                              child: TextFormField(
                                controller: motoristaController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Motorista',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? const ResponsiveRowColumnItem(
                                child: SizedBox(height: 10),
                              )
                            : const ResponsiveRowColumnItem(
                                child: SizedBox(width: 10),
                              ),
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.3,
                              child: TextFormField(
                                controller: corVeiculoController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Cor do Veículo',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ResponsiveRowColumn(
                      layout:
                          ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                      rowMainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.3,
                              child: TextFormField(
                                controller: observacaoController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Observação',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? const ResponsiveRowColumnItem(
                                child: SizedBox(height: 10),
                              )
                            : const ResponsiveRowColumnItem(
                                child: SizedBox(width: 10),
                              ),
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.3,
                              child: TextFormField(
                                controller: tipoController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Tipo',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ResponsiveRowColumn(
                      layout:
                          ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                      rowMainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.3,
                              child: TextFormField(
                                controller: nomeController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Nome do agente',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? const ResponsiveRowColumnItem(
                                child: SizedBox(height: 10),
                              )
                            : const ResponsiveRowColumnItem(
                                child: SizedBox(width: 10),
                              ),
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.3,
                              child: TextFormField(
                                controller: localController,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Local',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ResponsiveRowColumn(
                      layout:
                          ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                      rowMainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.6 + 10,
                              child: TextFormField(
                                controller: infosController,
                                minLines: 1,
                                maxLines: 10,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Informações da missão',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ResponsiveRowColumn(
                      layout:
                          ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                      rowMainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SizedBox(
                              width: ResponsiveBreakpoints.of(context)
                                      .smallerThan(DESKTOP)
                                  ? width * 0.6 + 10
                                  : width * 0.6 + 10,
                              child: TextFormField(
                                controller: infosComplementaresController,
                                minLines: 1,
                                maxLines: 10,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  focusColor: Colors.white,
                                  hoverColor: Colors.white,
                                  labelText: 'Informações Complementares',
                                  labelStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
      ),
      actions: [
        BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
          builder: (context, state) {
            if (state is ElevatedButtonBlocLoading) {
              return const CircularProgressIndicator();
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    BlocProvider.of<ElevatedButtonBloc>(context).add(
                      ElevatedButtonReset(),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Voltar',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    BlocProvider.of<ElevatedButtonBloc>(context).add(
                      ElevatedButtonPressed(),
                    );
                    try {
                      await relatorioServices.editarRelatorio(
                        MissaoRelatorio(
                            cnpj: widget.relatorio.cnpj,
                            nomeDaEmpresa: widget.relatorio.nomeDaEmpresa,
                            tipo: tipoController!.text.trim(),
                            missaoId: widget.relatorio.missaoId,
                            uid: widget.relatorio.uid,
                            userLatitude: widget.relatorio.userLatitude,
                            userLongitude: widget.relatorio.userLatitude,
                            missaoLatitude: widget.relatorio.missaoLatitude,
                            missaoLongitude: widget.relatorio.missaoLongitude,
                            placaCarreta: placaCarretaController!.text.trim(),
                            placaCavalo: placaCavaloController!.text.trim(),
                            motorista: motoristaController!.text.trim(),
                            observacao: observacaoController!.text.trim(),
                            local: localController!.text.trim(),
                            corVeiculo: corVeiculoController!.text.trim(),
                            infos: infosController!.text.trim(),
                            infosComplementares:
                                infosComplementaresController!.text.trim(),
                            nome: nomeController!.text.trim(),
                            fim: widget.relatorio.fim,
                            //fotos: widget.relatorio.fotos,
                            //fotosPosMissao: widget.relatorio.fotosPosMissao,
                            userFinalLatitude:
                                widget.relatorio.userFinalLatitude,
                            userFinalLongitude:
                                widget.relatorio.userFinalLongitude,
                            serverFim: widget.relatorio.serverFim,
                            inicio: widget.relatorio.inicio),
                      );
                    } catch (e) {
                      debugPrint(
                          'Erro ao editar relatorio ----> ${e.toString()}');
                      BlocProvider.of<ElevatedButtonBloc>(context).add(
                        ElevatedButtonReset(),
                      );
                      tratamento.showErrorSnackbar(context,
                          'Erro ao tentar editar relatório, tente novamente!');
                    }
                    BlocProvider.of<ElevatedButtonBloc>(context).add(
                      ElevatedButtonReset(),
                    );
                    BlocProvider.of<MissionDetailsBloc>(context).add(
                      FetchMissionDetails(
                          widget.relatorio.uid, widget.relatorio.missaoId),
                    );
                    Navigator.of(context).pop();
                    mensagemDeSucesso.showSuccessSnackbar(
                        context, 'Relatório editado com sucesso');
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
