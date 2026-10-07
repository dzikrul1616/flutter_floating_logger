import 'package:example/core/packages/packages.dart';

class CatalogSearchBarWidget extends StatelessWidget {
  const CatalogSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF313244) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (val) => provider.search(val),
                  ),
                ),
                if (provider.searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => provider.search(''),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final cat = provider.categories[index];
                final isSelected = provider.selectedCategory == cat;

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => provider.selectCategory(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF3B82F6)
                          : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : (isDark ? const Color(0xFF313244) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
          ),
        ],
      ),
    );
  }
}
