// lib/Service/DashboardService.dart

import 'dart:convert';
import 'package:heritage_numerique/model/family_response_dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:heritage_numerique/model/dashboard-models.dart';
// Assurez-vous d'avoir un moyen fiable d'obtenir le token de l'utilisateur
import 'Auth-service.dart'; // Supposons que ceci expose une méthode pour obtenir le token

class DashboardService {
  // ⚠️ Remplacez par votre URL de base
  static const String _baseUrl = "http://10.0.2.2:8080";
  final AuthService _authService = AuthService(); // Instance de votre service d'authentification

  /// Récupère les données du tableau de bord familial
  Future<FamilyDashboardResponse> fetchFamilyDashboard({
    required int familleId,
  }) async {
    // 1. Récupérer le jeton (token) d'authentification
    final String? token = await _authService.getAuthToken();

    if (token == null) {
      throw Exception("Token d'authentification non trouvé. Veuillez vous reconnecter.");
    }

    // 2. Construire l'URL de l'API
    final Uri uri = Uri.parse('$_baseUrl/api/dashboard/famille/$familleId');

    // 3. Effectuer l'appel API (GET)
    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        // Ajout du token dans l'en-tête Authorization
        'Authorization': 'Bearer $token',
      },
    );

    // 4. Traiter la réponse
    if (response.statusCode == 200) {
      // Succès : désérialisation du JSON
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return FamilyDashboardResponse.fromJson(jsonResponse);
    } else {
      // Échec : gérer l'erreur
      String errorMessage = "Échec du chargement du tableau de bord.";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        // Ignorer l'erreur de décodage si le corps n'est pas du JSON
        errorMessage = "Erreur du serveur (Statut: ${response.statusCode}).";
      }
      throw Exception(errorMessage);
    }
  }
}