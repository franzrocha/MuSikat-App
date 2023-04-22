import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/services/image_service.dart';
import 'package:musikat_app/utils/exports.dart';

class EditHubScreen extends StatefulWidget {
  const EditHubScreen({super.key});

  @override
  State<EditHubScreen> createState() => _EditHubScreenState();
}

class _EditHubScreenState extends State<EditHubScreen> {
  final TextEditingController _usernameCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        title: Text(
          'Edit Hub',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        showLogo: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  children: [
                    HeaderImage(uid: FirebaseAuth.instance.currentUser!.uid),
                    InkWell(
                      onTap: () => ImageService.updateHeaderImage(context),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white.withOpacity(0.8),
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                    profilePic(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: usernameForm(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  CustomTextField usernameForm() {
    return CustomTextField(
      obscureText: false,
      controller: _usernameCon,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else if (value.length < 3) {
          return 'Username must be more than 3 characters';
        } else if (value.length > 25) {
          return 'Username must not exceed to more than 25 characters';
        } else {
          return null;
        }
      },
      hintText: "Username",
      prefixIcon: const Icon(Icons.person_pin_circle),
    );
  }

  Align profilePic() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 30, bottom: 10),
        child: InkWell(
          onTap: () {
            ImageService.updateProfileImage(context);
          },
          child: Stack(
            children: [
              SizedBox(
                width: 100,
                height: 120,
                child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
              ),
              Positioned(
                left: 35,
                top: 45,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white.withOpacity(0.8),
                  size: 35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
