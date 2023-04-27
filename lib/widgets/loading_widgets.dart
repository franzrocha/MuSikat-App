import 'package:musikat_app/utils/exports.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 64,
      height: 64,
      child: CircularProgressIndicator(
        backgroundColor: musikatColor2,
        valueColor: AlwaysStoppedAnimation(
          musikatColor,
        ),
        strokeWidth: 10,
      ),
    );
  }
}

class LoadingContainer extends StatelessWidget {
  const LoadingContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(left: 25, top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
          );
        },
      ),
    );
  }
}
