// Assurez-vous que ce fichier est créé
import 'package:http/http.dart' as http;
// ... (logique complète du service donnée précédemment)
class LectureVocaleService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  static const String _endpointPath = '/api/public/lecture-vocale/contenu';

  LectureVocaleService();

  Future<List<int>> telechargerLectureVocale(int contenuId, String lang) async {
    final String url = '$_baseUrl$_endpointPath/$contenuId/$lang';
    // ... (Logique de l'appel HTTP)
    try {
      final response = await http.get(Uri.parse(url), headers: {'Accept': 'audio/mpeg'});
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Échec de la récupération audio. Statut: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}