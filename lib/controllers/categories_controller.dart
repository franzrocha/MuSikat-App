import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikat_app/utils/exports.dart';

class CategoriesController with ChangeNotifier {
  Future<List<String>> getLanguages() async {
    List<String> languages = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('languages').get();

    for (var doc in querySnapshot.docs) {
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        var language = data['language'];
        if (language != null) {
          languages.add(language);
        }
      }
    }
    languages.sort();
    return languages;
  }

  Future<List<String>> getGenres() async {
    List<String> genres = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('genres').get();

    for (var doc in querySnapshot.docs) {
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        var genre = data['genre'];
        if (genre != null) {
          genres.add(genre);
        }
      }
    }

    genres.sort();

    return genres;
  }

  Future<List<String>> getDescriptions() async {
    List<String> descriptions = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('descriptions').get();

    for (var doc in querySnapshot.docs) {
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        var description = data['description'];
        if (description != null) {
          descriptions.add(description);
        }
      }
    }

    descriptions.sort();

    return descriptions;
  }
}
