import 'package:musikat_app/utils/ui_exports.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final List<Widget>? actions;

  const CustomAppBar({super.key, this.title, required this.showLogo, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 60,
      title: title != null
          ? Text(title!,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ))
          : null,
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
