import 'dart:convert';
import 'package:http/http.dart' as http;
// Assurez-vous que cette importation correspond à la casse exacte de votre fichier Auth
import 'package:heritage_numerique/Service/auth-service.dart';
import 'package:heritage_numerique/model/MemberResponseModel.dart'; // Modèle de réponse pour le profil

/// Service dédié à la récupération des informations détaillées du membre.
class MembreService {
  final AuthService _authService;

  // L'URL de base doit correspondre à celle utilisée dans AuthService
  static const String _baseUrl = 'http://10.0.2.2:8080';
  static const String _membresBaseUrl = '$_baseUrl/api/membres';

  MembreService(this._authService);

  /// Récupère les informations détaillées du membre actuellement connecté.
  ///
  /// Utilise l'ID Membre stocké (l'ID que l'API attend).
  Future<MembreResponse> fetchMembreDetails() async {
    final String? token = await _authService.getAuthToken();
    // ✅ MODIFIÉ: Utilise maintenant getMembreId() pour récupérer l'ID de membre
    final String? rawMembreIdFromStorage = await _authService.getMembreId();

    if (token == null || token.isEmpty) {
      throw Exception('Jeton d\'authentification manquant. Veuillez vous reconnecter.');
    }

    if (rawMembreIdFromStorage == null || rawMembreIdFromStorage.isEmpty) {
      // 💡 Option 1: Essayer d'utiliser l'endpoint /me (Recommandé)
      // Ceci fonctionne si l'API n'a pas besoin de l'ID dans l'URL.
      return _fetchDetailsByToken(token);
    }

    // 💡 Option 2: Utiliser l'ID Membre stocké (ID d'enregistrement: ex. 1)
    final String urlWithMembreId = '$_membresBaseUrl/$rawMembreIdFromStorage';

    print('DEBUG MEMBRE SERVICE: Tentative de récupération du profil via ID Membre: $urlWithMembreId');

    try {
      final response = await http.get(
        Uri.parse(urlWithMembreId),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Réponse 200 OK, mais corps du profil vide.');
        }
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return MembreResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé. Le jeton est invalide ou expiré.');
      } else {
        // Tente de décoder l'erreur serveur
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Erreur serveur. Statut: ${response.statusCode}';
          throw Exception(errorMessage);
        } catch (_) {
          throw Exception('Échec de chargement du profil. Statut: ${response.statusCode}. Réponse serveur non lisible.');
        }
      }
    } catch (e) {
      throw Exception('Échec de la connexion réseau pour le profil : $e');
    }
  }

  /// Méthode de secours/alternative pour récupérer les détails via l'endpoint /me (token-based).
  Future<MembreResponse> _fetchDetailsByToken(String token) async {
    // Utilisez l'endpoint /me si votre backend le supporte.
    const String meUrl = '$_membresBaseUrl/me';

    print('DEBUG MEMBRE SERVICE: Tentative de récupération du profil via ME endpoint: $meUrl');

    final response = await http.get(
      Uri.parse(meUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return MembreResponse.fromJson(jsonResponse);
    } else {
      // Si le backend ne supporte pas /me, on propage une erreur spécifique
      throw Exception('Impossible de récupérer le profil: le serveur a retourné le statut ${response.statusCode}.');
    }
  }
}