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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meet the Team.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'We are a group of passionate individuals who love music and technology. Our goal is to create an app that helps promote Filipino musicians to a wider audience.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 40),
                children: [
                  _DeveloperTile(
                      name: 'Franz Lesly Rocha',
                      role: 'Lead Developer',
                      description:
                          'Franz is an experienced mobile app developer who specializes in using Flutter to build high-quality, user-friendly apps. He has a passion for music and believes that the Musikat app can help promote Filipino musicians to a wider audience.',
                      photoUrl: 'assets/images/furanzu.jpg'),
                  _DeveloperTile(
                      name: 'Hazel Lopez',
                      role: 'UI/UX Designer',
                      description:
                          'Hazel is a talented designer who loves creating beautiful and intuitive interfaces that enhance the user experience. She worked closely with the development team to ensure that the Musikat app looks and feels great for users.',
                      photoUrl: 'assets/images/hazel.jpg'),
                  _DeveloperTile(
                      name: 'Fabian Miguel Canizares',
                      role: 'Marketing Specialist',
                      description:
                          'Fabian is a seasoned marketer with a keen eye for branding and promotion. He helped develop the marketing strategy for the Musikat app and continues to work closely with the team to ensure that it reaches as many Filipino musicians as possible.',
                      photoUrl: 'assets/images/fabian.jpg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeveloperTile extends StatelessWidget {
  const _DeveloperTile({
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
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xff353434),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20, left: 10), // add left padding
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  image: DecorationImage(
                    image: AssetImage(photoUrl), // updated image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 15),
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
