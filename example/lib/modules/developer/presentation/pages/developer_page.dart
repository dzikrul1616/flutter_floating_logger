import 'package:example/core/packages/packages.dart';

class DeveloperPage extends StatelessWidget {
  static const routeName = '/developper';
  const DeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeveloperProvider()..init(),
      child: Scaffold(
        body: Consumer<DeveloperProvider>(
          builder: (context, provider, child) {
            return const Column(
              children: [
                DeveloperHeaderWidget(),
                DeveloperTabModeWidget(),
                DeveloperContentWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}
