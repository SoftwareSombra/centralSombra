import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_state.dart';
import '../../admin/services/admin_services.dart';
import '../bloc/empresa_user_bloc/empresa_users_bloc.dart';
import '../bloc/empresa_user_bloc/empresa_users_event.dart';
import '../bloc/get_empresas_bloc.dart';
import '../bloc/get_empresas_event.dart';
import '../model/empresa_model.dart';
import 'components/users_empresa_list.dart';

class EmpresaDetails extends StatefulWidget {
  final Empresa empresa;
  final BuildContext context;
  const EmpresaDetails(
      {super.key, required this.empresa, required this.context});

  @override
  State<EmpresaDetails> createState() => _EmpresaDetailsState();
}

class _EmpresaDetailsState extends State<EmpresaDetails> {
  final AdminServices adminServices = AdminServices();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  TextEditingController? representanteLegalController;
  TextEditingController? representanteLegalCpfController;
  TextEditingController? telefoneController;
  TextEditingController? emailController;
  TextEditingController? prazoContratoInicioController;
  TextEditingController? prazoContratoFimController;
  TextEditingController? enderecoController;
  bool readOnly = true;
  DateTime? prazoContratoInicio;
  DateTime? prazoContratoFim;

  @override
  void initState() {
    context
        .read<EmpresaUsersBloc>()
        .add(BuscarUsuariosDaEmpresa(cnpj: widget.empresa.cnpj));
    startControllers();
    super.initState();
  }

  @override
  void dispose() {
    representanteLegalController!.dispose();
    representanteLegalCpfController!.dispose();
    telefoneController!.dispose();
    emailController!.dispose();
    prazoContratoInicioController!.dispose();
    prazoContratoFimController!.dispose();
    enderecoController!.dispose();
    super.dispose();
  }

  void toggleReadOnly(bool value) {
    setState(() {
      readOnly = value;
    });
  }

  void startControllers() {
    representanteLegalController =
        TextEditingController(text: widget.empresa.representanteLegalNome);
    representanteLegalCpfController =
        TextEditingController(text: widget.empresa.representanteLegalCpf);
    telefoneController = TextEditingController(text: widget.empresa.telefone);
    emailController = TextEditingController(text: widget.empresa.email);
    prazoContratoInicioController = TextEditingController(
        text:
            '${widget.empresa.prazoContratoInicio.day}/${widget.empresa.prazoContratoInicio.month}/${widget.empresa.prazoContratoInicio.year}');
    prazoContratoFimController = TextEditingController(
        text:
            '${widget.empresa.prazoContratoFim.day}/${widget.empresa.prazoContratoFim.month}/${widget.empresa.prazoContratoFim.year}');
    enderecoController = TextEditingController(text: widget.empresa.endereco);
  }

  void updateTextControllers() {
    setState(() {
      readOnly = true;
      representanteLegalController!.text =
          widget.empresa.representanteLegalNome;
      representanteLegalCpfController!.text =
          widget.empresa.representanteLegalCpf;
      telefoneController!.text = widget.empresa.telefone;
      emailController!.text = widget.empresa.email;
      prazoContratoInicioController!.text = prazoContratoInicio != null
          ? '${prazoContratoInicio!.day}/${prazoContratoInicio!.month}/${prazoContratoInicio!.year}'
          : '${widget.empresa.prazoContratoInicio.day}/${widget.empresa.prazoContratoInicio.month}/${widget.empresa.prazoContratoInicio.year}';
      prazoContratoFimController!.text = prazoContratoFim != null
          ? '${prazoContratoFim!.day}/${prazoContratoFim!.month}/${prazoContratoFim!.year}'
          : '${widget.empresa.prazoContratoFim.day}/${widget.empresa.prazoContratoFim.month}/${widget.empresa.prazoContratoFim.year}';
      enderecoController!.text = widget.empresa.endereco;
    });
  }

  void saveEmpresaDetails() async {
    context.read<ElevatedButtonBloc>().add(ElevatedButtonPressed());

    //DateTime now = DateTime.now().toUtc().subtract(const Duration(hours: 3));

    bool success = await adminServices.editEmpresa(
      Empresa(
        nomeEmpresa: widget.empresa.nomeEmpresa,
        cnpj: widget.empresa.cnpj,
        endereco: enderecoController!.text,
        telefone: telefoneController!.text,
        email: emailController!.text,
        representanteLegalNome: representanteLegalController!.text,
        representanteLegalCpf: representanteLegalCpfController!.text,
        prazoContratoInicio: widget.empresa.prazoContratoInicio,
        prazoContratoFim: widget.empresa.prazoContratoFim,
        logo: widget.empresa.logo,
        observacao: widget.empresa.observacao,
      ),
    );

    if (success) {
      setState(() {
        // Atualizar os valores dos controladores para refletir os dados salvos
        updateTextControllers();
      });
      Navigator.pop(context);
      mensagemDeSucesso.showSuccessSnackbar(
          context, 'Empresa editada com sucesso.');
    } else {
      tratamentoDeErros.showErrorSnackbar(
          context, 'Erro ao editar empresa, tente novamente.');
    }
    context.read<ElevatedButtonBloc>().add(ElevatedButtonReset());
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? prazoContratoInicio ?? DateTime.now()
          : prazoContratoFim ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2040),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null &&
        picked != (isStartDate ? prazoContratoInicio : prazoContratoFim)) {
      setState(() {
        if (isStartDate) {
          prazoContratoInicio = picked;
        } else {
          prazoContratoFim = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // TextEditingController representanteLegalController =
    //     TextEditingController(text: widget.empresa.representanteLegalNome);
    // TextEditingController representanteLegalCpfController =
    //     TextEditingController(text: widget.empresa.representanteLegalCpf);
    // TextEditingController telefoneController =
    //     TextEditingController(text: widget.empresa.telefone);
    // TextEditingController emailController =
    //     TextEditingController(text: widget.empresa.email);
    // TextEditingController prazoContratoInicioController = TextEditingController(
    //     text:
    //         '${widget.empresa.prazoContratoInicio.day}/${widget.empresa.prazoContratoInicio.month}/${widget.empresa.prazoContratoInicio.year}');
    // TextEditingController prazoContratoFimController = TextEditingController(
    //     text:
    //         '${widget.empresa.prazoContratoFim.day}/${widget.empresa.prazoContratoFim.month}/${widget.empresa.prazoContratoFim.year}');
    // TextEditingController enderecoController =
    //     TextEditingController(text: widget.empresa.endereco);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        title: const Text(
          'DETALHES DA EMPRESA',
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
                                  CachedNetworkImageProvider(
                                      widget.empresa.logo == null
                                          ? 'assets/images/logo-null.jpg'
                                          : widget.empresa.logo!),
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
                                  widget.empresa.nomeEmpresa,
                                  style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w400),
                                ),
                                SelectableText(
                                  'CNPJ: ${widget.empresa.cnpj}',
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
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                EmpresaUsersListDialog(
                                              empresa: widget.empresa,
                                            ),
                                          );
                                        },
                                        child: const Column(
                                          children: [
                                            Icon(
                                              Icons.people_alt,
                                              //color: Colors.blue,
                                              size: 15,
                                            ),
                                            SizedBox(
                                              height: 1,
                                            ),
                                            Text(
                                              'Usuários',
                                              style: TextStyle(
                                                //color: Colors.blue,
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
                                    Row(
                                      children: [
                                        readOnly
                                            ? MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Editar'),
                                                        content: const Text(
                                                            'Deseja editar os dados da empresa?'),
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
                                                              toggleReadOnly(
                                                                  false);
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
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Salvar'),
                                                        content: const Text(
                                                            'Deseja salvar as alterações?'),
                                                        actions: [
                                                          BlocBuilder<
                                                              ElevatedButtonBloc,
                                                              ElevatedButtonBlocState>(
                                                            builder: (context,
                                                                state) {
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
                                                                        saveEmpresaDetails();
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
                                              _showDialog(widget.empresa);
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
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ResponsiveRowColumnItem(
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(vertical: 40),
                  //     child: Row(
                  //       children: [

                  //       ],
                  //     ),
                  //   ),
                  // ),
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
                                  widget.empresa.representanteLegalNome = value;
                                });
                              },
                              //enabled: false,
                              //initialValue: empresa.representanteLegalNome,
                              controller: representanteLegalController,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Representante legal',
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
                                  widget.empresa.representanteLegalCpf = value;
                                });
                              },
                              //enabled: false,
                              //initialValue: empresa.representanteLegalCpf,
                              controller: representanteLegalCpfController,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'CPF do representante legal',
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
                                  widget.empresa.telefone = value;
                                });
                              },
                              //enabled: false,
                              //initialValue: empresa.telefone,
                              controller: telefoneController,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Telefone',
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
                                  widget.empresa.email = value;
                                });
                              },
                              //enabled: false,
                              //initialValue: empresa.email,
                              controller: emailController,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Email',
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
                  // inicio e fim do contrato
                  readOnly
                      ? ResponsiveRowColumn(
                          layout: ResponsiveBreakpoints.of(context)
                                  .smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                          rowMainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ResponsiveRowColumnItem(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: SizedBox(
                                  width: ResponsiveBreakpoints.of(context)
                                          .smallerThan(DESKTOP)
                                      ? width * 0.6 + 10
                                      : width * 0.3,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        widget.empresa.prazoContratoInicio =
                                            DateTime(
                                                int.parse(value.split('/')[2]),
                                                int.parse(value.split('/')[1]),
                                                int.parse(value.split('/')[0]));
                                      });
                                    },
                                    //enabled: false,
                                    // initialValue: empresa.prazoContratoInicio.day
                                    //         .toString() +
                                    //     '/' +
                                    //     empresa.prazoContratoInicio.month.toString() +
                                    //     '/' +
                                    //     empresa.prazoContratoInicio.year.toString(),
                                    controller: prazoContratoInicioController,
                                    readOnly: readOnly,
                                    decoration: const InputDecoration(
                                      fillColor: Colors.grey,
                                      focusColor: Colors.grey,
                                      hoverColor: Colors.grey,
                                      labelText: 'Início do contrato',
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
                            ResponsiveBreakpoints.of(context)
                                    .smallerThan(DESKTOP)
                                ? const ResponsiveRowColumnItem(
                                    child: SizedBox(height: 10),
                                  )
                                : const ResponsiveRowColumnItem(
                                    child: SizedBox(width: 10),
                                  ),
                            ResponsiveRowColumnItem(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: SizedBox(
                                  width: ResponsiveBreakpoints.of(context)
                                          .smallerThan(DESKTOP)
                                      ? width * 0.6 + 10
                                      : width * 0.3,
                                  child: TextFormField(
                                    onChanged: (value) {
                                      setState(() {
                                        widget.empresa.prazoContratoFim =
                                            DateTime(
                                                int.parse(value.split('/')[2]),
                                                int.parse(value.split('/')[1]),
                                                int.parse(value.split('/')[0]));
                                      });
                                    },
                                    //enabled: false,
                                    // initialValue: empresa.prazoContratoFim.day
                                    //         .toString() +
                                    //     '/' +
                                    //     empresa.prazoContratoFim.month.toString() +
                                    //     '/' +
                                    //     empresa.prazoContratoFim.year.toString(),
                                    controller: prazoContratoFimController,
                                    readOnly: readOnly,
                                    decoration: const InputDecoration(
                                      fillColor: Colors.grey,
                                      focusColor: Colors.grey,
                                      hoverColor: Colors.grey,
                                      labelText: 'Fim do contrato',
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
                        )
                      : const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: width * 0.6 + 10,
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            widget.empresa.endereco = value;
                          });
                        },

                        //enabled: false,
                        //initialValue: empresa.endereco,
                        controller: enderecoController,
                        readOnly: readOnly,
                        decoration: InputDecoration(
                          fillColor: readOnly ? Colors.grey : Colors.white,
                          focusColor: readOnly ? Colors.grey : Colors.white,
                          hoverColor: readOnly ? Colors.grey : Colors.white,
                          labelText: 'Endereço',
                          labelStyle: TextStyle(
                            color: readOnly ? Colors.grey : Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: readOnly ? Colors.grey : Colors.white,
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
                  !readOnly
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SizedBox(
                            width: width * 0.6 + 10,
                            child: Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero)),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Prazo do contrato: início'),
                                    ],
                                  ),
                                  // subtitle: Text(prazoContratoInicio != null
                                  //     ? DateFormat('dd/MM/yyyy')
                                  //         .format(prazoContratoInicio!)
                                  //     : 'Selecionar data'),
                                  onPressed: () => _selectDate(context, true),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero)),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        size: 15,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text('Prazo do contrato: fim'),
                                    ],
                                  ),
                                  // subtitle: Text(prazoContratoFim != null
                                  //     ? DateFormat('dd/MM/yyyy')
                                  //         .format(prazoContratoFim!)
                                  //     : 'Selecionar data'),
                                  onPressed: () => _selectDate(context, false),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  //dialogo de exclusão
  void _showDialog(Empresa empresa) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 3, 9, 18),
          title: const Text('Confirmação'),
          content: const Text('Deseja realmente excluir esta empresa?'),
          actions: <Widget>[
            BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
              builder: (buttonContext, buttonState) {
                return buttonState is ElevatedButtonBlocLoading
                    ? const CircularProgressIndicator()
                    : Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              buttonContext.read<ElevatedButtonBloc>().add(
                                    ElevatedButtonPressed(),
                                  );
                              final delete = await adminServices
                                  .deleteEmpresa(empresa.cnpj);
                              if (context.mounted) {
                                if (delete) {
                                  mensagemDeSucesso.showSuccessSnackbar(
                                      context, 'Empresa excluída com sucesso.');
                                } else {
                                  tratamentoDeErros.showErrorSnackbar(context,
                                      'Erro ao excluir empresa, tente novamente.');
                                }
                                context
                                    .read<GetEmpresasBloc>()
                                    .add(GetEmpresas());
                                buttonContext.read<ElevatedButtonBloc>().add(
                                      ElevatedButtonReset(),
                                    );
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Confirmar'),
                          ),
                        ],
                      );
              },
            ),
          ],
        );
      },
    );
  }
}
