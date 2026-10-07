import 'package:example/core/packages/packages.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/myPage';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..init(),
      child: Scaffold(
        body: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            return const Column(
              children: [
                HomeHeaderWidget(),
                HomeStatusCardWidget(),
                HomeQuickActionsWidget(),
                HomeRequestListWidget(),
                HomeNavButtonsWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}
