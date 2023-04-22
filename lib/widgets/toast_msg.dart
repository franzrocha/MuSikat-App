import 'package:fluttertoast/fluttertoast.dart';
import 'package:musikat_app/utils/exports.dart';

class ToastMessage {
  static void show(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
