import 'dart:convert';
import 'package:http/http.dart' as http;

// NOTE: Adresse IP locale de l'émulateur Android vers l'hôte (Backend Java/Spring)
const String BASE_URL = 'http://10.0.2.2:8080';

/// Service dédié à la gestion des invitations.
class InvitationService {

  final String _authToken;

  InvitationService(this._authToken);

  // Méthode utilitaire pour les en-têtes
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_authToken',
  };

  /// Accepte une invitation en envoyant une requête POST à l'API.
  ///
  /// @param invitationId L'identifiant unique de l'invitation à accepter.
  /// @returns Future<void> Indique le succès ou lance une exception en cas d'échec.
  Future<void> acceptInvitation({required String invitationId}) async {
    if (_authToken.isEmpty) {
      throw Exception("Erreur d'authentification: Le jeton (Auth Token) est manquant.");
    }

    // Le chemin d'accès complet est /api/invitations/{id}/accepter
    final url = Uri.parse('$BASE_URL/api/invitations/$invitationId/accepter');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Invitation $invitationId acceptée avec succès.');
        return;
      } else if (response.statusCode == 404) {
        throw Exception("L'invitation n'existe pas, a déjà été traitée, ou est expirée.");
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Vous n'êtes pas autorisé à accepter cette invitation. Veuillez vous reconnecter.");
      } else if (response.statusCode == 409) {
        throw Exception("Cette invitation a déjà été traitée (acceptée ou refusée).");
      } else {
        throw Exception("Échec de l'acceptation de l'invitation. Statut: ${response.statusCode}");
      }
    } catch (e) {
      print('Erreur lors de l\'appel à acceptInvitation: $e');
      rethrow;
    }
  }

  /// Refuse une invitation en envoyant une requête POST à l'API.
  ///
  /// @param invitationId L'identifiant unique de l'invitation à refuser.
  /// @returns Future<void> Indique le succès ou lance une exception en cas d'échec.
  Future<void> refuseInvitation({required String invitationId}) async {
    if (_authToken.isEmpty) {
      throw Exception("Erreur d'authentification: Le jeton (Auth Token) est manquant.");
    }

    // Le chemin d'accès complet est /api/invitations/{id}/refuser
    final url = Uri.parse('$BASE_URL/api/invitations/$invitationId/refuser');

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Invitation $invitationId refusée avec succès.');
        return;
      } else if (response.statusCode == 404) {
        throw Exception("L'invitation n'existe pas ou a déjà été traitée.");
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception("Vous n'êtes pas autorisé à refuser cette invitation. Veuillez vous reconnecter.");
      } else if (response.statusCode == 409) {
        throw Exception("Cette invitation a déjà été traitée.");
      } else {
        throw Exception("Échec du refus de l'invitation. Statut: ${response.statusCode}");
      }
    } catch (e) {
      print('Erreur lors de l\'appel à refuseInvitation: $e');
      rethrow;
    }
  }
}
