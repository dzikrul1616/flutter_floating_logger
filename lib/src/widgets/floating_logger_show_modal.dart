import '../pages/pages.dart';
import 'package:floating_logger/floating_logger.dart';
import 'package:floating_logger/src/network/network_model.dart';

class FloatingLoggerModalBottomWidget extends StatelessWidget {
  const FloatingLoggerModalBottomWidget({
    super.key,
    this.widgetItemBuilder,
  });

  final Widget Function(
    int index,
    List<LogRepositoryModel> data,
  )? widgetItemBuilder;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (
      BuildContext context,
      StateSetter setState,
    ) {
      return Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.9,
              child: ValueListenableBuilder<List<LogRepositoryModel>>(
                  valueListenable: DioLogger.instance.logs.logsNotifier,
                  builder: (context, logs, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHandle(),
                        const SizedBox(height: 20.0),
                        _buildHeader(logs),
                        const SizedBox(height: 10.0),
                        PagesFloatingLogger(
                          widgetItemBuilder: widgetItemBuilder,
                        ),
                      ],
                    );
                  }),
            ),
          ),
        ],
      );
    });
  }

  // Function to build the handle for the modal
  // This is the small gray bar at the top that users can use to drag the modal
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

  // Function to build the header row with the "Clear" button and the log count
  // This row contains a "Clear" button to clear the logs and a text displaying the total number of logs
  Widget _buildHeader(List<LogRepositoryModel> logs) {
    return Row(
      children: [
        _buildLenghtData(logs),
        _buildClearButton(),
      ],
    );
  }

  Widget _buildLenghtData(List<LogRepositoryModel> logs) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          '${logs.length} Request',
          style: GoogleFonts.inter(
            fontSize: 10.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Function to build the "Clear" button
  // When tapped, this button clears the log data
  Widget _buildClearButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: GestureDetector(
        onTap: () => DioLogger.instance.logs.clearLogs(),
        child: Container(
          width: 80,
          decoration: BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: Colors.red,
              ),
              borderRadius: BorderRadius.circular(12)),
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
