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
