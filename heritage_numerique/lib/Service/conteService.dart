// lib/services/conte_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/conte.dart';

const String _apiBaseUrl = 'http://10.0.2.2:8080';

class ConteService {
  final String _endpoint = '/api/public/contes';

  Future<List<Conte>> getContes() async {
    final url = Uri.parse('$_apiBaseUrl$_endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Décodage : Utiliser 'dynamic' est plus idiomatique pour le résultat de json.decode
        final dynamic decodedBody = json.decode(response.body);

        // Vérification du type (par sécurité) et cast en List<dynamic>
        if (decodedBody is List) {
          final List<dynamic> contesJson = decodedBody;

          // On mappe chaque élément du tableau en un objet Conte
          return contesJson
              .map((jsonItem) => Conte.fromJson(jsonItem as Map<String, dynamic>))
              .toList();
        } else {
          // Si l'API retourne un objet unique au lieu d'une liste vide, on gère l'erreur
          throw const FormatException("La réponse de l'API n'est pas un tableau JSON.");
        }

      } else {
        // Gérer les erreurs HTTP (400, 500, etc.)
        throw Exception('Échec du chargement des contes. Statut: ${response.statusCode}');
      }
    } catch (e) {
      // Gérer les erreurs réseau ou de désérialisation
      print('Erreur lors du fetch des contes: $e');
      // On propage l'erreur pour que le FutureBuilder puisse la gérer
      rethrow;
    }
  }
}