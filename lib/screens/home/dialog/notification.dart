
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/controllers/firebase_service.dart';
import 'package:musikat_app/controllers/user_notification_controller.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import '../../../utils/exports.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _State();
}

class _State extends State<NotificationDialog> {
  static final firebaseService = FirebaseService();
  static final userNotificationController = UserNotificationController();

  static final currentUserId = firebaseService.getCurrentUserId();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userNotification')
            .where('following', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var notificationsData = snapshot.data!.docs;

            notificationsData.sort((a, b) {
              Timestamp timestampA = a['timestamp'];
              Timestamp timestampB = b['timestamp'];
              return timestampB.compareTo(timestampA);
            });

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notificationsData.length,
              itemBuilder: (context, index) {
                var notification = notificationsData[index];
                var followerId = notification['follower'];
                var followingId = notification['following'];
                Timestamp dateNotified = notification['timestamp'];
                String timeAgo =
                    userNotificationController.getTimeAgo(dateNotified);
                int notifiedUSer;

                final DateTime date = dateNotified.toDate();
                final DateFormat formatter = DateFormat(
                    'MMM-dd-yyyy:hh:ss'); // Define your desired date format
                final String formattedDate =
                    formatter.format(date); 

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('uid', isEqualTo: followerId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var usersData = snapshot.data!.docs;

                      if (usersData.isNotEmpty) {
                        var user = usersData.first;
                        var userFollowerId = user['uid'];
                        var firstname = user['firstName'];
                        var lastname = user['lastName'];
                        var profile = user['profileImage'];
                        var fullName = '$firstname $lastname';
                        var getFirstLetter = firstname.isNotEmpty
                            ? firstname[0].toUpperCase()
                            : '';

                        notifiedUSer = notification['notify'];

                        print('dateNotified');
                        print(timeAgo);

                        return ListTile(
                          enabled: notifiedUSer == 1 ? true : false,
                          onTap: () {
                            userNotificationController.updateNotificationState(
                                userFollowerId, followingId);
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistsProfileScreen(
                                  selectedUserUID: userFollowerId,
                                ),
                              ),
                            );
                          },
                          leading: profile == ''
                              ? CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  maxRadius: 30,
                                  child: Text(
                                    getFirstLetter,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(profile),
                                ),

                          title: Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: GoogleFonts.inter(
                                      color: notifiedUSer == 0
                                          ? Colors.teal
                                          : Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  timeAgo,
                                  style: GoogleFonts.inter(
                                      color: notifiedUSer == 0
                                          ? Colors.teal
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          subtitle: Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Followed you',
                                  style: GoogleFonts.inter(
                                      color: notifiedUSer == 0
                                          ? Colors.teal
                                          : Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.inter(
                                      color: notifiedUSer == 0
                                          ? Colors.teal
                                          : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          // trailing: GestureDetector(
                          //   onTap: () {
                          //
                          //   },
                          //   child: Text(
                          //     'X',
                          //     style: GoogleFonts.inter(
                          //       color: Colors.black,
                          //       fontSize: 15,
                          //     ),
                          //   ),
                          // ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}


Future<T?> showTopModalDialog<T>(BuildContext context, Widget child,
    {bool barrierDismissible = true}) {
  return showGeneralDialog<T?>(
    context: context,
    barrierDismissible: barrierDismissible,
    transitionDuration: const Duration(milliseconds: 250),
    barrierLabel: MaterialLocalizations.of(context).dialogLabel,
    barrierColor: Colors.black.withOpacity(0.5),
    pageBuilder: (context, _, __) => child,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)
            .drive(
                Tween<Offset>(begin: const Offset(0, -1.0), end: Offset.zero)),
        child: Container(
          margin: const EdgeInsets.only(top: 80.0),
          child: Column(
            children: [
              Positioned(
                top: 80.0,
                child: Material(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [child],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
