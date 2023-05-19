import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:musikat_app/utils/exports.dart';

class CategoriesController with ChangeNotifier{

Future<List<String>> getLanguages() async {
    List<String> languages = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('languages')
        .get();

    for (var doc in querySnapshot.docs) {
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        var language = data['language'];
        if (language != null) {
          languages.add(language);
        }
      }
    }

    return languages;
  }

}