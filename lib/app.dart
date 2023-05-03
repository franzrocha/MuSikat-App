import 'package:musikat_app/controllers/navigation/navigation_service.dart';
import 'package:musikat_app/service_locators.dart';
import 'utils/exports.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: musikatColor2,
            ),
      ),
      builder: (context, Widget? child) => child as Widget,
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: locator<NavigationService>().getRoute,
      // initialRoute: WelcomeScreen.route,
    
    );
  }
}
