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
        _buildTitleText(title),
        _buildColonText(),
        const SizedBox(width: 5.0),
        _buildDataText(data),
      ],
    );
  }

  // Function to build the title text widget
  Widget _buildTitleText(String title) {
    return SizedBox(
      width: 70,
      child: Text(
        title,
        style: GoogleFonts.inter(fontWeight: FontWeight.normal),
      ),
    );
  }

  // Function to build the colon text widget
  Widget _buildColonText() {
    return Text(
      ':',
      style: GoogleFonts.inter(fontWeight: FontWeight.normal),
    );
  }

  // Function to build the data text widget
  Widget _buildDataText(String data) {
    return Expanded(
      child: Text(
        data,
        style: GoogleFonts.inter(fontWeight: FontWeight.normal),
      ),
    );
  }
}
