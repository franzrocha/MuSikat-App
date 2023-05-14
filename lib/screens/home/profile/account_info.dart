import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/controllers/auth_controller.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/service_locators.dart';
import 'package:musikat_app/utils/exports.dart';
import 'package:intl/intl.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({Key? key}) : super(key: key);

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final AuthController _auth = locator<AuthController>();
  UserModel? user;

  @override
  void initState() {
    UserModel.fromUid(uid: _auth.currentUser!.uid).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'Account info',
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                profilePic(context),
                const SizedBox(height: 20),
                TileList(
                  icon: Icons.person,
                  title: 'Name',
                  subtitle: '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                ),
                TileList(
                  icon: Icons.person_pin,
                  title: 'Username',
                  subtitle: user?.username ?? '',
                ),
                TileList(
                  icon: Icons.email,
                  title: 'Email',
                  subtitle: user?.email ?? '',
                ),
                TileList(
                  icon: Icons.numbers,
                  title: 'Age',
                  subtitle: user?.age ?? '',
                ),
                TileList(
                  icon: FontAwesomeIcons.marsAndVenus,
                  title: 'Gender',
                  subtitle: user?.gender ?? '',
                ),
                TileList(
                  icon: FontAwesomeIcons.calendar,
                  title: 'Account created',
                  subtitle: user?.created == null
                      ? "..."
                      : DateFormat("MMMM dd, yyyy").format(
                          user!.created.toDate(),
                        ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding profilePic(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Stack(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
        ],
      ),
    );
  }
}
