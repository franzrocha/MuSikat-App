import 'package:musikat_app/utils/exports.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({Key? key}) : super(key: key);

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  List<Map<String, dynamic>> roomDataList = [
    {
      "name": "Tagalog",
      "color": const Color.fromARGB(255, 97, 55, 13),
    },
    {
      "name": "English",
      "color": const Color.fromARGB(255, 47, 50, 53),
    },
    {
      "name": "Waray",
      "color": const Color.fromARGB(255, 54, 54, 3),
    },
    {
      "name": "Cebuano",
      "color": const Color.fromARGB(255, 158, 4, 20),
    },
    {
      "name": "Ilonggo",
      "color": const Color.fromARGB(255, 65, 18, 128),
    },
    {
      "name": "Ilokano",
      "color": const Color.fromARGB(255, 11, 102, 31),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
           slivers: [
          CustomSliverBar(
            image: languagePic,
            title: 'Languages',
            caption: 'Expand your music horizons with ethno-languages from the Philippines.',
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
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
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
                      Text(roomName,
                          style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],),);
  }
}
