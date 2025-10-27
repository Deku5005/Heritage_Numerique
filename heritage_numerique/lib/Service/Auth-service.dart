import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:heritage_numerique/model/auth-response.dart';
import 'package:heritage_numerique/model/dashboard-models.dart';
import 'token-storage-service.dart'; // Import du service de stockage

/// Service centralisé pour l'authentification et les appels d'API protégés.
class AuthService {
  // Service pour gérer le stockage sécurisé du token
  final TokenStorageService _tokenStorageService = TokenStorageService();

  // CONSTRUCTEUR AJOUTÉ/MODIFIÉ POUR LA COMPATIBILITÉ
  // Il accepte l'argument nommé 'authToken', mais l'ignore car le service utilise
  // déjà TokenStorageService pour la persistance.
  AuthService({String? authToken});


  // *********** Configuration des Endpoints ***********
  // NOTE: Adresse IP locale de l'émulateur Android vers l'hôte (Backend Java/Spring)
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static const String _registerUrl = '$_baseUrl/api/auth/register';
  static const String _loginUrl = '$_baseUrl/api/auth/login';
  static const String _loginWithCodeUrl = '$_baseUrl/api/auth/login-with-code';
  static const String _dashboardPersonnelUrl = '$_baseUrl/api/dashboard/personnel';


  // ✅ EXPOSITION DE getAuthToken
  Future<String?> getAuthToken() async {
    return await _tokenStorageService.getAuthToken();
  }


  // ===================================
  // 1. MÉTHODE D'INSCRIPTION : register()
  // ===================================

  Future<AuthResponse> register({
    required String nom,
    required String prenom,
    required String email,
    required String numeroTelephone,
    required String ethnie,
    required String motDePasse,
    String? codeInvitation,
  }) async {
    final Map<String, dynamic> requestBody = {
      "nom": nom,
      "prenom": prenom,
      "email": email,
      "numeroTelephone": numeroTelephone,
      "ethnie": ethnie,
      "motDePasse": motDePasse,
      if (codeInvitation != null && codeInvitation.isNotEmpty)
        "codeInvitation": codeInvitation,
    };

    try {
      final response = await http.post(
        Uri.parse(_registerUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        if (response.body.isEmpty) {
          print('Réponse ${response.statusCode} OK. Corps vide. Inscription réussie.');
          return AuthResponse(
            accessToken: 'Success_No_Token',
            tokenType: 'Bearer',
            userId: 0,
            email: email,
            nom: nom,
            prenom: prenom,
            role: 'ROLE_MEMBRE',
          );
        }

        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          final authResponse = AuthResponse.fromJson(jsonResponse);
          return authResponse;

        } on FormatException {
          throw Exception('Erreur de décodage JSON après succès ${response.statusCode}. Le corps est invalide.');
        } on TypeError catch (e) {
          throw Exception('Erreur de conversion de type après succès ${response.statusCode}. Détail: ${e.toString()}');
        }

      } else {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Erreur serveur. Statut: ${response.statusCode}';
          throw Exception(errorMessage);
        } on FormatException {
          throw Exception('Échec de l\'inscription. Statut: ${response.statusCode}. Réponse serveur non lisible.');
        }
      }
    } catch (e) {
      throw Exception('Échec de la connexion réseau ou erreur non gérée : $e');
    }
  }


  // ===================================
  // 2. MÉTHODE DE CONNEXION : login()
  // ===================================

  Future<AuthResponse> login({
    required String email,
    required String motDePasse,
    String? codeInvitation,
  }) async {
    final bool useCode = codeInvitation != null && codeInvitation.isNotEmpty;
    final String url = useCode ? _loginWithCodeUrl : _loginUrl;

    final Map<String, dynamic> requestBody = {
      "email": email,
      "motDePasse": motDePasse,
      if (useCode) "codeInvitation": codeInvitation!,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {

        if (response.body.isEmpty) {
          throw Exception('Connexion réussie (200 OK), mais la réponse est vide. Token manquant.');
        }

        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          final authResponse = AuthResponse.fromJson(jsonResponse);

          // ✅ Stockage du token après succès
          await _tokenStorageService.saveAuthToken(authResponse.accessToken);

          return authResponse;

        } on FormatException {
          throw Exception('Erreur de décodage JSON. Le corps de la réponse 200 est invalide.');
        } on TypeError catch (e) {
          throw Exception('Erreur de conversion de type après succès 200. Détail: ${e.toString()}');
        }

      } else {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? errorBody['error'] ?? 'Échec de connexion. Statut: ${response.statusCode}';
          throw Exception(errorMessage);
        } on FormatException {
          throw Exception('Échec de la connexion. Statut: ${response.statusCode}. Réponse serveur non lisible.');
        }
      }
    } catch (e) {
      throw Exception('Échec de la connexion ou erreur réseau : $e');
    }
  }


  // ===================================
  // 3. MÉTHODE DU TABLEAU DE BORD : fetchPersonnelDashboard()
  // ===================================

  Future<DashboardPersonnelResponse> fetchPersonnelDashboard() async {
    final String? token = await getAuthToken();

    if (token == null || token.isEmpty || token == 'Success_No_Token') {
      throw Exception('Jeton d\'authentification manquant. Veuillez vous reconnecter.');
    }

    try {
      final response = await http.get(
        Uri.parse(_dashboardPersonnelUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Réponse 200 OK, mais corps du tableau de bord vide.');
        }

        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          return DashboardPersonnelResponse.fromJson(jsonResponse);

        } on FormatException {
          throw Exception('Erreur de décodage JSON pour le tableau de bord.');
        } on TypeError catch (e) {
          throw Exception('Erreur de conversion de type pour le tableau de bord. Détail: ${e.toString()}');
        }

      } else if (response.statusCode == 401) {
        throw Exception('Non autorisé. Le jeton Bearer est invalide ou expiré.');
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Erreur serveur. Statut: ${response.statusCode}';
          throw Exception(errorMessage);
        } on FormatException {
          throw Exception('Échec de chargement du tableau de bord. Statut: ${response.statusCode}. Réponse serveur non lisible.');
        }
      }
    } catch (e) {
      throw Exception('Échec de la connexion réseau pour le tableau de bord : $e');
    }
  }

  // Méthode de déconnexion pour supprimer le token
  Future<void> logout() async {
    await _tokenStorageService.deleteAuthToken();
  }
}
