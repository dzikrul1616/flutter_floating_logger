import 'package:example/core/packages/packages.dart';

class HomeRequestListWidget extends StatelessWidget {
  const HomeRequestListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _RequestTestItem(
        keyName: 'graphql',
        title: 'GraphQL Query (Countries)',
        subtitle: 'POST https://countries.trevorblades.com/',
        method: 'POST',
        methodColor: const Color(0xFFEAB308),
        icon: Icons.graphic_eq_rounded,
        tag: 'GraphQL & cURL',
        onExecute: () => provider.fetchGraphQL(context),
      ),
      _RequestTestItem(
        keyName: 'rest_get',
        title: 'REST API GET (Genderize)',
        subtitle: 'GET https://api.genderize.io?name=alex',
        method: 'GET',
        methodColor: const Color(0xFF16A34A),
        icon: Icons.http_rounded,
        tag: 'REST QueryParams',
        onExecute: () => provider.fetchRestGet(context),
      ),
      _RequestTestItem(
        keyName: 'image_preview',
        title: 'Image Binary Preview',
        subtitle: 'GET https://picsum.photos/id/237/400/300',
        method: 'GET',
        methodColor: const Color(0xFF3B82F6),
        icon: Icons.image_rounded,
        tag: 'Binary Image & Zoom',
        onExecute: () => provider.fetchImagePreview(context),
      ),
      _RequestTestItem(
        keyName: 'pdf_preview',
        title: 'PDF Document Preview',
        subtitle: 'GET https://www.adobe.com/.../c4611_sample_explain.pdf',
        method: 'GET',
        methodColor: const Color(0xFFDC2626),
        icon: Icons.picture_as_pdf_rounded,
        tag: 'Binary PDF & Badge',
        onExecute: () => provider.fetchPdfPreview(context),
      ),
      _RequestTestItem(
        keyName: 'form_data',
        title: 'FormData Multipart POST',
        subtitle: 'POST https://httpbin.org/post (fields & map)',
        method: 'POST',
        methodColor: const Color(0xFFA855F7),
        icon: Icons.post_add_rounded,
        tag: 'FormData & cURL',
        onExecute: () => provider.fetchFormData(context),
      ),
      _RequestTestItem(
        keyName: 'interceptor',
        title: 'Custom Interceptor Chaining',
        subtitle: 'GET https://dummyjson.com/quotes/random',
        method: 'GET',
        methodColor: const Color(0xFF0D9488),
        icon: Icons.alt_route_rounded,
        tag: 'Interceptor Chains',
        onExecute: () => provider.fetchWithCustomInterceptor(context),
      ),
      _RequestTestItem(
        keyName: 'error_500',
        title: 'HTTP 500 Internal Server Error',
        subtitle: 'GET https://httpstat.us/500 (Simulated)',
        method: 'GET',
        methodColor: const Color(0xFFEF4444),
        icon: Icons.warning_amber_rounded,
        tag: 'Error Tracking',
        onExecute: () => provider.fetchError500(context),
      ),
    ];

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          final isLoading = provider.isLoading(item.keyName);
          final result = provider.getResult(item.keyName);

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF313244) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.methodColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.methodColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: item.methodColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.method,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: item.methodColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF313244)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (result != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: result.isSuccess
                                  ? const Color(0xFF16A34A).withOpacity(0.12)
                                  : const Color(0xFFEF4444).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  result.isSuccess
                                      ? Icons.check_circle_rounded
                                      : Icons.error_rounded,
                                  size: 13,
                                  color: result.isSuccess
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${result.statusCode ?? "ERR"} • ${result.latencyMs}ms',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: result.isSuccess
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.methodColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isLoading ? null : item.onExecute,
                          child: isLoading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  children: [
                                    Icon(Icons.play_arrow_rounded, size: 16),
                                    SizedBox(width: 3),
                                    Text(
                                      'Test',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RequestTestItem {
  final String keyName;
  final String title;
  final String subtitle;
  final String method;
  final Color methodColor;
  final IconData icon;
  final String tag;
  final VoidCallback onExecute;

  const _RequestTestItem({
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.method,
    required this.methodColor,
    required this.icon,
    required this.tag,
    required this.onExecute,
  });
}
