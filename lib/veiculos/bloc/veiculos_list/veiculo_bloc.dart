import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/veiculo_model.dart';
import 'events.dart';
import 'states.dart';

class VeiculoBloc extends Bloc<VeiculoEvent, VeiculoState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  VeiculoBloc() : super(VeiculoLoading()) {
    on<FetchVeiculos>((event, emit) async {
      emit(VeiculoLoading());
      try {
        
        List<Veiculo> veiculos = [];
        final querySnapshot = await _firestore
            .collection('Veículos')
            .doc(event.uid)
            .collection('Veículo')
            .get();

        if (querySnapshot.docs.isEmpty) {
          emit(VeiculoNotFound());
          return;
        }

        for (var doc in querySnapshot.docs) {
          veiculos.add(Veiculo.fromFirestore(doc.data(), doc.id));
        }

        emit(VeiculoLoaded(veiculos));
      } catch (e) {
        emit(VeiculoError(e.toString()));
      }
    });
  }
}