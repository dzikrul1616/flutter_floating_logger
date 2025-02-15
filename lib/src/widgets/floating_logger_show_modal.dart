import '../pages/pages.dart';
import 'package:floating_logger/floating_logger.dart';
import 'package:floating_logger/src/network/network_model.dart';

class FloatingLoggerModalBottomWidget extends StatefulWidget {
  const FloatingLoggerModalBottomWidget({
    super.key,
    this.widgetItemBuilder,
  });

  final Widget Function(
    int index,
    List<LogRepositoryModel> data,
  )? widgetItemBuilder;

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
                          final matchesSearch = log.path!
                              .toLowerCase()
                              .contains(searchValue.toLowerCase());
                          final matchesFilter = filterValue.isEmpty ||
                              filterValue.contains(log.type) ||
                              filterValue.contains(log.method);
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
                            const SizedBox(height: 10.0),
                            PagesFloatingLogger(
                              logsFiltered: filteredLogs,
                              widgetItemBuilder: widget.widgetItemBuilder,
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

  Widget _buildHeader(
    List<LogRepositoryModel> logs,
    int filterLenght,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    var outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.black38),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: Colors.black54,
                  ),
                  onPressed: () => _showFilterDialog(logs),
                ),
                ValueListenableBuilder(
                  valueListenable: searchQuery,
                  builder: (context, query, _) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: isSearchActive
                          ? Row(
                              children: [
                                SizedBox(
                                  width: screenWidth < 550 && screenWidth >= 350
                                      ? 200
                                      : screenWidth < 350
                                          ? 100
                                          : 400,
                                  child: TextField(
                                    controller: searchController,
                                    onChanged: (value) =>
                                        searchQuery.value = value,
                                    decoration: InputDecoration(
                                        hintText: "Search logs...",
                                        suffixIcon: IconButton(
                                          icon: Icon(Icons.close,
                                              color: Colors.black54),
                                          onPressed: toggleSearch,
                                        ),
                                        focusedBorder: outlineInputBorder,
                                        border: outlineInputBorder),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                IconButton(
                                  key: ValueKey("searchIcon"),
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.black54,
                                  ),
                                  onPressed: toggleSearch,
                                ),
                                filterLenght == 0
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                        ),
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
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                    );
                  },
                ),
              ],
            ),
            _buildClearButton(),
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
      FilterLabelModel(title: 'POST', color: Color(0xffFFB700)),
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
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                      int logCount = logs
                          .where(
                            (log) =>
                                log.type == entry.title ||
                                log.method == entry.title,
                          )
                          .length;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: filters.contains(entry.title)
                              ? entry.color
                              : Colors.grey[200],
                        ),
                        onPressed: () => toggleFilter(entry.title),
                        child: Text(
                          '${entry.title} ($logCount)',
                          style: GoogleFonts.inter(
                            color: filters.contains(entry.title)
                                ? Colors.white
                                : Colors.black54,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.bold,
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

  Widget _buildClearButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: () {
          DioLogger.instance.logs.clearLogs();
          setState(() {});
        },
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.0,
              color: Colors.red,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text(
                "Clear",
                style: GoogleFonts.inter(
                  fontSize: 10.0,
                  color: Colors.red,
                ),
              ),
            ),
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
