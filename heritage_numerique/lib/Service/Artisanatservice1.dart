// lib/services/artisanat_service1.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// Assurez-vous d'importer le bon modèle
import '../model/ArtisanatTraduction.dart';
import '../model/Artisanat1.dart';

// Adresse de l'émulateur Android
const String _apiBaseUrl = 'http://10.0.2.2:8080';

class ArtisanatService1 { // Nom de la classe changé
  // L'endpoint pour la récupération des artisanats
  final String _endpoint = '/api/public/artisanats';
  // 💡 NOUVEL ENDPOINT pour la traduction
  final String _translationPath = '/api/public/traduction/artisanats';

  /// Récupère la liste des objets Artisanat1 depuis l'API.
  Future<List<Artisanat1>> getArtisanats() async {
    final url = Uri.parse('$_apiBaseUrl$_endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {

        if (response.body.isEmpty) {
          return [];
        }

        final dynamic decodedBody = json.decode(response.body);

        if (decodedBody is List) {
          final List<dynamic> artisanatsJson = decodedBody;

          // Mapping vers la liste d'objets Artisanat1
          return artisanatsJson
              .map((jsonItem) => Artisanat1.fromJson(jsonItem as Map<String, dynamic>))
              .toList();

        } else {
          throw const FormatException("Erreur de format de réponse : l'API n'a pas retourné une liste JSON.");
        }

      } else {
        final String errorMessage = 'Échec du chargement des artisanats. Statut: ${response.statusCode}. Corps de réponse: ${response.body}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erreur réseau ou de désérialisation dans ArtisanatService1: $e');
      rethrow;
    }
  }

  // ------------------------------------------------------------------
  // 💡 NOUVELLE MÉTHODE : Récupération de la traduction d'un Artisanat
  // ------------------------------------------------------------------

  /// Récupère la traduction d'un artisanat spécifique pour une langue cible.
  Future<ArtisanatTraduction> fetchArtisanatTranslationPublic({
    required int artisanatId,
    required String targetLanguageCode,
  }) async {
    // Construction de l'URL: /api/public/traduction/artisanats/{artisanatId}/{lang}
    final url = Uri.parse('$_apiBaseUrl$_translationPath/$artisanatId/$targetLanguageCode');

    print('DEBUG ARTISANAT SERVICE: Tentative de récupération traduction Artisanat ID $artisanatId pour langue $targetLanguageCode : $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception("Réponse vide lors de la traduction de l'artisanat.");
        }

        final Map<String, dynamic> jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        // 💡 Utilisation du modèle ArtisanatTraduction
        return ArtisanatTraduction.fromJson(jsonResponse);

      } else {
        String errorBody = response.body.isNotEmpty ? response.body : 'Aucun corps de réponse';

        // Tentative de décoder le corps pour un message d'erreur JSON
        try {
          final decodedError = json.decode(errorBody);
          errorBody = decodedError['message'] ?? errorBody;
        } catch (_) {
          // Si ce n'est pas du JSON, on utilise le corps brut
        }

        final String errorMessage = 'Échec de la traduction de l\'artisanat. Statut: ${response.statusCode}. Message: $errorBody';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erreur réseau ou de désérialisation lors de la traduction de l\'artisanat: $e');
      // Nous relançons l'exception pour être gérée par l'UI
      rethrow;
    }
  }
}