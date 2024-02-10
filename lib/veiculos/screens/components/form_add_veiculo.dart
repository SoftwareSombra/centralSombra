import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/veiculos/services/veiculos_services.dart';
import '../../bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_bloc.dart';
import '../../bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_state.dart';

class FormAddVeiculo extends StatelessWidget {
  final TextEditingController placa;
  final TextEditingController marca;
  final TextEditingController modelo;
  final TextEditingController cor;
  final TextEditingController ano;
  final GlobalKey<FormState> formKey;
  FormAddVeiculo(
      {super.key,
      required this.placa,
      required this.marca,
      required this.modelo,
      required this.cor,
      required this.ano,
      required this.formKey});

  final VeiculoServices veiculoServices = VeiculoServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool isValidPlaca(String placa) {
    if (placa.length == 7) {
      RegExp regExp = RegExp(
          r'^[A-Z]{3}[0-9][A-Z][0-9]{2}$|^[A-Z]{2}[0-9]{2}[A-Z][0-9]{2}$');
      return regExp.hasMatch(placa);
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;
    final nome = user?.displayName;

    return BlocBuilder<RespostaSolicitacaoVeiculoBloc,
        RespostaSolicitacaoVeiculoState>(builder: (context, state) {
      if (state is RespostaSolicitacaoVeiculoLoading) {
        return const CircularProgressIndicator();
      } else if (state is SemCadastro) {
        return const Center(
          child: Text('Você não possui cadastro'),
        );
      } else if (state is RespostaSolicitacaoVeiculoLoaded) {
        final placaAceita = state.placa;
        final marcaAceita = state.marca;
        final modeloAceito = state.modelo;
        final corAceita = state.cor;
        final anoAceito = state.ano;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                state.dados.containsKey('Placa')
                    ? TextFormField(
                        controller: placa,
                        decoration: const InputDecoration(
                          labelText: 'Placa',
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
                            return 'Por favor, insira o número da placa do veículo';
                          }
                          if (!isValidPlaca(value.toUpperCase())) {
                            return 'Placa inválida';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),
                state.dados.containsKey('Marca')
                    ? TextFormField(
                        controller: marca,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
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
                            return 'Por favor, insira a marca do veículo';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),
                state.dados.containsKey('Modelo')
                    ? TextFormField(
                        controller: modelo,
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
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
                            return 'Por favor, insira o modelo do veículo';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),
                state.dados.containsKey('Cor')
                    ? TextFormField(
                        controller: cor,
                        decoration: const InputDecoration(
                          labelText: 'Cor',
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
                            return 'Por favor, insira o modelo do veículo';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),
                state.dados.containsKey('Ano')
                    ? TextFormField(
                        controller: ano,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter
                              .digitsOnly, // Permite apenas dígitos
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Ano',
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
                            return 'Por favor, insira o ano do veículo';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final placaValor = placa.text.trim() != ''
                          ? placa.text.trim()
                          : placaAceita != ''
                              ? placaAceita
                              : null;
                      final marcaValor = marca.text.trim() != ''
                          ? marca.text.trim()
                          : marcaAceita != ''
                              ? marcaAceita
                              : null;
                      final modeloValor = modelo.text.trim() != ''
                          ? modelo.text.trim()
                          : modeloAceito != ''
                              ? modeloAceito
                              : null;
                      final corValor = cor.text.trim() != ''
                          ? cor.text.trim()
                          : corAceita != ''
                              ? corAceita
                              : null;
                      final anoValor = ano.text.trim() != ''
                          ? ano.text.trim()
                          : anoAceito != ''
                              ? anoAceito
                              : null;
                      // Chama a função addUserInfos com todos os parâmetros necessários
                      if (placaValor == null ||
                          marcaValor == null ||
                          modeloValor == null ||
                          corValor == null ||
                          anoValor == null) {
                        return;
                      }
                      bool success = await veiculoServices.preAddVeiculo(
                        nome!,
                        uid!,
                        placaValor,
                        marcaValor,
                        modeloValor,
                        corValor,
                        anoValor,
                      );
                      if (success) {
                        placa.clear();
                        marca.clear();
                        modelo.clear();
                        cor.clear();
                        ano.clear();
                        // Fazer algo em caso de sucesso (ex: mostrar uma mensagem ou navegar para outra página)
                      } else {
                        // Fazer algo em caso de falha (ex: mostrar uma mensagem de erro)
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
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: placa,
                decoration: const InputDecoration(
                  labelText: 'Placa',
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
                    return 'Por favor, insira o número da placa do veículo';
                  }
                  if (!isValidPlaca(value.toUpperCase())) {
                    return 'Placa inválida';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: marca,
                decoration: const InputDecoration(
                  labelText: 'Marca',
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
                    return 'Por favor, insira a marca do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: modelo,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
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
                    return 'Por favor, insira o modelo do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: cor,
                decoration: const InputDecoration(
                  labelText: 'Cor',
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
                    return 'Por favor, insira o modelo do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: ano,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter
                      .digitsOnly, // Permite apenas dígitos
                ],
                decoration: const InputDecoration(
                  labelText: 'Ano',
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
                    return 'Por favor, insira o ano do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    // Chama a função addUserInfos com todos os parâmetros necessários
                    bool success = await veiculoServices.preAddVeiculo(
                      nome!,
                      uid!,
                      placa.text.trim(),
                      marca.text.trim(),
                      modelo.text.trim(),
                      cor.text.trim(),
                      ano.text.trim(),
                    );
                    if (success) {
                      placa.clear();
                      marca.clear();
                      modelo.clear();
                      cor.clear();
                      ano.clear();
                      debugPrint('sucessoo');
                      // Fazer algo em caso de sucesso (ex: mostrar uma mensagem ou navegar para outra página)
                    } else {
                      debugPrint('errooou');
                      // Fazer algo em caso de falha (ex: mostrar uma mensagem de erro)
                    }
                  }
                },
                child: const Text('Adicionar informações'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
