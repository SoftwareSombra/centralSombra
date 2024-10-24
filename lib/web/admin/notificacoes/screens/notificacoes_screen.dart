import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra/web/admin/notificacoes/blocs/avisos/avisos_bloc_event.dart';
import 'package:sombra/web/admin/notificacoes/blocs/avisos/avisos_bloc_state.dart';
import 'package:sombra/widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import 'package:sombra/widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import 'package:sombra/widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';
import '../../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../blocs/avisos/avisos_bloc_bloc.dart';
import '../services/notificacoes_services.dart';

class NotificacoesAdmScreen extends StatefulWidget {
  const NotificacoesAdmScreen({super.key});

  @override
  State<NotificacoesAdmScreen> createState() => _NotificacoesAdmScreenState();
}

String? _selectedOption;
QuillController _controller = QuillController.basic();
TratamentoDeErros tratamento = TratamentoDeErros();
MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
final NotificacoesAdmServices notificacoesAdmServices =
    NotificacoesAdmServices();
TextEditingController? notTituloController;
TextEditingController? notConteudoController;
TextEditingController? avisoTituloController;
const canvasColor = Color.fromARGB(255, 0, 15, 42);

class _NotificacoesAdmScreenState extends State<NotificacoesAdmScreen> {
  @override
  void initState() {
    notConteudoController = TextEditingController();
    notTituloController = TextEditingController();
    avisoTituloController = TextEditingController();
    context.read<ElevatedButtonBloc>().add(ElevatedButtonReset());
    context.read<AvisosBloc>().add(BuscarAvisos());
    super.initState();
  }

  @override
  void dispose() {
    notConteudoController!.dispose();
    notTituloController!.dispose();
    avisoTituloController!.dispose();
    super.dispose();
  }

  void notDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: const Text('Deseja realmente enviar a notificação?'),
        actions: [
          BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
            builder: (context, state) {
              if (state is ElevatedButtonBlocLoading) {
                return const CircularProgressIndicator();
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await notificacoesAdmServices.enviarNotificacao(
                              _selectedOption!,
                              notTituloController!.value.text.trim(),
                              notConteudoController!.text.trim());
                        } catch (e) {
                          debugPrint(e.toString());
                          context.mounted
                              ? tratamento.showErrorSnackbar(context,
                                  'Erro ao enviar notificacao, tente novamente!')
                              : null;
                          return;
                        }
                        setState(() {
                          notConteudoController!.value = TextEditingValue.empty;
                          notTituloController!.value = TextEditingValue.empty;
                        });
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          mensagemDeSucesso.showSuccessSnackbar(
                              context, 'Notificação enviada com sucesso');
                        }
                      },
                      child: const Text('Enviar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void avisoDialog(context, aviso) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: const Text('Deseja realmente publicar o aviso?'),
        actions: [
          BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
            builder: (context, state) {
              if (state is ElevatedButtonBlocLoading) {
                return const CircularProgressIndicator();
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await notificacoesAdmServices.enviarAviso(
                              avisoTituloController!.text.trim(), aviso);
                        } catch (e) {
                          debugPrint(e.toString());
                          context.mounted
                              ? tratamento.showErrorSnackbar(context,
                                  'Erro ao enviar aviso, tente novamente!')
                              : null;
                          return;
                        }
                        setState(() {
                          avisoTituloController!.value = TextEditingValue.empty;
                          _controller.clear();
                        });
                        if (context.mounted) {
                          BlocProvider.of<AvisosBloc>(context)
                              .add(BuscarAvisos());
                          Navigator.of(context).pop();
                          mensagemDeSucesso.showSuccessSnackbar(
                              context, 'Aviso enviado com sucesso');
                        }
                      },
                      child: const Text('Enviar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void excluirAvisoDialog(context, id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmação'),
        content: const Text('Deseja realmente excluir este aviso?'),
        actions: [
          BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
            builder: (context, state) {
              if (state is ElevatedButtonBlocLoading) {
                return const CircularProgressIndicator();
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          await notificacoesAdmServices.excluirAviso(id);
                        } catch (e) {
                          debugPrint(e.toString());
                          context.mounted
                              ? tratamento.showErrorSnackbar(context,
                                  'Erro ao excluir aviso, tente novamente!')
                              : null;
                          return;
                        }
                        if (context.mounted) {
                          BlocProvider.of<AvisosBloc>(context)
                              .add(BuscarAvisos());
                          Navigator.of(context).pop();
                          mensagemDeSucesso.showSuccessSnackbar(
                              context, 'Aviso excluído com sucesso');
                        }
                      },
                      child: const Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void showAviso(context, aviso, titulo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: QuillEditor.basic(
          configurations: QuillEditorConfigurations(controller: aviso),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        title: const Text(
          '',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: ExpansionTile(
                //collapsedBackgroundColor: canvasColor.withOpacity(0.3),
                collapsedBackgroundColor: Colors.white,
                initiallyExpanded: false,
                //borda
                // collapsedShape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(20),
                // ),
                //cor do icone
                collapsedIconColor: canvasColor,
                //cor do texto
                collapsedTextColor: canvasColor,
                //backgroundColor: canvasColor.withOpacity(0.4),
                backgroundColor: Colors.white,
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
                        'CRIAR NOTIFICAÇÃO',
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
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Radio<String>(
                              //   value: 'Agentes',
                              //   groupValue: _selectedOption,
                              //   onChanged: (value) {
                              //     setState(() {
                              //       _selectedOption = value;
                              //       //_updateButtonState();
                              //     });
                              //   },
                              // ),
                              // const Text('Agentes'),
                              // const SizedBox(width: 15),
                              Radio<String>(
                                value: 'Usuários',
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value;
                                    //_updateButtonState();
                                  });
                                },
                              ),
                              const Text('Usuários'),
                              const SizedBox(width: 15),
                              Radio<String>(
                                value: 'Central',
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value;
                                    //_updateButtonState();
                                  });
                                },
                              ),
                              const Text('Central'),
                              const SizedBox(width: 15),
                              Radio<String>(
                                value: 'Clientes',
                                groupValue: _selectedOption,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedOption = value;
                                    // _updateButtonState();
                                  });
                                },
                              ),
                              const Text('Clientes'),
                              // const SizedBox(width: 15),
                              // Radio<String>(
                              //   value: 'Todos',
                              //   groupValue: _selectedOption,
                              //   onChanged: (value) {
                              //     setState(
                              //       () {
                              //         _selectedOption = value;
                              //         // _updateButtonState();
                              //       },
                              //     );
                              //   },
                              // ),
                              // const Text('Todos'),
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
                                  height: 40,
                                  constraints:
                                      const BoxConstraints(maxWidth: 600),
                                  child: TextFormField(
                                    cursorHeight: 14,
                                    //focusNode: ,
                                    controller: notTituloController,

                                    //style: TextStyle(color: Colors.grey[200]),
                                    decoration: const InputDecoration(
                                      labelText: 'Título',
                                      labelStyle: TextStyle(fontSize: 13),
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
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ResponsiveRowColumn(
                          layout: ResponsiveRowColumnType.COLUMN,
                          children: [
                            ResponsiveRowColumnItem(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.055, vertical: 0),
                                child: Container(
                                  height: 40,
                                  constraints:
                                      const BoxConstraints(maxWidth: 600),
                                  child: TextFormField(
                                    cursorHeight: 14,
                                    //focusNode: ,
                                    controller: notConteudoController,

                                    //style: TextStyle(color: Colors.grey[200]),
                                    decoration: const InputDecoration(
                                      labelText: 'Conteúdo',
                                      labelStyle: TextStyle(fontSize: 13),
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
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (notConteudoController!.value.text.isEmpty ||
                                notTituloController!.value.text.isEmpty ||
                                _selectedOption == null) {
                              tratamento.showErrorSnackbar(context,
                                  'Preencha todos os campos antes de tentar enviar uma notificação');
                            } else {
                              notDialog(context);
                            }
                          },
                          child: const Text('Enviar'),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: ExpansionTile(
                collapsedBackgroundColor: Colors.white,
                initiallyExpanded: false,
                //cor do icone
                collapsedIconColor: canvasColor,
                //cor do texto
                collapsedTextColor: canvasColor,
                backgroundColor: Colors.white,
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
                        'CRIAR AVISO',
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
                          height: 5,
                        ),
                        ResponsiveRowColumn(
                          layout: ResponsiveRowColumnType.COLUMN,
                          rowMainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ResponsiveRowColumnItem(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.005, vertical: 0),
                                child: Container(
                                  height: 40,
                                  constraints:
                                      const BoxConstraints(maxWidth: 600),
                                  child: TextFormField(
                                    cursorHeight: 14,
                                    //focusNode: ,
                                    controller: avisoTituloController,

                                    //style: TextStyle(color: Colors.grey[200]),
                                    decoration: const InputDecoration(
                                      labelText: 'Título',
                                      labelStyle: TextStyle(fontSize: 13),
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
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 400,
                          width: width,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  QuillToolbar.simple(
                                      configurations:
                                          QuillSimpleToolbarConfigurations(
                                              showAlignmentButtons: true,
                                              controller: _controller)),
                                  Expanded(
                                    child: QuillEditor.basic(
                                      configurations: QuillEditorConfigurations(
                                          padding: const EdgeInsets.all(10),
                                          controller: _controller),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final plainText =
                                _controller.document.toPlainText().trim();
                            if (plainText.isEmpty) {
                              tratamento.showErrorSnackbar(context,
                                  'Caixa de texto vazia, digite algo antes de enviar');
                              return;
                            }
                            final deltaToJson =
                                _controller.document.toDelta().toJson();
                            // QuillController controller = QuillController(
                            //     document: Document.fromJson(deltaToJson),
                            //     selection:
                            //         const TextSelection.collapsed(offset: 0));
                            // showDialog(
                            //   context: context,
                            //   builder: (context) =>
                            // AlertDialog(
                            //     content: QuillEditor.basic(
                            //       configurations: QuillEditorConfigurations(
                            //           controller: controller),
                            //     ),
                            //   ),
                            // );
                            avisoDialog(context, deltaToJson);
                          },
                          child: const Text('Enviar'),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: ExpansionTile(
                collapsedBackgroundColor: Colors.white,
                initiallyExpanded: false,
                //borda
                // collapsedShape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(20),
                // ),
                //cor do icone
                collapsedIconColor: canvasColor,
                //cor do texto
                collapsedTextColor: canvasColor,
                backgroundColor: Colors.white,
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
                        'MURAL DE AVISOS',
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
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: BlocBuilder<AvisosBloc, AvisosBlocState>(
                            builder: (context, state) {
                              if (state is AvisosBlocLoading) {
                                return const CircularProgressIndicator();
                              } else if (state is AvisosBlocError) {
                                return const Text(
                                    'Erro ao buscar avisos, tente novamente!');
                              } else if (state is AvisosBlocIsEmpty) {
                                return const Text(
                                    'Nenhum aviso está sendo exibido atualmente');
                              } else if (state is AvisosBlocLoaded) {
                                return SizedBox(
                                  height: 400,
                                  child: ListView.builder(
                                    itemCount: state.avisos!.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          QuillController quillController =
                                              QuillController(
                                                  document: Document.fromJson(
                                                      state.avisos![index]
                                                          .aviso),
                                                  selection: const TextSelection
                                                      .collapsed(offset: 0));
                                          showAviso(context, quillController,
                                              state.avisos![index].titulo);
                                        },
                                        child: MouseRegion(
                                          cursor: MaterialStateMouseCursor
                                              .clickable,
                                          child: Card(
                                            // color: const Color.fromARGB(
                                            //     255, 3, 9, 18),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Título: ${state.avisos![index].titulo}'),
                                                  const Spacer(),
                                                  IconButton(
                                                    onPressed: () {
                                                      excluirAvisoDialog(
                                                          context,
                                                          state.avisos![index]
                                                              .id);
                                                    },
                                                    icon:
                                                        const Icon(Icons.close),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              } else {
                                return const Text(
                                    'Algum erro ocorreu, recarregue a página');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
