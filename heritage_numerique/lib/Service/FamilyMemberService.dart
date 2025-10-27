import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/family_member_model.dart';
import 'Auth-service.dart';

class FamilyMemberService {
  // ⚠️ Remplacez par votre URL de base (doit être la même que dans DashboardService)
  static const String _baseUrl = "http://10.0.2.2:8080";
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

  // --- 💡 NOUVELLE MÉTHODE : Ajouter un membre manuellement (POST) ---

  /// Ajoute un nouveau membre manuellement à la famille via l'API: api/membres
  Future<void> addFamilyMemberManual({
    required int familleId,
    required String nomComplet,
    required String lienParent,
    required String telephone,
    String? description,
  }) async {
    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse('$_baseUrl/api/membres');

    final Map<String, dynamic> body = {
      'idFamille': familleId,       // 💡 CORRECTION DU NOM DE CLÉ pour correspondre au style du backend
      'nomComplet': nomComplet,
      'lienParent': lienParent,
      'telephone': telephone,
      'description': description,
      'statut': 'ACCEPTE',
      'roleFamille': 'LECTEUR',
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
      String errorMessage = "Échec de l'ajout manuel du membre (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  // --- 💡 NOUVELLE MÉTHODE : Inviter un membre (POST) ---

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
      'idFamille': familleId,       // 💡 CORRECTION DU NOM DE CLÉ (était 'familleId')
      'nomInvite': nomComplet,      // 💡 CORRECTION DU NOM DE CLÉ (était 'nomComplet')
      'emailInvite': email,         // 💡 CORRECTION DU NOM DE CLÉ (était 'email')
      'telephone': telephone,
      'lienParente': lienParent,    // 💡 CORRECTION DU NOM DE CLÉ (était 'lienParent')
      'roleSuggeré': 'LECTEUR',
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
}
