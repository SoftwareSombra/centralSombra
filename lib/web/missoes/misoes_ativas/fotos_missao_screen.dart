import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import '../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../missao/model/missao_model.dart';
import '../../../missao/services/missao_services.dart';
import '../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/elevated_button/bloc/elevated_button_bloc_state.dart';
import '../../relatorios/services/relatorio_services.dart';

class FotosDaMissaoScreen extends StatefulWidget {
  final String uid;
  final String missaoId;
  const FotosDaMissaoScreen(
      {super.key, required this.missaoId, required this.uid});

  @override
  State<FotosDaMissaoScreen> createState() => _FotosDaMissaoScreenState();
}

final MissaoServices _missaoServices = MissaoServices();
final MensagemDeSucesso _msgDeSucesso = MensagemDeSucesso();
final TratamentoDeErros _msgDeErro = TratamentoDeErros();

class _FotosDaMissaoScreenState extends State<FotosDaMissaoScreen> {
  @override
  void initState() {
    visualizarFoto();
    super.initState();
  }

  void visualizarFoto() async {
    await _missaoServices.fotoVisualizada(widget.uid, widget.missaoId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FOTOS DA MISSÃO'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Foto>>(
        stream: RelatorioServices()
            .streamDeFotosDaMissao(widget.uid, widget.missaoId),
        builder: (BuildContext context, AsyncSnapshot<List<Foto>> snapshot) {
          debugPrint("Mensagens Snapshot Data: ${snapshot.data}");
          if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('Nenhuma foto encontrada'),
            );
          } else if (snapshot.hasData) {
            List<Foto> fotos = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: fotos.length,
                    itemBuilder: (context, index) {
                      ValueNotifier<bool> enviada =
                          ValueNotifier(fotos[index].enviada ?? false);
                      //bool enviada = fotos[index].enviada ?? false;
                      return Padding(
                        padding: const EdgeInsets.all(25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const SizedBox.shrink(),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => showImageDialog(context,
                                      fotos[index].url, fotos[index].caption),
                                  child: Image.network(fotos[index].url),
                                ),
                              ),
                            ),
                            !enviada.value
                                ? MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: IconButton(
                                      onPressed: () async {
                                        return _showDialog(
                                          enviada,
                                          fotos[index],
                                        );
                                      },
                                      icon: const Icon(Icons.send),
                                    ),
                                  )
                                : IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.check),
                                  ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          }
          return const Center(
            child: Text('Atualize a tela'),
          );
        },
      ),
    );
  }

  void _showDialog(ValueNotifier<bool> enviada, Foto foto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 3, 9, 18),
          title: const Text('Confirmação'),
          content: const Text('Deseja realmente enviar a foto?'),
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
                              try {
                                await _missaoServices.marcarFotoComoEnviada(
                                    widget.uid, widget.missaoId, foto.url);
                                enviada.value = true;
                                if (context.mounted) {
                                  _msgDeSucesso.showSuccessSnackbar(
                                      context, 'Foto enviada com sucesso!');
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor:
                                            const Color.fromARGB(255, 3, 9, 18),
                                        title: const Text('Erro'),
                                        content: const Text(
                                            'Erro ao enviar foto, tente novamente!'),
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
                              buttonContext.read<ElevatedButtonBloc>().add(
                                    ElevatedButtonReset(),
                                  );
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

  void showImageDialog(BuildContext context, String imageUrl, String? caption) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          width: MediaQuery.of(context).size.width * 0.65,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(40),
                      child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close))),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: PhotoView(
                    imageProvider: NetworkImage(imageUrl),
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
              if (caption != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Legenda: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SelectableText(caption),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
