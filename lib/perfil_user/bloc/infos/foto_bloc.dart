import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../autenticacao/services/user_services.dart';
import 'events_foto.dart';
import 'states_foto.dart';

class FotoBloc extends Bloc<SelectFotoEvent, SelectFotoState> {
  final UserServices userServices;
  final Map<String, PlatformFile> fotos = {};

  FotoBloc({required this.userServices}) : super(SelectFotoInitial()) {
    on<FotoSelected>(
      (event, emit) async {
        emit(SelectFotoLoading());
        try {
          final PlatformFile? selectedImage = await userServices.selectImage();

          if (selectedImage != null) {
            fotos[event.tipo] = selectedImage;
            emit(SelectFotoLoaded(Map.from(fotos)));
          }
        } catch (_) {
          emit(SelectFotoError('Erro ao buscar credencial'));
        }
      },
    );
  }
}
