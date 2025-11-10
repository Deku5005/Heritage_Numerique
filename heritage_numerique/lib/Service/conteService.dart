// lib/services/conte_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/conte.dart'; // Assurez-vous du bon chemin d'importation

const String _apiBaseUrl = 'http://10.0.2.2:8080';

class ConteService {
  final String _endpoint = '/api/public/contes';

  Future<List<Conte>> getContes() async {
    final url = Uri.parse('$_apiBaseUrl$_endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // La réponse est un tableau JSON (List<dynamic>)
        final List<dynamic> contesJson = json.decode(response.body);

        // On mappe chaque élément du tableau en un objet Conte
        return contesJson
            .map((jsonItem) => Conte.fromJson(jsonItem as Map<String, dynamic>))
            .toList();

      } else {
        // Gérer les erreurs HTTP
        throw Exception('Échec du chargement des contes. Statut: ${response.statusCode}');
      }
    } catch (e) {
      // Gérer les erreurs réseau ou de désérialisation
      print('Erreur lors du fetch des contes: $e');
      rethrow;
    }
  }
}