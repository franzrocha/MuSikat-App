import 'package:get_it/get_it.dart';
import 'package:musikat_app/music_player/music_handler.dart';
import 'controllers/auth_controller.dart';
import 'controllers/navigation/navigation_service.dart';

final locator = GetIt.instance;
Future<void> setupLocators() async {
  
  locator.registerSingleton<NavigationService>(NavigationService());
  locator.registerSingleton<AuthController>(AuthController());
  locator.registerSingleton<MusicHandler>(MusicHandler());
}
