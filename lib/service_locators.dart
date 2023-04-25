import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'controllers/auth_controller.dart';
import 'controllers/navigation/navigation_service.dart';
import 'handlers/audio_handler.dart';

final locator = GetIt.instance;
void setupLocators() {
  locator.registerSingleton<NavigationService>(NavigationService());
  locator.registerSingleton<AuthController>(AuthController());
  locator.registerSingletonAsync<AudioHandler>(() => initAudioService());
}
