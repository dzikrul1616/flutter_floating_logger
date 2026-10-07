import 'package:example/core/packages/packages.dart';

class DeveloperInspectorWidget extends StatelessWidget {
  const DeveloperInspectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeveloperProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRunning = provider.isInspectorRunning;
    final url = provider.inspectorUrl;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF313244) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isRunning
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF3B82F6))
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.laptop_mac_rounded,
                            color: isRunning
                                ? const Color(0xFF10B981)
                                : const Color(0xFF3B82F6),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Web Inspector Server',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              isRunning ? 'Realtime Server Active' : 'Server is offline',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isRunning
                                    ? const Color(0xFF10B981)
                                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRunning
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => provider.toggleWebInspector(),
                      child: Text(
                        isRunning ? 'Stop Server' : 'Start Server',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                if (isRunning && url != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Desktop Browser URL:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                url,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                minimumSize: const Size(0, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: const Text('Copy', style: TextStyle(fontSize: 11)),
                              onPressed: () => provider.copyInspectorUrl(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  'How Web Inspector Works:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                _buildStep(
                  '1',
                  'Ensure your desktop/laptop is on the same local Wi-Fi network.',
                  isDark,
                ),
                _buildStep(
                  '2',
                  'Click "Start Server" above to launch HTTP/WebSocket on port 21616.',
                  isDark,
                ),
                _buildStep(
                  '3',
                  'Open the displayed URL in Chrome, Safari, or Firefox.',
                  isDark,
                ),
                _buildStep(
                  '4',
                  'Inspect all HTTP requests, responses, headers, and cURL commands live on your big screen!',
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B82F6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
