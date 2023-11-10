import 'package:musikat_app/utils/exports.dart';

class SupportBadgeWidget extends StatelessWidget {
  const SupportBadgeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Tooltip(
      showDuration: Duration(seconds: 5),
      decoration: BoxDecoration(
        color: Color(0xffD9D9D9),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: EdgeInsets.all(20),
      triggerMode: TooltipTriggerMode.tap,
      richMessage: TextSpan(
        children: [
          TextSpan(
            text: 'Support Badge Guidelines\n',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: '\nBoost Your Favorite Artist, Earn Recognition Badges!\n',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          TextSpan(
            text:
                '\n₱100 - ₱200 for a weekly badge.\n₱201 - ₱500 for a monthly badge.\n₱501 - 1,500 for an annual badge.',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
      child: Icon(Icons.info_outline),
    );
  }
}
