part of 'navigation_service.dart';

PageRoute getRoute(RouteSettings settings) {
  switch (settings.name) {
    case WelcomeScreen.route:
      return SlideUpRoute(page: const WelcomeScreen(), settings: settings);
    case NavBar.route:
      return SlideUpRoute(page: const NavBar(), settings: settings);
    case HomeScreen.route:
      return SlideDownRoute(page: const HomeScreen(), settings: settings);
      // case ArtistsScreen.route:
      // return SlideDownRoute(page: const ArtistsScreen(), settings: settings);
    default:
      return FadeRoute(page: const NavBar(), settings: settings);
  }
}
