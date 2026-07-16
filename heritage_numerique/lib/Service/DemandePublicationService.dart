// Fichier: lib/service/DemandePublicationService.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/DemandePublicationn.dart'; // 💡 CORRIGÉ : Assurez-vous d'importer le bon modèle
import 'Auth-service.dart'; // 💡 AJOUT : Import du service d'authentification
import 'dart:async'; // Ajout pour Future

import '../config/api_config.dart';

// Base URL de votre API
String get _BASE_URL => ApiConfig.baseUrl;

class DemandePublicationService {

  final AuthService _authService = AuthService(); // Instance du service d'auth

  // --- Méthode d'utilitaire pour obtenir le Token ---
  Future<String?> _getAuthToken() async {
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      print("Erreur: Token d'authentification non trouvé.");
      // Lancer une erreur pour être capturée par l'écran appelant
      throw Exception("Token d'authentification non trouvé. Veuillez vous reconnecter.");
    }
    return token;
  }

  // -----------------------------------------------------------------
  // --- 1. RÉCUPÉRATION DES DEMANDES PAR FAMILLE (GET) ---
  // Endpoint: GET /api/contenus/demandes/famille/{familleId}
  // -----------------------------------------------------------------
  Future<List<DemandePublicationn>> fetchDemandesByFamille({required int familleId}) async {
    final String? token = await _getAuthToken();
    final url = Uri.parse(_BASE_URL).resolve('/api/contenus/demandes/famille/$familleId');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 💡 AJOUT : Utilisation du jeton
      });

      if (response.statusCode == 200) {
        // Le corps de la réponse est une liste JSON
        final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));

        // Mappage de chaque élément JSON vers le modèle DemandePublication
        return jsonList.map((json) => DemandePublicationn.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Accès refusé. Vous n\'avez pas les permissions requises (403).');
      } else {
        // Gérer les autres erreurs de serveur ou de requête
        throw Exception(
            'Échec du chargement des demandes. Statut: ${response.statusCode}');
      }
    } catch (e) {
      // Gérer les erreurs de réseau ou autres exceptions
      print('Erreur lors du chargement des demandes: $e');
      rethrow;
    }
  }


  // -----------------------------------------------------------------
  // --- 2. APPROBATION D'UNE DEMANDE (POST) ---
  // Endpoint: POST /api/contenus/demandes/{demandeId}/approuver
  // -----------------------------------------------------------------

  /// Approuve une demande de publication spécifique.
  Future<DemandePublicationn> approveDemande({required int demandeId}) async {
    final String? token = await _getAuthToken();
    final url = Uri.parse(_BASE_URL).resolve('/api/contenus/demandes/$demandeId/approuver');

    try {
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: jsonEncode({})); // Le corps peut être vide

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Retourne la demande mise à jour (incluant le nouveau statut)
        final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
        return DemandePublicationn.fromJson(responseBody);
      } else {
        String errorMessage = "Échec de l'approbation (Statut: ${response.statusCode}).";
        try {
          final Map<String, dynamic> errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Erreur réseau lors de l\'approbation: $e');
    }
  }


  // -----------------------------------------------------------------
  // --- 3. REJET D'UNE DEMANDE (POST) ---
  // Endpoint: POST /api/contenus/demandes/{demandeId}/rejeter
  // -----------------------------------------------------------------

  /// Rejette une demande de publication spécifique.
  Future<DemandePublicationn> rejectDemande({required int demandeId}) async {
    final String? token = await _getAuthToken();
    final url = Uri.parse(_BASE_URL).resolve('/api/contenus/demandes/$demandeId/rejeter');

    try {
      final response = await http.post(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: jsonEncode({})); // Le corps peut être vide

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Retourne la demande mise à jour (incluant le nouveau statut)
        final Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes));
        return DemandePublicationn.fromJson(responseBody);
      } else {
        String errorMessage = "Échec du rejet (Statut: ${response.statusCode}).";
        try {
          final Map<String, dynamic> errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Erreur réseau lors du rejet: $e');
    }
  }

}