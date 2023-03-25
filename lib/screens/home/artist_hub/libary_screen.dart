import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:musikat_app/models/song_model.dart';


class LibraryScreen extends StatefulWidget {

   const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('songs').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final List<DocumentSnapshot> documents = snapshot.data!.docs;
            return ListView(
              children: documents.map((doc) {
                final song = SongModel.fromDocumentSnap(doc);
                return ListTile(
                  title: Text(song.title),
                  subtitle: Text(song.genre),
                );
              }).toList(),
            );
          },
        ),
      );
  }
}
