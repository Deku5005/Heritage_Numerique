

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/conte.dart';
import '../model/traduction_conte_model.dart';

// Adresse de l'émulateur Android
const String _apiBaseUrl = 'http://192.168.43.22:8080';

class ConteService {
  final String _endpointContes = '/api/public/contes';
  //  Nouvel endpoint de traduction
  final String _endpointTraduction = '/api/public/traduction/contes';

  Future<List<Conte>> getContes() async {
    final url = Uri.parse('$_apiBaseUrl$_endpointContes');

    // ... (Logique getContes inchangée) ...
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final dynamic decodedBody = json.decode(response.body);

        if (decodedBody is List) {
          final List<dynamic> contesJson = decodedBody;

          return contesJson
              .map((jsonItem) => Conte.fromJson(jsonItem as Map<String, dynamic>))
              .toList();
        } else {
          throw const FormatException("Erreur de format de réponse : l'API n'a pas retourné une liste JSON.");
        }

      } else {
        throw Exception('Échec du chargement des contes. Statut: ${response.statusCode}. Corps de réponse: ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau ou de désérialisation (getContes): $e');
      rethrow;
    }
  }

  //  Nouvelle méthode pour récupérer la traduction
  Future<TraductionConteModel> getConteTraduction({
    required int conteId,
    required String langCode // 'bm', 'en', ou 'fr'
  }) async {
    final url = Uri.parse('$_apiBaseUrl$_endpointTraduction/$conteId/$langCode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception("Réponse de traduction vide.");
        }

        final dynamic decodedBody = json.decode(response.body);

        if (decodedBody is Map<String, dynamic>) {
          return TraductionConteModel.fromJson(decodedBody);
        } else {
          throw const FormatException("Erreur de format de réponse de traduction.");
        }

      } else {
        throw Exception('Échec du chargement de la traduction. Statut: ${response.statusCode}. Corps de réponse: ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau ou de désérialisation (getConteTraduction): $e');
      rethrow;
    }
  }
}