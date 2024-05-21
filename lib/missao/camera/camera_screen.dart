import 'dart:io';
import 'package:diacritic/diacritic.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

import '../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import '../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import '../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_state.dart';
import '../services/missao_services.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final String? missaoId;

  const CameraScreen({super.key, required this.camera, this.missaoId});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  double? _latitude;
  double? _longitude;
  String? address;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
    // verificar se o controller esta inicializado
    _initializeControllerFuture.then((_) {
      if (!mounted) {
        return;
      }
      setarFlash();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  setarFlash() async {
    await _controller.setFlashMode(FlashMode.off);
  }

  //funcao para acessar localizacao precisa do usuario
  Future<void> _getCurrentLocation() async {
    final location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _latitude = location.latitude;
      _longitude = location.longitude;
    });
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    const String googleAPIKey = 'AIzaSyDMX3eGdpKR2-9owNLETbE490WcoSkURAU';
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleAPIKey';

    Dio dio = Dio();

    final response = await dio.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      if (jsonResponse['results'].length > 0) {
        String address = jsonResponse['results'][0]['formatted_address'];
        return removeDiacritics(address);
      } else {
        return "S/E";
      }
    } else {
      return 'S/E';
    }
  }

  String _formatCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd – HH:mm:ss');
    return formatter.format(now);
  }

  void drawAddressWithLineBreaks(img.Image image, img.BitmapFont font,
      String address, int startX, int startY) {
    const int lineSpacing = 30; // Espaçamento entre linhas
    List<String> words = address.split(' '); // Divide o endereço em palavras
    StringBuffer currentLine = StringBuffer();
    int currentY = startY;

    for (String word in words) {
      // Adiciona a palavra atual na linha
      String testLine =
          currentLine.isNotEmpty ? '${currentLine.toString()} $word' : word;
      int averageCharacterWidth =
          font.size ~/ 2; // Ajuste este valor conforme necessário
      int estimatedLineWidth = testLine.length * averageCharacterWidth;

      if (estimatedLineWidth > image.width - startX) {
        // Desenha a linha atual e inicia uma nova linha
        addTextWithBackground(
            image, font, startX, currentY, currentLine.toString());
        currentLine.clear();
        currentY += lineSpacing;
      }

      // Adiciona a palavra na linha atual
      currentLine.write('$word ');
    }

    // Desenha a última linha se houver texto restante
    if (currentLine.isNotEmpty) {
      addTextWithBackground(
          image, font, startX, currentY, currentLine.toString());
    }
  }

  void addTextWithBackground(
      img.Image image, img.BitmapFont font, int x, int y, String text) {
    // Defina a cor do fundo (cinza escuro, por exemplo)
    var backgroundColor = img.ColorRgba8(80, 80, 80, 180); // RGBA

    // Estimativa da largura e altura do texto
    int textWidth = text.length * font.size ~/ 2;
    int textHeight = font.base;

    // Desenhe o fundo
    img.fillRect(image,
        x1: x - 5,
        y1: y - textHeight - 5,
        x2: x + textWidth + 5,
        y2: y + 5,
        color: backgroundColor);

    // Desenhe o texto sobre o fundo
    img.drawString(image, font: font, x: x, y: y - textHeight, text);
  }

  Future<void> _takePicture() async {
    context.read<ElevatedButtonBloc>().add(ElevatedButtonPressed());
    try {
      await _initializeControllerFuture;

      // Captura a imagem
      final XFile imageFile = await _controller.takePicture();

      // Carrega a imagem para edição
      img.Image image =
          img.decodeImage(File(imageFile.path).readAsBytesSync())!;

      // Especifica a fonte
      String dateText = _formatCurrentDate();
      img.BitmapFont font = img.arial24;

      // Obtem a localização atual
      await _getCurrentLocation();

      try {
        if (_latitude != null || _longitude != null) {
          debugPrint('buscando endereço');
          address = await getAddressFromCoordinates(_latitude!, _longitude!);
          debugPrint('endereço encontrado: $address');
        }
      } catch (e) {
        debugPrint('Erro ao buscar endereço: $e');
        // Considerar atribuir um valor padrão para 'address' aqui se necessário
      }
      debugPrint('continuando...');

      // Adiciona a data no canto inferior direito da imagem
      int textWidth =
          dateText.length * 10; // Estimativa de 10 pixels por caractere

      // Calcular a posição x e y onde o texto será desenhado
      int xDatePosition = image.width - textWidth - 40; // margem à direita
      int yDatePosition =
          image.height.toInt() - font.base - 270; // margem inferior

      int xLatPosition = image.width - textWidth - 40; // margem à direita
      int yLatPosition =
          image.height.toInt() - font.base - 240; // margem inferior

      int xLongPosition = image.width - textWidth - 40; // margem à direita
      int yLongPosition =
          image.height.toInt() - font.base - 210; // margem inferior

      int xAddressPosition = image.width - textWidth - 40; // margem à direita
      int yAddressPosition =
          image.height.toInt() - font.base - 170; // margem inferior

      // Desenha o texto na imagem
      addTextWithBackground(
          image, font, xDatePosition, yDatePosition, dateText);

      _latitude != null
          ? addTextWithBackground(
              image, font, xLatPosition, yLatPosition, _latitude.toString())
          : null;

      _longitude != null
          ? addTextWithBackground(
              image, font, xLongPosition, yLongPosition, _longitude.toString())
          : null;

      address != null
          ? drawAddressWithLineBreaks(
              image,
              font,
              address!,
              xAddressPosition,
              yAddressPosition,
            )
          : null;

      // Salva a imagem editada
      File editedImage = File(imageFile.path)
        ..writeAsBytesSync(img.encodePng(image));

      context.read<ElevatedButtonBloc>().add(ElevatedButtonActionCompleted());

      // Navega para a tela de visualização da imagem
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
              imagePath: editedImage.path, missaoId: widget.missaoId),
        ),
      );
    } catch (e) {
      // Se ocorrer um erro, você pode tratar aqui
      debugPrint(e.toString());
      context.read<ElevatedButtonBloc>().add(ElevatedButtonActionCompleted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
      builder: (context, state) {
        if (state is ElevatedButtonBlocLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Scaffold(
            appBar: AppBar(
              //title: const Text('Tire uma foto'),
            ),
            body: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: <Widget>[
                      CameraPreview(_controller),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: Text(
                          _formatCurrentDate(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Positioned(
                        top: 500,
                        left: 20,
                        child: IconButton(
                          icon: _controller.value.flashMode == FlashMode.off
                              ? const Icon(
                                  Icons.flash_off,
                                  color: Colors.white,
                                  size: 40,
                                )
                              : const Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: 40,
                                ),
                          onPressed: () {
                            setState(() {
                              _controller.setFlashMode(
                                  _controller.value.flashMode == FlashMode.off
                                      ? FlashMode.torch
                                      : FlashMode.off);
                            });
                          },
                        ),
                      )
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed:
                  state is ElevatedButtonBlocLoading ? null : _takePicture,
              child: const Icon(Icons.camera_alt),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        }
      },
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String? missaoId;

  DisplayPictureScreen({super.key, required this.imagePath, this.missaoId});

  final TextEditingController captionController = TextEditingController();
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  final MissaoServices missaoServices = MissaoServices();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  //funcao para exibir dialogo
  Future<void> _showDialog(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    //context.read<ElevatedButtonBloc>().add(ElevatedButtonActionCompleted());

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
          builder: (context, state) {
            return AlertDialog(
              title: const Text('Adicione uma descrição'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                    TextField(
                      controller: captionController,
                      decoration: const InputDecoration(
                          hintText: 'Digite uma descrição...'),
                    ),
                  ],
                ),
              ),
              actions: [
                state is! ElevatedButtonBlocLoading
                    ? TextButton(
                        onPressed: () async {
                          context
                              .read<ElevatedButtonBloc>()
                              .add(ElevatedButtonPressed());

                          String caption = captionController.text;
                          // Agora você pode usar a variável 'caption' para a legenda e 'photo' para a foto
                          // final url = await missaoServices.uploadPhoto(
                          //     File(imagePath), missaoId!);
                          // List<Map<String, dynamic>> fotoComLegenda = [
                          //   {
                          //     'url': url,
                          //     'caption': caption,
                          //     'timestamp': now,
                          //   }
                          // ];
                          // //fotosComLegendas.add(fotoComLegenda);

                          // final sucesso =
                          //     await missaoServices.fotoRelatorioMissao(
                          //         uid, missaoId!, fotoComLegenda);

                          final image =
                              await missaoServices.imageToBase64(imagePath);

                          final sucesso = await missaoServices
                              .enviarFotoRelatorioSelectFunction(
                                  uid, missaoId!, image, caption);

                          captionController.clear();
                          if (context.mounted) {
                            if (sucesso.item1) {
                              context
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonActionCompleted());
                              mensagemDeSucesso.showSuccessSnackbar(
                                  context, sucesso.item2);
                              Navigator.of(context).pop();
                            } else {
                              context
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonActionCompleted());
                              tratamentoDeErros.showErrorSnackbar(
                                  context, sucesso.item2);
                            }
                            Navigator.of(context).pop(); // Fechar o AlertDialog
                          }
                        },
                        child: const Text('Confirmar'),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visualizar Imagem')),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(context),
        tooltip: 'Adicionar Descrição',
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
