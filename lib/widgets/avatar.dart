// ignore_for_file: sort_child_properties_last
import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/utils/exports.dart';

class AvatarImage extends StatelessWidget {
  final String uid;
  final double radius;
  const AvatarImage({required this.uid, this.radius = 22, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
        stream: UserModel.fromUidStream(uid: uid),
        builder: (context, AsyncSnapshot<UserModel?> snap) {
          if (snap.error != null || !snap.hasData) {
            return tempProfile(context);  
          } else {
            if (snap.data!.profileImage.isEmpty) {
              return tempProfile(context);
            } else if (snap.connectionState == ConnectionState.waiting) {
              return tempProfile(context);
            } else {
              return FittedBox(
                child: CircleAvatar(
                  radius: radius,
                  backgroundImage: CachedNetworkImageProvider(snap.data!.profileImage),
                  
                ),
              );
            }
          }
        });
  }

  Widget tempProfile(BuildContext context) {
    return FittedBox(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white24,
       backgroundImage: CachedNetworkImageProvider(userIcon),
      ),
      
    );
  }
}
