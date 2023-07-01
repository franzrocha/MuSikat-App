import 'package:cached_network_image/cached_network_image.dart';
import 'package:musikat_app/utils/exports.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool showLogo;
  final List<Widget>? actions;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar(
      {super.key,
      this.title,
      required this.showLogo,
      this.actions,
      this.centerTitle,
      this.bottom});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 70,
      title: (title != null) ? title : null,
      centerTitle: centerTitle,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      bottom: bottom,
      leading: showLogo
          ? Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Image.asset(
                "assets/images/musikat_logo.png",
                width: 30,
                height: 30,
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
    Key? key,
    required this.title,
    this.caption,
    this.image,
    this.linearGradient,
    this.actions,
    this.children,
  }) : super(key: key);

  final String title;
  final String? caption;
  final String? image;
  final LinearGradient? linearGradient;
  final List<Widget>? actions;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      actions: actions,
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
            image: image != null
                ? DecorationImage(
                    image: CachedNetworkImageProvider(image!),
                    fit: BoxFit.cover,
                  )
                : null,
            gradient: linearGradient,
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Gotham',
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    caption ?? "",
                    style: const TextStyle(
                      fontFamily: 'Gotham',
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: children ?? [],
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
