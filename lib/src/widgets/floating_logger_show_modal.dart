import '../pages/pages.dart';
import 'package:floating_logger/floating_logger.dart';
import 'package:floating_logger/src/network/network_model.dart';

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
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.9,
            child: ValueListenableBuilder(
              valueListenable: searchQuery,
              builder: (context, searchValue, _) {
                return ValueListenableBuilder(
                  valueListenable: activeFilters,
                  builder: (context, filterValue, __) {
                    return ValueListenableBuilder(
                      valueListenable: DioLogger.instance.logs.logsNotifier,
                      builder: (context, logs, ___) {
                        List<LogRepositoryModel> filteredLogs =
                            logs.where((log) {
                          final hasTypeFilter = filterValue.contains(log.type);
                          final hasMethodFilter =
                              filterValue.contains(log.method);

                          final selectedTypes = filterValue
                              .where((f) =>
                                  ["REQUEST", "RESPONSE", "ERROR"].contains(f))
                              .toSet();
                          final selectedMethods =
                              filterValue.difference(selectedTypes);
                          final q = searchValue.toLowerCase();
                          final matchesSearch = log.path!
                                  .toLowerCase()
                                  .contains(q) ||
                              (log.data?.toLowerCase().contains(q) ?? false) ||
                              (log.responseData?.toLowerCase().contains(q) ??
                                  false) ||
                              (log.queryparameter?.toLowerCase().contains(q) ??
                                  false) ||
                              (log.header?.toLowerCase().contains(q) ??
                                  false) ||
                              (log.message?.toLowerCase().contains(q) ?? false);

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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHandle(),
                            const SizedBox(height: 20.0),
                            _buildHeader(
                              logs,
                              filteredLogs.length,
                            ),
                            if (searchValue.isNotEmpty &&
                                filteredLogs.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: currentMatchIndex,
                                      builder: (context, matchIdx, _) {
                                        return Text(
                                          "${matchIdx + 1}/${filteredLogs.length} matches found",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange,
                                            fontFamily: 'Inter',
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    _buildNavButton(
                                      icon: Icons.keyboard_arrow_up,
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
                            const SizedBox(height: 10.0),
                            ValueListenableBuilder(
                              valueListenable: currentMatchIndex,
                              builder: (context, activeIdx, _) {
                                return PagesFloatingLogger(
                                  logsFiltered: filteredLogs,
                                  widgetItemBuilder: widget.widgetItemBuilder,
                                  searchQuery: searchValue,
                                  activeMatchIndex:
                                      searchValue.isEmpty ? -1 : activeIdx,
                                  scrollController: scrollController,
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
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange.withOpacity(0.8), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
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
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 24, color: Colors.orange[800]),
          ),
        ),
      ),
    );
  }

  void _scrollToMatch() {
    final index = currentMatchIndex.value;
    if (scrollController.hasClients) {
      scrollController.animateTo(
        index *
            100.0, // Refined estimation of item height during collapsed transition
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildHeader(
    List<LogRepositoryModel> logs,
    int filterLenght,
  ) {
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black38),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: Colors.black54,
              ),
              onPressed: () => _showFilterDialog(logs),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ValueListenableBuilder(
                    valueListenable: searchQuery,
                    builder: (context, query, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isSearchActive
                            ? SizedBox(
                                key: const ValueKey("searchFieldBox"),
                                width: constraints.maxWidth,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: searchController,
                                          onChanged: (value) {
                                            searchQuery.value = value;
                                            currentMatchIndex.value = 0;
                                          },
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 12),
                                            hintText: "Search logs...",
                                            hintStyle: const TextStyle(
                                                fontSize: 13,
                                                fontFamily: 'Inter'),
                                            suffixIcon: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.close,
                                                  size: 20,
                                                  color: Colors.black54),
                                              onPressed: toggleSearch,
                                            ),
                                            focusedBorder: outlineInputBorder,
                                            border: outlineInputBorder,
                                          ),
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                              fontFamily: 'Inter',
                                              package: 'floating_logger'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey("searchIconBox"),
                                width: constraints.maxWidth,
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.search,
                                        color: Colors.black54,
                                      ),
                                      onPressed: toggleSearch,
                                    ),
                                    if (filterLenght > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.blue[300],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              'Total Data : $filterLenght',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                                package: 'floating_logger',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                if (widget.isSimulationActive) _buildSpeedControl(),
                _buildClearButton(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _showFilterDialog(List<LogRepositoryModel> logs) {
    final List<FilterLabelModel> logTypes = [
      FilterLabelModel(title: 'REQUEST', color: Colors.grey),
      FilterLabelModel(title: 'RESPONSE', color: Colors.blue),
      FilterLabelModel(title: 'ERROR', color: Colors.red),
      FilterLabelModel(title: 'GET', color: Colors.green),
      FilterLabelModel(title: 'POST', color: const Color(0xffFFB700)),
      FilterLabelModel(title: 'PUT', color: Colors.blue),
      FilterLabelModel(title: 'PATCH', color: Colors.purpleAccent),
      FilterLabelModel(title: 'OPTIONS', color: Colors.purple),
      FilterLabelModel(title: 'HEAD', color: Colors.greenAccent),
      FilterLabelModel(title: 'DELETE', color: Colors.red),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Logs',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: activeFilters,
            builder: (context, filters, _) {
              return ListView(
                shrinkWrap: true,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          filters.isEmpty ? Colors.white : Colors.white30,
                    ),
                    onPressed: showAllLogs,
                    child: Text(
                      'SHOW ALL',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: logTypes.map((entry) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: filters.contains(entry.title)
                              ? entry.color
                              : Colors.grey[200],
                        ),
                        onPressed: () => toggleFilter(entry.title),
                        child: Text(
                          '${entry.title} (${logs.where((log) => log.type == entry.title || log.method == entry.title).length})',
                          style: TextStyle(
                            color: filters.contains(entry.title)
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 100,
        height: 5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildSpeedControl() {
    return ValueListenableBuilder<NetworkSimulation>(
      valueListenable: NetworkSimulator.instance.simulationNotifier,
      builder: (context, simulation, _) {
        return GestureDetector(
          onTap: () => _showSpeedDialog(),
          child: Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: simulation == NetworkSimulation.normal
                    ? Colors.green
                    : Colors.orange,
              ),
              borderRadius: BorderRadius.circular(8),
              color: simulation == NetworkSimulation.normal
                  ? const Color.fromARGB(45, 125, 255, 129)
                  : const Color.fromARGB(31, 255, 153, 0),
            ),
            child: Row(
              children: [
                Icon(
                  _getSimulationIcon(simulation),
                  size: 16,
                  color: simulation == NetworkSimulation.normal
                      ? Colors.green
                      : Colors.orange,
                ),
                if (simulation != NetworkSimulation.normal) ...[
                  const SizedBox(width: 4),
                  Text(
                    simulation.label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ],
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

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Network Simulation',
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              package: 'floating_logger'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: NetworkSimulation.values.map((simulation) {
            return ListTile(
              title: Text(simulation.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontFamily: 'Inter')),
              leading: Icon(
                _getSimulationIcon(simulation),
                color: Colors.blue,
              ),
              onTap: () {
                NetworkSimulator.instance.setSimulation(simulation);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: () {
          DioLogger.instance.logs.clearLogs();
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.0,
              color: Colors.red,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.delete_outline,
            size: 16,
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
