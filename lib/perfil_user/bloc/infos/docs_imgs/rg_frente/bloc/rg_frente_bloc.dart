import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../autenticacao/services/user_services.dart';
import 'rg_frente_event.dart';
import 'rg_frente_state.dart';

class RgFrenteBloc extends Bloc<RgFrenteEvent, RgFrenteState> {
  RgFrenteBloc() : super(RgFrenteInitial()) {
    final UserServices userServices = UserServices();
    PlatformFile? foto;
    on<RgFrenteSelect>(
      (event, emit) async {
        emit(SelectRgFrenteLoading());
        try {
          final PlatformFile? selectedImage = await userServices.selectImage();
          if (selectedImage != null) {
            foto = selectedImage;
            emit(SelectRgFrenteLoaded(foto!));
          } else {
            if (foto != null) {
              emit(SelectRgFrenteLoaded(foto!));
            } else {
              emit(RgFrenteInitial());
            }
          }
        } catch (e) {
          emit(SelectRgFrenteError('Erro ao selecionar foto'));
        }
      },
    );
  }
}
