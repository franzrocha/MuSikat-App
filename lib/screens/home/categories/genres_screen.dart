import 'package:musikat_app/utils/exports.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({Key? key}) : super(key: key);

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  List<Map<String, dynamic>> roomDataList = [
    {
      "name": "Bed room",
      "color": const Color.fromARGB(255, 70, 69, 68),
    },
    {
      "name": "Living room",
      "color": Colors.blue[100],
    },
    {
      "name": "Living room",
      "color": Colors.yellow[100],
    },
    {
      "name": "Living room",
      "color": Colors.red[100],
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      body: CustomScrollView(
        slivers: [
          CustomSliverBar(
            image: genrePic,
            title: 'Genres',
            caption: 'All genres that might suit your taste.',
          ),
          SliverFillRemaining(
            child: GridView.count(
              crossAxisCount: 2,
              children: roomDataList.map((roomData) {
                return SizedBox(
                  height: 200,
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: roomData["color"],
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
                        Text(roomData["name"],
                            style: const TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
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
