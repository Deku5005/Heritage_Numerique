import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/family_member_model.dart';
import '../model/family_model.dart'; // ✅ Import du modèle FamilyModel pour la réponse
import 'Auth-service.dart';

class FamilyMemberService {
  // ⚠️ Remplacez par votre URL de base (doit être la même que dans DashboardService)
  static const String _baseUrl = "http://192.168.43.22:8080";
  final AuthService _authService = AuthService(); // Instance de votre service d'authentification

  // --- Méthode d'utilitaire pour les appels API ---
  Future<String?> _getAuthToken() async {
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      // Note: L'exception est levée ici pour intercepter dans le service
      throw Exception("Token d'authentification non trouvé. Veuillez vous reconnecter.");
    }
    return token;
  }

  // --- Méthode existante pour la liste des membres ---

  /// Récupère la liste des membres d'une famille à partir de l'API: api/membres/famille/{familleId}
  Future<List<FamilyMemberModel>> fetchFamilyMembers({
    required int familleId,
  }) async {
    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse('$_baseUrl/api/membres/famille/$familleId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((jsonItem) => FamilyMemberModel.fromJson(jsonItem as Map<String, dynamic>))
          .toList();
    } else {
      String errorMessage = "Échec du chargement des membres (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- Méthode existante pour les détails d'un membre ---

  /// Récupère les détails d'un membre à partir de l'API: api/membres/{membreId}
  Future<FamilyMemberModel> fetchMemberDetail({
    required int membreId,
  }) async {
    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse('$_baseUrl/api/membres/$membreId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return FamilyMemberModel.fromJson(jsonMap);
    } else {
      String errorMessage = "Échec du chargement des détails du membre (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- ✅ MÉTHODE CORRIGÉE : Ajouter un membre manuellement (POST) ---

  /// Ajoute un nouveau membre manuellement à la famille via l'API: api/membres/ajouter.
  /// L'API renvoie le membre créé au complet.
  Future<FamilyMemberModel> addFamilyMemberManual({
    required int idFamille,
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String ethnie,
    required String lienParente,
    required String roleFamille,
  }) async {
    final String? token = await _getAuthToken();
    // 💡 URL API corrigée : api/membres/ajouter
    final Uri uri = Uri.parse('$_baseUrl/api/membres/ajouter');

    // 💡 Corps de la requête adapté exactement au Request Body spécifié
    final Map<String, dynamic> body = {
      'idFamille': idFamille,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'ethnie': ethnie,
      'lienParente': lienParente,
      'roleFamille': roleFamille,
    };

    final http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    // L'API est censée renvoyer le FamilyMemberModel complet après la création (statut 200 ou 201)
    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
      // Retourne l'objet complet créé
      return FamilyMemberModel.fromJson(jsonMap);
    } else {
      String errorMessage = "Échec de l'ajout manuel du membre (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- 💡 MÉTHODE EXISTANTE : Inviter un membre (POST) ---

  /// Envoie une invitation à un membre via l'API: api/invitations
  Future<void> inviteFamilyMember({
    required int familleId,
    required String nomComplet,
    required String email,
    required String telephone,
    required String lienParent,
  }) async {
    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse('$_baseUrl/api/invitations');

    // 💡 CORRECTION DES NOMS DE CLÉS pour correspondre au DTO InvitationRequest du backend
    final Map<String, dynamic> body = {
      'idFamille': familleId,
      'nomInvite': nomComplet,
      'emailInvite': email,
      'telephone': telephone,
      'lienParente': lienParent,
      'roleSuggeré': 'LECTEUR', // Rôle par défaut pour les invitations
    };

    final http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      String errorMessage = "Échec de l'envoi de l'invitation (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- ✅ NOUVELLE MÉTHODE : Changer le rôle d'un membre (PUT) ---

  /// Change le rôle d'un membre via l'API: api/familles/{familleId}/membres/{membreId}/role
  /// Autorise uniquement les rôles "EDITEUR" et "LECTEUR".
  /// Retourne le modèle FamilyModel mis à jour.
  Future<FamilyModel> updateMemberRole({
    required int familleId,
    required int membreId,
    required String nouveauRole,
  }) async {
    // 1. Validation de rôle (contrainte utilisateur)
    const allowedRoles = ['EDITEUR', 'LECTEUR'];
    if (!allowedRoles.contains(nouveauRole.toUpperCase())) {
      throw Exception("Le rôle '$nouveauRole' n'est pas autorisé pour cette action. Seuls 'EDITEUR' et 'LECTEUR' sont permis.");
    }

    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse('$_baseUrl/api/familles/$familleId/membres/$membreId/role');

    final Map<String, dynamic> body = {
      'nouveauRole': nouveauRole,
    };

    final http.Response response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      // L'API retourne le modèle FamilyModel mis à jour
      final Map<String, dynamic> jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return FamilyModel.fromJson(jsonMap);
    } else {
      String errorMessage = "Échec de la mise à jour du rôle (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
