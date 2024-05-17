import 'package:brasil_fields/brasil_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra_testes/widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import '../../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import '../../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_state.dart';
import '../../services/admin_services.dart';
import '../model/agente_model.dart';

class AgenteDetailsScreen extends StatefulWidget {
  final AgenteAdmList agente;
  const AgenteDetailsScreen({super.key, required this.agente});

  @override
  State<AgenteDetailsScreen> createState() => _AgenteDetailsScreenState();
}

class _AgenteDetailsScreenState extends State<AgenteDetailsScreen> {
  TextEditingController? rgController;
  TextEditingController? cpfController;
  TextEditingController? celularController;
  TextEditingController? nivelController;
  TextEditingController? enderecoController;
  TextEditingController? logradouroController;
  TextEditingController? complementoController;
  TextEditingController? numeroController;
  TextEditingController? bairroController;
  TextEditingController? cepController;
  TextEditingController? cidadeController;
  TextEditingController? estadoController;
  bool readOnly = true;
  final AdminServices adminServices = AdminServices();

  @override
  void initState() {
    super.initState();
    rgController = TextEditingController(text: widget.agente.rg);
    cpfController = TextEditingController(text: widget.agente.cpf);
    celularController = TextEditingController(text: widget.agente.celular);
    nivelController = TextEditingController(text: widget.agente.nivel);
    enderecoController = TextEditingController(
        text:
            '${widget.agente.logradouro}, nº ${widget.agente.numero}, ${widget.agente.bairro} (${widget.agente.complemento}), ${widget.agente.cidade} ${widget.agente.cep} - ${widget.agente.estado}');
    logradouroController =
        TextEditingController(text: widget.agente.logradouro);
    complementoController =
        TextEditingController(text: widget.agente.complemento);
    numeroController = TextEditingController(text: widget.agente.numero);
    bairroController = TextEditingController(text: widget.agente.bairro);
    cepController = TextEditingController(text: widget.agente.cep);
    cidadeController = TextEditingController(text: widget.agente.cidade);
    estadoController = TextEditingController(text: widget.agente.estado);
  }

  @override
  void dispose() {
    rgController!.dispose();
    cpfController!.dispose();
    celularController!.dispose();
    nivelController!.dispose();
    enderecoController!.dispose();
    super.dispose();
  }

  void toggleReadOnly(bool value) {
    setState(() {
      readOnly = value;
    });
  }

  void saveAgentDetails() async {
    // Indicar início da operação de salvamento
    context.read<ElevatedButtonBloc>().add(ElevatedButtonPressed());

    DateTime now = DateTime.now().toUtc().subtract(const Duration(hours: 3));

    bool success = await adminServices.editUserInfos(
        widget.agente.uid,
        logradouroController!.text,
        numeroController!.text,
        bairroController!.text,
        cidadeController!.text,
        estadoController!.text,
        complementoController!.text,
        cepController!.text,
        celularController!.text,
        rgController!.text,
        cpfController!.text,
        widget.agente.rgFotoFrenteUrl,
        widget.agente.rgFotoVersoUrl,
        widget.agente.compResidFotoUrl,
        now,
        widget.agente.nome);

    if (success) {
      setState(() {
        // Atualizar os valores dos controladores para refletir os dados salvos
        updateTextControllers();
      });

      // Fechar qualquer modal aberto e mostrar snackbar
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alterações salvas com sucesso')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao salvar as alterações, tente novamente')));
    }

    // Indicar fim da operação de salvamento
    context.read<ElevatedButtonBloc>().add(ElevatedButtonReset());
  }

  void updateTextControllers() {
    setState(() {
      readOnly = true;
      rgController!.text = widget.agente.rg;
      cpfController!.text = widget.agente.cpf;
      celularController!.text = widget.agente.celular;
      nivelController!.text = widget.agente.nivel ?? '';
      logradouroController!.text = widget.agente.logradouro;
      complementoController!.text = widget.agente.complemento;
      numeroController!.text = widget.agente.numero;
      bairroController!.text = widget.agente.bairro;
      cepController!.text = widget.agente.cep;
      cidadeController!.text = widget.agente.cidade;
      estadoController!.text = widget.agente.estado;
      enderecoController!.text =
          '${widget.agente.logradouro}, nº ${widget.agente.numero}, ${widget.agente.bairro} (${widget.agente.complemento}), ${widget.agente.cidade} ${widget.agente.cep} - ${widget.agente.estado}';
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        title: const Text(
          'DETALHES DO AGENTE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.15, vertical: height * 0.05),
              child: ResponsiveRowColumn(
                layout: ResponsiveBreakpoints.of(context).smallerThan(TABLET)
                    ? ResponsiveRowColumnType.COLUMN
                    : ResponsiveRowColumnType.ROW,
                rowCrossAxisAlignment: CrossAxisAlignment.end,
                rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ResponsiveRowColumnItem(
                    child: ResponsiveRowColumn(
                      layout:
                          ResponsiveBreakpoints.of(context).smallerThan(TABLET)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                      rowCrossAxisAlignment: CrossAxisAlignment.end,
                      rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: CircleAvatar(
                              //width: width * 0.2,
                              //height: height * 0.2,
                              backgroundColor:
                                  const Color.fromARGB(255, 3, 9, 18),
                              foregroundColor:
                                  const Color.fromARGB(255, 3, 9, 18),
                              radius: width > 600 ? width * 0.05 : width * 0.09,
                              backgroundImage:
                                  //image:
                                  const CachedNetworkImageProvider(
                                      'assets/images/fotoDePerfilNull.jpg'),
                            ),
                          ),
                        ),
                        ResponsiveRowColumnItem(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    width > 600 ? width * 0.02 : width * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SelectableText(
                                  widget.agente.nome,
                                  style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w400),
                                ),
                                SelectableText(
                                  'UID: ${widget.agente.uid}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    readOnly
                                        ? MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text('Editar'),
                                                    content: const Text(
                                                        'Deseja editar os dados do agente?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Fechar'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          toggleReadOnly(false);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Editar'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons.edit,
                                                    color: Colors.blue,
                                                    size: 15,
                                                  ),
                                                  SizedBox(
                                                    height: 1,
                                                  ),
                                                  Text(
                                                    'Editar',
                                                    style: TextStyle(
                                                      //color: Colors.blue,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        :
                                        //salvar alterações
                                        MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const Text('Salvar'),
                                                    content: const Text(
                                                        'Deseja salvar as alterações?'),
                                                    actions: [
                                                      BlocBuilder<
                                                          ElevatedButtonBloc,
                                                          ElevatedButtonBlocState>(
                                                        builder:
                                                            (context, state) {
                                                          if (state
                                                              is ElevatedButtonBlocLoading) {
                                                            return const CircularProgressIndicator();
                                                          } else {
                                                            return Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      'Fechar'),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () async {
                                                                    saveAgentDetails();
                                                                  },
                                                                  child: const Text(
                                                                      'Salvar'),
                                                                ),
                                                              ],
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: const Column(
                                                children: [
                                                  Icon(
                                                    Icons.save,
                                                    color: Colors.green,
                                                    size: 15,
                                                  ),
                                                  SizedBox(
                                                    height: 1,
                                                  ),
                                                  Text(
                                                    'Salvar',
                                                    style: TextStyle(
                                                      //color: Colors.green,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Excluir'),
                                              content: const Text(
                                                  'Em desenvolvimento'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Fechar'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 15,
                                            ),
                                            SizedBox(
                                              height: 1,
                                            ),
                                            Text(
                                              'Excluir',
                                              style: TextStyle(
                                                //color: Colors.red,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.005,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //nome do representante legal
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
                              onChanged: (value) {
                                setState(() {
                                  widget.agente.rg = value;
                                });
                              },
                              //enabled: false,
                              //initialValue: empresa.representanteLegalNome,
                              controller: rgController,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'RG',
                                labelStyle: TextStyle(
                                  color: readOnly ? Colors.grey : Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                                color: readOnly ? Colors.grey : Colors.white,
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
                              onChanged: (value) {
                                setState(() {
                                  widget.agente.cpf = value;
                                });
                              },
                              controller: cpfController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                CpfInputFormatter(),
                              ],
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'CPF',
                                labelStyle: TextStyle(
                                  color: readOnly ? Colors.grey : Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                                color: readOnly ? Colors.grey : Colors.white,
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
                              onChanged: (value) {
                                setState(() {
                                  widget.agente.celular = value;
                                });
                              },
                              controller: celularController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter
                                    .digitsOnly, // Permite apenas dígitos
                                TelefoneInputFormatter(),
                              ],
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Celular',
                                labelStyle: TextStyle(
                                  color: readOnly ? Colors.grey : Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                                color: readOnly ? Colors.grey : Colors.white,
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
                              //enabled: false,
                              //initialValue: empresa.email,
                              controller: nivelController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Nível',
                                labelStyle: TextStyle(
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: width * 0.6 + 10,
                      child: readOnly
                          ? TextFormField(
                              controller: enderecoController,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor:
                                    readOnly ? Colors.grey : Colors.white,
                                focusColor:
                                    readOnly ? Colors.grey : Colors.white,
                                hoverColor:
                                    readOnly ? Colors.grey : Colors.white,
                                labelText: 'Endereço',
                                labelStyle: TextStyle(
                                  color: readOnly ? Colors.grey : Colors.white,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w300,
                                color: readOnly ? Colors.grey : Colors.white,
                              ),
                            )
                          : Column(
                              children: [
                                TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      widget.agente.logradouro = value;
                                    });
                                  },
                                  controller: logradouroController,
                                  readOnly: readOnly,
                                  decoration: InputDecoration(
                                    fillColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    focusColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    hoverColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    labelText: 'Logradouro',
                                    labelStyle: TextStyle(
                                      color:
                                          readOnly ? Colors.grey : Colors.white,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: readOnly
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      widget.agente.numero = value;
                                    });
                                  },
                                  controller: numeroController,
                                  readOnly: readOnly,
                                  decoration: InputDecoration(
                                    fillColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    focusColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    hoverColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    labelText: 'Número',
                                    labelStyle: TextStyle(
                                      color:
                                          readOnly ? Colors.grey : Colors.white,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: readOnly
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      widget.agente.bairro = value;
                                    });
                                  },
                                  controller: bairroController,
                                  readOnly: readOnly,
                                  decoration: InputDecoration(
                                    fillColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    focusColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    hoverColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    labelText: 'Bairro',
                                    labelStyle: TextStyle(
                                      color:
                                          readOnly ? Colors.grey : Colors.white,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: readOnly
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      widget.agente.complemento = value;
                                    });
                                  },
                                  controller: complementoController,
                                  readOnly: readOnly,
                                  decoration: InputDecoration(
                                    fillColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    focusColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    hoverColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    labelText: 'Complemento',
                                    labelStyle: TextStyle(
                                      color:
                                          readOnly ? Colors.grey : Colors.white,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: readOnly
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      widget.agente.cidade = value;
                                    });
                                  },
                                  controller: cidadeController,
                                  readOnly: readOnly,
                                  decoration: InputDecoration(
                                    fillColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    focusColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    hoverColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    labelText: 'Cidade',
                                    labelStyle: TextStyle(
                                      color:
                                          readOnly ? Colors.grey : Colors.white,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: readOnly
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      widget.agente.cep = value;
                                    });
                                  },
                                  controller: cepController,
                                  readOnly: readOnly,
                                  decoration: InputDecoration(
                                    fillColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    focusColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    hoverColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    labelText: 'CEP',
                                    labelStyle: TextStyle(
                                      color:
                                          readOnly ? Colors.grey : Colors.white,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: readOnly
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: estadoController,
                                  readOnly: readOnly,
                                  decoration: InputDecoration(
                                    fillColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    focusColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    hoverColor:
                                        readOnly ? Colors.grey : Colors.white,
                                    labelText: 'Estado',
                                    labelStyle: TextStyle(
                                      color:
                                          readOnly ? Colors.grey : Colors.white,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: readOnly
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        readOnly ? Colors.grey : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // ResponsiveRowColumn(
                  //   layout:
                  //       ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                  //           ? ResponsiveRowColumnType.COLUMN
                  //           : ResponsiveRowColumnType.ROW,
                  //   children: [
                  //     ResponsiveRowColumnItem(child:,)
                  //   ],),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showImageDialog(
                                context, widget.agente.rgFotoFrenteUrl!);
                          },
                          icon: const Icon(Bootstrap.file_image_fill),
                        ),
                        const SizedBox(
                          width: 1,
                        ),
                        const Text('Rg (frente)')
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showImageDialog(
                                context, widget.agente.rgFotoVersoUrl!);
                          },
                          icon: const Icon(Bootstrap.file_image_fill),
                        ),
                        const SizedBox(
                          width: 1,
                        ),
                        const Text('Rg (verso)')
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            showImageDialog(
                                context, widget.agente.compResidFotoUrl!);
                          },
                          icon: const Icon(Bootstrap.file_image_fill),
                        ),
                        const SizedBox(
                          width: 1,
                        ),
                        const Text('Comprovante de residência')
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                alignment: Alignment.topRight,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
            ),
            Dialog(
              child: PhotoView(
                maxScale: PhotoViewComputedScale.covered * 2,
                minScale: PhotoViewComputedScale.contained,
                imageProvider: CachedNetworkImageProvider(
                  imageUrl,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
