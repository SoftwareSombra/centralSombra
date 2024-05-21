import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sombra_testes/autenticacao/screens/tratamento/error_snackbar.dart';
import 'package:sombra_testes/autenticacao/screens/tratamento/success_snackbar.dart';
import 'package:sombra_testes/missao/bloc/agente/agente_bloc.dart';
import 'package:sombra_testes/missao/bloc/agente/events.dart';
import 'package:sombra_testes/missao/services/missao_services.dart';

import '../../../mapa/screens/mapa.dart';
import '../../model/missao_model.dart';

class AddRelatorioScreen extends StatefulWidget {
  //final Missao missao;
  final String uid;
  final String missaoId;

  const AddRelatorioScreen({
    super.key,
    //required this.missao,
    required this.uid,
    required this.missaoId,
  });

  @override
  State<AddRelatorioScreen> createState() => _AddRelatorioScreenState();
}

class _AddRelatorioScreenState extends State<AddRelatorioScreen> {
  List<File?> images = [null, null, null, null, null];
  final ImagePicker _picker = ImagePicker();
  MissaoServices missaoServices = MissaoServices();
  TextEditingController controller = TextEditingController();
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  List<Map<String, dynamic>> imageData = [];
  bool isUploading = false;
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage(int index) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (index >= imageData.length) {
          imageData.add({
            'image': File(pickedFile.path),
            'description': '',
            'controller': TextEditingController(),
          });
        } else {
          imageData[index]['image'] = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Relatório'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Campos para as fotos
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: GestureDetector(
                      onTap: () => _pickImage(index),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 125,
                                width: 125,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: (index < imageData.length &&
                                        imageData[index]['image'] != null)
                                    ? Image.file(
                                        imageData[index]['image'],
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.add_a_photo),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: (index < imageData.length)
                                      ? imageData[index]['controller']
                                      : TextEditingController(),
                                  autofillHints: const ['controller'],
                                  decoration: InputDecoration(
                                    hintText: 'Descrição ${index + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Campo de texto livre
              TextField(
                controller: controller,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Mais informações...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isUploading ? null : uploadRelatorio,
                    child: isUploading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Enviar'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadRelatorio() async {
    setState(() {
      isUploading = true;
    });
    try {
      //adicionar foto por foto no firebase storage e pegar a url de cada uma
      List<Foto> fotosPosMissao = [];
      for (var i = 0; i < imageData.length; i++) {
        debugPrint('imageData: ${imageData[i]}');
        if (imageData[i]['image'] != null) {
          String filePath = imageData[i]['image'].path;
          final base64 =
              await missaoServices.imageToBase64(filePath);
          // final bytes = imageData[i]['image'].readAsBytesSync();
          // final base64Image = base64Encode(bytes);
          // debugPrint('imageData: ${imageData[i]}');
          // final storageReference = FirebaseStorage.instance
          //     .ref()
          //     .child('Fotos missões/${widget.missaoId}/${imageData[i]}.jpg');
          // debugPrint('storageReference: $storageReference');
          // //transformar o File em Uint8List
          // final imagem = imageData[i]['image'].readAsBytesSync();
          // debugPrint('imagem: ${imagem.toString()}');
          // final uploadTask = storageReference.putData(
          //     imagem, SettableMetadata(contentType: 'image/jpeg'));
          // debugPrint('uploadTask: $uploadTask');
          // final snapshot = await uploadTask.whenComplete(() {});
          // debugPrint('snapshot: $snapshot');
          // final downloadUrl = await snapshot.ref.getDownloadURL();
          // debugPrint('downloadUrl: $downloadUrl');
          fotosPosMissao.add(
            Foto(
              caption: imageData[i]['controller'].text,
              url: base64,
              timestamp: Timestamp.now(),
            ),
          );
        }
      }
      debugPrint('fotosPosMissao: $fotosPosMissao');
      debugPrint('infos: ${controller.text}');
      debugPrint('uid: ${widget.uid}');
      debugPrint('missaoId: ${widget.missaoId}');
      final relatorio =
          await missaoServices.incrementoRelatorioMissaoSelectFunction(
        widget.uid,
        widget.missaoId,
        fotosPosMissao: fotosPosMissao,
        infos: controller.text,
      );
      debugPrint('relatorio: $relatorio');
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted && relatorio.item1) {
        setState(() {
          isUploading = false;
        });
        mensagemDeSucesso.showSuccessSnackbar(
            context, 'Relatório enviado com sucesso');
        context.read<AgentMissionBloc>().add(FetchMission());
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const SearchScreen(),
        );
      } else {
        if (context.mounted) {
          setState(() {
            isUploading = false;
          });
          tratamentoDeErros.showErrorSnackbar(
              context, 'Erro ao enviar relatório');
        }
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          isUploading = false;
        });
        tratamentoDeErros.showErrorSnackbar(
            context, 'Erro ao enviar relatório: $e');
      }
    }
  }
}
