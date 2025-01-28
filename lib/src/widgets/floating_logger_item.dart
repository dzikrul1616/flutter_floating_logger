import 'package:floating_logger/floating_logger.dart';

class FloatingLoggerItem extends StatelessWidget {
  const FloatingLoggerItem({
    super.key,
    required this.data,
    required this.index,
  });

  final LogRepositoryModel data;
  final int index;
  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> isExpand = ValueNotifier(true);
    return ValueListenableBuilder(
        valueListenable: isExpand,
        builder: (context, value, child) {
          return GestureDetector(
            onLongPress: () => data.curl!.isEmpty
                ? CustomToast.showError(
                    "Gagal menyalin, Tidak ada data ",
                    context: context,
                  )
                : FlutterClipboard.copy(data.curl!).then((value) {
                    CustomToast.showSuccess(
                      "Berhasil mengcopy curl data",
                      // ignore: use_build_context_synchronously
                      context: context,
                    );
                  }),
            onTap: () => isExpand.value = !value,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0xffeaeaea),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Color(0xffeaeaea),
                      blurRadius: 4,
                      offset: Offset(-4, 0),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(
                          '${index + 1}. ',
                          style: GoogleFonts.inter(),
                        ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '[${data.type}]',
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                data.response!.isEmpty
                                                    ? ''
                                                    : '[${data.response}]',
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          data.type == 'Request'
                                              ? const SizedBox.shrink()
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    color: data.type == 'Response' ||
                                                            data.response ==
                                                                "200" ||
                                                            data.response ==
                                                                "201" ||
                                                            data.response ==
                                                                "202"
                                                        ? Colors.green
                                                        : data.type ==
                                                                    'Error' ||
                                                                data.response ==
                                                                    "500" ||
                                                                data.response ==
                                                                    "203" ||
                                                                data.response ==
                                                                    "404"
                                                            ? Colors.red
                                                            : Colors.yellow,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    child: Text(
                                                      data.type == 'Response' ||
                                                              data.response ==
                                                                  "200" ||
                                                              data.response ==
                                                                  "201" ||
                                                              data.response ==
                                                                  "202"
                                                          ? "Success"
                                                          : data.type ==
                                                                      'Error' ||
                                                                  data.response ==
                                                                      "500" ||
                                                                  data.response ==
                                                                      "203" ||
                                                                  data.response ==
                                                                      "404"
                                                              ? "Error"
                                                              : "Unkown",
                                                      style: GoogleFonts.inter(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5.0,
                                      ),
                                      Text(
                                        data.path!,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  value
                                      ? Icons.arrow_drop_down_sharp
                                      : Icons.arrow_drop_up_sharp,
                                  color: Colors.grey[700],
                                ),
                              ],
                            ),
                            value
                                ? const SizedBox.shrink()
                                : Column(
                                    children: [
                                      const Divider(
                                        thickness: 1,
                                        color: Colors.white,
                                      ),
                                      data.type == "Request"
                                          ? FloatingLoggerRowText(
                                              title: 'Param',
                                              data: data.queryparameter!,
                                            )
                                          : const SizedBox.shrink(),
                                      data.type == "Request"
                                          ? const SizedBox.shrink()
                                          : FloatingLoggerRowText(
                                              title: 'Message',
                                              data: data.message!,
                                            ),
                                      FloatingLoggerRowText(
                                        title: 'Data',
                                        data: data.type == "Request"
                                            ? data.data!
                                            : data.responseData!,
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
