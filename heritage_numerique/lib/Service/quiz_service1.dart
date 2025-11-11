// lib/service/quiz_service1.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// Assurez-vous d'ajuster ce chemin si nécessaire
import '../model/soumission_reponse.dart';
// Assurez-vous d'importer votre service de stockage de token
import 'token-storage-service.dart';

// Remplacez par votre URL de base API réelle
const String _baseUrl = "http://10.0.2.2:8080";

class QuizService1 {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  /// Endpoint pour soumettre les réponses d'un quiz public.
  // CHANGEMENT : La méthode retourne Future<void> pour ne pas dépendre du corps de réponse JSON.
  Future<void> soumettreReponsesQuiz(SoumissionReponse soumission) async {
    // 1. Définition de l'URL de l'endpoint
    final url = Uri.parse('$_baseUrl/api/superadmin/quiz-publics/repondre');

    // 2. Récupération du token d'authentification
    final token = await _tokenStorageService.getAuthToken();

    if (token == null || token.isEmpty) {
      throw Exception("Utilisateur non authentifié. Veuillez vous reconnecter.");
    }

    // 3. Configuration des headers
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // 4. Encodage du corps de la requête (SoumissionReponse -> JSON)
    final body = jsonEncode(soumission.toJson());

    try {
      // 5. Envoi de la requête POST
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // 6. Gestion des réponses
      if (response.statusCode == 200) {
        // La requête a réussi (200 OK)

        // CORRECTION : Nous considérons le 200 comme un succès et ignorons
        // le corps de réponse JSON défectueux du serveur.
        return;

      } else {
        // Gestion des erreurs HTTP (4xx, 5xx)
        String errorMessage = "Erreur du serveur lors de la soumission du quiz";
        try {
          // Tente de décoder le corps pour obtenir un message d'erreur clair
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorBody['detail'] ?? errorMessage;
        } catch (_) {}

        throw Exception("Échec de la soumission du quiz (${response.statusCode}): $errorMessage");
      }
    } catch (e) {
      // Gestion des erreurs réseau (pas de connexion, timeout)
      throw Exception("Échec de la connexion réseau pour la soumission du quiz: $e");
    }
  }
}