import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/ui_exports.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
        stream: UserModel.fromUidStream(uid: uid),
        builder: (context, AsyncSnapshot<UserModel?> snap) {
          if (snap.error != null || !snap.hasData) {
            return tempHeader(context);
          }
          if (snap.data!.headerImage.isEmpty) {
            return tempHeader(context);
          } else if (snap.connectionState == ConnectionState.waiting) {
            return tempHeader(context);
          } else {
            return SizedBox(
              height: 150,
              width: double.infinity,
              child: Container(
                  decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(snap.data!.headerImage),
                  fit: BoxFit.cover,
                ),
              )),
            );
          }
        });
  }

  Widget tempHeader(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: musikatBackgroundColor.withOpacity(0.5),
      ),
    );
  }
}
