import 'package:example/core/packages/packages.dart';

class GuideTipsWidget extends StatelessWidget {
  const GuideTipsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuideProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tip = provider.currentSnippet.tip;

    return Container(
      margin: EdgeInsets.fromLTRB(
        16,
        6,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFF3B82F6),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pro Tip:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
