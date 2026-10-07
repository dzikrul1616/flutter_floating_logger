import 'package:example/core/packages/packages.dart';

class CatalogHeaderWidget extends StatelessWidget {
  const CatalogHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CatalogProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF313244) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF313244) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'E-Commerce Store',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Real-world API testing with DioLogger',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            tooltip: 'Reload Products',
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            onPressed: () => provider.fetchProducts(),
          ),
        ],
      ),
    );
  }
}
