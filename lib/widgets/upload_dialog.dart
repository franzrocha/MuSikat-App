import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/utils/constants.dart';
import 'package:musikat_app/services/song_service.dart';

class UploadDialog extends StatelessWidget {
  const UploadDialog({
    Key? key,
    required this.songService,
  }) : super(key: key);

  final SongService songService;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Uploading...",
        style: GoogleFonts.inter(fontSize: 18),
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
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(musikatColor),
                  backgroundColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 10.0),
                Text('${uploadPercent.toStringAsFixed(0)}% uploaded'),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {
                    songService.cancelUpload();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
