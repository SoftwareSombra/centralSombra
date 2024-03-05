import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/veiculo_model.dart';
import 'events.dart';
import 'states.dart';

class VeiculoSolicitacaoBloc
    extends Bloc<VeiculoSolicitacaoEvent, VeiculoSolicitacaoState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VeiculoSolicitacaoBloc() : super(VeiculoSolicitacaoLoading()) {
    on<FetchVeiculoSolicitacoes>((event, emit) async {

      emit(VeiculoSolicitacaoLoading());
      try {
        List<Veiculo> veiculos = [];
        final uidsSnapshot =
            await _firestore.collection('Aprovação de veículos').get();

        for (var uidDoc in uidsSnapshot.docs) {
          final veiculosSnapshot =
              await uidDoc.reference.collection('Veículo').orderBy('Timestamp', descending: true).get();
          for (var veiculoDoc in veiculosSnapshot.docs) {
            veiculos
                .add(Veiculo.fromFirestore(veiculoDoc.data(), veiculoDoc.id));
          }
        }

        if (veiculos.isEmpty) {
          emit(VeiculoSolicitacaoNotFound());
          return;
        }

        emit(VeiculoSolicitacaoLoaded(veiculos));
      } catch (e) {
        emit(VeiculoSolicitacaoError(e.toString()));
      }
    });
  }
}
