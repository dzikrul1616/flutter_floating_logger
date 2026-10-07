import 'package:example/core/packages/packages.dart';

class DeveloperTabModeWidget extends StatelessWidget {
  const DeveloperTabModeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeveloperProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      {'title': 'General', 'icon': Icons.tune_rounded},
      {'title': 'Throttle', 'icon': Icons.speed_rounded},
      {'title': 'Web Inspector', 'icon': Icons.laptop_mac_rounded},
      {'title': 'Style', 'icon': Icons.palette_outlined},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = provider.currentTab == index;
          final tab = tabs[index];

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => provider.setTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF313244) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 15,
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tab['title'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
