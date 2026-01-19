import 'package:floating_logger/src/network/network_model.dart';
import 'package:floating_logger/floating_logger.dart';
import '../widgets/widgets.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: logsFiltered!.isEmpty
          ? _buildEmptyState(context) // Display empty state when no logs exist
          : _buildLogList(logsFiltered!),
    );
  }

  /// Builds a widget for an empty state when no logs are available.
  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.data_array,
            size: 40,
          ),
          const SizedBox(height: 15),
          Text(
            "Data Not Found!", // Message when no data is found
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Inter',
              package: 'floating_logger',
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            "You don't have any data yet, please refresh or add data first!", // Suggestion message
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
              fontFamily: 'Inter',
              package: 'floating_logger',
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
      itemCount: logsFiltered!.length, // Number of logs to display
      shrinkWrap: true, // Allows flexible sizing
      physics: const ScrollPhysics(), // Standard scroll behavior
      itemBuilder: (context, index) {
        return _buildLogItem(index, logsFiltered!);
      },
    );
  }

  /// Builds a single log item based on its index and data.
  Widget _buildLogItem(int index, List<LogRepositoryModel> logs) {
    return FloatingLoggerItem(
      index: index,
      data: logs[index],
      searchQuery: searchQuery,
      isActive: index == activeMatchIndex,
      child: widgetItemBuilder == null
          ? null // If no custom builder is provided, use default display
          : widgetItemBuilder!(index, logs),
    );
  }
}
