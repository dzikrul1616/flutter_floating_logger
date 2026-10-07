import 'package:example/core/packages/packages.dart';

class RouteGenerator {
  static MaterialPageRoute<dynamic> pageRoute(
    Widget page, {
    bool isWithoutTest = false,
  }) =>
      MaterialPageRoute(
        builder: (_) => isWithoutTest
            ? page
            : FloatingLoggerControl(
                getPreference: () async =>
                    await CustomSharedPreferences.getDebugger(),
                child: page,
              ),
      );

  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    final args = settings.arguments;
    switch (settings.name) {
      case HomePage.routeName:
      case '/':
        return pageRoute(
          const HomePage(),
        );

      case CatalogPage.routeName:
        return pageRoute(
          const CatalogPage(),
        );

      case DetailPage.routeName:
        if (args is DetailModel) {
          return pageRoute(
            DetailPage(
              param: args,
            ),
          );
        }
        return pageRoute(
          const HomePage(),
        );

      case DeveloperPage.routeName:
        return pageRoute(
          const DeveloperPage(),
          isWithoutTest: true,
        );

      case GuidePage.routeName:
        return pageRoute(
          const GuidePage(),
        );

      default:
        return pageRoute(
          const HomePage(),
        );
    }
  }
}
