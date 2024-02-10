

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../autenticacao/services/user_services.dart';
import 'comp_resid_event.dart';
import 'comp_resid_state.dart';

class CompResidBloc extends Bloc<CompResidEvent, CompResidState> {
  CompResidBloc() : super(CompResidInitial()) {
    final UserServices userServices = UserServices();
    PlatformFile? foto;
    on<CompResidSelect>(
      (event, emit) async {
        emit(SelectCompResidLoading());
        try {
          final PlatformFile? selectedImage = await userServices.selectImage();
          if (selectedImage != null) {
            foto = selectedImage;
            emit(SelectCompResidLoaded(foto!));
          } else {
            if (foto != null) {
              emit(SelectCompResidLoaded(foto!));
            } else {
              emit(CompResidInitial());
            }
          }
        } catch (e) {
          emit(SelectCompResidError('Erro ao selecionar foto'));
        }
      },
    );
  }
}