import 'package:flutter/material.dart';

class MissionDetailsDialog extends StatefulWidget {
  final String? cnpj;
  final String? nomeDaEmpresa;
  final String? placaCavalo;
  final String? placaCarreta;
  final String? motorista;
  final String? corVeiculo;
  final String? observacao;
  final double? latitude;
  final double? longitude;
  final String? local;
  final String? missaoId;
  final String tipo;
  const MissionDetailsDialog(
      {super.key,
      this.cnpj,
      this.nomeDaEmpresa,
      this.placaCavalo,
      this.placaCarreta,
      this.motorista,
      this.corVeiculo,
      this.observacao,
      this.latitude,
      this.longitude,
      this.local,
      this.missaoId,
      required this.tipo});

  @override
  State<MissionDetailsDialog> createState() => _MissionDetailsDialogState();
}

class _MissionDetailsDialogState extends State<MissionDetailsDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('DETALHES'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
                widget.cnpj == null ? 'CNPJ: Não informado' : 'CNPJ: ${widget.cnpj}'),
            SelectableText(widget.nomeDaEmpresa == ''
                ? 'Nome da Empresa: Não informado'
                : 'Nome da Empresa: ${widget.nomeDaEmpresa}'),
            SelectableText(widget.placaCavalo == ''
                ? 'Placa do Cavalo: Não informado'
                : 'Placa do Cavalo: ${widget.placaCavalo}'),
            SelectableText(widget.placaCarreta == ''
                ? 'Placa da Carreta: Não informado'
                : 'Placa da Carreta: ${widget.placaCarreta}'),
            SelectableText(widget.motorista == ''
                ? 'Motorista: Não informado'
                : 'Motorista: ${widget.motorista}'),
            SelectableText(widget.corVeiculo == ''
                ? 'Cor do Veículo: Não informado'
                : 'Cor do Veículo: ${widget.corVeiculo}'),
            SelectableText(widget.observacao == ''
                ? 'Observação: Não informado'
                : 'Observação: ${widget.observacao}'),
            SelectableText(widget.latitude == null
                ? 'Latitude: Não informado'
                : 'Latitude: ${widget.latitude}'),
            SelectableText(widget.longitude == null
                ? 'Longitude: Não informado'
                : 'Longitude: ${widget.longitude}'),
            SelectableText(widget.local == ''
                ? 'Local: Não informado'
                : 'Local: ${widget.local}'),
            SelectableText(widget.missaoId == ''
                ? 'Missão ID: Não informado'
                : 'Missão ID: ${widget.missaoId}'),
            SelectableText('Tipo: ${widget.tipo}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
