import 'package:example/core/packages/packages.dart';

class HomeQuickActionsWidget extends StatelessWidget {
  const HomeQuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chips = [
      _ActionChipItem(
        label: 'GraphQL',
        method: 'POST',
        color: const Color(0xFFEAB308),
        isLoading: provider.isLoading('graphql'),
        onTap: () => provider.fetchGraphQL(context),
      ),
      _ActionChipItem(
        label: 'REST Facts',
        method: 'GET',
        color: const Color(0xFF16A34A),
        isLoading: provider.isLoading('rest_get'),
        onTap: () => provider.fetchRestGet(context),
      ),
      _ActionChipItem(
        label: 'Image Preview',
        method: 'BIN',
        color: const Color(0xFF3B82F6),
        isLoading: provider.isLoading('image_preview'),
        onTap: () => provider.fetchImagePreview(context),
      ),
      _ActionChipItem(
        label: 'PDF Preview',
        method: 'PDF',
        color: const Color(0xFFDC2626),
        isLoading: provider.isLoading('pdf_preview'),
        onTap: () => provider.fetchPdfPreview(context),
      ),
      _ActionChipItem(
        label: 'FormData',
        method: 'POST',
        color: const Color(0xFFA855F7),
        isLoading: provider.isLoading('form_data'),
        onTap: () => provider.fetchFormData(context),
      ),
      _ActionChipItem(
        label: 'Interceptor',
        method: 'GET',
        color: const Color(0xFF0D9488),
        isLoading: provider.isLoading('interceptor'),
        onTap: () => provider.fetchWithCustomInterceptor(context),
      ),
      _ActionChipItem(
        label: 'Error 500',
        method: 'ERR',
        color: const Color(0xFFEF4444),
        isLoading: provider.isLoading('error_500'),
        onTap: () => provider.fetchError500(context),
      ),
    ];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = chips[index];
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: item.isLoading ? null : item.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? const Color(0xFF313244) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.method,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (item.isLoading)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: item.color,
                      ),
                    )
                  else
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionChipItem {
  final String label;
  final String method;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionChipItem({
    required this.label,
    required this.method,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });
}
