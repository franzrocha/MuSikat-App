import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:musikat_app/controllers/firebase_service_user_notif_controller.dart';
import '../../../utils/constants.dart';
import '../../../widgets/appbar_widgets.dart';
import '../other_artist_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static final firebaseService = FirebaseService();
  static final userNotificationController = UserNotificationController();

  static final currentUserId = firebaseService.getCurrentUserId();

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
                          int notifiedUSer;

                          final DateTime date = dateNotified.toDate();
                          final DateFormat formatter = DateFormat(
                              'MMM-dd-yyyy:hh:ss'); // Define your desired date format
                          final String formattedDate = formatter
                              .format(date); // Format the date as a string

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
                                    textColor: listileColor,
                                    onTap: () {
                                      userNotificationController
                                          .updateNotificationState(
                                              userFollowerId, followingId);
                                      Navigator.pop(context);
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
                                    leading: profile == ''
                                        ? CircleAvatar(
                                            backgroundColor: Colors.blue,
                                            maxRadius: 30,
                                            child: Text(
                                              getFirstLetter,
                                              style: const TextStyle(
                                                color: musikatTextColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(profile),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fullName,
                                          style: GoogleFonts.inter(
                                            color: notifiedUSer == 0
                                                ? Colors.teal
                                                : musikatTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          timeAgo,
                                          style: GoogleFonts.inter(
                                            color: notifiedUSer == 0
                                                ? Colors.teal
                                                : musikatTextColor,
                                            fontSize: 12,
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
                                          'Followed you',
                                          style: GoogleFonts.inter(
                                            color: notifiedUSer == 0
                                                ? Colors.teal
                                                : musikatTextColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          formattedDate,
                                          style: GoogleFonts.inter(
                                            color: notifiedUSer == 0
                                                ? Colors.teal
                                                : musikatTextColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
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
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'No notification yet',
                              style: GoogleFonts.inter(
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                            ),
                          )
                        ],
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
                    'userNotification', 'following', currentUserId);
                Fluttertoast.showToast(
                    msg: "Deleted all record successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    textColor: Colors.white,
                    fontSize: 16.0);
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}
