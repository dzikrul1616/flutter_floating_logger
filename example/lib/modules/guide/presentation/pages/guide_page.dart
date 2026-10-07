import 'package:example/core/packages/packages.dart';

class GuidePage extends StatelessWidget {
  static const routeName = '/guidePage';
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GuideProvider(),
      child: Scaffold(
        body: Consumer<GuideProvider>(
          builder: (context, provider, child) {
            return const Column(
              children: [
                GuideHeaderWidget(),
                GuideTabSelectorWidget(),
                GuideSnippetCardWidget(),
                GuideTipsWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}
