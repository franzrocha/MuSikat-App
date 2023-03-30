import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musikat_app/constants.dart';
import 'package:musikat_app/models/song_model.dart';
import 'package:musikat_app/models/user_model.dart';
import 'package:musikat_app/screens/home/categories_screen.dart';
import 'package:musikat_app/screens/home/other_artist_screen.dart';
import 'package:musikat_app/widgets/avatar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textCon = TextEditingController();
  // ignore: prefer_typing_uninitialized_variables
  var getUsers;

  @override
  Widget build(BuildContext context) {
    getUsers ??= UserModel.getUsers();

    return SafeArea(
      child: Scaffold(
        appBar: appbar(context),
        backgroundColor: musikatBackgroundColor,
        body: SizedBox(
          child: FutureBuilder<List<UserModel>>(
              future: getUsers,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<UserModel>> snapshot,
              ) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                List<UserModel> searchResult = [];
                if (_textCon.text.isNotEmpty) {
                  for (var element in snapshot.data!) {
                    if (element.searchUsername(_textCon.text)) {
                      searchResult.add(element);
                    }
                  }

                  return searchResult.isEmpty
                      ? Center(
                          child: Text('No results found',
                              style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        )
                      : ListView.builder(
                          itemCount: searchResult.length,
                          itemBuilder: (context, index) {
                            return searchResult[index].uid !=
                                    FirebaseAuth.instance.currentUser?.uid
                                ? ListTile(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ArtistsProfileScreen(
                                                    selectedUserUID:
                                                        searchResult[index]
                                                            .uid)),
                                      );
                                    },
                                    leading: AvatarImage(
                                        uid: searchResult[index].uid),
                                    title: Text(
                                      searchResult[index].username,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: null,
                                  )
                                : const SizedBox();
                          });
                }
                return Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30, bottom: 15),
                        child: Image.asset(
                          "assets/images/search.png",
                          width: 254,
                          height: 254,
                        ),
                      ),
                      Text('Search for your favourite music or your friends',
                          style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  AppBar appbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      title: TextField(
        autofocus: true,
        controller: _textCon,
        onSubmitted: (textCon) {},
        onChanged: (text) {
          setState(() {});
          // if (text) print(text);
        },
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
        // ignore: prefer_const_constructors
        decoration: InputDecoration(
          hintText: 'Search',

          border: InputBorder.none,
          // ignore: prefer_const_constructors
          hintStyle: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const FaIcon(
          FontAwesomeIcons.angleLeft,
          size: 20,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CategoriesScreen(),
              ),
            );
          },
          icon: const Icon(
            Icons.category,
            size: 20,
          ),
        ),
      ],
    );
  }
}
