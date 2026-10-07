import 'package:example/core/packages/packages.dart';

class GuideTabSelectorWidget extends StatelessWidget {
  const GuideTabSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuideProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: provider.snippets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = provider.selectedTabIndex == index;
          final item = provider.snippets[index];

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => provider.selectTab(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3B82F6)
                    : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : (isDark ? const Color(0xFF313244) : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Center(
                child: Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
