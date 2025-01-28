import 'package:floating_logger/floating_logger.dart';

class FloatingLoggerControl extends StatefulWidget {
  const FloatingLoggerControl({
    super.key,
    required this.child,
    this.isShow,
    this.getPreference = true,
  });
  final Widget child;
  final ValueNotifier<bool>? isShow;
  final bool getPreference;

  @override
  State<FloatingLoggerControl> createState() => _FloatingLoggerControlState();
}

class _FloatingLoggerControlState extends State<FloatingLoggerControl> {
  bool? isShow = true;
  Offset position = const Offset(10, 100);

  Future<void> getShow() async {
    setState(() {
      isShow = widget.getPreference;
    });
  }

  @override
  void initState() {
    if (widget.getPreference) getShow();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool showWidget = widget.isShow == null
        ? isShow!
        : widget.getPreference
            ? isShow!
            : widget.isShow!.value;
    return Stack(
      children: [
        widget.child,
        if (showWidget)
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable(
              feedback: _buildFloatingActionButton(),
              childWhenDragging: const SizedBox.shrink(),
              onDragEnd: (details) {
                setState(() {
                  position = details.offset;
                });
              },
              child: _buildFloatingActionButton(),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      mouseCursor: MouseCursor.uncontrolled,
      autofocus: true,
      tooltip: "Debug API",
      backgroundColor: const Color.fromARGB(255, 77, 159, 226),
      onPressed: () => showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
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
                      Center(
                        child: Container(
                          width: 100,
                          height: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
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
                          ValueListenableBuilder<List<LogRepositoryModel>>(
                            valueListenable:
                                DioLogger.instance.logs.logsNotifier,
                            builder: (context, logs, child) {
                              return Text(
                                'Total Data : ${logs.length}',
                                style: GoogleFonts.inter(),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
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
        },
      ),
      child: const Icon(
        Icons.code_rounded,
        color: Colors.white,
      ),
    );
  }
}
