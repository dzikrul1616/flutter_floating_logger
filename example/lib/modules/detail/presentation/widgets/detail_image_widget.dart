import 'package:example/core/packages/packages.dart';

class DetailImageWidget extends StatelessWidget {
  const DetailImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DetailProvider>();
    final item = provider.item;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (item == null) {
      return Container(
        height: 220,
        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF8F9FA),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Center(
            child: item.image != null
                ? Image.network(
                    item.image!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: Colors.grey,
                    ),
                  )
                : const Icon(Icons.image, size: 48, color: Colors.grey),
          ),
          if (item.category != null)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.category!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF3B82F6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
