// lib/services/conte_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/conte.dart';

// Adresse de l'émulateur Android
const String _apiBaseUrl = 'http://10.0.2.2:8080';

class ConteService {
  final String _endpoint = '/api/public/contes';

  Future<List<Conte>> getContes() async {
    final url = Uri.parse('$_apiBaseUrl$_endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Vérifier si le corps de la réponse n'est pas vide
        if (response.body.isEmpty) {
          return []; // Retourne une liste vide si le corps est vide (ex: 200 OK mais pas de contes)
        }

        // Utilisation de jsonDecode pour décoder la chaîne en objet Dart
        final dynamic decodedBody = json.decode(response.body);

        // Assurez-vous que la réponse est bien une liste
        if (decodedBody is List) {
          final List<dynamic> contesJson = decodedBody;

          // Mapping vers la liste d'objets Conte
          return contesJson
              .map((jsonItem) => Conte.fromJson(jsonItem as Map<String, dynamic>))
              .toList();
        } else {
          // Si l'API retourne un objet (même vide) au lieu d'une liste
          throw const FormatException("Erreur de format de réponse : l'API n'a pas retourné une liste JSON.");
        }

      } else {
        // Gérer les codes d'erreur HTTP (400, 500, etc.)
        throw Exception('Échec du chargement des contes. Statut: ${response.statusCode}. Corps de réponse: ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau ou de désérialisation: $e');
      rethrow; // Propagation de l'erreur
    }
  }
}