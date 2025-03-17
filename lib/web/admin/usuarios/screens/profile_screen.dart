import 'package:brasil_fields/brasil_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import '../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import '../../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';
import '../../../empresa/services/empresa_services.dart';
import '../../services/admin_services.dart';
import '../bloc/users_list_bloc/users_list_bloc.dart';
import '../bloc/users_list_bloc/users_list_event.dart';

class UserProfileScreen extends StatefulWidget {
  final Usuario user;
  final String? cnpj;
  const UserProfileScreen({super.key, required this.user, this.cnpj});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

TextEditingController? nomeController;
TextEditingController? emailController;
TextEditingController? emailVerifiedController;
TextEditingController? celularController;
TextEditingController? cargoController;
TextEditingController? lastLoginController;
TextEditingController? criadoEmController;
TextEditingController? atualizadoEmController;
bool readOnly = true;
ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);
final AdminServices adminServices = AdminServices();
final EmpresaServices empresaServices = EmpresaServices();
final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    initControllers();
    super.initState();
  }

  @override
  void dispose() {
    nomeController!.dispose();
    emailController!.dispose();
    emailVerifiedController!.dispose();
    celularController!.dispose();
    cargoController!.dispose();
    lastLoginController!.dispose();
    criadoEmController!.dispose();
    atualizadoEmController!.dispose();
    super.dispose();
  }

  void initControllers() {
    nomeController = TextEditingController(text: widget.user.nome);
    emailController = TextEditingController(text: widget.user.email);
    emailVerifiedController =
        TextEditingController(text: widget.user.emailVerified! ? 'Sim' : 'Não');
    celularController = TextEditingController(
        text: widget.user.phoneNumber == 'Não informado'
            ? null
            : widget.user.phoneNumber!.startsWith('+55')
                ? widget.user.phoneNumber!.substring(3)
                : widget.user.phoneNumber);
    cargoController = TextEditingController(text: widget.user.cargo);
    lastLoginController = TextEditingController(
        text: widget.user.lastLogin != null
            ? '${widget.user.lastLogin!}h'
            : 'Nunca');
    criadoEmController = TextEditingController(
        text: widget.user.creationTime != null
            ? '${widget.user.creationTime!}h'
            : 'N/A');
    atualizadoEmController = TextEditingController(
        text: widget.user.lastRefreshTime != null
            ? '${widget.user.lastRefreshTime!}h'
            : 'N/A');
  }

  void toggleReadOnly(bool value) {
    setState(() {
      readOnly = value;
    });
  }

  void updateTextControllers() {
    setState(() {
      readOnly = true;
      if (nomeController != null) {
        widget.user.nome = nomeController!.text;
      }
      if (widget.user.email != null && emailController != null) {
        widget.user.email = emailController!.text;
      }
      if (widget.user.phoneNumber != null && celularController != null) {
        widget.user.phoneNumber = celularController!.text;
      }
    });
  }

  void saveUserChanges() async {
    context.read<ElevatedButtonBloc>().add(ElevatedButtonPressed());

    String? nome;
    String? email;
    String? celular;

    if (nomeController != null) {
      nome = nomeController!.text;
    } else {
      nome = widget.user.nome;
    }

    if (emailController != null) {
      email = emailController!.text;
    } else {
      email = widget.user.email;
    }

    debugPrint('celularController: ${celularController!.text}');

    if (celularController!.text != '') {
      String celularSemParenteses =
          celularController!.text.replaceAll(RegExp(r'[()-\s+]'), '').trim();
      //double celular = double.parse(celularSemParenteses);
      //verificar se os primeiros caracteres sao +55
      if (celularSemParenteses.startsWith('+55')) {
        celular = celularSemParenteses;
      } else {
        celular = '+55$celularSemParenteses';
      }
      debugPrint(celular.toString());
    } else {
      celular = null;
    }

    debugPrint('uid: ${widget.user.uid}');
    debugPrint('nome: ${nome}');
    debugPrint('email: ${email}');
    debugPrint('celular: ${celular}');

    bool success = await adminServices.updateUserData(
      widget.user.uid,
      nome,
      email,
      celular,
    );

    if (success) {
      setState(() {
        // Atualizar os valores dos controladores para refletir os dados salvos
        updateTextControllers();
      });

      // Fechar qualquer modal aberto e mostrar snackbar
      Navigator.pop(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Alterações salvas com sucesso')));
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Sucesso'),
                content: const Text('Alterações salvas com sucesso'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ));
      BlocProvider.of<UsersListBloc>(context).add(FetchUsersList());
    } else {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Erro'),
                content:
                    const Text('Erro ao salvar as alterações, tente novamente'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  ),
                ],
              ));
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text('Erro ao salvar as alterações, tente novamente')));
    }
    // Indicar fim da operação de salvamento
    context.read<ElevatedButtonBloc>().add(ElevatedButtonReset());
  }

  void _showDialog(Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
          title: const Text('Confirmação'),
          content: const Text('Deseja realmente excluir este usuário?'),
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
                              final delete =
                                  await adminServices.deleteUser(usuario.uid);
                              if (context.mounted) {
                                if (delete) {
                                  mensagemDeSucesso.showSuccessSnackbar(
                                      context, 'Usuário excluído com sucesso');
                                  BlocProvider.of<UsersListBloc>(context)
                                      .add(FetchUsersList());
                                  Navigator.of(context).pop();
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          // backgroundColor: const Color.fromARGB(
                                          //     255, 3, 9, 18),
                                          title: const Text('Erro'),
                                          content: const Text(
                                              'Erro ao excluir usuário, tente novamente.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Ok'),
                                            ),
                                          ],
                                        );
                                      });
                                }
                                context
                                    .read<UsersListBloc>()
                                    .add(FetchUsersList());
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

  void removerCargos(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Remover cargos'),
          ],
        ),
        content: const Text('Deseja remover os cargos do usuário?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              //verifica se o usuario.cargo contém 'cliente' ou 'central'
              final cargos = usuario.cargo!.split(', ');
              bool isClient =
                  cargos.contains('Cliente') || cargos.contains('cliente');
              //remover cargos
              isClient
                  ? adminServices.removeClientCustomClaims(
                      usuario.uid, usuario.empresaId)
                  : adminServices.removeCentralCustomCalims(usuario.uid);
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void addCargo(Usuario usuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Selecione o cargo'),
          ],
        ),
        content: ValueListenableBuilder<String?>(
          valueListenable: selectedOption,
          builder: (context, value, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<String>(
                  value: 'Administrador',
                  groupValue: value,
                  onChanged: (newValue) {
                    selectedOption.value = newValue;
                  },
                ),
                const Text('Administrador'),
                const SizedBox(
                  width: 20,
                ),
                Radio<String>(
                  value: 'Gestor',
                  groupValue: value,
                  onChanged: (newValue) {
                    selectedOption.value = newValue;
                  },
                ),
                const Text('Gestor'),
                const SizedBox(
                  width: 20,
                ),
                Radio<String>(
                  value: 'Operador',
                  groupValue: value,
                  onChanged: (newValue) {
                    selectedOption.value = newValue;
                  },
                ),
                const Text('Operador'),
                const SizedBox(
                  width: 15,
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (selectedOption.value != null) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
                        title: const Text('Confirmação'),
                        content: const Text('Deseja adicionar o cargo?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              bool? sucesso;
                              //Navigator.of(context).pop();
                              if (selectedOption.value == 'Administrador') {
                                sucesso =
                                    await adminServices.addAdmin(usuario.uid);
                              } else if (selectedOption.value == 'Gestor') {
                                sucesso =
                                    await adminServices.addGestor(usuario.uid);
                              } else if (selectedOption.value == 'Operador') {
                                sucesso = await adminServices
                                    .addOperador(usuario.uid);
                              }
                              if (sucesso != null &&
                                  sucesso &&
                                  context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      // backgroundColor:
                                      //     const Color.fromARGB(255, 3, 9, 18),
                                      title: const Text('Sucesso'),
                                      content: const Text(
                                          'Cargo adicionado com sucesso'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            setState(() {
                                              cargoController!.text =
                                                  selectedOption.value!;
                                            });
                                          },
                                          child: const Text('Ok'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                BlocProvider.of<UsersListBloc>(context)
                                    .add(FetchUsersList());
                              } else if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      // backgroundColor:
                                      //     const Color.fromARGB(255, 3, 9, 18),
                                      title: const Text('Erro'),
                                      content: const Text(
                                          'Erro ao adicionar cargo, tente novamente'),
                                      actions: [
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
                              }
                            },
                            child: const Text('Confirmar'),
                          ),
                        ],
                      );
                    });
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
                    title: const Text('Erro'),
                    content: const Text('Selecione um cargo'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showCargosDialog(Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cargos'),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
                //color: Colors.white,
              ),
            ],
          ),
          content: const Text('Deseja adicionar ou remover cargos?'),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    removerCargos(usuario);
                  },
                  child: const Text('Remover'),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (cargoController!.text.contains('Cliente')) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Atenção'),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.close),
                                //color: Colors.white,
                              ),
                            ],
                          ),
                          content: const Text('O usuário pertence a plataforma do cliente.'),
                        ),
                      );
                    } else {
                      addCargo(usuario);
                    }
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        title: const Text(
          'DETALHES DO USUÁRIO',
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
                                      widget.user.photoUrl ??
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
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SelectableText(
                                  widget.user.nome,
                                  style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w400),
                                ),
                                SelectableText(
                                  'UID: ${widget.user.uid}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Último login: ',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SelectableText(
                                      lastLoginController!.text,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      'Criado em: ',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SelectableText(
                                      criadoEmController!.text,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Text(
                                      'Atualizado em: ',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SelectableText(
                                      atualizadoEmController!.text,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _showCargosDialog(widget.user),
                                        child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.key,
                                              color: Colors.yellow,
                                              size: 15,
                                            ),
                                            SizedBox(
                                              height: 1,
                                            ),
                                            Text(
                                              'Cargos',
                                              style: TextStyle(
                                                //color: Colors.red,
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
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            readOnly
                                                ? MouseRegion(
                                                    cursor: SystemMouseCursors
                                                        .click,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              AlertDialog(
                                                            title: const Text(
                                                                'Editar'),
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
                                                    cursor: SystemMouseCursors
                                                        .click,
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
                                                                builder:
                                                                    (context,
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
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              const Text('Fechar'),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed:
                                                                              () async {
                                                                            saveUserChanges();
                                                                          },
                                                                          child:
                                                                              const Text('Salvar'),
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
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () => _showDialog(widget.user),
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SizedBox(
                  width: width * 0.6 + 10,
                  child: !readOnly
                      ? TextFormField(
                          controller: nomeController,
                          readOnly: readOnly,
                          decoration: InputDecoration(
                            fillColor: readOnly ? Colors.grey : Colors.white,
                            focusColor: readOnly ? Colors.grey : Colors.white,
                            hoverColor: readOnly ? Colors.grey : Colors.white,
                            labelText: 'Nome',
                            labelStyle: TextStyle(
                              color: readOnly ? Colors.grey : Colors.black,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: readOnly ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w300,
                            color: readOnly ? Colors.grey : Colors.black,
                          ),
                        )
                      : null),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
                              controller: emailController,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor:
                                    readOnly ? Colors.grey : Colors.white,
                                focusColor:
                                    readOnly ? Colors.grey : Colors.white,
                                hoverColor:
                                    readOnly ? Colors.grey : Colors.white,
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: readOnly ? Colors.grey : Colors.black,
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
                                color: readOnly ? Colors.grey : Colors.black,
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
                              //initialValue: empresa.representanteLegalCpf,
                              controller: emailVerifiedController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Email verificado',
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
                                color: Colors.grey,
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
                              //enabled: false,
                              //initialValue: empresa.telefone,
                              inputFormatters: [
                                readOnly
                                    ? FilteringTextInputFormatter
                                        .singleLineFormatter
                                    : FilteringTextInputFormatter
                                        .digitsOnly, // Permite apenas dígitos
                                TelefoneInputFormatter(),
                              ],
                              controller: celularController,
                              readOnly: readOnly,
                              decoration: InputDecoration(
                                fillColor:
                                    readOnly ? Colors.grey : Colors.white,
                                focusColor:
                                    readOnly ? Colors.grey : Colors.white,
                                hoverColor:
                                    readOnly ? Colors.grey : Colors.white,
                                labelText: 'Celular',
                                labelStyle: TextStyle(
                                  color: readOnly ? Colors.grey : Colors.black,
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
                                color: readOnly ? Colors.grey : Colors.black,
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
                              controller: cargoController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                fillColor: Colors.grey,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                labelText: 'Cargo',
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
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
