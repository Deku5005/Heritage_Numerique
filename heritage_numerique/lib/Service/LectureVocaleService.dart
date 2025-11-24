import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data'; // 💡 Importation nécessaire pour Uint8List

class LectureVocaleService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  // Chemins des deux APIs
  static const String _pathStandard = '/api/lecture-vocale/contenu';
  static const String _pathPublic = '/api/public/lecture-vocale/contenu';

  final http.Client _client = http.Client();

  LectureVocaleService();

  // 💡 CORRECTION : Le type de retour est maintenant Uint8List (plus précis et compatible avec AudioPlayer)
  Future<Uint8List> telechargerLectureVocale(
      int contenuId,
      String lang,
      {bool usePublicApi = false} // <-- PARAMÈTRE OPTIONNEL
      ) async {

    // 1. Choix du chemin en fonction du paramètre
    final String path = usePublicApi ? _pathPublic : _pathStandard;

    // 2. Construction de l'URL
    final String url = '$_baseUrl$path/$contenuId/$lang';
    print('Téléchargement audio depuis: $url');

    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Accept': 'audio/mpeg'},
      );

      if (response.statusCode == 200) {
        // response.bodyBytes retourne déjà un Uint8List
        return response.bodyBytes;
      } else {
        // Gestion des erreurs
        String errorMsg = 'Échec de la récupération audio. Statut: ${response.statusCode}.';
        try {
          errorMsg += ' Corps: ${utf8.decode(response.bodyBytes)}';
        } catch (_) {}

        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception('Erreur réseau lors de l\'appel à $url: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}