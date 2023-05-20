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
      width: 130,
      height: 130,
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

class LoadingCircularContainer extends StatelessWidget {
  const LoadingCircularContainer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  // color: Colors.grey[300],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
