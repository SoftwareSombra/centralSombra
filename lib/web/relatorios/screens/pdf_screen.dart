import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_static_maps_controller/google_static_maps_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import '../../../missao/model/missao_model.dart';
import '../bloc/mission_details_bloc.dart';
import '../bloc/mission_details_event.dart';
import '../bloc/mission_details_state.dart';

class PdfScreen extends StatefulWidget {
  final String missaoId;
  final String agenteId;
  final bool tipo;
  final bool cnpj;
  final bool nomeDaEmpresa;
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
  const PdfScreen(
      {super.key,
      required this.missaoId,
      required this.agenteId,
      required this.tipo,
      required this.cnpj,
      required this.nomeDaEmpresa,
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
      required this.fotosPos});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final pdf = pw.Document();
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final canvasColor = const Color.fromARGB(255, 0, 15, 42);

  @override
  void initState() {
    context
        .read<MissionDetailsBloc>()
        .add(FetchMissionDetails(widget.agenteId, widget.missaoId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Relatório de Missão'),
        ),
        body: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    BlocBuilder<MissionDetailsBloc, MissionDetailsState>(
                      builder: (context, state) {
                        debugPrint(state.toString());
                        if (state is MissionDetailsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is MissionDetailsNoRouteFound) {
                          return const Center(
                              child: Text('Nenhum percurso feito'));
                        }
                        if (state is MissionDetailsLoaded) {
                          // Acessando a missão carregada
                          MissaoRelatorio missao = state.missoes;

                          final Path path = Path(
                            color: Colors.blue,
                            points: state.locations!,
                          );

                          //Configurar o StaticMapController
                          final staticMapController = StaticMapController(
                            googleApiKey:
                                "AIzaSyBGozAuPStyTlmF22-zku_I-8gcX3EMfm4",
                            width: 1000,
                            height: 700,
                            zoom: 11,
                            center: state
                                .middleLocation, // Usar a primeira localização como centro
                            paths: [path], // Incluir o Path criado
                          );

                          final ImageProvider image = staticMapController.image;

                          // Construindo linhas da tabela com os dados da missão
                          return Column(
                            children: [
                              ResponsiveRowColumn(
                                layout: ResponsiveBreakpoints.of(context)
                                        .smallerThan(DESKTOP)
                                    ? ResponsiveRowColumnType.COLUMN
                                    : ResponsiveRowColumnType.ROW,
                                rowMainAxisAlignment: MainAxisAlignment.start,
                                rowPadding: EdgeInsets.only(
                                    left: width * 0.1,
                                    top: 10,
                                    bottom: 20,
                                    right: width * 0.1),
                                columnPadding: const EdgeInsets.all(8.0),
                                columnSpacing: 20.0,
                                children: [
                                  ResponsiveRowColumnItem(
                                    child: SizedBox(
                                      height: 100,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Image.asset(
                                            'assets/images/escudo.png'),
                                      ),
                                    ),
                                  ),
                                  ResponsiveRowColumnItem(
                                    rowFlex: 1,
                                    rowFit: FlexFit.tight,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Relatório de missão',
                                          style: TextStyle(
                                              fontFamily:
                                                  AutofillHints.jobTitle,
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: canvasColor),
                                        ),
                                        SelectableText(
                                          'Id: ${widget.missaoId}',
                                          style: TextStyle(
                                              fontFamily:
                                                  AutofillHints.jobTitle,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: canvasColor),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (ResponsiveBreakpoints.of(context)
                                      .largerThan(MOBILE))
                                    const ResponsiveRowColumnItem(
                                      child: Spacer(),
                                    ),
                                  // Botão no final
                                  ResponsiveRowColumnItem(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        generateAndDownloadPdf(
                                          missao,
                                          distancia: widget.distancia
                                              ? state.distancia
                                              : null,
                                          image: widget.mapa ? image : null,
                                          locations: widget.mapa
                                              ? state.locations
                                              : null,
                                        );
                                      },
                                      child: const Text('Baixar'),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: width * 0.15,
                                        right: width * 0.15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Dados:',
                                          style: TextStyle(
                                              fontFamily:
                                                  AutofillHints.jobTitle,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        buildDataItem(
                                          'Tipo: ',
                                          missao.tipo,
                                          widget.tipo,
                                        ),
                                        buildDataItem(
                                          'CNPJ: ',
                                          missao.cnpj,
                                          widget.cnpj,
                                        ),
                                        buildDataItem(
                                          'Nome da empresa: ',
                                          missao.nomeDaEmpresa,
                                          widget.nomeDaEmpresa,
                                        ),
                                        buildDataItem(
                                          'Placa cavalo: ',
                                          missao.placaCavalo,
                                          widget.placaCavalo,
                                        ),
                                        buildDataItem(
                                          'Placa carreta: ',
                                          missao.placaCarreta,
                                          widget.placaCarreta,
                                        ),
                                        buildDataItem(
                                          'Nome do motorista: ',
                                          missao.motorista,
                                          widget.nomeMotorista,
                                        ),
                                        buildDataItem(
                                          'Cor: ',
                                          missao.corVeiculo,
                                          widget.cor,
                                        ),
                                        buildDataItem(
                                          'Observações: ',
                                          missao.observacao,
                                          widget.obs,
                                        ),
                                        buildDataItem(
                                          'Início: ',
                                          missao.inicio != null
                                              ? DateFormat(
                                                      'dd/MM/yyyy HH:mm:ss')
                                                  .format(
                                                      missao.inicio!.toDate())
                                              : null,
                                          widget.inicio,
                                        ),
                                        buildDataItem(
                                          'Fim: ',
                                          missao.fim != null
                                              ? DateFormat(
                                                      'dd/MM/yyyy HH:mm:ss')
                                                  .format(missao.fim!.toDate())
                                              : null,
                                          widget.fim,
                                        ),
                                        buildDataItem(
                                          'Informações: ',
                                          missao.infos,
                                          widget.infos,
                                        ),
                                        buildDataItem(
                                          'Distância: ',
                                          state.distancia != null
                                              ? '${state.distancia!.toStringAsFixed(2)}km'
                                              : null,
                                          widget.distancia,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      state.locations!.isEmpty
                                          ? const Center(
                                              child:
                                                  Text('Nenhum percurso feito'),
                                            )
                                          : widget.mapa
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                      right: width * 0.15,
                                                      top: 20,
                                                      bottom: 20,
                                                      left: width * 0.15),
                                                  child: SizedBox(
                                                    height: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .height *
                                                        0.7, // 70% da altura da tela, por exemplo
                                                    child: Image(image: image),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                    ],
                                  ),
                                  widget.fotos
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              right: width * 0.15,
                                              top: 20,
                                              left: width * 0.15),
                                          child: const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Fotos:',
                                                style: TextStyle(
                                                    fontFamily:
                                                        AutofillHints.jobTitle,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  widget.fotos
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              right: width * 0.15,
                                              bottom: 20,
                                              left: width * 0.15),
                                          child: Column(
                                            children: [
                                              if (missao.fotos != null)
                                                for (var foto in missao.fotos!)
                                                  buildFotos(foto.url, context),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                      widget.fotosPos
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              right: width * 0.15,
                                              top: 20,
                                              left: width * 0.15),
                                          child: const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Fotos após a missão:',
                                                style: TextStyle(
                                                    fontFamily:
                                                        AutofillHints.jobTitle,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                  widget.fotosPos
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              right: width * 0.15,
                                              bottom: 20,
                                              left: width * 0.15),
                                          child: Column(
                                            children: [
                                              if (missao.fotosPosMissao != null)
                                                for (var foto in missao.fotosPosMissao!)
                                                  buildFotos(foto.url, context),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                            ],
                          );
                        }
                        if (state is MissionDetailsError) {
                          return Center(child: Text('Erro: ${state.message}'));
                        }
                        return Container(); // Estado inicial ou desconhecido
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  Future<void> _takeScreenshot() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      if (context.mounted) {
        RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary;

        double pixelRatio = MediaQuery.of(context).devicePixelRatio;
        ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List imgBytes = byteData!.buffer.asUint8List();

        // Criar um PDF e adicionar a imagem
        final pdf = pw.Document();
        final imagePdf = pw.MemoryImage(imgBytes);

        // Ajuste o tamanho da página com base no tamanho da imagem capturada
        pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat(
            image.width.toDouble() / pixelRatio,
            image.height.toDouble() / pixelRatio,
          ),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(imagePdf),
            );
          },
        ));

        // Salvar o PDF
        Uint8List pdfBytes = await pdf.save();
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'screenshot.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      debugPrint('Erro ao capturar screenshot: $e');
    }
  }

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

  Future<List<pw.MemoryImage>> convertUrlsToPdfImages(List<String> urls) async {
    Dio dio = Dio();

    // Uma função auxiliar para baixar cada imagem e convertê-la para um MemoryImage
    Future<pw.MemoryImage> _fetchImage(String url) async {
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

    // Mapear cada URL para uma Future de MemoryImage e aguardar todas as Futures
    List<pw.MemoryImage> pdfImages = await Future.wait(
      urls.map((url) => _fetchImage(url)),
    );

    return pdfImages;
  }

  Future<void> generateAndDownloadPdf(MissaoRelatorio missao,
      {distancia, ImageProvider? image, locations}) async {
    final pdf = pw.Document();
    final escudo = await _loadAssetImage('assets/images/escudo.png');
    final mapa =
        image != null ? await convertImageProviderToPdfImage(image) : null;
    final fotos = missao.fotos != null
        ? await convertUrlsToPdfImages(missao.fotos!.map((e) => e.url).toList())
        : null;

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
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: data,
                        style: pw.TextStyle(
                          fontSize: 16,
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

    pw.Widget buildFotosPdf(pw.ImageProvider fotoBytes) {
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.SizedBox(
            height: 500,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Container(
                width: 450,
                height: 500,
                child: pw.Image(fotoBytes),
              ),
            ),
          ),
        ],
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
                  height: 100,
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(16.0),
                    child: pw.Image(escudo),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Relatório de Missão',
                      style: const pw.TextStyle(fontSize: 26),
                    ),
                    pw.Text(
                      'ID: ${widget.missaoId}',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),

            // Dados da missão
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: pw.Text(
                    'Dados:',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'Tipo: ',
                    missao.tipo,
                    widget.tipo,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'CNPJ: ',
                    missao.cnpj,
                    widget.cnpj,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'Nome da empresa: ',
                    missao.nomeDaEmpresa,
                    widget.nomeDaEmpresa,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'Placa cavalo: ',
                    missao.placaCavalo,
                    widget.placaCavalo,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'Placa carreta: ',
                    missao.placaCarreta,
                    widget.placaCarreta,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'Nome do motorista: ',
                    missao.motorista,
                    widget.nomeMotorista,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'Cor: ',
                    missao.corVeiculo,
                    widget.cor,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'Observações: ',
                    missao.observacao,
                    widget.obs,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
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
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'Fim: ',
                    missao.fim != null
                        ? DateFormat('dd/MM/yyyy HH:mm:ss')
                            .format(missao.fim!.toDate())
                        : null,
                    widget.fim,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
                  child: buildDataItemPdf(
                    'Informações: ',
                    missao.infos,
                    widget.infos,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8.0),
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
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Container(
                  height: 600,
                  width: 500,
                  child: pw.Image(mapa),
                ),
              ),

            // Fotos (Se aplicável)
            if (widget.fotos && fotos != null)
              pw.Column(
                children: [
                  for (var foto in fotos) buildFotosPdf(foto),
                ],
              ),
          ];
        },
      ),
    );
    

    // Salvar o PDF
    final bytes = await pdf.save();

    // Chama downloadFile() para baixar o arquivo PDF
    downloadFile(
        bytes, 'application/pdf', 'relatorio_missao_${widget.missaoId}.pdf');
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

  Widget buildFotos(url, context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
