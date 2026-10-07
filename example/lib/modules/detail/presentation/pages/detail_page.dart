import 'package:example/core/packages/packages.dart';

class DetailPage extends StatelessWidget {
  static const routeName = '/itemPage';
  final DetailModel param;

  const DetailPage({
    super.key,
    required this.param,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailProvider()..init(param.id, param.item),
      child: Scaffold(
        body: Consumer<DetailProvider>(
          builder: (context, provider, child) {
            return const Column(
              children: [
                DetailHeaderWidget(),
                DetailImageWidget(),
                DetailContentWidget(),
                DetailBottomBarWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}
