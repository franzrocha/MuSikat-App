import 'package:musikat_app/utils/exports.dart';

class MoodsScreen extends StatefulWidget {
  const MoodsScreen({Key? key}) : super(key: key);

  @override
  State<MoodsScreen> createState() => _MoodsScreenState();
}

class _MoodsScreenState extends State<MoodsScreen> {
  List<Map<String, dynamic>> roomDataList = [
    {
      "name": "Romance",
      "color": const Color.fromARGB(255, 70, 69, 68),
    },
    {
      "name": "Gaming",
      "color": const Color.fromARGB(255, 18, 40, 58),
    },
    {
      "name": "Sad",
      "color": const Color.fromARGB(255, 22, 22, 16),
    },
    {
      "name": "Happy",
      "color": const Color.fromARGB(255, 68, 18, 23),
    },
    {
      "name": "Relaxing",
      "color": const Color.fromARGB(255, 182, 111, 118),
    },
    {
      "name": "Studying",
      "color": const Color.fromARGB(255, 141, 38, 48),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomSliverBar(
            image: moodPic,
            title: 'Moods',
            caption: 'Let your mood guide your next listening choice.',
          ),
          SliverFillRemaining(
            child: GridView.count(
              crossAxisCount: 2,
              children: roomDataList.map((roomData) {
                final String roomName = roomData['name'];
                final Color roomColor = roomData['color'];
                return GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    height: 200,
                    child: Container(
                      height: 200,
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: roomColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            spreadRadius: 0.5,
                            offset: Offset(2.0, 2.0),
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roomName,
                            style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
