import 'package:http/http.dart' as http;

Future<http.Response> fetchAlbum(String emotion) {
  return http.get(Uri.parse('http://127.0.0.1:7777/?image="$emotion"'));
}
