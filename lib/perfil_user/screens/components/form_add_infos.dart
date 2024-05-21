import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sombra_testes/agente/services/agente_services.dart';
import 'package:sombra_testes/home/screens/components/missao.dart';
import 'package:validadores/validadores.dart';
import '../../../agente/bloc/get_user/agente_bloc.dart';
import '../../../agente/bloc/get_user/events.dart';
import '../../../agente/bloc/get_user/states.dart';
import '../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_state.dart';
import '../../bloc/infos/docs_imgs/comp_resid/bloc/comp_resid_bloc.dart';
import '../../bloc/infos/docs_imgs/comp_resid/bloc/comp_resid_event.dart';
import '../../bloc/infos/docs_imgs/comp_resid/bloc/comp_resid_state.dart';
import '../../bloc/infos/docs_imgs/rg_frente/bloc/rg_frente_bloc.dart';
import '../../bloc/infos/docs_imgs/rg_frente/bloc/rg_frente_event.dart';
import '../../bloc/infos/docs_imgs/rg_frente/bloc/rg_frente_state.dart';
import '../../bloc/infos/docs_imgs/rg_verso/bloc/rg_verso_bloc.dart';
import '../../bloc/infos/docs_imgs/rg_verso/bloc/rg_verso_event.dart';
import '../../bloc/infos/docs_imgs/rg_verso/bloc/rg_verso_state.dart';
import 'package:stepper_a/stepper_a.dart';
import '../perfil.dart';

class FormAddInfo extends StatelessWidget {
  final BuildContext infosContext;
  final TextEditingController nome;
  final TextEditingController endereco;
  final TextEditingController cep;
  final TextEditingController celular;
  final TextEditingController rg;
  final TextEditingController cpf;
  final GlobalKey<FormState> formKey;
  final StepperAController stepperController;
  final TextEditingController logradouroController;
  final TextEditingController numeroController;
  final TextEditingController complementoController;
  final TextEditingController bairroController;
  final TextEditingController cidadeController;
  final TextEditingController estadoController;
  FormAddInfo({
    super.key,
    required this.infosContext,
    required this.nome,
    required this.endereco,
    required this.cep,
    required this.celular,
    required this.rg,
    required this.cpf,
    required this.formKey,
    required this.stepperController,
    required this.logradouroController,
    required this.numeroController,
    required this.complementoController,
    required this.bairroController,
    required this.cidadeController,
    required this.estadoController,
  });

  final AgenteServices agenteServices = AgenteServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  @override
  Widget build(BuildContext context) {
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;
    return BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
      builder: (context, state) {
        debugPrint(state.toString());
        if (state is ElevatedButtonBlocLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return BlocBuilder<AgenteBloc, AgenteState>(
            builder: (context, agenteState) {
              if (agenteState is AgenteLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (agenteState is EmAnalise) {
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
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                );
              } else if (agenteState is AgenteInfosRejected) {
                //final enderecoAceito = agenteState.enderecoAceito;
                final logradouroAceito = agenteState.logradouroAceito;
                final numeroAceito = agenteState.numeroAceito;
                final complementoAceito = agenteState.complementoAceito;
                final bairroAceito = agenteState.bairroAceito;
                final cidadeAceito = agenteState.cidadeAceito;
                final estadoAceito = agenteState.estadoAceito;
                final cepAceito = agenteState.cepAceito;
                final celularAceito = agenteState.celularAceito;
                final rgAceito = agenteState.rgAceito;
                final cpfAceito = agenteState.cpfAceito;
                final rgFrenteAceito = agenteState.rgFrenteAceito;
                final rgVersoAceito = agenteState.rgVersoAceito;
                final compResidAceito = agenteState.compResidAceito;
                final nomeAceito = agenteState.nomeAceito;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              //icone do ponto de exclamação branco, vermelho em volta e circular
                              Icons.error,
                              size: 30,
                              color: Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Os dados abaixo foram rejeitados, corrija e envie novamente.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        agenteState.dados.containsKey('Nome')
                            ? BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: nome,
                                  keyboardType: TextInputType.name,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                          "[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
                                    ),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  labelText: 'Nome',
                                  validateFunction: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira o seu nome';
                                    }
                                    return null;
                                  },
                                  context: context,
                                ),
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('Nome')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        // agenteState.dados.containsKey('Endereço')
                        //     ? TextFormField(
                        //         keyboardType: TextInputType.streetAddress,
                        //         controller: endereco,
                        //         decoration: const InputDecoration(
                        //           labelText: 'Endereço',
                        //           labelStyle: TextStyle(color: Colors.grey),
                        //           border: OutlineInputBorder(
                        //             borderSide: BorderSide(color: Colors.grey),
                        //           ),
                        //           enabledBorder: OutlineInputBorder(
                        //             borderSide: BorderSide(color: Colors.grey),
                        //           ),
                        //           focusedBorder: OutlineInputBorder(
                        //             borderSide: BorderSide(color: Colors.grey),
                        //           ),
                        //         ),
                        //         validator: (value) {
                        //           if (value == null || value.isEmpty) {
                        //             return 'Por favor, insira o seu endereço';
                        //           }
                        //           return null;
                        //         },
                        //       )
                        //     : const SizedBox.shrink(),
                        agenteState.dados.containsKey('logradouro')
                            ? BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: logradouroController,
                                  keyboardType: TextInputType.streetAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                          "[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ0-9 ]"),
                                    ),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  labelText: 'Logradouro',
                                  validateFunction: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira o logradouro';
                                    }
                                    return null;
                                  },
                                  context: context,
                                ),
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('logradouro')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('numero')
                            ? BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: numeroController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(8),
                                  ],
                                  labelText: 'Número da residência',
                                  validateFunction: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira o número';
                                    }
                                    return null;
                                  },
                                  context: context,
                                ),
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('numero')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('complemento')
                            ? BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: complementoController,
                                  keyboardType: TextInputType.streetAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                          "[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ0-9 ]"),
                                    ),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  labelText: 'Complemento',
                                  validateFunction: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira o complemento';
                                    }
                                    return null;
                                  },
                                  context: context,
                                ),
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('complemento')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('bairro')
                            ? BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: bairroController,
                                  keyboardType: TextInputType.streetAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                          "[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ0-9 ]"),
                                    ),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  labelText: 'Bairro',
                                  validateFunction: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira o bairro';
                                    }
                                    return null;
                                  },
                                  context: context,
                                ),
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('bairro')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('cidade')
                            ? BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: cidadeController,
                                  keyboardType: TextInputType.streetAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                          "[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
                                    ),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  labelText: 'Cidade',
                                  validateFunction: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira a cidade';
                                    }
                                    return null;
                                  },
                                  context: context,
                                ),
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('cidade')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('estado')
                            ? BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: estadoController,
                                  keyboardType: TextInputType.streetAddress,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(
                                          "[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
                                    ),
                                    LengthLimitingTextInputFormatter(50),
                                  ],
                                  labelText: 'Estado',
                                  validateFunction: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira o estado';
                                    }
                                    return null;
                                  },
                                  context: context,
                                ),
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('estado')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('Cep')
                            ? TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Permite apenas dígitos
                                  CepInputFormatter(),
                                ],
                                controller: cep,
                                decoration: const InputDecoration(
                                  labelText: 'CEP',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira o seu CEP';
                                  } else if (value.length < 8 ||
                                      value.length > 9 ||
                                      !RegExp(r'^[0-9]{2}.[0-9]{3}-[0-9]{3}$')
                                          .hasMatch(value)) {
                                    return 'CEP inválido';
                                  }

                                  return null;
                                },
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('Cep')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('Celular')
                            ? BuildTextFormField(
                                data: TextFormFieldData(
                                  controller: celular,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter
                                        .digitsOnly, // Permite apenas dígitos
                                    TelefoneInputFormatter(),
                                  ],
                                  labelText: 'Celular (com WhatsApp)',
                                  validateFunction: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira o seu número de celular';
                                    } else if (!agenteServices
                                        .validarNumeroCelular(value)) {
                                      return 'Número de celular inválido';
                                    }
                                    return null;
                                  },
                                  context: context,
                                ),
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('Celular')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('RG')
                            ? TextFormField(
                                controller: rg,
                                decoration: const InputDecoration(
                                  labelText: 'RG',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira o seu RG';
                                  } else if (!agenteServices.validarRG(value)) {
                                    return 'RG inválido';
                                  }
                                  return null;
                                },
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('RG')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('CPF')
                            ? TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Permite apenas dígitos
                                ],
                                controller: cpf,
                                decoration: const InputDecoration(
                                  labelText: 'CPF',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                validator: (value) {
                                  // Aqui entram as validações
                                  return Validador()
                                      .add(Validar.CPF, msg: 'CPF Inválido')
                                      .add(Validar.OBRIGATORIO,
                                          msg: 'Campo obrigatório')
                                      .valido(value, clearNoNumber: true);
                                },
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('CPF')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('RG frente')
                            ? BlocBuilder<RgFrenteBloc, RgFrenteState>(
                                builder: (context, rgFrenteState) {
                                  if (rgFrenteState is SelectRgFrenteLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (rgFrenteState
                                      is SelectRgFrenteLoaded) {
                                    return ElevatedButton(
                                      onPressed: () async {
                                        showImageDialog(
                                            context, rgFrenteState.foto);
                                      },
                                      child: const Text('Ver'),
                                    );
                                  } else {
                                    return ElevatedButton(
                                      onPressed: () async {
                                        final fotoBloc =
                                            context.read<RgFrenteBloc>();
                                        fotoBloc.add(
                                          RgFrenteSelect(),
                                        );
                                      },
                                      child: const Text('Foto do RG (frente)'),
                                    );
                                  }
                                },
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('RG frente')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('RG verso')
                            ? BlocBuilder<RgVersoBloc, RgVersoState>(
                                builder: (context, rgVersoState) {
                                  if (rgVersoState is SelectRgVersoLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (rgVersoState
                                      is SelectRgVersoLoaded) {
                                    return ElevatedButton(
                                      onPressed: () async {
                                        showImageDialogRgVerso(
                                            context, rgVersoState.foto);
                                      },
                                      child: const Text('Ver'),
                                    );
                                  } else {
                                    return ElevatedButton(
                                      onPressed: () async {
                                        final fotoBloc =
                                            context.read<RgVersoBloc>();
                                        fotoBloc.add(
                                          RgVersoSelect(),
                                        );
                                      },
                                      child: const Text('Foto do RG (verso)'),
                                    );
                                  }
                                },
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados.containsKey('RG verso')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados
                                .containsKey('Comprovante de residência')
                            ? BlocBuilder<CompResidBloc, CompResidState>(
                                builder: (context, compResidState) {
                                  if (compResidState
                                      is SelectCompResidLoading) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  } else if (compResidState
                                      is SelectCompResidLoaded) {
                                    return ElevatedButton(
                                      onPressed: () async {
                                        showImageDialogCompResid(
                                            context, compResidState.foto);
                                      },
                                      child: const Text('Ver'),
                                    );
                                  } else {
                                    return ElevatedButton(
                                      onPressed: () async {
                                        final fotoBloc =
                                            context.read<CompResidBloc>();
                                        fotoBloc.add(
                                          CompResidSelect(),
                                        );
                                      },
                                      child: const Text(
                                          'Comprovante de Residência'),
                                    );
                                  }
                                },
                              )
                            : const SizedBox.shrink(),
                        agenteState.dados
                                .containsKey('Comprovante de residência')
                            ? const SizedBox(
                                height: 10,
                              )
                            : const SizedBox.shrink(),
                        ElevatedButton(
                          onPressed: () async {
                            context
                                .read<ElevatedButtonBloc>()
                                .add(ElevatedButtonPressed());
                            debugPrint('passo 1');
                            if (formKey.currentState!.validate()) {
                              debugPrint('passo 2');
                              final nomeValor = nome.text.trim() != ''
                                  ? nome.text.trim()
                                  : nomeAceito != ''
                                      ? nomeAceito
                                      : null;
                              final logradouroValor =
                                  logradouroController.text.trim() != ''
                                      ? logradouroController.text.trim()
                                      : logradouroAceito != ''
                                          ? logradouroAceito
                                          : null;

                              final numeroValor =
                                  numeroController.text.trim() != ''
                                      ? numeroController.text.trim()
                                      : numeroAceito != ''
                                          ? numeroAceito
                                          : null;
                              final complementoValor =
                                  complementoController.text.trim() != ''
                                      ? complementoController.text.trim()
                                      : complementoAceito != ''
                                          ? complementoAceito
                                          : null;
                              final bairroValor =
                                  bairroController.text.trim() != ''
                                      ? bairroController.text.trim()
                                      : bairroAceito != ''
                                          ? bairroAceito
                                          : null;
                              final cidadeValor =
                                  cidadeController.text.trim() != ''
                                      ? cidadeController.text.trim()
                                      : cidadeAceito != ''
                                          ? cidadeAceito
                                          : null;
                              final estadoValor =
                                  estadoController.text.trim() != ''
                                      ? estadoController.text.trim()
                                      : estadoAceito != ''
                                          ? estadoAceito
                                          : null;
                              final cepValor = cep.text.trim() != ''
                                  ? cep.text.trim()
                                  : cepAceito != ''
                                      ? cepAceito
                                      : null;
                              final celularValor = celular.text.trim() != ''
                                  ? celular.text.trim()
                                  : celularAceito != ''
                                      ? celularAceito
                                      : null;
                              final rgValor = rg.text.trim() != ''
                                  ? rg.text.trim()
                                  : rgAceito != ''
                                      ? rgAceito
                                      : null;
                              final cpfValor = cpf.text.trim() != ''
                                  ? cpf.text.trim()
                                  : cpfAceito != ''
                                      ? cpfAceito
                                      : null;

                              debugPrint('nome: $nomeValor');
                              debugPrint('logradouro: $logradouroValor');
                              debugPrint('numero: $numeroValor');
                              debugPrint('complemento: $complementoValor');
                              debugPrint('bairro: $bairroValor');
                              debugPrint('cidade: $cidadeValor');
                              debugPrint('estado: $estadoValor');
                              debugPrint('cep: $cepValor');
                              debugPrint('celular: $celularValor');
                              debugPrint('rg: $rgValor');
                              debugPrint('cpf: $cpfValor');

                              formKey.currentState!.save();

                              var rgFrenteState =
                                  context.read<RgFrenteBloc>().state;

                              PlatformFile? rgFrente;

                              if (rgFrenteState is SelectRgFrenteLoaded) {
                                rgFrente = rgFrenteState.foto;
                                debugPrint('rgFrente: $rgFrente');
                              }

                              var rgVersoState =
                                  context.read<RgVersoBloc>().state;

                              PlatformFile? rgVerso;

                              if (rgVersoState is SelectRgVersoLoaded) {
                                rgVerso = rgVersoState.foto;
                              }

                              var compResidState =
                                  context.read<CompResidBloc>().state;

                              PlatformFile? compResid;

                              if (compResidState is SelectCompResidLoaded) {
                                compResid = compResidState.foto;
                              }

                              final rgFotoFrenteValor = rgFrente ??
                                  (rgFrenteAceito != ''
                                      ? rgFrenteAceito
                                      : null);

                              final rgFotoVersoValor = rgVerso ??
                                  (rgVersoAceito != '' ? rgVersoAceito : null);

                              final compDeResidValor = compResid ??
                                  (compResidAceito != ''
                                      ? compResidAceito
                                      : null);

                              debugPrint('rgFotoFrente: $rgFotoFrenteValor');
                              debugPrint('rgFotoVerso: $rgFotoVersoValor');
                              debugPrint('compDeResid: $compDeResidValor');

                              if (rgFotoFrenteValor == null ||
                                  rgFotoVersoValor == null ||
                                  compDeResidValor == null ||
                                  nomeValor == null ||
                                  logradouroValor == null ||
                                  numeroValor == null ||
                                  complementoValor == null ||
                                  bairroValor == null ||
                                  cidadeValor == null ||
                                  estadoValor == null ||
                                  cepValor == null ||
                                  celularValor == null ||
                                  rgValor == null ||
                                  cpfValor == null) {
                                context
                                    .read<ElevatedButtonBloc>()
                                    .add(ElevatedButtonActionCompleted());
                                tratamentoDeErros.showErrorSnackbar(
                                    context, 'Erro ao adicionar informações');
                                return;
                              } else {
                                bool success =
                                    await agenteServices.preAddUserInfos(
                                  uid!,
                                  nomeValor,
                                  logradouroValor,
                                  numeroValor,
                                  complementoValor,
                                  bairroValor,
                                  cidadeValor,
                                  estadoValor,
                                  cepValor,
                                  celularValor,
                                  rgValor,
                                  cpfValor,
                                  rgFotoFrenteValor,
                                  rgFotoVersoValor,
                                  compDeResidValor,
                                );
                                if (success) {
                                  debugPrint('sucessoo');
                                  endereco.clear();
                                  cep.clear();
                                  celular.clear();
                                  rg.clear();
                                  cpf.clear();
                                  if (context.mounted) {
                                    context
                                        .read<ElevatedButtonBloc>()
                                        .add(ElevatedButtonActionCompleted());
                                    mensagemDeSucesso.showSuccessSnackbar(
                                        context,
                                        'Informações adicionadas com sucesso');
                                    context
                                        .read<AgenteBloc>()
                                        .add(FetchAgenteInfo(uid));
                                    Navigator.pop(context);
                                  } else {
                                    if (infosContext.mounted) {
                                      infosContext
                                          .read<ElevatedButtonBloc>()
                                          .add(ElevatedButtonActionCompleted());
                                      mensagemDeSucesso.showSuccessSnackbar(
                                          infosContext,
                                          'Informações adicionadas com sucesso');
                                      infosContext
                                          .read<AgenteBloc>()
                                          .add(FetchAgenteInfo(uid));
                                      Navigator.pop(infosContext);
                                    }
                                  }
                                } else {
                                  debugPrint('errooou');
                                  if (context.mounted) {
                                    context
                                        .read<ElevatedButtonBloc>()
                                        .add(ElevatedButtonActionCompleted());
                                    tratamentoDeErros.showErrorSnackbar(context,
                                        'Erro ao adicionar informações, tente novamente');
                                  } else {
                                    if (infosContext.mounted) {
                                      infosContext
                                          .read<ElevatedButtonBloc>()
                                          .add(ElevatedButtonActionCompleted());
                                      tratamentoDeErros.showErrorSnackbar(
                                          infosContext,
                                          'Erro ao adicionar informações, tente novamente');
                                    }
                                  }
                                }
                              }
                            } else {
                              context
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonActionCompleted());
                              tratamentoDeErros.showErrorSnackbar(context,
                                  'Por favor, insira todas as informações');
                            }
                          },
                          child: const Text('Adicionar informações'),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                var rgFrenteState = context.read<RgFrenteBloc>().state;
                var rgVersoState = context.read<RgVersoBloc>().state;
                var compResidState = context.read<CompResidBloc>().state;

                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 688,
                  child: StepperA(
                    stepperSize: const Size(200, 100),
                    borderShape: BorderShape.rRect,
                    borderType: BorderType.straight,
                    stepperAxis: Axis.horizontal,
                    lineType: LineType.dotted,
                    stepperBackgroundColor: Colors.transparent,
                    stepperAController: stepperController,
                    stepHeight: 55,
                    stepWidth: 55,
                    stepBorder: true,
                    pageSwipe: false,
                    formValidation: true,
                    previousButton: (int index) => StepperAButton(
                      width: 90,
                      height: 40,
                      onTap: (int currentIndex) {},
                      buttonWidget: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    forwardButton: (index) => StepperAButton(
                      width: index == 0 ? 100 : 90,
                      height: 40,
                      onTap: (int currentIndex) {
                        debugPrint('index: ${currentIndex.toString()}');
                        if (currentIndex == 1) {
                          stepperController.next(onTap: (currentIndex) {});
                        } else if (currentIndex == 2) {
                          if (compResidState is SelectCompResidLoaded) {
                            stepperController.next(onTap: (currentIndex) {});
                          } else {
                            stepperController.back(
                              onTap: (currentIndex) {
                                tratamentoDeErros.showErrorSnackbar(context,
                                    'Por favor, insira todas as fotos');
                              },
                            );
                          }
                        } else if (currentIndex == 3) {
                          stepperController.next(onTap: (currentIndex) {});
                        }
                      },
                      onComplete: () async {
                        debugPrint('passo 1');
                        //if (formKey.currentState!.validate()) {
                        debugPrint('passo 2');
                        debugPrint(
                            context.mounted == true ? 'true1' : 'false1');
                        context
                            .read<ElevatedButtonBloc>()
                            .add(ElevatedButtonPressed());
                        debugPrint('passo 3');

                        //formKey.currentState!.save();

                        debugPrint(
                            context.mounted == true ? 'true2' : 'false2');

                        PlatformFile? rgFrente;

                        if (rgFrenteState is SelectRgFrenteLoaded) {
                          rgFrente = rgFrenteState.foto;
                        }

                        PlatformFile? rgVerso;

                        if (rgVersoState is SelectRgVersoLoaded) {
                          rgVerso = rgVersoState.foto;
                        }

                        PlatformFile? compResid;

                        if (compResidState is SelectCompResidLoaded) {
                          compResid = compResidState.foto;
                        }

                        debugPrint(
                            context.mounted == true ? 'true3' : 'false3');

                        PlatformFile? rgFotoFrente = rgFrente;
                        PlatformFile? rgFotoVerso = rgVerso;
                        PlatformFile? compDeResid = compResid;

                        debugPrint(rgFotoFrente.toString());
                        debugPrint('passo4');

                        if (rgFotoFrente == null ||
                            rgFotoVerso == null ||
                            compDeResid == null) {
                          tratamentoDeErros.showErrorSnackbar(
                              context, 'Por favor, insira todas as fotos');
                          if (context.mounted) {
                            debugPrint('contexto de erro1 aqui');
                            context
                                .read<ElevatedButtonBloc>()
                                .add(ElevatedButtonActionCompleted());
                            tratamentoDeErros.showErrorSnackbar(
                                context, 'Erro ao adicionar informações');
                          }
                          return;
                        }
                        debugPrint('inicio do envio');
                        bool success = await agenteServices.preAddUserInfos(
                          uid!,
                          nome.text.trim(),
                          logradouroController.text.trim(),
                          numeroController.text.trim(),
                          complementoController.text.trim(),
                          bairroController.text.trim(),
                          cidadeController.text.trim(),
                          estadoController.text.trim(),
                          cep.text.trim(),
                          celular.text.trim(),
                          rg.text.trim(),
                          cpf.text.trim(),
                          rgFotoFrente,
                          rgFotoVerso,
                          compDeResid,
                        );
                        if (success) {
                          debugPrint('----------- sucessoo --------');
                          endereco.clear();
                          cep.clear();
                          celular.clear();
                          rg.clear();
                          cpf.clear();
                          if (context.mounted) {
                            context
                                .read<ElevatedButtonBloc>()
                                .add(ElevatedButtonActionCompleted());
                            mensagemDeSucesso.showSuccessSnackbar(
                                context, 'Informações adicionadas com sucesso');
                            context
                                .read<AgenteBloc>()
                                .add(FetchAgenteInfo(uid));
                            Navigator.pop(context);
                          } else {
                            if (infosContext.mounted) {
                              infosContext
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonActionCompleted());
                              mensagemDeSucesso.showSuccessSnackbar(
                                  infosContext,
                                  'Informações adicionadas com sucesso');
                              infosContext
                                  .read<AgenteBloc>()
                                  .add(FetchAgenteInfo(uid));
                              Navigator.pop(infosContext);
                            }
                          }
                        } else {
                          debugPrint('errooou');
                          if (context.mounted) {
                            context
                                .read<ElevatedButtonBloc>()
                                .add(ElevatedButtonActionCompleted());
                            tratamentoDeErros.showErrorSnackbar(
                                context, 'Erro ao adicionar informações');
                          } else {
                            if (infosContext.mounted) {
                              infosContext
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonActionCompleted());
                              tratamentoDeErros.showErrorSnackbar(infosContext,
                                  'Erro ao adicionar informações');
                            }
                          }
                        }
                      },
                      buttonWidget: index == 2
                          ? const Text('Finalizar',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white))
                          : const Text('Próximo',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                    customSteps: const [
                      CustomSteps(stepsIcon: Icons.person, title: "Dados"),
                      CustomSteps(stepsIcon: Icons.home, title: "Endereço"),
                      CustomSteps(stepsIcon: Icons.check, title: "Finalização"),
                    ],
                    step: const StepA(
                      currentStepColor: Colors.blue,
                      completeStepColor: Colors.green,
                      inactiveStepColor: Colors.grey,
                      // loadingWidget: CircularProgressIndicator(color: Colors.green,),
                      margin: EdgeInsets.all(5),
                    ),
                    stepperBodyWidget: [
                      Step(
                        fieldsData: [
                          TextFormFieldData(
                            controller: nome,
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
                              ),
                              LengthLimitingTextInputFormatter(50),
                            ],
                            labelText: 'Nome',
                            validateFunction: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o seu nome';
                              }
                              return null;
                            },
                            context: context,
                          ),
                          //celular
                          TextFormFieldData(
                            controller: celular,
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter
                                  .digitsOnly, // Permite apenas dígitos
                              TelefoneInputFormatter(),
                            ],
                            labelText: 'Celular (com WhatsApp)',
                            validateFunction: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o seu número de celular';
                              } else if (!agenteServices
                                  .validarNumeroCelular(value)) {
                                return 'Número de celular inválido';
                              }
                              return null;
                            },
                            context: context,
                          ),
                          TextFormFieldData(
                            controller: rg,
                            labelText: 'RG',
                            validateFunction: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira o seu RG';
                              } else if (!agenteServices.validarRG(value)) {
                                return 'RG inválido';
                              }
                              return null;
                            },
                            context: context,
                          ),
                          TextFormFieldData(
                            controller: cpf,
                            labelText: 'CPF',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CpfInputFormatter(),
                            ],
                            validateFunction: (value) {
                              // Aqui entram as validações
                              return Validador()
                                  .add(Validar.CPF, msg: 'CPF Inválido')
                                  .add(Validar.OBRIGATORIO,
                                      msg: 'Campo obrigatório')
                                  .valido(value, clearNoNumber: true);
                            },
                            context: context,
                          ),
                        ],
                      ),
                      EnderecoForm(
                        logradouroController: logradouroController,
                        numeroController: numeroController,
                        complementoController: complementoController,
                        bairroController: bairroController,
                        cidadeController: cidadeController,
                        estadoController: estadoController,
                        cepController: cep,
                      ),
                      const FinalStep(),
                    ],
                  ),
                );
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: Form(
                //     key: formKey,
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.stretch,
                //       children: [
                //         TextFormField(
                //           keyboardType: TextInputType.name,
                //           inputFormatters: [
                //             FilteringTextInputFormatter.allow(
                //                 RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]")),
                //           ],
                //           controller: nome,
                //           decoration: const InputDecoration(
                //             labelText: 'Nome',
                //             labelStyle: TextStyle(color: Colors.grey),
                //             border: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             enabledBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             focusedBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //           ),
                //           validator: (value) {
                //             if (value == null || value.isEmpty) {
                //               return 'Por favor, insira o seu nome';
                //             }
                //             return null;
                //           },
                //         ),
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         TextFormField(
                //           keyboardType: TextInputType.streetAddress,
                //           controller: endereco,
                //           decoration: const InputDecoration(
                //             labelText: 'Endereço',
                //             labelStyle: TextStyle(color: Colors.grey),
                //             border: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             enabledBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             focusedBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //           ),
                //           validator: (value) {
                //             if (value == null || value.isEmpty) {
                //               return 'Por favor, insira o seu endereço';
                //             }
                //             return null;
                //           },
                //         ),
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         TextFormField(
                //           keyboardType: TextInputType.number,
                //           inputFormatters: <TextInputFormatter>[
                //             FilteringTextInputFormatter
                //                 .digitsOnly, // Permite apenas dígitos
                //           ],
                //           controller: cep,
                //           decoration: const InputDecoration(
                //             labelText: 'CEP',
                //             labelStyle: TextStyle(color: Colors.grey),
                //             border: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             enabledBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             focusedBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //           ),
                //           validator: (value) {
                //             if (value == null || value.isEmpty) {
                //               return 'Por favor, insira o CEP';
                //             } else if (!agenteServices.validarCEP(value)) {
                //               return 'CEP inválido';
                //             }
                //             return null;
                //           },
                //         ),
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         TextFormField(
                //           keyboardType: TextInputType.phone,
                //           inputFormatters: <TextInputFormatter>[
                //             FilteringTextInputFormatter
                //                 .digitsOnly, // Permite apenas dígitos
                //           ],
                //           controller: celular,
                //           decoration: const InputDecoration(
                //             labelText: 'Celular (com WhatsApp)',
                //             labelStyle: TextStyle(color: Colors.grey),
                //             border: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             enabledBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             focusedBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //           ),
                //           validator: (value) {
                //             if (value == null || value.isEmpty) {
                //               return 'Por favor, insira o seu número de celular';
                //             } else if (!agenteServices
                //                 .validarNumeroCelular(value)) {
                //               return 'Número de celular inválido';
                //             }
                //             return null;
                //           },
                //         ),
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         TextFormField(
                //           keyboardType: TextInputType.number,
                //           inputFormatters: <TextInputFormatter>[
                //             FilteringTextInputFormatter
                //                 .digitsOnly, // Permite apenas dígitos
                //           ],
                //           controller: rg,
                //           decoration: const InputDecoration(
                //             labelText: 'RG',
                //             labelStyle: TextStyle(color: Colors.grey),
                //             border: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             enabledBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             focusedBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //           ),
                //           validator: (value) {
                //             if (value == null || value.isEmpty) {
                //               return 'Por favor, insira o seu RG';
                //             } else if (!agenteServices.validarRG(value)) {
                //               return 'RG inválido';
                //             }
                //             return null;
                //           },
                //         ),
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         TextFormField(
                //           keyboardType: TextInputType.number,
                //           inputFormatters: <TextInputFormatter>[
                //             FilteringTextInputFormatter
                //                 .digitsOnly, // Permite apenas dígitos
                //           ],
                //           controller: cpf,
                //           decoration: const InputDecoration(
                //             labelText: 'CPF',
                //             labelStyle: TextStyle(color: Colors.grey),
                //             border: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             enabledBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //             focusedBorder: OutlineInputBorder(
                //               borderSide: BorderSide(color: Colors.grey),
                //             ),
                //           ),
                //           validator: (value) {
                //             // Aqui entram as validações
                //             return Validador()
                //                 .add(Validar.CPF, msg: 'CPF Inválido')
                //                 .add(Validar.OBRIGATORIO,
                //                     msg: 'Campo obrigatório')
                //                 .minLength(11)
                //                 .maxLength(11)
                //                 .valido(value, clearNoNumber: true);
                //           },
                //         ),
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         BlocBuilder<RgFrenteBloc, RgFrenteState>(
                //           builder: (context, rgFrenteState) {
                //             if (rgFrenteState is SelectRgFrenteLoading) {
                //               return const Center(
                //                 child: CircularProgressIndicator(),
                //               );
                //             } else if (rgFrenteState is SelectRgFrenteLoaded) {
                //               return ElevatedButton(
                //                 onPressed: () async {
                //                   showImageDialog(context, rgFrenteState.foto);
                //                 },
                //                 child: const Text('Ver'),
                //               );
                //             } else {
                //               return ElevatedButton(
                //                 onPressed: () async {
                //                   final fotoBloc = context.read<RgFrenteBloc>();
                //                   fotoBloc.add(
                //                     RgFrenteSelect(),
                //                   );
                //                 },
                //                 child: const Text('Foto do RG (frente)'),
                //               );
                //             }
                //           },
                //         ),
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         BlocBuilder<RgVersoBloc, RgVersoState>(
                //           builder: (context, rgVersoState) {
                //             if (rgVersoState is SelectRgVersoLoading) {
                //               return const Center(
                //                 child: CircularProgressIndicator(),
                //               );
                //             } else if (rgVersoState is SelectRgVersoLoaded) {
                //               return ElevatedButton(
                //                 onPressed: () async {
                //                   showImageDialogRgVerso(
                //                       context, rgVersoState.foto);
                //                 },
                //                 child: const Text('Ver'),
                //               );
                //             } else {
                //               return ElevatedButton(
                //                 onPressed: () async {
                //                   final fotoBloc = context.read<RgVersoBloc>();
                //                   fotoBloc.add(
                //                     RgVersoSelect(),
                //                   );
                //                 },
                //                 child: const Text('Foto do RG (verso)'),
                //               );
                //             }
                //           },
                //         ),
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         BlocBuilder<CompResidBloc, CompResidState>(
                //           builder: (context, compResidState) {
                //             if (compResidState is SelectCompResidLoading) {
                //               return const Center(
                //                 child: CircularProgressIndicator(),
                //               );
                //             } else if (compResidState
                //                 is SelectCompResidLoaded) {
                //               return ElevatedButton(
                //                 onPressed: () async {
                //                   showImageDialogCompResid(
                //                       context, compResidState.foto);
                //                 },
                //                 child: const Text('Ver'),
                //               );
                //             } else {
                //               return ElevatedButton(
                //                 onPressed: () async {
                //                   final fotoBloc =
                //                       context.read<CompResidBloc>();
                //                   fotoBloc.add(
                //                     CompResidSelect(),
                //                   );
                //                 },
                //                 child: const Text('Comprovante de Residência'),
                //               );
                //             }
                //           },
                //         ),
                //         const SizedBox(
                //           height: 10,
                //         ),
                //         ElevatedButton(
                //           onPressed: () async {
                //             debugPrint('passo 1');
                //             if (formKey.currentState!.validate()) {
                //               debugPrint('passo 2');
                //               debugPrint(
                //                   context.mounted == true ? 'true1' : 'false1');
                //               context
                //                   .read<ElevatedButtonBloc>()
                //                   .add(ElevatedButtonPressed());
                //               debugPrint('passo 3');

                //               formKey.currentState!.save();

                //               var rgFrenteState =
                //                   context.read<RgFrenteBloc>().state;

                //               debugPrint(
                //                   context.mounted == true ? 'true2' : 'false2');

                //               PlatformFile? rgFrente;

                //               if (rgFrenteState is SelectRgFrenteLoaded) {
                //                 rgFrente = rgFrenteState.foto;
                //               }

                //               var rgVersoState =
                //                   context.read<RgVersoBloc>().state;

                //               PlatformFile? rgVerso;

                //               if (rgVersoState is SelectRgVersoLoaded) {
                //                 rgVerso = rgVersoState.foto;
                //               }

                //               var compResidState =
                //                   context.read<CompResidBloc>().state;

                //               PlatformFile? compResid;

                //               if (compResidState is SelectCompResidLoaded) {
                //                 compResid = compResidState.foto;
                //               }

                //               debugPrint(
                //                   context.mounted == true ? 'true3' : 'false3');

                //               PlatformFile? rgFotoFrente = rgFrente;
                //               PlatformFile? rgFotoVerso = rgVerso;
                //               PlatformFile? compDeResid = compResid;

                //               debugPrint(rgFotoFrente.toString());
                //               debugPrint('passo4');

                //               if (rgFotoFrente == null ||
                //                   rgFotoVerso == null ||
                //                   compDeResid == null) {
                //                 tratamentoDeErros.showErrorSnackbar(context,
                //                     'Por favor, insira todas as fotos');
                //                 if (context.mounted) {
                //                   debugPrint('contexto de erro1 aqui');
                //                   context
                //                       .read<ElevatedButtonBloc>()
                //                       .add(ElevatedButtonActionCompleted());
                //                   tratamentoDeErros.showErrorSnackbar(
                //                       context, 'Erro ao adicionar informações');
                //                 }
                //                 return;
                //               }
                //               debugPrint('inicio do envio');
                //               bool success =
                //                   await agenteServices.preAddUserInfos(
                //                 uid!,
                //                 nome.text.trim(),
                //                 endereco.text.trim(),
                //                 cep.text.trim(),
                //                 celular.text.trim(),
                //                 rg.text.trim(),
                //                 cpf.text.trim(),
                //                 rgFotoFrente,
                //                 rgFotoVerso,
                //                 compDeResid,
                //               );
                //               if (success) {
                //                 debugPrint('----------- sucessoo --------');
                //                 endereco.clear();
                //                 cep.clear();
                //                 celular.clear();
                //                 rg.clear();
                //                 cpf.clear();
                //                 if (context.mounted) {
                //                   context
                //                       .read<ElevatedButtonBloc>()
                //                       .add(ElevatedButtonActionCompleted());
                //                   mensagemDeSucesso.showSuccessSnackbar(context,
                //                       'Informações adicionadas com sucesso');
                //                   context
                //                       .read<AgenteBloc>()
                //                       .add(FetchAgenteInfo(uid));
                //                   Navigator.pop(context);
                //                 } else {
                //                   if (infosContext.mounted) {
                //                     infosContext
                //                         .read<ElevatedButtonBloc>()
                //                         .add(ElevatedButtonActionCompleted());
                //                     mensagemDeSucesso.showSuccessSnackbar(
                //                         infosContext,
                //                         'Informações adicionadas com sucesso');
                //                     infosContext
                //                         .read<AgenteBloc>()
                //                         .add(FetchAgenteInfo(uid));
                //                     Navigator.pop(infosContext);
                //                   }
                //                 }
                //               } else {
                //                 debugPrint('errooou');
                //                 if (context.mounted) {
                //                   context
                //                       .read<ElevatedButtonBloc>()
                //                       .add(ElevatedButtonActionCompleted());
                //                   tratamentoDeErros.showErrorSnackbar(
                //                       context, 'Erro ao adicionar informações');
                //                 } else {
                //                   if (infosContext.mounted) {
                //                     infosContext
                //                         .read<ElevatedButtonBloc>()
                //                         .add(ElevatedButtonActionCompleted());
                //                     tratamentoDeErros.showErrorSnackbar(
                //                         infosContext,
                //                         'Erro ao adicionar informações');
                //                   }
                //                 }
                //               }
                //             }
                //           },
                //           child: const Text('Adicionar informações'),
                //         ),
                //       ],
                //     ),
                //   ),
                // );
              }
            },
          );
        }
      },
    );
  }

  void showImageDialog(BuildContext context, PlatformFile imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Container(
              width: 300,
              height: 610,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 400,
                      width: 250,
                      child: PhotoView(
                        disableGestures: true,
                        imageProvider: FileImage(File(imageUrl.path!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final fotoBloc = context.read<RgFrenteBloc>();
                      fotoBloc.add(
                        RgFrenteSelect(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Selecionar outra'),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showImageDialogRgVerso(BuildContext context, PlatformFile imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Container(
              width: 300,
              height: 550,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 400,
                      width: 250,
                      child: PhotoView(
                        disableGestures: true,
                        imageProvider: FileImage(File(imageUrl.path!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final fotoBloc = context.read<RgVersoBloc>();
                      fotoBloc.add(
                        RgVersoSelect(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Selecionar outra'),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showImageDialogCompResid(BuildContext context, PlatformFile imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Container(
              color: Colors.black,
              width: 300,
              height: 550,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 400,
                      width: 250,
                      child: PhotoView(
                        disableGestures: true,
                        imageProvider: FileImage(File(imageUrl.path!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final fotoBloc = context.read<CompResidBloc>();
                      fotoBloc.add(
                        CompResidSelect(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Selecionar outra'),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BuildTextFormField extends StatelessWidget {
  final TextFormFieldData data;
  const BuildTextFormField({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: TextFormField(
        keyboardType: data.keyboardType,
        inputFormatters: data.inputFormatters ?? [],
        controller: data.controller,
        decoration: InputDecoration(
          labelText: data.labelText,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(10.0), // Raio de arredondamento
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(10.0), // Raio de arredondamento
          ),
        ),
        validator: data.validateFunction,
      ),
    );
  }
}

class FinalStep extends StatelessWidget {
  // final String nomeValor;
  // final String logradouroValor;
  // final String numeroValor;
  // final String complementoValor;
  // final String bairroValor;
  // final String cidadeValor;
  // final String estadoValor;
  // final String cepValor;
  // final String celularValor;
  // final String rgValor;
  // final String cpfValor;
  // final PlatformFile rgFotoFrenteValor;
  // final PlatformFile rgFotoVersoValor;
  // final PlatformFile compDeResidValor;

  const FinalStep({
    super.key,
    // required this.nomeValor,
    // required this.logradouroValor,
    // required this.numeroValor,
    // required this.complementoValor,
    // required this.bairroValor,
    // required this.cidadeValor,
    // required this.estadoValor,
    // required this.cepValor,
    // required this.celularValor,
    // required this.rgValor,
    // required this.cpfValor,
    // required this.rgFotoFrenteValor,
    // required this.rgFotoVersoValor,
    // required this.compDeResidValor,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: PanaraContainerWidget(
        title: 'Confirmação',
        message:
            "As informações serão enviadas para análise e somente após a aprovação "
            "você terá acesso total ao aplicativo.",
        panaraDialogType: PanaraDialogType.warning,
        noImage: false,
        imagePath: 'assets/images/confirm.png',
      ),
    );
  }
}

class Step extends StatelessWidget {
  final List<TextFormFieldData> fieldsData;

  Step({super.key, required this.fieldsData});

  final AgenteServices agenteServices = AgenteServices();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...fieldsData
            .map((fieldData) => BuildTextFormField(data: fieldData))
            .toList(),
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: StepThree(),
            ),
          ],
        ),
      ],
    );
  }
}

class EnderecoForm extends StatelessWidget {
  final TextEditingController logradouroController;
  final TextEditingController numeroController;
  final TextEditingController complementoController;
  final TextEditingController bairroController;
  final TextEditingController cidadeController;
  final TextEditingController estadoController;
  final TextEditingController cepController;
  const EnderecoForm(
      {super.key,
      required this.logradouroController,
      required this.numeroController,
      required this.complementoController,
      required this.bairroController,
      required this.cidadeController,
      required this.estadoController,
      required this.cepController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: TextFormField(
            controller: logradouroController,
            keyboardType: TextInputType.streetAddress,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ0-9 ]"),
              ),
              LengthLimitingTextInputFormatter(50),
            ],
            decoration: InputDecoration(
              labelText: 'Logradouro',
              labelStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                borderRadius:
                    BorderRadius.circular(10.0), // Raio de arredondamento
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                borderRadius:
                    BorderRadius.circular(10.0), // Raio de arredondamento
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o seu logradouro';
              }
              return null;
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: TextFormField(
                  controller: numeroController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Número',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius:
                          BorderRadius.circular(10.0), // Raio de arredondamento
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius:
                          BorderRadius.circular(10.0), // Raio de arredondamento
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o número';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: TextFormField(
                  controller: cepController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CepInputFormatter(),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'CEP',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius:
                          BorderRadius.circular(10.0), // Raio de arredondamento
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius:
                          BorderRadius.circular(10.0), // Raio de arredondamento
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o CEP';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: TextFormField(
            controller: complementoController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ0-9 ]"),
              ),
              LengthLimitingTextInputFormatter(50),
            ],
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Complemento',
              labelStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                borderRadius:
                    BorderRadius.circular(10.0), // Raio de arredondamento
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                borderRadius:
                    BorderRadius.circular(10.0), // Raio de arredondamento
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o complemento';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5),
          child: TextFormField(
            controller: bairroController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ0-9 ]"),
              ),
              LengthLimitingTextInputFormatter(50),
            ],
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Bairro',
              labelStyle: const TextStyle(color: Colors.grey),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                borderRadius:
                    BorderRadius.circular(10.0), // Raio de arredondamento
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                borderRadius:
                    BorderRadius.circular(10.0), // Raio de arredondamento
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira o bairro';
              }
              return null;
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: TextFormField(
                  controller: cidadeController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ0-9 ]"),
                    ),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Cidade',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius:
                          BorderRadius.circular(10.0), // Raio de arredondamento
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius:
                          BorderRadius.circular(10.0), // Raio de arredondamento
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a cidade';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 10), // Espaçamento entre os campos
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: TextFormField(
                  controller: estadoController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]"),
                    ),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius:
                          BorderRadius.circular(10.0), // Raio de arredondamento
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                      borderRadius:
                          BorderRadius.circular(10.0), // Raio de arredondamento
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o estado';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
        const StepFour()
      ],
    );
  }
}

class SteoTwo extends StatelessWidget {
  const SteoTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class TextFormFieldData {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String labelText;
  final String? Function(String?) validateFunction;
  final BuildContext context;

  TextFormFieldData({
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    required this.labelText,
    required this.validateFunction,
    required this.context,
  });
}

class StepThree extends StatelessWidget {
  const StepThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<RgFrenteBloc, RgFrenteState>(
          builder: (context, rgFrenteState) {
            if (rgFrenteState is SelectRgFrenteLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (rgFrenteState is SelectRgFrenteLoaded) {
              return ElevatedButton(
                style: ButtonStyle(
                  //backgroundColor: MaterialStateProperty.all(Colors.blue),
                  //borda quadrada
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  showImageDialog(context, rgFrenteState.foto);
                },
                child: const Text('Visualizar foto selecionada'),
              );
            } else {
              return ElevatedButton(
                style: ButtonStyle(
                  //backgroundColor: MaterialStateProperty.all(Colors.blue),
                  //borda quadrada
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  final fotoBloc = context.read<RgFrenteBloc>();
                  fotoBloc.add(
                    RgFrenteSelect(),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 5),
                    Text('Adicionar foto do RG (frente)'),
                  ],
                ),
              );
            }
          },
        ),
        const SizedBox(
          height: 10,
        ),
        BlocBuilder<RgVersoBloc, RgVersoState>(
          builder: (context, rgVersoState) {
            if (rgVersoState is SelectRgVersoLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (rgVersoState is SelectRgVersoLoaded) {
              return ElevatedButton(
                style: ButtonStyle(
                  //backgroundColor: MaterialStateProperty.all(Colors.blue),
                  //borda quadrada
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  showImageDialogRgVerso(context, rgVersoState.foto);
                },
                child: const Text('Visualizar foto selecionada'),
              );
            } else {
              return ElevatedButton(
                style: ButtonStyle(
                  //backgroundColor: MaterialStateProperty.all(Colors.blue),
                  //borda quadrada
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ),
                onPressed: () async {
                  final fotoBloc = context.read<RgVersoBloc>();
                  fotoBloc.add(
                    RgVersoSelect(),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.upload),
                    SizedBox(width: 5),
                    Text('Adicionar foto do RG (verso)'),
                  ],
                ),
              );
            }
          },
        ),
        // const SizedBox(
        //   height: 10,
        // ),
        // BlocBuilder<CompResidBloc, CompResidState>(
        //   builder: (context, compResidState) {
        //     if (compResidState is SelectCompResidLoading) {
        //       return const Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     } else if (compResidState is SelectCompResidLoaded) {
        //       return ElevatedButton(
        //         onPressed: () async {
        //           showImageDialogCompResid(context, compResidState.foto);
        //         },
        //         child: const Text('Ver'),
        //       );
        //     } else {
        //       return ElevatedButton(
        //         onPressed: () async {
        //           final fotoBloc = context.read<CompResidBloc>();
        //           fotoBloc.add(
        //             CompResidSelect(),
        //           );
        //         },
        //         child: const Text('Comprovante de Residência'),
        //       );
        //     }
        //   },
        // ),
      ],
    );
  }

  void showImageDialog(BuildContext context, PlatformFile imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Container(
              width: 300,
              height: 550,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 400,
                      width: 250,
                      child: PhotoView(
                        disableGestures: true,
                        imageProvider: FileImage(File(imageUrl.path!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final fotoBloc = context.read<RgFrenteBloc>();
                      fotoBloc.add(
                        RgFrenteSelect(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Selecionar outra'),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showImageDialogRgVerso(BuildContext context, PlatformFile imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Container(
              width: 300,
              height: 550,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 400,
                      width: 250,
                      child: PhotoView(
                        disableGestures: true,
                        imageProvider: FileImage(File(imageUrl.path!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final fotoBloc = context.read<RgVersoBloc>();
                      fotoBloc.add(
                        RgVersoSelect(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Selecionar outra'),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showImageDialogCompResid(BuildContext context, PlatformFile imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Container(
              color: Colors.black,
              width: 300,
              height: 550,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 400,
                      width: 250,
                      child: PhotoView(
                        disableGestures: true,
                        imageProvider: FileImage(File(imageUrl.path!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final fotoBloc = context.read<CompResidBloc>();
                      fotoBloc.add(
                        CompResidSelect(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Selecionar outra'),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class StepFour extends StatelessWidget {
  const StepFour({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          BlocBuilder<CompResidBloc, CompResidState>(
            builder: (context, compResidState) {
              if (compResidState is SelectCompResidLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (compResidState is SelectCompResidLoaded) {
                return ElevatedButton(
                  style: ButtonStyle(
                    //backgroundColor: MaterialStateProperty.all(Colors.blue),
                    //borda quadrada
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    showImageDialogCompResid(context, compResidState.foto);
                  },
                  child: const Text('Visualizar foto selecionada'),
                );
              } else {
                return ElevatedButton(
                  style: ButtonStyle(
                    //backgroundColor: MaterialStateProperty.all(Colors.blue),
                    //borda quadrada
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final fotoBloc = context.read<CompResidBloc>();
                    fotoBloc.add(
                      CompResidSelect(),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload),
                      SizedBox(width: 5),
                      Text('Adicionar comprovante de residência'),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void showImageDialog(BuildContext context, PlatformFile imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Container(
              width: 300,
              height: 550,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 400,
                      width: 250,
                      child: PhotoView(
                        disableGestures: true,
                        imageProvider: FileImage(File(imageUrl.path!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final fotoBloc = context.read<RgFrenteBloc>();
                      fotoBloc.add(
                        RgFrenteSelect(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Selecionar outra'),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showImageDialogRgVerso(BuildContext context, PlatformFile imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Container(
              width: 300,
              height: 550,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 400,
                      width: 250,
                      child: PhotoView(
                        disableGestures: true,
                        imageProvider: FileImage(File(imageUrl.path!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final fotoBloc = context.read<RgVersoBloc>();
                      fotoBloc.add(
                        RgVersoSelect(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Selecionar outra'),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showImageDialogCompResid(BuildContext context, PlatformFile imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Center(
            child: Container(
              color: Colors.black,
              width: 300,
              height: 550,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      height: 400,
                      width: 250,
                      child: PhotoView(
                        disableGestures: true,
                        imageProvider: FileImage(File(imageUrl.path!)),
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final fotoBloc = context.read<CompResidBloc>();
                      fotoBloc.add(
                        CompResidSelect(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Selecionar outra'),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Fechar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
