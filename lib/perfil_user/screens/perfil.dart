import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sombra_testes/conta_bancaria/screens/add_conta.dart';
import 'package:sombra_testes/perfil_user/bloc/conta_bancaria/conta_bancaria_bloc.dart';
import 'package:sombra_testes/perfil_user/bloc/conta_bancaria/states.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:validadores/validadores.dart';
import '../../agente/bloc/get_user/agente_bloc.dart';
import '../../agente/bloc/get_user/events.dart';
import '../../agente/bloc/get_user/states.dart';
import '../bloc/conta_bancaria/events.dart';
import '../bloc/foto/user/states.dart';
import '../bloc/foto/user/user_foto_bloc.dart';
import '../bloc/nome/get_name_bloc.dart';
import '../bloc/nome/get_name_states.dart';
import 'add_infos.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _controller = StreamController<SwipeRefreshState>.broadcast();
  Stream<SwipeRefreshState> get _stream => _controller.stream;

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  Future<void> _refresh(BuildContext context, uid) async {
    if (context.mounted) {
      try {
        context.read<AgenteBloc>().add(FetchAgenteInfo(uid!));
        context.read<ContaBancariaBloc>().add(FetchContaBancariaInfo(uid));
        _controller.sink.add(SwipeRefreshState.hidden);
      } catch (e) {
        _controller.sink.add(SwipeRefreshState.hidden);
      } finally {
        _controller.sink.add(SwipeRefreshState.hidden);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 14, 14, 14),
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PERFIL',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: SwipeRefresh.adaptive(
        indicatorColor: Colors.blue,
        stateStream: _stream,
        onRefresh: () async {
          try {
            await _refresh(context, uid);
          } catch (e) {
            debugPrint('Erro ao atualizar: $e');
          }
        },
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BlocBuilder<UserFotoBloc, UserFotoState>(
                          builder: (context, state) {
                            if (state is UserFotoLoading) {
                              return const CircularProgressIndicator();
                            } else if (state is UserFotoLoaded ||
                                state is UserFotoUpdated) {
                              return CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                    state is UserFotoLoaded
                                        ? state.foto
                                        : (state as UserFotoUpdated).foto),
                              );
                            } else if (state is UserFotoError) {
                              return const CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(
                                    'assets/images/fotoDePerfilNull.jpg'),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 3,
                      ),
                      BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          if (state is UserNameLoading) {
                            return const CircularProgressIndicator();
                          } else if (state is UserNameLoaded) {
                            return Column(
                              children: [
                                Text(
                                  state.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  state.email,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey),
                                ),
                              ],
                            );
                          } else if (state is UserNameError) {
                            return Text(state.message);
                          }
                          return const SizedBox
                              .shrink(); // Pode ser substituído por um widget padrão ou vazio
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  BlocBuilder<AgenteBloc, AgenteState>(
                    builder: (context, state) {
                      if (state is AgenteLoading) {
                        return const CircularProgressIndicator();
                      } else if (state is EmAnalise) {
                        return const Center(
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning,
                                    size: 50,
                                    color: Colors.yellow,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Dados em análise, aguarde.',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      } else if (state is AgenteLoaded) {
                        return Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Seus dados pessoais:",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // TextFormField(
                                //   enabled: false,
                                //   initialValue: state.agente.cidade,
                                //   decoration: const InputDecoration(
                                //     labelText: "Endereço",
                                //     border: OutlineInputBorder(),
                                //   ),
                                //   style: const TextStyle(
                                //       fontSize: 17,
                                //       fontWeight: FontWeight.w300),
                                // ),
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.agente.logradouro,
                                  decoration: const InputDecoration(
                                    labelText: "Logradouro",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(
                                    height: 10), // Espaço entre os campos
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.agente.numero,
                                  decoration: const InputDecoration(
                                    labelText: "Número",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.agente.complemento,
                                  decoration: const InputDecoration(
                                    labelText: "Complemento",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.agente.bairro,
                                  decoration: const InputDecoration(
                                    labelText: "Bairro",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.agente.cidade,
                                  decoration: const InputDecoration(
                                    labelText: "Cidade",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.agente.estado,
                                  decoration: const InputDecoration(
                                    labelText: "Estado",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.agente.cep,
                                  decoration: const InputDecoration(
                                    labelText: "CEP",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.agente.celular,
                                  decoration: const InputDecoration(
                                    labelText: "Celular",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.agente.rg,
                                  decoration: const InputDecoration(
                                    labelText: "RG",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  validator: (value) {
                                    // Aqui entram as validações
                                    return Validador()
                                        .add(Validar.CPF, msg: 'CPF Inválido')
                                        .add(Validar.OBRIGATORIO,
                                            msg: 'Campo obrigatório')
                                        .minLength(11)
                                        .maxLength(11)
                                        .valido(value, clearNoNumber: true);
                                  },
                                  enabled: false,
                                  initialValue: state.agente.cpf,
                                  decoration: const InputDecoration(
                                    labelText: "CPF",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else if (state is AgenteInfosRejected) {
                        return Center(
                          child: Column(
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    //icone do ponto de exclamação branco, vermelho em volta e circular
                                    Icons.error,
                                    size: 50,
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Alguns ou todos os dados foram rejeitados, corrija e envie novamente.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 50),
                                child: PanaraButton(
                                  buttonTextColor: Colors.white,
                                  text: 'Reenviar',
                                  onTap: () {
                                    PersistentNavBarNavigator.pushNewScreen(
                                      context,
                                      screen: AddInfosScreen(),
                                      withNavBar: false,
                                    );
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             AddInfosScreen()));
                                  },
                                  bgColor: Colors.blue,
                                  isOutlined: false,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (state is AgenteNotExist) {
                        return Column(
                          children: [
                            PanaraInfoDialogWidget(
                              title: "Dados pessoais",
                              message:
                                  "Você não tem dados pessoais cadastrados, cadastre-os",
                              buttonText: "Cadastrar",
                              onTapDismiss: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: AddInfosScreen(),
                                  withNavBar: false,
                                );

                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             AddInfosScreen()));
                              },
                              panaraDialogType: PanaraDialogType.normal,
                              noImage: false,
                              imagePath:
                                  'assets/images/file_searching-pana.png',
                              textColor: Colors.white,
                              containerColor: Colors.grey[800],
                              buttonTextColor: Colors.white,
                            ),
                            // const SizedBox(
                            //   height: 20,
                            // ),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //             builder: (context) => AddInfosScreen()));
                            //   },
                            //   child: const Text('Cadastrar'),
                            // )
                          ],
                        );
                      } else if (state is AgenteError) {
                        return Text("Erro: ${state.message}");
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  BlocBuilder<ContaBancariaBloc, ContaBancariaState>(
                    builder: (context, state) {
                      if (state is ContaBancariaLoading) {
                        return const CircularProgressIndicator();
                      } else if (state is ContaBancariaLoaded) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sua conta bancária:",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.contaBancaria.titular,
                                  decoration: const InputDecoration(
                                    labelText: "Titular",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(
                                    height: 10), // Espaço entre os campos
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.contaBancaria.agencia,
                                  decoration: const InputDecoration(
                                    labelText: "Agência",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  enabled: false,
                                  initialValue: state.contaBancaria.chavePix,
                                  decoration: const InputDecoration(
                                    labelText: "Chave pix",
                                    border: OutlineInputBorder(),
                                  ),
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else if (state is ContaBancariaAguardandoAprovacao) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 50,
                                  color: Colors.yellow,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Os dados da sua conta bancária estão sendo analisados, aguarde.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      } else if (state is ContaBancariaInfosRejected) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error,
                                  size: 50,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Um ou mais dados da sua conta bancária foram rejeitados, corrija e envie novamente.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 50),
                              child: PanaraButton(
                                buttonTextColor: Colors.white,
                                text: 'Reenviar',
                                onTap: () {
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: AddContaBancariaScreeen(),
                                    withNavBar: false,
                                  );
                                },
                                bgColor: Colors.blue,
                                isOutlined: false,
                              ),
                            ),
                          ],
                        );
                      } else if (state is ContaBancariaNotExist) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 30,
                            ),
                            const Text(
                              "Você não tem conta bancária cadastrada",
                              style: TextStyle(fontSize: 17),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: AddContaBancariaScreeen(),
                                  withNavBar: false,
                                );
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             AddContaBancariaScreeen()));
                              },
                              child: const Text('Cadastrar'),
                            )
                          ],
                        );
                      } else if (state is ContaBancariaError) {
                        return Text("Erro: ${state.message}");
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PanaraInfoDialogWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? imagePath;
  final String buttonText;
  final VoidCallback onTapDismiss;
  final PanaraDialogType panaraDialogType;
  final Color? containerColor;
  final Color? color;
  final Color? textColor;
  final Color? buttonTextColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  /// If you don't want any icon or image, you toggle it to true.
  final bool noImage;
  const PanaraInfoDialogWidget({
    super.key,
    this.title,
    required this.message,
    required this.buttonText,
    required this.onTapDismiss,
    required this.panaraDialogType,
    this.textColor = const Color(0xFF707070),
    this.containerColor = Colors.white,
    this.color = const Color(0xFF179DFF),
    this.buttonTextColor,
    this.imagePath,
    this.padding =
        const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 24),
    this.margin =
        const EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 24),
    required this.noImage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Card(
          elevation: 2,
          color: Colors.black,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 340,
            ),
            margin: margin ?? const EdgeInsets.all(0),
            padding: padding ?? const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                if (!noImage)
                  Image.asset(
                    imagePath ?? 'assets/info.png',
                    package: imagePath != null ? null : 'panara_dialogs',
                    width: 110,
                    height: 110,
                    color: imagePath != null
                        ? null
                        : (panaraDialogType == PanaraDialogType.normal
                            ? PanaraColors.normal
                            : panaraDialogType == PanaraDialogType.success
                                ? PanaraColors.success
                                : panaraDialogType == PanaraDialogType.warning
                                    ? PanaraColors.warning
                                    : panaraDialogType == PanaraDialogType.error
                                        ? PanaraColors.error
                                        : color),
                  ),
                if (title != null)
                  Text(
                    title ?? "",
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (title != null)
                  const SizedBox(
                    height: 5,
                  ),
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    height: 1.5,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                PanaraButton(
                  buttonTextColor: buttonTextColor ?? Colors.white,
                  text: buttonText,
                  onTap: onTapDismiss,
                  bgColor: panaraDialogType == PanaraDialogType.normal
                      ? PanaraColors.normal
                      : panaraDialogType == PanaraDialogType.success
                          ? PanaraColors.success
                          : panaraDialogType == PanaraDialogType.warning
                              ? PanaraColors.warning
                              : panaraDialogType == PanaraDialogType.error
                                  ? PanaraColors.error
                                  : color ?? PanaraColors.normal,
                  isOutlined: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PanaraButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color bgColor;
  final Color buttonTextColor;
  final bool isOutlined;

  const PanaraButton({
    super.key,
    required this.text,
    this.onTap,
    required this.bgColor,
    required this.isOutlined,
    this.buttonTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isOutlined ? Colors.white : bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: isOutlined ? Border.all(color: bgColor) : null,
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue,
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isOutlined ? bgColor : buttonTextColor,
            ),
          ),
        ),
      ),
    );
  }
}

enum PanaraDialogType { success, normal, warning, error, custom }

class PanaraColors {
  /// All the Colors used in the Dialog themes
  /// <h3>Hex Code: #61D800</h3>
  static Color success = const Color(0xFF61D800);

  /// <h3>Hex Code: #179DFF</h3>
  static Color normal = const Color(0xFF179DFF);

  /// <h3>Hex Code: #FF8B17</h3>
  static Color warning = const Color(0xFFFF8B17);

  /// <h3>Hex Code: #FF4D17</h3>
  static Color error = const Color(0xFFFF4D17);

  /// <h3>Hex Code: #707070</h3>
  static Color defaultTextColor = const Color(0xFF707070);
}
