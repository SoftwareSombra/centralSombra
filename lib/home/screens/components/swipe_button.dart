import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import '../../bloc/swipe_button_bloc/swipe_button_bloc.dart';
import '../../bloc/swipe_button_bloc/swipe_button_event.dart';
import '../../bloc/swipe_button_bloc/swipe_button_state.dart';

class CustomSwipeSwitch extends StatefulWidget {
  const CustomSwipeSwitch({super.key});

  @override
  State<CustomSwipeSwitch> createState() => _CustomSwipeSwitchState();
}

class _CustomSwipeSwitchState extends State<CustomSwipeSwitch> {
  late bool isSwitched;

  @override
  void initState() {
    super.initState();
    context.read<SwipeButtonBloc>().add(SwipeButtonLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: BlocBuilder<SwipeButtonBloc, SwipeButtonState>(
          builder: (context, state) {
            if (state is SwipeButtonLoadind) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is SwipeButtonLoaded) {
              isSwitched = state.status;
              return SwipeButton(
                thumb: Container(
                  color: Colors.white.withOpacity(0.5),
                  child: Icon(
                    isSwitched ? Icons.check : Icons.close,
                    color: isSwitched ? Colors.green : Colors.red,
                  ),
                ),
                activeThumbColor: Colors.white.withOpacity(0.5),
                inactiveThumbColor: Colors.white.withOpacity(0.5),
                activeTrackColor: isSwitched
                    ? Colors.green.withOpacity(0.5)
                    : Colors.red.withOpacity(0.5),
                inactiveTrackColor: Colors.red,
                onSwipeEnd: () async {
                  showDialog(
                    context: context,
                    builder: (context) => PanaraConfirmDialogWidget(
                        panaraDialogType: PanaraDialogType.normal,
                        color: Colors.black,
                        textColor: Colors.white,
                        title: 'Atenção',
                        message: isSwitched
                            ? 'Deseja ficar indisponível?'
                            : 'Deseja ficar disponível?',
                        onTapConfirm: () {
                          context
                              .read<SwipeButtonBloc>()
                              .add(SwipeButtonChange(!isSwitched));
                          Navigator.pop(context);
                        },
                        onTapCancel: () {
                          Navigator.pop(context);
                        },
                        confirmButtonText: 'Confirmar',
                        cancelButtonText: 'Cancelar',
                        noImage: false,
                        imagePath: 'assets/images/confirm.png'),
                  );
                },
                child: Text(
                  isSwitched ? 'Disponível' : 'Indisponível',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }
            if (state is SwipeButtonError) {
              return const Center(
                child: Text(
                  'Erro ao buscar o seu status',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }
            return const Center(
              child: Text(
                'Erro ao buscar o seu status, atualize a tela',
                style: TextStyle(color: Colors.red),
              ),
            );
          },
        ),
      ),
    );
  }
}
