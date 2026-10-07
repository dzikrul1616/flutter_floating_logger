import 'package:example/core/packages/packages.dart';

class CatalogPage extends StatelessWidget {
  static const routeName = '/listPage';
  final bool autoFetch;
  const CatalogPage({super.key, this.autoFetch = true});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = CatalogProvider();
        if (autoFetch) {
          provider.init();
        }
        return provider;
      },
      child: Scaffold(
        body: Consumer<CatalogProvider>(
          builder: (context, provider, child) {
            return const Column(
              children: [
                CatalogHeaderWidget(),
                CatalogSearchBarWidget(),
                CatalogGridWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}
