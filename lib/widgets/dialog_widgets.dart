import 'package:musikat_app/services/song_service.dart';
import 'package:musikat_app/utils/exports.dart';

class UploadDialog extends StatelessWidget {
  const UploadDialog({
    Key? key,
    required this.songService,
  }) : super(key: key);

  final SongService songService;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          "Uploading",
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      content: StreamBuilder<double>(
        stream: songService.uploadProgressStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          } else {
            final double uploadPercent = snapshot.data!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: uploadPercent / 100,
                  valueColor: const AlwaysStoppedAnimation<Color>(musikatColor),
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 10.0),
                Text(
                  '${uploadPercent.toStringAsFixed(0)}% uploaded',
                  style: GoogleFonts.inter(fontSize: 15),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    songService.cancelUpload();
                    Navigator.of(context).pop();
                  },
                  style: ButtonStyle(
                    overlayColor:
                        MaterialStateProperty.all(Colors.grey.shade300),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: Colors.black),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class SliderDialog extends StatelessWidget {
  final String title;
  final int divisions;
  final double min;
  final double max;
  final String valueSuffix;
  final double value;
  final Stream<double> stream;
  final ValueChanged<double> onChanged;
  final BuildContext context;

  const SliderDialog({
    super.key,
    required this.title,
    required this.divisions,
    required this.min,
    required this.max,
    this.valueSuffix = '',
    required this.value,
    required this.stream,
    required this.onChanged, required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
       shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // Set border radius
      ),
      backgroundColor: musikatBackgroundColor,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text(
                '${((snapshot.data ?? value) * 100).toStringAsFixed(0)}%$valueSuffix',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
