import 'package:floating_logger/floating_logger.dart';

class FloatingLoggerRowText extends StatelessWidget {
  const FloatingLoggerRowText({
    super.key,
    required this.data,
    required this.title,
  });

  final String title;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Text(
          ':',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(
          width: 5.0,
        ),
        Expanded(
          child: Text(
            data,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
