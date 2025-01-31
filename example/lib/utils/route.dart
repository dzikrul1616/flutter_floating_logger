import 'package:floating_logger/floating_logger.dart';
import 'preferences.dart';
import '../pages/detail_item.dart';
import '../pages/home_page.dart';
import '../pages/list_page.dart';
import '../pages/developper_page.dart';

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
      case MyHomePage.routeName:
        return pageRoute(
          const MyHomePage(),
        );
      case ListPage.routeName:
        return pageRoute(
          const ListPage(),
        );
      case DetailItem.routeName:
        if (args is DetailModel) {
          return pageRoute(
            DetailItem(
              param: args,
            ),
          );
        }
        return MaterialPageRoute(builder: (context) {
          return const MyHomePage();
        });
      case DevelopperMode.routeName:
        return pageRoute(
          const DevelopperMode(),
          isWithoutTest: true,
        );

      default:
        return MaterialPageRoute(builder: (context) {
          return const MyHomePage();
        });
    }
  }
}
