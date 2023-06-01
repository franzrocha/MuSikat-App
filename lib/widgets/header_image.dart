import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

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
                    image: CachedNetworkImageProvider(snap.data!.headerImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }
        });
  }

  Widget tempHeader(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(color: musikatColor4.withOpacity(0.5)),
      ),
    );
  }
}
