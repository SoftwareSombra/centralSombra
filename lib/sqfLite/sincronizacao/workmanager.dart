import 'package:workmanager/workmanager.dart';
import '../../missao/services/missao_services.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    MissaoServices missaoServices = MissaoServices();
    await missaoServices.finalLocalPendente();
    await missaoServices.finalizarMissaoPendente();
    await missaoServices.enviarRelatorioPendente();
    await missaoServices.enviarFotosPendentes();
    await missaoServices.enviarIncrementoRelatorioPendente();
    return Future.value(true);
  });
}