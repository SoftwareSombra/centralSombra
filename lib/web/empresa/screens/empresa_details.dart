import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../bloc/empresa_user_bloc/empresa_users_bloc.dart';
import '../bloc/empresa_user_bloc/empresa_users_event.dart';
import '../model/empresa_model.dart';
import 'components/users_empresa_list.dart';

class EmpresaDetails extends StatefulWidget {
  final Empresa empresa;
  const EmpresaDetails({super.key, required this.empresa});

  @override
  State<EmpresaDetails> createState() => _EmpresaDetailsState();
}

class _EmpresaDetailsState extends State<EmpresaDetails> {
  @override
  void initState() {
    context
        .read<EmpresaUsersBloc>()
        .add(BuscarUsuariosDaEmpresa(cnpj: widget.empresa.cnpj));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    TextEditingController representanteLegalController =
        TextEditingController(text: widget.empresa.representanteLegalNome);
    TextEditingController representanteLegalCpfController =
        TextEditingController(text: widget.empresa.representanteLegalCpf);
    TextEditingController telefoneController =
        TextEditingController(text: widget.empresa.telefone);
    TextEditingController emailController =
        TextEditingController(text: widget.empresa.email);
    TextEditingController prazoContratoInicioController = TextEditingController(
        text:
            '${widget.empresa.prazoContratoInicio.day}/${widget.empresa.prazoContratoInicio.month}/${widget.empresa.prazoContratoInicio.year}');
    TextEditingController prazoContratoFimController = TextEditingController(
        text:
            '${widget.empresa.prazoContratoFim.day}/${widget.empresa.prazoContratoFim.month}/${widget.empresa.prazoContratoFim.year}');
    TextEditingController enderecoController =
        TextEditingController(text: widget.empresa.endereco);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
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
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Editar'),
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
                              //enabled: false,
                              //initialValue: empresa.representanteLegalNome,
                              controller: representanteLegalController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Representante legal',
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
                              //initialValue: empresa.representanteLegalCpf,
                              controller: representanteLegalCpfController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'CPF do representante legal',
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
                              //enabled: false,
                              //initialValue: empresa.telefone,
                              controller: telefoneController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Telefone',
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
                              controller: emailController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Email',
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
                  // inicio e fim do contrato
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
                              //enabled: false,
                              // initialValue: empresa.prazoContratoInicio.day
                              //         .toString() +
                              //     '/' +
                              //     empresa.prazoContratoInicio.month.toString() +
                              //     '/' +
                              //     empresa.prazoContratoInicio.year.toString(),
                              controller: prazoContratoInicioController,
                              readOnly: true,
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
                              // initialValue: empresa.prazoContratoFim.day
                              //         .toString() +
                              //     '/' +
                              //     empresa.prazoContratoFim.month.toString() +
                              //     '/' +
                              //     empresa.prazoContratoFim.year.toString(),
                              controller: prazoContratoFimController,
                              readOnly: true,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: width * 0.6 + 10,
                      child: TextFormField(
                        //enabled: false,
                        //initialValue: empresa.endereco,
                        controller: enderecoController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          fillColor: Colors.grey,
                          focusColor: Colors.grey,
                          hoverColor: Colors.grey,
                          labelText: 'Endereço',
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
