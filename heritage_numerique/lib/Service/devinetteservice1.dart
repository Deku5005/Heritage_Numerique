import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Devinette1.dart'; // Importe le modèle de Devinette

class DevinetteService1 {
  // Base URL pour l'émulateur Android (pour accéder au localhost de la machine hôte)
  static const String _baseUrl = 'http://10.0.2.2:8080';
  static const String _endpoint = '/api/public/devinettes';

  /// Récupère UN seul devinette par son ID.
  Future<Devinette1> getDevinette(int id) async {
    final url = Uri.parse('$_baseUrl$_endpoint/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(utf8.decode(response.bodyBytes));
        return Devinette1.fromJson(jsonBody);
      } else {
        throw Exception('Impossible de charger la devinette (ID: $id). Statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion ou de traitement des données: $e');
    }
  }

  /// Récupère une LISTE de devinettes.
  Future<List<Devinette1>> getDevinettes() async {
    final url = Uri.parse('$_baseUrl$_endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Décode le corps de la réponse en UTF-8 pour gérer les caractères français
        final dynamic decodedBody = json.decode(utf8.decode(response.bodyBytes));

        if (decodedBody is List) {
          // Si l'API renvoie une liste
          return decodedBody.map((json) => Devinette1.fromJson(json as Map<String, dynamic>)).toList();
        } else if (decodedBody is Map<String, dynamic>) {
          // Si l'API renvoie un seul objet (cas peu probable pour cet endpoint, mais géré par sécurité)
          return [Devinette1.fromJson(decodedBody)];
        } else {
          throw Exception("Le format de réponse de l'API est inattendu.");
        }
      } else {
        throw Exception('Impossible de charger les devinettes. Statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion ou de traitement des données: $e');
    }
  }
}