import 'package:flutter/material.dart';
import 'package:musikat_app/screens/auth_screen.dart';
import 'package:musikat_app/screens/welcome_screen.dart';
import 'package:musikat_app/service_locators.dart';
import 'controllers/navigation/navigation_service.dart';


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
              primary: Colors.green,),),
      builder: (context, Widget? child) => child as Widget,
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: NavigationService.generateRoute,
      initialRoute: WelcomeScreen.route,
    );
  }

}