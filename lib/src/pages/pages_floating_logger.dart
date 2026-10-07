import 'package:floating_logger/floating_logger.dart';
import '../widgets/widgets.dart';

/// A widget that displays a list of logs using a floating logger.
/// It listens to the logs from `DioLogger` and updates the UI accordingly.
class PagesFloatingLogger extends StatelessWidget {
  /// Constructor with an optional custom item builder for log items.
  const PagesFloatingLogger({
    super.key,
    this.widgetItemBuilder,
    this.logsFiltered,
    this.searchQuery = "",
    this.activeMatchIndex = -1,
    this.scrollController,
    this.itemKeys,
  });

  /// A function that allows custom rendering of each log item.
  final Widget Function(
    int index,
    List<LogRepositoryModel> data,
  )? widgetItemBuilder;
  final List<LogRepositoryModel>? logsFiltered;
  final String searchQuery;
  final int activeMatchIndex;
  final ScrollController? scrollController;
  final Map<int, GlobalKey>? itemKeys;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: (logsFiltered == null || logsFiltered!.isEmpty)
          ? _buildEmptyState(context)
          : _buildLogList(logsFiltered!),
    );
  }

  /// Builds a widget for an empty state when no logs are available.
  Widget _buildEmptyState(BuildContext context) {
    final colors = FloatingLoggerTheme.of(context);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.data_array,
            size: 48,
            color: colors.textSecondary.withOpacity(0.6),
          ),
          const SizedBox(height: 15),
          Text(
            "Data Not Found!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
              fontFamily: 'Inter',
              package: 'floating_logger',
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "You don't have any matching logs yet, make API calls or clear filters!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: colors.textSecondary,
                fontFamily: 'Inter',
                package: 'floating_logger',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a list of log items when logs are available.
  Widget _buildLogList(List<LogRepositoryModel> logs) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      itemCount: logs.length,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildLogItem(index, logs);
      },
    );
  }

  /// Builds a single log item based on its index and data.
  Widget _buildLogItem(int index, List<LogRepositoryModel> logs) {
    final key = itemKeys != null ? itemKeys![index] : null;
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 2),
      child: FloatingLoggerItem(
        index: index,
        data: logs[index],
        searchQuery: searchQuery,
        isActive: index == activeMatchIndex,
        child: widgetItemBuilder == null
            ? null
            : widgetItemBuilder!(index, logs),
      ),
    );
  }
}
