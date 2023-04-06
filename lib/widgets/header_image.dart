import 'package:flutter/material.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:transparent_image/transparent_image.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel>(
        stream: UserModel.fromUidStream(uid: uid),
        builder: (context, AsyncSnapshot<UserModel?> snap) {
          if (snap.error != null || !snap.hasData) {
            return Container();
          }
          if (snap.data!.headerImage.isEmpty) {
            return Container();
          } else if (snap.connectionState == ConnectionState.waiting) {
            return Container();
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
                 
                )
              ),
            );
          }
        });
  }

  Widget tempHeader(BuildContext context) {
    return Container(
      height: 150,
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
    );
  }
}
