import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/controllers/notification_controller.dart';
import 'package:musikat_app/utils/exports.dart';
import '../../utils/constants.dart';
import '../../widgets/appbar_widgets.dart';
import 'other_artist_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final firebaseService = FirebaseService();
  final userNotificationController = UserNotificationController();

  late Stream<QuerySnapshot<Map<String, dynamic>>> notificationStream =
      const Stream.empty();
  late Stream<User?> authStateStream;
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    // Subscribe to the authentication state changes
    authStateStream = FirebaseAuth.instance.authStateChanges();
    authStateStream.listen((User? user) {
      if (mounted) {
        setState(() {
          currentUser = user;
          if (user != null) {
            // User is logged in, subscribe to the notification stream
            notificationStream = FirebaseFirestore.instance
                .collection('userNotification')
                .where('following', isEqualTo: user.uid)
                .snapshots();
          } else {
            // User is logged out, set the notification stream to null
            notificationStream = const Stream.empty();
          }
        });
      }
    });
  }

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
                'Notification',
                style: appBarStyle,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  showDialog(
                    builder: (BuildContext context) =>
                        _buildPopupDialog(context),
                    context: context,
                  );
                },
                icon: const Icon(
                  Icons.delete_rounded,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        showLogo: false,
      ),
      backgroundColor: musikatBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream: notificationStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var notificationsData = snapshot.data!.docs;

                notificationsData.sort((a, b) {
                  Timestamp timestampA = a['timestamp'];
                  Timestamp timestampB = b['timestamp'];
                  return timestampB.compareTo(timestampA);
                });

                return notificationsData.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notificationsData.length,
                        itemBuilder: (context, index) {
                          var notification = notificationsData[index];
                          var followerId = notification['follower'];
                          var followingId = notification['following'];
                          Timestamp dateNotified = notification['timestamp'];
                          String timeAgo = userNotificationController
                              .getTimeAgo(dateNotified);
                          int notifiedUser;

                          final DateTime date = dateNotified.toDate();
                          final DateFormat formatter =
                              DateFormat('MMM dd, yyyy');
                          final String formattedDate = formatter.format(date);

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
                                  var username = user['username'];

                                  notifiedUser = notification['notify'];

                                  return ListTile(
                                    tileColor: notifiedUser == 0
                                        ? musikatBackgroundColor
                                        : Colors.black.withOpacity(0.5),
                                    onTap: () {
                                      userNotificationController
                                          .updateNotificationState(
                                              userFollowerId, followingId);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArtistsProfileScreen(
                                            selectedUserUID: userFollowerId,
                                          ),
                                        ),
                                      );
                                    },
                                    leading: AvatarImage(uid: userFollowerId),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: TextStyle(
                                            color: notifiedUser == 0
                                                ? musikatTextColor
                                                    .withOpacity(0.5)
                                                : musikatTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          timeAgo,
                                          style: GoogleFonts.inter(
                                            color: notifiedUser == 0
                                                ? musikatTextColor
                                                    .withOpacity(0.5)
                                                : musikatTextColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'followed you',
                                          style: TextStyle(
                                            color: notifiedUser == 0
                                                ? musikatTextColor
                                                    .withOpacity(0.5)
                                                : musikatTextColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: TextStyle(
                                            color: notifiedUser == 0
                                                ? musikatTextColor
                                                    .withOpacity(0.5)
                                                : musikatTextColor,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        },
                      )
                    : const Center(
                        child: Column(
                          children: [
                            Text(
                              'No notification yet...',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 20, height: 20),
                            )
                          ],
                        ),
                      );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPopupDialog(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: AlertDialog(
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Are you sure you want to delete ?',
            style: TextStyle(color: musikatColor4, fontSize: 17),
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: const Text('Cancel', style: TextStyle(color: cancelColor)),
              onPressed: () {
                Navigator.pop(context);
              }),
          TextButton(
              child:
                  const Text('Confirm', style: TextStyle(color: deleteColor)),
              onPressed: () {
                firebaseService.deleteAllCollection(
                    'userNotification', 'following', currentUser!.uid);
                ToastMessage.show(context, 'Notification deleted successfully');

                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}
