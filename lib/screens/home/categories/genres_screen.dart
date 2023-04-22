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
      "lights": "4 Lights",
      "color": const Color.fromARGB(255, 70, 69, 68),
    },
    {
      "name": "Living room",
      "lights": "2 Lights",
      "color": Colors.blue[100],
    },
    {
      "name": "Livinedasg room",
      "lights": "2 Lights",
      "color": Colors.yellow[100],
    },
    {
      "name": "Livinedasg room",
      "lights": "2 Lights",
      "color": Colors.red[100],
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Genres',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: GridView.count(
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
                  Text(roomData["name"],
                      style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  Text(roomData["lights"],
                      style: const TextStyle(
                          fontSize: 18.0, color: Colors.orange)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
