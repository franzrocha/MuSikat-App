import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/utils/exports.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool showLogo;
  final List<Widget>? actions;
  final bool? centerTitle;

  const CustomAppBar(
      {super.key,
      this.title,
      required this.showLogo,
      this.actions,
      this.centerTitle});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      title: (title != null) ? title : null,
      centerTitle: centerTitle,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: showLogo
          ? Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Image.asset(
                "assets/images/musikat_logo.png",
                width: 30,
                height: 35,
              ),
            )
          : IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const FaIcon(
                FontAwesomeIcons.angleLeft,
                size: 20,
              ),
            ),
      actions: actions ?? [],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class CustomSliverBar extends StatelessWidget {
  const CustomSliverBar({
    super.key,
    required this.image,
    required this.title,
    required this.caption,
  });

  final String image;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      // title: Text(
      //   title,
      //   style: const TextStyle(
      //     fontSize: 20,
      //     fontWeight: FontWeight.bold,
      //     color: Colors.white,
      //   ),
      // ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const FaIcon(
          FontAwesomeIcons.angleLeft,
          size: 20,
        ),
      ),
      backgroundColor: musikatBackgroundColor,
      floating: true,
      pinned: true,
      snap: true,
      expandedHeight: 200,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider(image),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 50,
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    caption,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
