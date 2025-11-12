import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/proverbe1.dart'; // Assurez-vous que le chemin est correct

class ProverbeService1 {
  // L'URL de base pour l'émulateur Android vers votre machine locale
  static const String _baseUrl = 'http://10.0.2.2:8080';
  static const String _endpoint = '/api/public/proverbes';

  /// Récupère UN seul proverbe (si l'API prend un ID).
  Future<Proverbe1> getProverbe(int id) async {
    final url = Uri.parse('$_baseUrl$_endpoint/$id');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonBody = json.decode(utf8.decode(response.bodyBytes));
        return Proverbe1.fromJson(jsonBody);
      } else {
        throw Exception('Impossible de charger le proverbe (ID: $id). Statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion ou de traitement des données: $e');
    }
  }

  /// Récupère une LISTE de proverbes.
  Future<List<Proverbe1>> getProverbes() async {
    final url = Uri.parse('$_baseUrl$_endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Supposons que l'endpoint sans ID renvoie une liste
        final dynamic decodedBody = json.decode(utf8.decode(response.bodyBytes));

        if (decodedBody is List) {
          return decodedBody.map((json) => Proverbe1.fromJson(json as Map<String, dynamic>)).toList();
        } else if (decodedBody is Map<String, dynamic>) {
          // Si l'endpoint renvoie un seul objet au lieu d'une liste
          return [Proverbe1.fromJson(decodedBody)];
        } else {
          throw Exception("Le format de réponse de l'API est inattendu.");
        }
      } else {
        throw Exception('Impossible de charger les proverbes. Statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion ou de traitement des données: $e');
    }
  }
}