import 'package:flutter/services.dart';
import '../pages/pages.dart';
import 'package:floating_logger/floating_logger.dart';
import 'floating_logger_toast.dart';

class FloatingLoggerModalBottomWidget extends StatefulWidget {
  const FloatingLoggerModalBottomWidget({
    super.key,
    this.widgetItemBuilder,
    this.isSimulationActive = true,
  });

  final Widget Function(
    int index,
    List<LogRepositoryModel> data,
  )? widgetItemBuilder;

  /// Controls whether the network simulation control is shown (default: true).
  final bool isSimulationActive;

  @override
  State<FloatingLoggerModalBottomWidget> createState() =>
      FloatingLoggerModalBottomWidgetState();
}

class FloatingLoggerModalBottomWidgetState
    extends State<FloatingLoggerModalBottomWidget> {
  bool isSearchActive = false;
  final ValueNotifier<String> searchQuery = ValueNotifier("");
  final ValueNotifier<Set<String>> activeFilters = ValueNotifier({});
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<int> currentMatchIndex = ValueNotifier(0);
  final Map<int, GlobalKey> _itemKeys = {};

  @visibleForTesting
  Map<int, GlobalKey> get itemKeys => _itemKeys;

  void toggleFilter(String type) {
    activeFilters.value = {
      ...activeFilters.value.contains(type)
          ? activeFilters.value.where((t) => t != type)
          : {...activeFilters.value, type}
    };
  }

  void showAllLogs() {
    activeFilters.value = {};
  }

  void toggleSearch() {
    if (!mounted) return;
    if (isSearchActive) {
      FocusScope.of(context).unfocus();
    }
    setState(() {
      if (isSearchActive) {
        searchController.clear();
        searchQuery.value = "";
      }
      isSearchActive = !isSearchActive;
    });
  }

  bool _isCustomHeaderMatch(String? headerStr, String q) {
    if (headerStr == null ||
        headerStr.isEmpty ||
        headerStr == "{}" ||
        headerStr == "null") {
      return false;
    }
    final lower = headerStr.toLowerCase();
    if (!lower.contains(q)) return false;
    final clean = lower
        .replaceAll('application/json', '')
        .replaceAll('charset=utf-8', '')
        .replaceAll('gzip, deflate', '')
        .replaceAll('text/plain', '');
    return clean.contains(q);
  }

  @override
  void dispose() {
    activeFilters.dispose();
    searchQuery.dispose();
    searchController.dispose();
    scrollController.dispose();
    currentMatchIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: FloatingLoggerTheme.themeModeNotifier,
      builder: (context, currentMode, _) {
        final themeData = FloatingLoggerTheme.getIsolatedTheme(context);
        final colors = FloatingLoggerTheme.of(context);
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return Theme(
          data: themeData,
          child: Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  right: 14,
                  top: 10,
                  bottom: bottomInset > 0 ? bottomInset + 8 : 12,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.88,
                  child: ValueListenableBuilder(
                    valueListenable: searchQuery,
                    builder: (context, searchValue, _) {
                      return ValueListenableBuilder(
                        valueListenable: activeFilters,
                        builder: (context, filterValue, __) {
                          return ValueListenableBuilder(
                            valueListenable:
                                DioLogger.instance.logs.logsNotifier,
                            builder: (context, logs, ___) {
                              List<LogRepositoryModel> filteredLogs =
                                  logs.where((log) {
                                final hasTypeFilter =
                                    filterValue.contains(log.type);
                                final hasMethodFilter =
                                    filterValue.contains(log.method);

                                final selectedTypes = filterValue
                                    .where((f) => [
                                          "REQUEST",
                                          "RESPONSE",
                                          "ERROR"
                                        ].contains(f))
                                    .toSet();
                                final selectedMethods = filterValue
                                    .where((f) => [
                                          "GET",
                                          "POST",
                                          "PUT",
                                          "PATCH",
                                          "DELETE",
                                          "OPTIONS",
                                          "HEAD"
                                        ].contains(f))
                                    .toSet();

                                final q = searchValue.trim().toLowerCase();

                                final pathMatches =
                                    log.path?.toLowerCase().contains(q) ??
                                        false;
                                final paramMatches =
                                    (log.queryparameter != null &&
                                            log.queryparameter!.isNotEmpty &&
                                            log.queryparameter != "{}" &&
                                            log.queryparameter != "[]" &&
                                            log.queryparameter != "null") &&
                                        log.queryparameter!
                                            .toLowerCase()
                                            .contains(q);
                                final dataMatches = (log.data != null &&
                                        log.data!.isNotEmpty &&
                                        log.data != "{}" &&
                                        log.data != "null" &&
                                        log.data != "[]") &&
                                    log.data!.toLowerCase().contains(q);
                                final respMatches = (log.responseData != null &&
                                        log.responseData!.isNotEmpty &&
                                        log.responseData != "{}" &&
                                        log.responseData != "null" &&
                                        log.responseData != "[]") &&
                                    log.responseData!.toLowerCase().contains(q);
                                final msgMatches = (log.message != null &&
                                        log.message!.isNotEmpty &&
                                        log.message != "null") &&
                                    log.message!.toLowerCase().contains(q);
                                final headerMatches =
                                    _isCustomHeaderMatch(log.header, q);

                                final matchesSearch = q.isEmpty ||
                                    pathMatches ||
                                    paramMatches ||
                                    dataMatches ||
                                    respMatches ||
                                    msgMatches ||
                                    headerMatches;

                                final matchesFilter = filterValue.isEmpty ||
                                    (selectedTypes.isNotEmpty &&
                                        selectedMethods.isEmpty &&
                                        hasTypeFilter) ||
                                    (selectedMethods.isNotEmpty &&
                                        selectedTypes.isEmpty &&
                                        hasMethodFilter) ||
                                    (selectedTypes.isNotEmpty &&
                                        selectedMethods.isNotEmpty &&
                                        hasTypeFilter &&
                                        hasMethodFilter);

                                return matchesSearch && matchesFilter;
                              }).toList();

                              // Clear and rebuild keys map for filtered logs
                              _itemKeys.clear();
                              for (int i = 0; i < filteredLogs.length; i++) {
                                _itemKeys[i] = GlobalKey();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHandle(colors),
                                  const SizedBox(height: 12.0),
                                  _buildHeader(
                                    logs,
                                    filteredLogs.length,
                                    colors,
                                  ),
                                  if (searchValue.trim().isNotEmpty &&
                                      filteredLogs.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ValueListenableBuilder(
                                            valueListenable: currentMatchIndex,
                                            builder: (context, matchIdx, _) {
                                              final safeIdx = matchIdx.clamp(
                                                  0, filteredLogs.length - 1);
                                              return Text(
                                                "${safeIdx + 1}/${filteredLogs.length} matches found",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.orange,
                                                  fontFamily: 'Inter',
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 10),
                                          _buildNavButton(
                                            icon: Icons.keyboard_arrow_up,
                                            colors: colors,
                                            onPressed: () {
                                              if (filteredLogs.isEmpty) return;
                                              if (currentMatchIndex.value > 0) {
                                                currentMatchIndex.value--;
                                              } else {
                                                currentMatchIndex.value =
                                                    filteredLogs.length - 1;
                                              }
                                              _scrollToMatch();
                                            },
                                          ),
                                          const SizedBox(width: 4),
                                          _buildNavButton(
                                            icon: Icons.keyboard_arrow_down,
                                            colors: colors,
                                            onPressed: () {
                                              if (filteredLogs.isEmpty) return;
                                              if (currentMatchIndex.value <
                                                  filteredLogs.length - 1) {
                                                currentMatchIndex.value++;
                                              } else {
                                                currentMatchIndex.value = 0;
                                              }
                                              _scrollToMatch();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 6.0),
                                  ValueListenableBuilder(
                                    valueListenable: currentMatchIndex,
                                    builder: (context, activeIdx, _) {
                                      return PagesFloatingLogger(
                                        logsFiltered: filteredLogs,
                                        widgetItemBuilder:
                                            widget.widgetItemBuilder,
                                        searchQuery: searchValue,
                                        activeMatchIndex: searchValue.isEmpty
                                            ? -1
                                            : activeIdx,
                                        scrollController: scrollController,
                                        itemKeys: _itemKeys,
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required FloatingLoggerColors colors,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.navButtonBackground,
        border: Border.all(color: colors.navButtonBorder, width: 1.5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Icon(icon, size: 20, color: Colors.orange[700]),
          ),
        ),
      ),
    );
  }

  void _scrollToMatch() {
    final index = currentMatchIndex.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetKey = _itemKeys[index];
      if (targetKey?.currentContext != null) {
        Scrollable.ensureVisible(
          targetKey!.currentContext!,
          duration: const Duration(milliseconds: 250),
          curve: Curves.fastOutSlowIn,
          alignment: 0.0,
        );
      } else if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        final totalLogs = DioLogger.instance.logs.logsNotifier.value.length;
        final approxOffset =
            totalLogs > 1 ? (index / totalLogs) * maxScroll : 0.0;
        scrollController.jumpTo(approxOffset.clamp(0.0, maxScroll));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final retryKey = _itemKeys[index];
          if (retryKey?.currentContext != null) {
            Scrollable.ensureVisible(
              retryKey!.currentContext!,
              duration: const Duration(milliseconds: 250),
              curve: Curves.fastOutSlowIn,
              alignment: 0.0,
            );
          }
        });
      }
    });
  }

  @visibleForTesting
  void scrollToMatch() => _scrollToMatch();

  Widget _buildHeader(
    List<LogRepositoryModel> logs,
    int filterLength,
    FloatingLoggerColors colors,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.filter_list,
                color: colors.textSecondary,
              ),
              onPressed: () => _showFilterDialog(logs, colors),
              tooltip: "Detailed Filters",
            ),
            if (!isSearchActive) ...[
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: colors.textSecondary,
                ),
                onPressed: toggleSearch,
                tooltip: "Search Logs",
              ),
              if (filterLength > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue.withOpacity(0.85),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 8,
                      ),
                      child: Text(
                        'Logs: $filterLength',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          package: 'floating_logger',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
        if (isSearchActive)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: searchController,
                autofocus: true,
                onChanged: (value) {
                  searchQuery.value = value;
                  currentMatchIndex.value = 0;
                },
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  hintText: "Search logs (URL, header, JSON)...",
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    color: colors.textMuted,
                  ),
                  suffixIcon: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close,
                        size: 18, color: colors.textSecondary),
                    onPressed: toggleSearch,
                  ),
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  package: 'floating_logger',
                ),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                FloatingLoggerTheme.isDarkMode(context)
                    ? Icons.wb_sunny_outlined
                    : Icons.nightlight_round_outlined,
                color: colors.textSecondary,
                size: 20,
              ),
              tooltip: "Toggle Dark/Light Mode",
              onPressed: () => FloatingLoggerTheme.toggleTheme(context),
            ),
            IconButton(
              icon: ValueListenableBuilder<bool>(
                valueListenable: WebInspectorServer.instance.isRunningNotifier,
                builder: (context, isRunning, _) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.laptop_mac_rounded,
                        color: isRunning
                            ? const Color(0xFF3B82F6)
                            : colors.textSecondary,
                        size: 20,
                      ),
                      if (isRunning)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              tooltip: "Web Inspector (Desktop)",
              onPressed: () => _showWebInspectorDialog(colors),
            ),
            if (widget.isSimulationActive) _buildSpeedControl(colors),
            _buildClearButton(),
          ],
        ),
      ],
    );
  }

  void _showFilterDialog(
      List<LogRepositoryModel> logs, FloatingLoggerColors colors) {
    final List<FilterLabelModel> statusTypes = [
      const FilterLabelModel(title: 'REQUEST', color: Colors.grey),
      const FilterLabelModel(title: 'RESPONSE', color: Color(0xFF2563EB)),
      const FilterLabelModel(title: 'ERROR', color: Color(0xFFDC2626)),
    ];

    final List<FilterLabelModel> methodTypes = [
      const FilterLabelModel(title: 'GET', color: Color(0xFF16A34A)),
      const FilterLabelModel(title: 'POST', color: Color(0xFFEAB308)),
      const FilterLabelModel(title: 'PUT', color: Color(0xFF3B82F6)),
      const FilterLabelModel(title: 'PATCH', color: Color(0xFFA855F7)),
      const FilterLabelModel(title: 'DELETE', color: Color(0xFFEF4444)),
      const FilterLabelModel(title: 'OPTIONS', color: Color(0xFF8B5CF6)),
      const FilterLabelModel(title: 'HEAD', color: Color(0xFF0D9488)),
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.border, width: 1.2),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Logs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                          fontFamily: 'Inter',
                          package: 'floating_logger',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Filter logs by status or HTTP method',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                          fontFamily: 'Inter',
                          package: 'floating_logger',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 20, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<Set<String>>(
                valueListenable: activeFilters,
                builder: (context, filters, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'LOG TYPE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: colors.textSecondary,
                              fontFamily: 'Inter',
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: showAllLogs,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(
                                filters.isEmpty
                                    ? 'All Selected'
                                    : 'Reset Filters',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: filters.isEmpty
                                      ? colors.textSecondary
                                      : Colors.orange[700],
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: statusTypes.map((entry) {
                          final isSelected = filters.contains(entry.title);
                          final count = logs
                              .where((log) => log.type == entry.title)
                              .length;
                          return _buildFilterChip(
                            title: entry.title,
                            count: count,
                            color: entry.color,
                            isSelected: isSelected,
                            colors: colors,
                            onTap: () => toggleFilter(entry.title),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'HTTP METHOD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: colors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: methodTypes.map((entry) {
                          final isSelected = filters.contains(entry.title);
                          final count = logs
                              .where((log) => log.method == entry.title)
                              .length;
                          return _buildFilterChip(
                            title: entry.title,
                            count: count,
                            color: entry.color,
                            isSelected: isSelected,
                            colors: colors,
                            onTap: () => toggleFilter(entry.title),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String title,
    required int count,
    required Color color,
    required bool isSelected,
    required FloatingLoggerColors colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : colors.codeBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : colors.border,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 5),
                child: Icon(Icons.check, size: 14, color: Colors.white),
              )
            else
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              '$title ($count)',
              style: TextStyle(
                color: isSelected ? Colors.white : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(FloatingLoggerColors colors) {
    return Center(
      child: Container(
        width: 60,
        height: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colors.handleBar,
        ),
      ),
    );
  }

  Widget _buildSpeedControl(FloatingLoggerColors colors) {
    return ValueListenableBuilder<NetworkSimulation>(
      valueListenable: NetworkSimulator.instance.simulationNotifier,
      builder: (context, simulation, _) {
        return GestureDetector(
          onTap: () => _showSpeedDialog(colors),
          child: Container(
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: simulation == NetworkSimulation.normal
                    ? Colors.green
                    : Colors.orange,
              ),
              borderRadius: BorderRadius.circular(8),
              color: simulation == NetworkSimulation.normal
                  ? Colors.green.withOpacity(0.12)
                  : Colors.orange.withOpacity(0.12),
            ),
            child: Icon(
              _getSimulationIcon(simulation),
              size: 15,
              color: simulation == NetworkSimulation.normal
                  ? Colors.green
                  : Colors.orange,
            ),
          ),
        );
      },
    );
  }

  IconData _getSimulationIcon(NetworkSimulation simulation) {
    switch (simulation) {
      case NetworkSimulation.normal:
        return Icons.speed;
      case NetworkSimulation.slow3g:
        return Icons.network_check;
      case NetworkSimulation.offline:
        return Icons.wifi_off;
      case NetworkSimulation.socketError:
        return Icons.error_outline;
      case NetworkSimulation.serverError:
        return Icons.cloud_off;
      case NetworkSimulation.timeout:
        return Icons.timer_off;
    }
  }

  Color _getSimulationColor(NetworkSimulation simulation) {
    switch (simulation) {
      case NetworkSimulation.normal:
        return const Color(0xFF16A34A);
      case NetworkSimulation.slow3g:
        return const Color(0xFFEAB308);
      case NetworkSimulation.offline:
        return const Color(0xFFDC2626);
      case NetworkSimulation.socketError:
        return const Color(0xFFEF4444);
      case NetworkSimulation.serverError:
        return const Color(0xFF9333EA);
      case NetworkSimulation.timeout:
        return const Color(0xFF0284C7);
    }
  }

  String _getSimulationDescription(NetworkSimulation simulation) {
    switch (simulation) {
      case NetworkSimulation.normal:
        return "Standard device network speed";
      case NetworkSimulation.slow3g:
        return "Adds 2000ms latency to all requests";
      case NetworkSimulation.offline:
        return "Throws connection offline exception";
      case NetworkSimulation.socketError:
        return "Simulates socket connection refused";
      case NetworkSimulation.serverError:
        return "Simulates 500 internal server error";
      case NetworkSimulation.timeout:
        return "Simulates network timeout after delay";
    }
  }

  void _showSpeedDialog(FloatingLoggerColors colors) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.border, width: 1.2),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Network Simulation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                          fontFamily: 'Inter',
                          package: 'floating_logger',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Test app resilience under network profiles',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                          fontFamily: 'Inter',
                          package: 'floating_logger',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 20, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ValueListenableBuilder<NetworkSimulation>(
                valueListenable: NetworkSimulator.instance.simulationNotifier,
                builder: (context, activeSimulation, _) {
                  return Column(
                    children: NetworkSimulation.values.map((simulation) {
                      final isSelected = activeSimulation == simulation;
                      final simColor = _getSimulationColor(simulation);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            NetworkSimulator.instance.setSimulation(simulation);
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? simColor.withOpacity(0.12)
                                  : colors.codeBackground,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? simColor : colors.border,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: simColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getSimulationIcon(simulation),
                                    color: simColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        simulation.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSelected
                                              ? simColor
                                              : colors.textPrimary,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _getSimulationDescription(simulation),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colors.textSecondary,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: simColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWebInspectorDialog(FloatingLoggerColors colors) {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isRunning = WebInspectorServer.instance.isRunningNotifier.value;
          final serverUrl = WebInspectorServer.instance.serverUrl;
          final port = WebInspectorServer.instance.currentPort ??
              WebInspectorServer.defaultPort;

          return Dialog(
            backgroundColor: colors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: colors.border, width: 1.2),
            ),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                              color: const Color(0xFF3B82F6).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.laptop_mac_rounded,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Web Inspector",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                "Inspect logs on your computer",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textMuted,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 20, color: colors.textSecondary),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Server Status",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isRunning
                                  ? "Active & Streaming"
                                  : "Inactive (Stopped)",
                              style: TextStyle(
                                fontSize: 11,
                                color: isRunning
                                    ? const Color(0xFF10B981)
                                    : colors.textMuted,
                                fontWeight: isRunning
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isRunning,
                          activeColor: const Color(0xFF3B82F6),
                          onChanged: (val) async {
                            if (val) {
                              await WebInspectorServer.instance.start();
                            } else {
                              await WebInspectorServer.instance.stop();
                            }
                            setDialogState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  if (isRunning && serverUrl != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      "ACCESS URL",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              serverUrl,
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            label: const Text(
                              "Copy",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: serverUrl));
                              LoggerToast.successToast(
                                context,
                                "URL copied to clipboard!",
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wifi_rounded,
                                  size: 14, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Text(
                                "Wi-Fi Mode:",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Ensure your phone and computer are connected to the same Wi-Fi / Hotspot, then open the URL above in Google Chrome or Safari.",
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.usb_rounded,
                                  size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 6),
                              Text(
                                "USB Mode (If Wi-Fi is isolated):",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          SelectableText(
                            "adb reverse tcp:$port tcp:$port",
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'Courier',
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Then open http://localhost:$port in your computer's browser.",
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClearButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: () {
          DioLogger.instance.logs.clearLogs();
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.0,
              color: Colors.red,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.delete_outline,
            size: 15,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class FilterLabelModel {
  const FilterLabelModel({
    required this.title,
    required this.color,
  });
  final String title;
  final Color color;
}
