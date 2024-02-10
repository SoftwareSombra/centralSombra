import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../autenticacao/services/user_services.dart';
import 'rg_verso_event.dart';
import 'rg_verso_state.dart';

class RgVersoBloc extends Bloc<RgVersoEvent, RgVersoState> {
  RgVersoBloc() : super(RgVersoInitial()) {
    final UserServices userServices = UserServices();
    PlatformFile? foto;
    on<RgVersoSelect>(
      (event, emit) async {
        emit(SelectRgVersoLoading());
        try {
          final PlatformFile? selectedImage = await userServices.selectImage();
          if (selectedImage != null) {
            foto = selectedImage;
            emit(SelectRgVersoLoaded(foto!));
          } else {
            if (foto != null) {
              emit(SelectRgVersoLoaded(foto!));
            } else {
              emit(RgVersoInitial());
            }
          }
        } catch (e) {
          emit(SelectRgVersoError('Erro ao selecionar foto'));
        }
      },
    );
  }
}
