import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sombra_testes/missao/bloc/agente/agente_bloc.dart';
import 'package:sombra_testes/missao/bloc/agente/states.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';
import '../../../perfil_user/screens/add_infos.dart';
import '../../../perfil_user/screens/perfil.dart';
import '../../bloc/missao_bloc/events.dart';
import '../../bloc/missao_bloc/get_missao_bloc.dart';
import '../../bloc/missao_bloc/states.dart';
import 'swipe_button.dart';

class MissaoHome extends StatelessWidget {
  final PersistentTabController? controller;
  MissaoHome({super.key, this.controller});

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final uid = firebaseAuth.currentUser!.uid;
    final nome = firebaseAuth.currentUser!.displayName;
    MissaoServices missaoServices = MissaoServices();
    final double width = MediaQuery.of(context).size.width;
    // context.read<GetMissaoBloc>().add(LoadMissao(uid));
    // context.read<AgentMissionBloc>().add(FetchMission());
    //TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
    //final navBloc = context.read<NavigationBloc>();

    return BlocBuilder<GetMissaoBloc, GetMissaoState>(
      builder: (context, missaoState) {
        return BlocBuilder<AgentMissionBloc, AgentState>(
          builder: (context, agentState) {
            if (missaoState is GetMissaoLoading ||
                agentState is LoadingAgentState) {
              return grayContainer(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                context,
              );
            } else if (agentState is IsNotAgent ||
                missaoState is IsNotAvailable) {
              return PanaraInfoDialogWidget(
                title: "Ops...",
                message: "Você não possui cadastro como agente.",
                panaraDialogType: PanaraDialogType.normal,
                buttonText: "Cadastre-se",
                onTapDismiss: () {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: AddInfosScreen(),
                    withNavBar: false,
                  );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => AddInfosScreen(),
                  //   ),
                  // );
                },
                noImage: false,
                imagePath: 'assets/images/stop-pana.png',
                textColor: Colors.white,
                containerColor: Colors.grey[800],
                buttonTextColor: Colors.white,
              );
            } else if (agentState is ReportPending) {
              return grayContainer(
                  const Center(
                    child: Text('Você possui um relatório pendente'),
                  ),
                  context);
            } else if (missaoState is GetMissaoLoaded) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      //elevation: 5,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Center(
                              child: Column(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        //icone de sirene
                                        Icons.notifications_active,
                                        color: Colors.red,
                                        size: 35,
                                      ),
                                      Text(
                                        'Chamado!',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.gps_fixed,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Tipo:',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        Text(
                                          missaoState.missao.tipo,
                                          style: const TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Local:',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        SizedBox(
                                          width: width * 0.75,
                                          child: Text(
                                            missaoState.missao.local,
                                            maxLines: 3,
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 21,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      // missionBloc.add(
                                      //   StartLocationTracking(
                                      //       MissionType.type1, state.missao.missaoId),
                                      // );
                                      context.read<GetMissaoBloc>().add(
                                            AceitarChamado(
                                                missaoState.missao.missaoId,
                                                nome!),
                                          );
                                      //navBloc.add(ChangeToMissao());
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green),
                                      minimumSize: MaterialStateProperty.all(
                                          const Size(55, 55)),
                                    ),
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => ));
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Aviso'),
                                            content:
                                                const SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Text('Em desenvolvimento'),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Ok'),
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(Colors.red),
                                      minimumSize: MaterialStateProperty.all(
                                          const Size(55, 55)),
                                    ),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (missaoState is EmMissao) {
              return
                  //  Card(
                  //   elevation: 1,
                  //   child: SizedBox(
                  //     height: 300,
                  //     width: width * 0.9,
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.center,
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         const Icon(
                  //           //ponto de exclamacao com o entorno de um circulo
                  //           Icons.warning_amber_outlined,
                  //           size: 40,
                  //           color: Colors.yellow,
                  //         ),
                  //         const SizedBox(
                  //           height: 5,
                  //         ),
                  //         const Text(
                  //           'Você está em missão!',
                  //           style: TextStyle(fontSize: 18),
                  //         ),
                  //         Padding(
                  //           padding: const EdgeInsets.all(25),
                  //           child: ElevatedButton(
                  //             style: ElevatedButton.styleFrom(
                  //               backgroundColor: Colors.blue,
                  //             ),
                  //             onPressed: () {
                  //               controller?.jumpToTab(1);
                  //             },
                  //             child: const Text(
                  //               'Visualizar',
                  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // );
                  PanaraInfoDialogWidget(
                title: "Atenção",
                message: "Você está em missão!",
                panaraDialogType: PanaraDialogType.normal,
                buttonText: "Visualizar",
                onTapDismiss: () {
                  controller?.jumpToTab(1);
                },
                noImage: false,
                imagePath: 'assets/images/missao-pana.png',
                textColor: Colors.white,
                containerColor: Colors.grey[800],
                buttonTextColor: Colors.white,
              );
            } else if (missaoState is SemMissao) {
              return Column(
                children: [
                  PanaraContainerWidget(
                    title: "Fique atento",
                    message: "Atualize seu status no botão abaixo",
                    panaraDialogType: PanaraDialogType.normal,
                    noImage: false,
                    imagePath: 'assets/images/attention-pana.png',
                    textColor: Colors.white,
                    containerColor: Colors.grey[800],
                    buttonTextColor: Colors.white,
                  ),
                  CustomSwipeSwitch(),
                ],
              );
            } else if (missaoState is GetMissaoError) {
              return grayContainer(
                  Center(
                    child: Text('Erro: ${missaoState.error}'),
                  ),
                  context);
            } else if (missaoState is AceitarChamadoLoading) {
              return grayContainer(
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                  context);
            } else if (missaoState is AceitarChamadoLoaded) {
              return grayContainer(
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_clock_outlined,
                        size: 50,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: width * 0.75,
                        child: const Text(
                          'Aguarde o retorno da central.',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  context);
            } else if (missaoState is ConfirmacaoMissaoSuccess) {
              return grayContainer(
                  Center(
                    child: Text(missaoState.message),
                  ),
                  context);
            } else if (missaoState is ConfirmacaoMissaoFailed) {
              return grayContainer(
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(missaoState.message),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await missaoServices.excluirResposta(uid);
                            Future.delayed(
                              const Duration(seconds: 1),
                            );
                            if (context.mounted) {
                              context
                                  .read<GetMissaoBloc>()
                                  .add(LoadMissao(uid));
                            }
                          },
                          child: const Text('Ok'),
                        )
                      ],
                    ),
                  ),
                  context);
            } else if (missaoState is ChamadoError) {
              return grayContainer(
                  Center(
                    child: Text('Erro: ${missaoState.message}'),
                  ),
                  context);
            } else if (missaoState is ChamadoError) {
              return grayContainer(
                  Center(
                    child: Text('Erro: ${missaoState.message}'),
                  ),
                  context);
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget grayContainer(Widget child, BuildContext context) {
    return Card(
      //color: Colors.grey[800],
      //: 5,
      child: SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width * 0.9,
        child: child,
      ),
    );
  }
}

class PanaraContainerWidget extends StatelessWidget {
  final String? title;
  final String message;
  final String? imagePath;
  final String? buttonText;
  final VoidCallback? onTapDismiss;
  final PanaraDialogType panaraDialogType;
  final Color? containerColor;
  final Color? color;
  final Color? textColor;
  final Color? buttonTextColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  /// If you don't want any icon or image, you toggle it to true.
  final bool noImage;
  const PanaraContainerWidget({
    Key? key,
    this.title,
    required this.message,
    this.buttonText,
    this.onTapDismiss,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Card(
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
                  height: 30,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
