import 'package:floating_logger/floating_logger.dart';

class PagesFloatingLogger extends StatelessWidget {
  const PagesFloatingLogger({
    super.key,
    required this.logs,
  });
  final List<LogRepositoryModel> logs;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: logs.isEmpty
          ? const FloatingLoggerEmpty()
          : ListView.builder(
              itemCount: logs.length,
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemBuilder: (context, index) {
                return FloatingLoggerItem(
                  data: logs[index],
                  index: index,
                );
              },
            ),
    );
  }
}

class FloatingLoggerEmpty extends StatelessWidget {
  const FloatingLoggerEmpty({
    super.key,
    this.title,
    this.width = 100,
    this.size = 16,
    this.isTitle = false,
  });
  final String? title;
  final double? width;
  final double size;
  final bool isTitle;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.data_array,
          size: 40,
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          "Data Tidak Ditemukan!",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: size,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Text(
          isTitle
              ? title!
              : "Anda belum memiliki data, silahkan refresh atau tambah data terlebih dahulu!",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: size - 2,
            fontWeight: FontWeight.normal,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
