import 'package:get_it/get_it.dart';
import 'package:musikat_app/controllers/liked_songs_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/navigation/navigation_service.dart';

final locator = GetIt.instance;
void setupLocators() {
  locator.registerSingleton<NavigationService>(NavigationService());
  locator.registerSingleton<AuthController>(AuthController());
  locator.registerSingleton<LikedSongsController>(LikedSongsController());
}
