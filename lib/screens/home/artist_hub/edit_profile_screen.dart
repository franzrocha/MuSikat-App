import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/services/image_service.dart';
import 'package:musikat_app/utils/exports.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});
  final UserModel user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController? _usernameCon, _lastNameCon, _firstNameCon;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameCon = TextEditingController(text: widget.user.username);
    _lastNameCon = TextEditingController(text: widget.user.lastName);
    _firstNameCon = TextEditingController(text: widget.user.firstName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: musikatBackgroundColor,
      appBar: CustomAppBar(
        title: Text(
          'Edit Profile',
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
              Form(
                onChanged: () {
                  _formKey.currentState?.validate();
                  if (mounted) {
                    setState(() {});
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username', style: shortThinStyle),
                        usernameForm(),
                        const SizedBox(height: 15),
                        Text('Last name', style: shortThinStyle),
                        lastNameForm(),
                        const SizedBox(height: 15),
                        Text('First name', style: shortThinStyle),
                        firstNameForm()
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: musikatColor,
        onPressed: () {
          String newUsername = _usernameCon!.text.trim();
          String newLastName = _lastNameCon!.text.trim();
          String newFirstName = _firstNameCon!.text.trim();

          if (widget.user.username == newUsername &&
              widget.user.lastName == newLastName &&
              widget.user.firstName == newFirstName) {
            ToastMessage.show(context, 'User details are already up to date');
          } else {
            widget.user
                .updateProfile(newUsername, newLastName, newFirstName)
                .then((value) {
              ToastMessage.show(context, 'User profile updated successfully');
              Navigator.pop(context);
            }).catchError((error) {
              ToastMessage.show(context, 'Error updating user profile $error');
            });
          }
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

  CustomTextField firstNameForm() {
    return CustomTextField(
      hintText: 'First Name',
      controller: _firstNameCon,
      obscureText: false,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else {
          return null;
        }
      },
      prefixIcon: const Icon(Icons.label_important),
    );
  }

  CustomTextField lastNameForm() {
    return CustomTextField(
      hintText: 'Last Name',
      controller: _lastNameCon,
      obscureText: false,
      validator: (value) {
        if (value!.isEmpty) {
          return null;
        } else {
          return null;
        }
      },
      prefixIcon: const Icon(Icons.label),
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
                width: 120,
                height: 120,
                child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
              ),
              Positioned(
                left: 45,
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
