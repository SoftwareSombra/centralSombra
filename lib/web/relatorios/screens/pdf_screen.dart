import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_static_maps_controller/google_static_maps_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:printing/printing.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra_testes/chat_view/chatview.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import '../../../chat_view/src/models/message.dart';
import '../../../chat_view/src/values/enumaration.dart';
import '../../../missao/model/missao_model.dart';
import '../bloc/mission_details_bloc.dart';
import '../bloc/mission_details_event.dart';
import '../bloc/mission_details_state.dart';

class PdfScreen extends StatefulWidget {
  final MissaoRelatorio missao;
  final double? distanciaValue;
  final ImageProvider<Object>? mapUrl;
  final dynamic locations;
  final List<Message>? messages;
  final String missaoId;
  final String agenteId;
  final bool tipo;
  final bool cnpj;
  final bool nomeDaEmpresa;
  final bool local;
  final bool placaCavalo;
  final bool placaCarreta;
  final bool nomeMotorista;
  final bool cor;
  final bool obs;
  final bool inicio;
  final bool fim;
  final bool infos;
  final bool distancia;
  final bool mapa;
  final bool fotos;
  final bool fotosPos;
  final bool showMessages;
  const PdfScreen(
      {super.key,
      required this.missao,
      this.distanciaValue,
      this.mapUrl,
      this.locations,
      this.messages,
      required this.missaoId,
      required this.agenteId,
      required this.tipo,
      required this.cnpj,
      required this.nomeDaEmpresa,
      required this.local,
      required this.placaCavalo,
      required this.placaCarreta,
      required this.nomeMotorista,
      required this.cor,
      required this.obs,
      required this.inicio,
      required this.fim,
      required this.infos,
      required this.distancia,
      required this.mapa,
      required this.fotos,
      required this.fotosPos,
      required this.showMessages});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

Set<Marker> userMarkers = {};

class _PdfScreenState extends State<PdfScreen> {
  final pdf = pw.Document();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final canvasColor = const Color.fromARGB(255, 0, 15, 42);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: Text('Download PDF'),
      content: Text('Deseja baixar o arquivo PDF?'),
      actions: [
        TextButton(
          onPressed: () {
            generateAndDownloadPdf(widget.missao,
                distancia: widget.distancia ? widget.distanciaValue : null,
                image:
                    widget.mapa && widget.mapUrl != null ? widget.mapUrl : null,
                locations: widget.mapa ? widget.locations : null,
                messages: widget.showMessages ? widget.messages : null);
          },
          child: const Text('Baixar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Future<void> _salvarComoPDF(Uint8List imagem) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final diretorio = await getApplicationDocumentsDirectory();
      final arquivo = File('${diretorio.path}/screenshot.pdf');

      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Image(pw.MemoryImage(imagem)),
        ),
      ));

      await arquivo.writeAsBytes(await pdf.save());
      // Aqui você pode implementar a lógica para abrir o arquivo ou compartilhá-lo
    }
  }

  // Future<void> _takeScreenshot() async {
  //   try {
  //     await Future.delayed(const Duration(milliseconds: 100));
  //     if (context.mounted) {
  //       RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
  //           .findRenderObject() as RenderRepaintBoundary;

  //       double pixelRatio = MediaQuery.of(context).devicePixelRatio;
  //       ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
  //       ByteData? byteData =
  //           await image.toByteData(format: ui.ImageByteFormat.png);
  //       Uint8List imgBytes = byteData!.buffer.asUint8List();

  //       // Criar um PDF e adicionar a imagem
  //       final pdf = pw.Document();
  //       final imagePdf = pw.MemoryImage(imgBytes);

  //       // Ajuste o tamanho da página com base no tamanho da imagem capturada
  //       pdf.addPage(pw.Page(
  //         pageFormat: PdfPageFormat(
  //           image.width.toDouble() / pixelRatio,
  //           image.height.toDouble() / pixelRatio,
  //         ),
  //         build: (pw.Context context) {
  //           return pw.Center(
  //             child: pw.Image(imagePdf),
  //           );
  //         },
  //       ));

  //       // Salvar o PDF
  //       Uint8List pdfBytes = await pdf.save();
  //       final blob = html.Blob([pdfBytes], 'application/pdf');
  //       final url = html.Url.createObjectUrlFromBlob(blob);
  //       final anchor = html.AnchorElement(href: url)
  //         ..setAttribute('download', 'screenshot.pdf')
  //         ..click();
  //       html.Url.revokeObjectUrl(url);
  //     }
  //   } catch (e) {
  //     debugPrint('Erro ao capturar screenshot: $e');
  //   }
  // }

  Future<pw.ImageProvider> _loadAssetImage(String path) async {
    final byteData = await rootBundle.load(path);
    return pw.MemoryImage(
      byteData.buffer.asUint8List(),
    );
  }

  Future<pw.MemoryImage> convertImageProviderToPdfImage(
      ImageProvider imageProvider) async {
    final completer = Completer<ImageInfo>();
    final stream = imageProvider.resolve(const ImageConfiguration());

    void imageListener(ImageInfo info, bool synchronousCall) {
      completer.complete(info);
      stream.removeListener(ImageStreamListener(imageListener));
    }

    stream.addListener(ImageStreamListener(imageListener));

    final imageInfo = await completer.future;
    final ui.Image image = imageInfo.image;
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imgBytes = byteData!.buffer.asUint8List();

    return pw.MemoryImage(imgBytes);
  }

  // Future<List<pw.MemoryImage>> convertUrlsToPdfImages(List<String> urls) async {
  //   Dio dio = Dio();

  //   // Uma função auxiliar para baixar cada imagem e convertê-la para um MemoryImage
  //   Future<pw.MemoryImage> _fetchImage(String url) async {
  //     try {
  //       final response = await dio.get<Uint8List>(
  //         url,
  //         options: Options(responseType: ResponseType.bytes),
  //       );
  //       return pw.MemoryImage(response.data!);
  //     } catch (e) {
  //       throw Exception('Erro ao baixar a imagem: $e');
  //     }
  //   }

  //   // Mapear cada URL para uma Future de MemoryImage e aguardar todas as Futures
  //   List<pw.MemoryImage> pdfImages = await Future.wait(
  //     urls.map((url) => _fetchImage(url)),
  //   );

  //   return pdfImages;
  // }

  Future<pw.MemoryImage> _fetchImage(String url) async {
    Dio dio = Dio();
    try {
      final response = await dio.get<Uint8List>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return pw.MemoryImage(response.data!);
    } catch (e) {
      throw Exception('Erro ao baixar a imagem: $e');
    }
  }

  // Future<List<FotoComLegenda>> convertUrlsToPdfImages(
  //     List<String> urls, List<String> legendas) async {
  //   List<FotoComLegenda> fotosComLegenda = [];
  //   for (int i = 0; i < urls.length; i++) {
  //     final imagem = await _fetchImage(urls[i]);
  //     fotosComLegenda.add(FotoComLegenda(imagem: imagem, legenda: legendas[i]));
  //   }
  //   return fotosComLegenda;
  // }

  Future<List<FotoComLegenda>> convertUrlsToPdfImages(
      List<String> urls, List<String> legendas) async {
    Dio dio = Dio();
    List<FotoComLegenda> fotosComLegenda = [];

    for (int i = 0; i < urls.length; i++) {
      final response = await dio.get<Uint8List>(
        urls[i],
        options: Options(responseType: ResponseType.bytes),
      );
      final imagem = pw.MemoryImage(response.data!);
      final legenda =
          legendas[i]; // Supondo que cada URL tenha uma legenda correspondente
      fotosComLegenda.add(FotoComLegenda(imagem: imagem, legenda: legenda));
    }

    return fotosComLegenda;
  }

  Future<pw.MemoryImage> convertUrlToMemoryImage(String url) async {
    Dio dio = Dio();
    final response = await dio.get<Uint8List>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return pw.MemoryImage(response.data!);
  }

  Future<void> generateAndDownloadPdf(MissaoRelatorio missao,
      {distancia,
      ImageProvider? image,
      locations,
      List<Message>? messages}) async {
    final pdf = pw.Document();
    final escudo = await _loadAssetImage('assets/images/escudo.png');
    final mapa =
        image != null ? await convertImageProviderToPdfImage(image) : null;
    // final fotos = missao.fotos != null
    //     ? await convertUrlsToPdfImages(missao.fotos!.map((e) => e.url).toList())
    //     : null;
    List<FotoComLegenda>? fotosComLegenda = missao.fotos != null
        ? await convertUrlsToPdfImages(missao.fotos!.map((e) => e.url).toList(),
            missao.fotos!.map((e) => e.caption).toList())
        : null;

    if (messages != null) {
      List<Message> updatedMessages = [];

      for (Message message in messages) {
        if (message.messageType == MessageType.image) {
          // Converte a URL para uma imagem em memória (MemoryImage)
          final pdfImage = await convertUrlToMemoryImage(message.message);
          // Cria uma nova mensagem com a imagem convertida
          final Message newMessage = Message(
              pdfImage: pdfImage,
              message: message.message,
              createdAt: message.createdAt,
              sendBy: message.sendBy,
              autor: message.autor,
              messageType: MessageType.image,
              id: message.id,
              reaction: message.reaction,
              replyMessage: message.replyMessage,
              status: message.status,
              voiceMessageDuration: message.voiceMessageDuration);
          updatedMessages.add(newMessage);
        } else {
          updatedMessages.add(message);
        }
      }

      // Substitui a lista original pelas mensagens atualizadas
      messages = updatedMessages;
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    pw.Widget buildDataItemPdf(
      String title,
      String? data,
      bool isChecked,
    ) {
      return isChecked
          ? pw.Row(
              children: [
                pw.RichText(
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: title,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: data,
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : pw.SizedBox.shrink();
    }

    //transformar cada url em um ImageProvider

    // pw.Widget buildFotosPdf(pw.ImageProvider fotoBytes) {
    //   return pw.Row(
    //     mainAxisAlignment: pw.MainAxisAlignment.center,
    //     children: [
    //       pw.SizedBox(
    //         height: 500,
    //         child: pw.Padding(
    //           padding: const pw.EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
    //           child: pw.Container(
    //             width: 450,
    //             height: 500,
    //             child: pw.Image(fotoBytes),
    //           ),
    //         ),
    //       ),
    //     ],
    //   );
    // }

    pw.Widget buildFotosComLegendaPdf(FotoComLegenda fotoComLegenda) {
      return pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(height: 50),
          pw.Image(fotoComLegenda.imagem, height: 500, fit: pw.BoxFit.contain),
          pw.SizedBox(height: 5), // Espaçamento entre a foto e a legenda
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Row(
                children: [
                  pw.Text(
                    'Legenda: ',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  fotoComLegenda.legenda != null
                      ? pw.Text(
                          fotoComLegenda.legenda!,
                          textAlign: pw.TextAlign.left,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.black,
                          ),
                        )
                      : pw.SizedBox.shrink()
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 250)
        ],
      );
    }

    pw.Widget pdfImageMessageView(
      pw.MemoryImage url,
      bool isMessageBySender,
    ) {
      return pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        mainAxisAlignment: isMessageBySender
            ? pw.MainAxisAlignment.end
            : pw.MainAxisAlignment.start,
        children: [
          pw.Stack(
            children: [
              pw.Transform.scale(
                scale: 1.2,
                alignment: isMessageBySender
                    ? pw.Alignment.centerRight
                    : pw.Alignment.centerLeft,
                child: pw.Container(
                  padding: pw.EdgeInsets.zero,
                  margin: pw.EdgeInsets.only(
                    top: 6,
                    right: isMessageBySender ? 6 : 0,
                    left: isMessageBySender ? 0 : 6,
                    bottom: 0,
                  ),
                  height: 200,
                  width: 150,
                  child: pw.ClipRRect(
                    verticalRadius: 15,
                    horizontalRadius: 15,
                    child: pw.Image(
                      url,
                      fit: pw.BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    pw.Widget pdfTextMessageView(String message, bool isMessageBySender) {
      return pw.Stack(
        children: [
          pw.Container(
            constraints: const pw.BoxConstraints(maxWidth: 200),
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            margin: const pw.EdgeInsets.fromLTRB(5, 0, 6, 2),
            decoration: pw.BoxDecoration(
              color: isMessageBySender
                  ? const PdfColor.fromInt(0xFF454545)
                  : const PdfColor.fromInt(0xFF0000FF),
              borderRadius: pw.BorderRadius.circular(
                (15),
              ),
            ),
            child: pw.Text(
              message,
              style: const pw.TextStyle(
                color: PdfColor.fromInt(0xFFFFFFFF),
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }

    pw.Widget buildChatAgente(List<Message> messages) {
      return pw.ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          if (messages[index].messageType.isText) {
            debugPrint('-----> message index: ${messages[index].message}');
          } else if (messages[index].messageType == MessageType.voice) {
            debugPrint('-----> audio');
          } else if (messages[index].messageType == MessageType.image) {
            debugPrint(
                '-----> image message index: ${messages[index].pdfImage.toString()}');
          }
          return pw.Center(
            child: pw.ConstrainedBox(
              constraints: const pw.BoxConstraints(maxWidth: 400),
              child: pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: messages[index].autor == 'Atendente'
                        ? pw.MainAxisAlignment.start
                        : pw.MainAxisAlignment.end,
                    children: [
                      messages[index].messageType == MessageType.text
                          ?
                          //pw.Text(messages[index].message)
                          pdfTextMessageView(messages[index].message,
                              messages[index].autor == 'Atendente')
                          : messages[index].messageType == MessageType.image
                              ?
                              // pw.Image(messages[index].pdfImage!,
                              //     height: 150, fit: pw.BoxFit.contain)
                              pdfImageMessageView(messages[index].pdfImage!,
                                  messages[index].autor == 'Atendente')
                              :
                              //pw.Text('---- audio ----')
                              pdfTextMessageView('---- audio ----',
                                  messages[index].autor == 'Atendente')
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: messages[index].autor == 'Atendente'
                        ? pw.MainAxisAlignment.start
                        : pw.MainAxisAlignment.end,
                    children: [
                      pw.Text(
                          '${DateFormat('dd/MM/yyy', 'pt_BR').format(messages[index].createdAt)} - ${DateFormat('HH:mm', 'pt_BR').format(messages[index].createdAt)}',
                          style: const pw.TextStyle(color: PdfColors.grey, fontSize: 11))
                    ],
                  ),
                  pw.SizedBox(height: 15),
                ],
              ),
            ),
          );
        },
      );
    }

    // Adicione páginas ao seu PDF como necessário
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(5),
        build: (pw.Context context) {
          return <pw.Widget>[
            // Cabeçalho
            pw.Row(
              children: [
                pw.SizedBox(
                  height: 60,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(10.0),
                    child: pw.Image(escudo),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Relatório de Missão',
                      style: const pw.TextStyle(fontSize: 15),
                    ),
                    pw.Text(
                      'ID: ${widget.missaoId}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Dados da missão
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // pw.Padding(
                //   padding: const pw.EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                //   child: pw.Text(
                //     'Dados:',
                //     style: const pw.TextStyle(fontSize: 18),
                //   ),
                // ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Tipo: ',
                    missao.tipo,
                    widget.tipo,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'CNPJ: ',
                    missao.cnpj,
                    widget.cnpj,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Nome da empresa: ',
                    missao.nomeDaEmpresa,
                    widget.nomeDaEmpresa,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Local: ',
                    missao.local,
                    widget.local,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Placa cavalo: ',
                    missao.placaCavalo,
                    widget.placaCavalo,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Placa carreta: ',
                    missao.placaCarreta,
                    widget.placaCarreta,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Nome do motorista: ',
                    missao.motorista,
                    widget.nomeMotorista,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Cor: ',
                    missao.corVeiculo,
                    widget.cor,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Observações: ',
                    missao.observacao,
                    widget.obs,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Início: ',
                    missao.inicio != null
                        ? DateFormat('dd/MM/yyyy HH:mm:ss')
                            .format(missao.inicio!.toDate())
                        : null,
                    widget.inicio,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Fim: ',
                    missao.serverFim != null
                        ? DateFormat('dd/MM/yyyy HH:mm:ss')
                            .format(missao.serverFim!.toDate())
                        : null,
                    widget.fim,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Informações: ',
                    missao.infos,
                    widget.infos,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 50),
                  child: buildDataItemPdf(
                    'Distância: ',
                    distancia != null
                        ? '${distancia!.toStringAsFixed(2)}km'
                        : null,
                    widget.distancia,
                  ),
                ),
              ],
            ),

            // Mapa (Se aplicável)
            if (widget.mapa && mapa != null)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 20),
                    child: pw.Container(
                      height: 600,
                      width: 500,
                      child: pw.Image(mapa),
                    ),
                  ),
                ],
              ),
            // if (widget.fotos && fotosComLegenda != null)
            //   pw.Row(
            //     mainAxisAlignment: pw.MainAxisAlignment.center,
            //     children: [
            //       pw.Padding(
            //         padding: const pw.EdgeInsets.symmetric(
            //             vertical: 10, horizontal: 50),
            //         child: pw.Text(
            //           'FOTOS',
            //           style: const pw.TextStyle(fontSize: 20),
            //         ),
            //       ),
            //     ],
            //   ),
            // if (widget.fotos && fotosComLegenda != null)
            //   pw.SizedBox(
            //     height: 25,
            //   ),
            if (widget.fotos && fotosComLegenda != null)
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  for (var fotoComLegenda in fotosComLegenda)
                    buildFotosComLegendaPdf(fotoComLegenda),
                ],
              ),
            if (messages != null && widget.showMessages)
              pw.SizedBox(
                height: 50,
              ),
            if (messages != null && widget.showMessages)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Padding(
                    padding:
                        pw.EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                    child: pw.Text(
                      'CHAT',
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            if (messages != null && widget.showMessages)
              pw.SizedBox(
                height: 25,
              ),
            if (messages != null && widget.showMessages)
              buildChatAgente(messages)
          ];
        },
      ),
    );

    // Salvar o PDF
    final bytes = await pdf.save();

    // Chama downloadFile() para baixar o arquivo PDF
    // downloadFile(
    //     bytes, 'application/pdf', 'relatorio_missao_${widget.missaoId}.pdf');

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
    );
  }

  void downloadFile(Uint8List fileBytes, String mimeType, String defaultName) {
    // Cria um Blob com os dados do arquivo
    final blob = html.Blob([fileBytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Cria um elemento de âncora (link) para o download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", defaultName) // Define o nome padrão do arquivo
      ..click(); // Simula um clique para iniciar o download

    html.Url.revokeObjectUrl(url); // Libera o objeto URL após o download
  }

  Widget buildFotos(url, caption, context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: height * 0.6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => showImageDialog(context, url),
                  child: Container(
                    width: width * 0.5,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
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
        //legenda
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Legenda: ',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              caption,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        );
      },
    );
  }
}

Widget buildDataItem(String title, String? data, bool isChecked,
    {Function(bool?)? onChanged}) {
  return isChecked
      ? Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextSpan(
                    text: data,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      : const SizedBox.shrink();
}

class FotoComLegenda {
  final pw.MemoryImage imagem;
  final String? legenda;

  FotoComLegenda({required this.imagem, this.legenda});
}
