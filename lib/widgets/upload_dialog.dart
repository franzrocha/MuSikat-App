import 'package:musikat_app/services/song_service.dart';
import 'package:musikat_app/utils/ui_exports.dart';

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
