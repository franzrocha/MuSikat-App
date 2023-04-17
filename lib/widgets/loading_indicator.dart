
import 'package:musikat_app/utils/ui_exports.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          backgroundColor: musikatColor2,
          valueColor: AlwaysStoppedAnimation(
            musikatColor,
          ),
          strokeWidth: 10,
        ));
  }
}
