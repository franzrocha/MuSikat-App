import 'package:musikat_app/utils/exports.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Text(
                    'Meet the Team.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'We are a group of passionate individuals who love music and technology. Our goal is to create an app that helps promote Filipino musicians to a wider audience.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            const DeveloperTile(
                name: 'Franz Lesly Rocha',
                role: 'Lead Developer',
                description:
                    'Franz is a mobile app developer who specializes in using Flutter to build high-quality, user-friendly apps. He has a passion for music and believes that the Musikat app can help promote Filipino musicians to a wider audience.',
                photoUrl: 'assets/images/furanzu.jpg'),
            const DeveloperTile(
                name: 'Fabian Miguel Canizares',
                role: 'Software Developer',
                description:
                    'Fabian is a mobile app developer who also happens to be a music enthusiast. He has a creative approach to problem-solving and enjoys brainstorming innovative solutions with his team. In addition to his technical skills, Fabian is also a great communicator and collaborator, making him a valuable asset of the team.',
                photoUrl: 'assets/images/fabian.jpg'),
            const DeveloperTile(
                name: 'Hazel Lopez',
                role: 'UI/UX Designer',
                description:
                    'Hazel is a talented designer who loves creating beautiful and intuitive interfaces that enhance the user experience. She worked closely with the development team to ensure that the Musikat app looks and feels great for users.',
                photoUrl: 'assets/images/hazel.jpg'),
          ],
        ),
      ),
    );
  }
}

class DeveloperTile extends StatelessWidget {
  const DeveloperTile({
    Key? key,
    required this.name,
    required this.role,
    required this.description,
    required this.photoUrl,
  }) : super(key: key);

  final String name;
  final String role;
  final String description;
  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: const Color(0xff353434),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 10),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  image: DecorationImage(
                    image: AssetImage(photoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
