import 'package:example/core/packages/packages.dart';

class DeveloperSimulationWidget extends StatelessWidget {
  const DeveloperSimulationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeveloperProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final simulations = [
      _SimulationItem(
        mode: NetworkSimulation.normal,
        title: 'Normal Connection',
        description: 'Standard device network without any artificial delay or errors',
        icon: Icons.speed_rounded,
        color: const Color(0xFF10B981),
      ),
      _SimulationItem(
        mode: NetworkSimulation.slow3g,
        title: 'Slow 3G Latency',
        description: 'Injects 2000ms synthetic delay to test spinners and slow conditions',
        icon: Icons.hourglass_top_rounded,
        color: const Color(0xFFF59E0B),
      ),
      _SimulationItem(
        mode: NetworkSimulation.offline,
        title: 'Offline Mode',
        description: 'Throws DioExceptionType.connectionError simulating airplane mode',
        icon: Icons.wifi_off_rounded,
        color: const Color(0xFFEF4444),
      ),
      _SimulationItem(
        mode: NetworkSimulation.socketError,
        title: 'Socket Error',
        description: 'Throws OS Error Connection Refused (errno 111) for unreachable hosts',
        icon: Icons.cloud_off_rounded,
        color: const Color(0xFFDC2626),
      ),
      _SimulationItem(
        mode: NetworkSimulation.serverError,
        title: 'Server Error 500',
        description: 'Returns HTTP 500 Bad Response with simulated JSON payload',
        icon: Icons.error_outline_rounded,
        color: const Color(0xFF9333EA),
      ),
      _SimulationItem(
        mode: NetworkSimulation.timeout,
        title: 'Connection Timeout',
        description: 'Waits 2000ms and raises DioExceptionType.connectionTimeout',
        icon: Icons.timer_off_rounded,
        color: const Color(0xFF0284C7),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: simulations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = simulations[index];
        final isSelected = provider.currentSimulation == item.mode;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            provider.setSimulation(item.mode);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Simulation set to: ${item.title}'),
                backgroundColor: item.color,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? item.color.withValues(alpha: 0.12)
                  : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? item.color
                    : (isDark ? const Color(0xFF313244) : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.8 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? item.color
                              : (isDark ? Colors.white : const Color(0xFF0F172A)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: item.color, size: 20)
                else
                  Icon(
                    Icons.radio_button_unchecked_rounded,
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SimulationItem {
  final NetworkSimulation mode;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _SimulationItem({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
