import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sombra_testes/agente/services/agente_services.dart';
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
import '../../bloc/infos/events_foto.dart';
import '../../bloc/infos/foto_bloc.dart';
import '../../bloc/infos/states_foto.dart';

class FormAddInfo extends StatelessWidget {
  final BuildContext infosContext;
  final TextEditingController nome;
  final TextEditingController endereco;
  final TextEditingController cep;
  final TextEditingController celular;
  final TextEditingController rg;
  final TextEditingController cpf;
  final GlobalKey<FormState> formKey;
  FormAddInfo(
      {super.key,
      required this.infosContext,
      required this.nome,
      required this.endereco,
      required this.cep,
      required this.celular,
      required this.rg,
      required this.cpf,
      required this.formKey});

  final AgenteServices agenteServices = AgenteServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  @override
  Widget build(BuildContext context) {
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;
    print('Está parando aqui');
    return BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
      builder: (context, state) {
        print(state.toString());
        if (state is ElevatedButtonBlocLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return BlocBuilder<AgenteBloc, AgenteState>(
            builder: (context, agenteState) {
              print(agenteState.toString());
              if (agenteState is AgenteLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (agenteState is EmAnalise) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: Row(
                      children: [
                        Text('Dados em análise, aguarde'),
                      ],
                    ))
                  ],
                );
              } else if (agenteState is AgenteInfosRejected) {
                final enderecoAceito = agenteState.enderecoAceito;
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
                        agenteState.dados.containsKey('Nome')
                            ? TextFormField(
                                keyboardType: TextInputType.name,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(
                                      "[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]")),
                                ],
                                controller: nome,
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
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
                                    return 'Por favor, insira o seu nome';
                                  }
                                  return null;
                                },
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(
                          height: 10,
                        ),
                        agenteState.dados.containsKey('Endereço')
                            ? TextFormField(
                                keyboardType: TextInputType.streetAddress,
                                controller: endereco,
                                decoration: const InputDecoration(
                                  labelText: 'Endereço',
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
                                    return 'Por favor, insira o seu endereço';
                                  }
                                  return null;
                                },
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(
                          height: 10,
                        ),
                        agenteState.dados.containsKey('Cep')
                            ? TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Permite apenas dígitos
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
                                    return 'Por favor, insira o CEP';
                                  } else if (!agenteServices
                                      .validarCEP(value)) {
                                    return 'CEP inválido';
                                  }
                                  return null;
                                },
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(
                          height: 10,
                        ),
                        agenteState.dados.containsKey('Celular')
                            ? TextFormField(
                                keyboardType: TextInputType.phone,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Permite apenas dígitos
                                ],
                                controller: celular,
                                decoration: const InputDecoration(
                                  labelText: 'Celular (com WhatsApp)',
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
                                    return 'Por favor, insira o seu número de celular';
                                  } else if (!agenteServices
                                      .validarNumeroCelular(value)) {
                                    return 'Número de celular inválido';
                                  }
                                  return null;
                                },
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(
                          height: 10,
                        ),
                        agenteState.dados.containsKey('RG')
                            ? TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Permite apenas dígitos
                                ],
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
                        const SizedBox(
                          height: 10,
                        ),
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
                                      .minLength(11)
                                      .maxLength(11)
                                      .valido(value, clearNoNumber: true);
                                },
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(
                          height: 10,
                        ),
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
                        const SizedBox(
                          height: 10,
                        ),
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
                        const SizedBox(
                          height: 10,
                        ),
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
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            print('passo 1');
                            if (formKey.currentState!.validate()) {
                              print('passo 2');
                              final nomeValor = nome.text.trim() != ''
                                  ? nome.text.trim()
                                  : nomeAceito != ''
                                      ? nomeAceito
                                      : null;
                              final enderecoValor = endereco.text.trim() != ''
                                  ? endereco.text.trim()
                                  : enderecoAceito != ''
                                      ? enderecoAceito
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

                              context
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonPressed());

                              formKey.currentState!.save();

                              var rgFrenteState =
                                  context.read<RgFrenteBloc>().state;

                              PlatformFile? rgFrente;

                              if (rgFrenteState is SelectRgFrenteLoaded) {
                                rgFrente = rgFrenteState.foto;
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

                              if (rgFotoFrenteValor == null ||
                                  rgFotoVersoValor == null ||
                                  compDeResidValor == null ||
                                  nomeValor == null ||
                                  enderecoValor == null ||
                                  cepValor == null ||
                                  celularValor == null ||
                                  rgValor == null ||
                                  cpfValor == null) {
                                tratamentoDeErros.showErrorSnackbar(context,
                                    'Por favor, insira todas as fotos');
                                return;
                              } else {
                                bool success =
                                    await agenteServices.preAddUserInfos(
                                  uid!,
                                  nomeValor,
                                  enderecoValor,
                                  cepValor,
                                  celularValor,
                                  rgValor,
                                  cpfValor,
                                  rgFotoFrenteValor,
                                  rgFotoVersoValor,
                                  compDeResidValor,
                                );
                                if (success) {
                                  print('sucessoo');
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
                                  print('errooou');
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
                            }
                          },
                          child: const Text('Adicionar informações'),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-ZáéíóúâêôàüãõçÁÉÍÓÚÂÊÔÀÜÃÕÇ ]")),
                          ],
                          controller: nome,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
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
                              return 'Por favor, insira o seu nome';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.streetAddress,
                          controller: endereco,
                          decoration: const InputDecoration(
                            labelText: 'Endereço',
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
                              return 'Por favor, insira o seu endereço';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter
                                .digitsOnly, // Permite apenas dígitos
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
                              return 'Por favor, insira o CEP';
                            } else if (!agenteServices.validarCEP(value)) {
                              return 'CEP inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter
                                .digitsOnly, // Permite apenas dígitos
                          ],
                          controller: celular,
                          decoration: const InputDecoration(
                            labelText: 'Celular (com WhatsApp)',
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
                              return 'Por favor, insira o seu número de celular';
                            } else if (!agenteServices
                                .validarNumeroCelular(value)) {
                              return 'Número de celular inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter
                                .digitsOnly, // Permite apenas dígitos
                          ],
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
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
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
                                .minLength(11)
                                .maxLength(11)
                                .valido(value, clearNoNumber: true);
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        BlocBuilder<RgFrenteBloc, RgFrenteState>(
                          builder: (context, rgFrenteState) {
                            if (rgFrenteState is SelectRgFrenteLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (rgFrenteState is SelectRgFrenteLoaded) {
                              return ElevatedButton(
                                onPressed: () async {
                                  showImageDialog(context, rgFrenteState.foto);
                                },
                                child: const Text('Ver'),
                              );
                            } else {
                              return ElevatedButton(
                                onPressed: () async {
                                  final fotoBloc = context.read<RgFrenteBloc>();
                                  fotoBloc.add(
                                    RgFrenteSelect(),
                                  );
                                },
                                child: const Text('Foto do RG (frente)'),
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
                                onPressed: () async {
                                  showImageDialogRgVerso(
                                      context, rgVersoState.foto);
                                },
                                child: const Text('Ver'),
                              );
                            } else {
                              return ElevatedButton(
                                onPressed: () async {
                                  final fotoBloc = context.read<RgVersoBloc>();
                                  fotoBloc.add(
                                    RgVersoSelect(),
                                  );
                                },
                                child: const Text('Foto do RG (verso)'),
                              );
                            }
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        BlocBuilder<CompResidBloc, CompResidState>(
                          builder: (context, compResidState) {
                            if (compResidState is SelectCompResidLoading) {
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
                                child: const Text('Comprovante de Residência'),
                              );
                            }
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            print('passo 1');
                            if (formKey.currentState!.validate()) {
                              print('passo 2');
                              print(
                                  context.mounted == true ? 'true1' : 'false1');
                              context
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonPressed());
                              print('passo 3');

                              formKey.currentState!.save();

                              var rgFrenteState =
                                  context.read<RgFrenteBloc>().state;

                              print(
                                  context.mounted == true ? 'true2' : 'false2');

                              PlatformFile? rgFrente;

                              if (rgFrenteState is SelectRgFrenteLoaded) {
                                rgFrente = rgFrenteState.foto;
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

                              print(
                                  context.mounted == true ? 'true3' : 'false3');

                              PlatformFile? rgFotoFrente = rgFrente;
                              PlatformFile? rgFotoVerso = rgVerso;
                              PlatformFile? compDeResid = compResid;

                              print(rgFotoFrente.toString());
                              print('passo4');

                              if (rgFotoFrente == null ||
                                  rgFotoVerso == null ||
                                  compDeResid == null) {
                                tratamentoDeErros.showErrorSnackbar(context,
                                    'Por favor, insira todas as fotos');
                                if (context.mounted) {
                                  print('contexto de erro1 aqui');
                                  context
                                      .read<ElevatedButtonBloc>()
                                      .add(ElevatedButtonActionCompleted());
                                  tratamentoDeErros.showErrorSnackbar(
                                      context, 'Erro ao adicionar informações');
                                }
                                return;
                              }
                              print('inicio do envio');
                              bool success =
                                  await agenteServices.preAddUserInfos(
                                uid!,
                                nome.text.trim(),
                                endereco.text.trim(),
                                cep.text.trim(),
                                celular.text.trim(),
                                rg.text.trim(),
                                cpf.text.trim(),
                                rgFotoFrente,
                                rgFotoVerso,
                                compDeResid,
                              );
                              if (success) {
                                print('----------- sucessoo --------');
                                endereco.clear();
                                cep.clear();
                                celular.clear();
                                rg.clear();
                                cpf.clear();
                                if (context.mounted) {
                                  context
                                      .read<ElevatedButtonBloc>()
                                      .add(ElevatedButtonActionCompleted());
                                  mensagemDeSucesso.showSuccessSnackbar(context,
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
                                print('errooou');
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
                                    tratamentoDeErros.showErrorSnackbar(
                                        infosContext,
                                        'Erro ao adicionar informações');
                                  }
                                }
                              }
                            }
                          },
                          child: const Text('Adicionar informações'),
                        ),
                      ],
                    ),
                  ),
                );
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
