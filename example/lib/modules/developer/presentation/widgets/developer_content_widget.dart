import 'package:example/core/packages/packages.dart';

class DeveloperContentWidget extends StatelessWidget {
  const DeveloperContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeveloperProvider>();

    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildBody(provider.currentTab),
      ),
    );
  }

  Widget _buildBody(int tab) {
    switch (tab) {
      case 0:
        return const DeveloperControlsWidget();
      case 1:
        return const DeveloperSimulationWidget();
      case 2:
        return const DeveloperInspectorWidget();
      case 3:
        return const DeveloperStyleWidget();
      default:
        return const DeveloperControlsWidget();
    }
  }
}
