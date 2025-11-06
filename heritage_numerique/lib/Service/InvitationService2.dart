import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:heritage_numerique/model/InvitationResponse.dart'; // Import du modèle d'invitation
import 'auth-service.dart'; // Pour l'accès au token

/// Service dédié aux opérations liées aux invitations (envoi, récupération, gestion).
class InvitationService {
  // Instance du service d'authentification pour accéder aux tokens
  final AuthService _authService;

  // Configuration de l'URL de base (doit correspondre à celle de l'AuthService)
  static const String _baseUrl = 'http://10.0.2.2:8080';

  InvitationService(this._authService);

  /// Récupère toutes les invitations envoyées par une famille donnée.
  /// Endpoint: GET /api/invitations/famille/{familleId}
  Future<List<InvitationResponse>> fetchFamilyInvitations(int familleId) async {
    // 1. Récupérer le token pour l'autorisation
    final String? token = await _authService.getAuthToken();

    if (token == null || token.isEmpty || token == 'Success_No_Token') {
      throw Exception('Jeton d\'authentification manquant. Veuillez vous reconnecter.');
    }

    // 2. Construction de l'URL de l'endpoint
    final String url = '$_baseUrl/api/invitations/famille/$familleId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          // Si la réponse est 200 mais le corps est vide, cela signifie aucune invitation.
          return [];
        }

        try {
          // Le corps de la réponse est une LISTE de Map<String, dynamic>
          final List<dynamic> jsonResponse = jsonDecode(response.body);

          // Mappage de chaque Map en une instance de InvitationResponse
          return jsonResponse
              .map((json) => InvitationResponse.fromJson(json as Map<String, dynamic>))
              .toList();

        } on FormatException {
          throw Exception('Erreur de décodage JSON pour les invitations. Réponse serveur invalide.');
        }

      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé. Le jeton Bearer est invalide ou expiré.');
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Erreur serveur. Statut: ${response.statusCode}';
          throw Exception(errorMessage);
        } on FormatException {
          throw Exception('Échec de la récupération des invitations. Statut: ${response.statusCode}. Réponse serveur non lisible.');
        }
      }
    } catch (e) {
      throw Exception('Échec de la connexion réseau ou erreur non gérée lors de la récupération des invitations : $e');
    }
  }
}