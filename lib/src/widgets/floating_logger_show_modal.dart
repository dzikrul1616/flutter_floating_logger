import 'package:floating_logger/floating_logger.dart';

class FloatingLoggerModalBottomWidget extends StatelessWidget {
  const FloatingLoggerModalBottomWidget({
    super.key,
  });

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Container(
                        width: 100,
                        height: 5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          DioLogger.instance.logs.clearLogs();
                        },
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
                      ValueListenableBuilder<List<LogRepositoryModel>>(
                        valueListenable: DioLogger.instance.logs.logsNotifier,
                        builder: (context, logs, child) {
                          return Text(
                            'Total Data : ${logs.length}',
                            style: GoogleFonts.inter(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  ValueListenableBuilder<List<LogRepositoryModel>>(
                    valueListenable: DioLogger.instance.logs.logsNotifier,
                    builder: (context, logs, child) {
                      return PagesFloatingLogger(logs: logs);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
