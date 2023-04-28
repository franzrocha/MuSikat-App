import 'package:musikat_app/utils/exports.dart';

class GenresScreen extends StatefulWidget {
  const GenresScreen({Key? key}) : super(key: key);

  @override
  State<GenresScreen> createState() => _GenresScreenState();
}

class _GenresScreenState extends State<GenresScreen> {
  List<Map<String, dynamic>> genreData = [
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
              children: genreData.map((genre) {
                return SizedBox(
                  height: 200,
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 124, 131, 127),
                        width: 1.0,
                      ),
                      color: genre["color"],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(genre["name"],
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
