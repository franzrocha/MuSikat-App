import 'package:firebase_auth/firebase_auth.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/donations_feature/controllers/wallet_transaction_controller.dart';
import 'package:musikat_app/utils/exports.dart';

class ListOfAllSupportersScreen extends StatelessWidget {
  ListOfAllSupportersScreen({super.key});

  final WalletTransactionService walletService = WalletTransactionService();
  final currentUser = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Supporters',
                style: appBarStyle,
              ),
            ),
          ],
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: FutureBuilder<List<String>>(
        future: walletService.getArtistThatSupportedMe(currentUser),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final supported = snapshot.data!;
            final supportedCount = supported.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Color(0xff353434),
                  ),
                  child: Text(
                    'List of all your supporters: $supportedCount',
                    style: shortDefault.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: supportedCount,
                    itemBuilder: (BuildContext context, int index) {
                      final artistThatSupportedMe = supported[index];
                      return FutureBuilder<UserModel>(
                        future: UserModel.fromUid(uid: artistThatSupportedMe),
                        builder: (BuildContext context,
                            AsyncSnapshot<UserModel> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final user = snapshot.data!;
                            return ListTile(
                              title: Row(
                                children: [
                                  Text(
                                    (index + 1).toString(),
                                    style: sloganStyle.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const AvatarImage(
                                    uid: 'uid',
                                    radius: 20,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    user.username,
                                    style: shortDefault.copyWith(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
