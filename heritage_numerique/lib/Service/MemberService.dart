import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:heritage_numerique/Service/auth-service.dart';
import 'package:heritage_numerique/model/MemberResponseModel.dart'; // Votre modèle MembreResponse adapté

/// Service dédié à la récupération des membres d'une famille via l'API Utilisateurs.
class FamilleMembreService {
  final AuthService _authService;

  // L'URL de base doit correspondre à celle utilisée dans AuthService
  static const String _baseUrl = 'http://10.0.2.2:8080';

  FamilleMembreService(this._authService);

  // --- Méthode d'utilitaire pour obtenir le Token et l'ID Utilisateur ---
  Future<Map<String, String>> _getAuthAndUserId() async {
    final String? token = await _authService.getAuthToken();
    // ✅ CORRECTION: Utilisation de getMembreId() comme ID Utilisateur dans l'URL
    final String? utilisateurId = await _authService.getMembreId();

    if (token == null || token.isEmpty) {
      throw Exception('Jeton d\'authentification manquant. Veuillez vous reconnecter.');
    }
    if (utilisateurId == null || utilisateurId.isEmpty) {
      throw Exception('ID Utilisateur (Membre) manquant. Veuillez vous reconnecter.');
    }

    return {
      'token': token,
      'utilisateurId': utilisateurId,
    };
  }

  // -------------------------------------------------------------------
  // --- Récupération des Membres de la Famille (GET) ---
  // -------------------------------------------------------------------

  /// Récupère la liste des membres associés à une famille.
  /// L'ID de l'utilisateur est récupéré via le service d'authentification.
  /// L'ID de la famille est fourni en paramètre.
  ///
  /// Endpoint : /api/utilisateurs/{utilisateurId}/famille/{familleId}
  Future<List<MembreResponse>> fetchMembresByFamilleId({
    required int familleId, // 🔑 L'ID de la famille est maintenant un paramètre requis
  }) async {
    // 1. Récupérer le Token et l'ID Utilisateur (Membre)
    final authInfo = await _getAuthAndUserId();
    final String token = authInfo['token']!;
    final String utilisateurId = authInfo['utilisateurId']!;

    // 2. Construire l'URL
    final String path = '/api/utilisateurs/$utilisateurId/famille/${familleId.toString()}';
    final Uri uri = Uri.parse(_baseUrl).resolve(path);

    print('DEBUG FAMILLE MEMBRE SERVICE: Tentative de récupération des membres de la famille : $uri');

    try {
      final http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Réponse GET $path: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }

        final decodedBody = jsonDecode(response.body);

        // ✅ CORRECTION DU TYPE : Vérifie si la réponse est une Liste ou un Objet unique (Map).
        if (decodedBody is List) {
          // Cas normal: L'API renvoie une LISTE de membres.
          return decodedBody
              .map((json) => MembreResponse.fromJson(json as Map<String, dynamic>))
              .toList();

        } else if (decodedBody is Map) {
          // Cas de l'erreur: L'API renvoie un seul OBJET (probablement le profil de l'utilisateur connecté).
          // On enveloppe cet objet dans une liste pour respecter la signature de la méthode (Future<List<...>>).
          print('ATTENTION FAMILLE MEMBRE SERVICE: L\'API a renvoyé un objet unique au lieu d\'une liste. Traitement comme une liste d\'un élément.');
          return [MembreResponse.fromJson(decodedBody as Map<String, dynamic>)];

        } else {
          // Type de réponse inattendu.
          throw Exception("Réponse API inattendue : ni liste, ni objet.");
        }

      } else {
        String errorMessage = "Échec du chargement des membres (Statut: ${response.statusCode}).";
        try {
          final Map<String, dynamic> errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {
          errorMessage += " Réponse brute: ${response.body}";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Le bloc catch attrape maintenant aussi les erreurs de type de réponse et les erreurs réseau
      throw Exception('Échec de la connexion réseau ou erreur de traitement de la réponse : $e');
    }
  }
}