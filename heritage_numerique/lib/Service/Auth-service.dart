import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:heritage_numerique/model/auth-response.dart';
import 'package:heritage_numerique/model/dashboard-models.dart';
import 'token-storage-service.dart'; // Import du service de stockage du Token
// ✅ CORRECTION DE L'IMPORT: Utilisation du service de stockage de l'ID Membre
import 'user-id-storage-service.dart';
import '../config/api_config.dart';

/// Service centralisé pour l'authentification et les appels d'API protégés.
class AuthService {
  // Service pour gérer le stockage sécurisé du token
  final TokenStorageService _tokenStorageService = TokenStorageService();
  // NOUVEAU: Service pour gérer le stockage sécurisé de l'ID Membre (l'ID que l'API attend)
  final MembreIdStorageService _membreIdStorageService = MembreIdStorageService();

  // CONSTRUCTEUR AJOUTÉ/MODIFIÉ POUR LA COMPATIBILITÉ
  AuthService({String? authToken});


  // *********** Configuration des Endpoints ***********
  // NOTE: Adresse IP locale de l'émulateur Android vers l'hôte (Backend Java/Spring)
  static String get _baseUrl => ApiConfig.baseUrl;

  static String get _registerUrl => '$_baseUrl/api/auth/register';
  static String get _loginUrl => '$_baseUrl/api/auth/login';
  static String get _loginWithCodeUrl => '$_baseUrl/api/auth/login-with-code';
  static String get _dashboardPersonnelUrl => '$_baseUrl/api/dashboard/personnel';


  // ✅ EXPOSITION DE getAuthToken
  Future<String?> getAuthToken() async {
    return await _tokenStorageService.getAuthToken();
  }

  // ✅ NOUVEAU: EXPOSITION DE getMembreId
  // Renommé pour plus de clarté
  Future<String?> getMembreId() async {
    return await _membreIdStorageService.getMembreId();
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
    // 👇 LOG 1
    print('📤 [register] Début - email: $email');
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

    // 👇 LOG 2
    print('📤 [register] URL: $_registerUrl');
    print('📤 [register] Body: $requestBody');


    try {
      // 👇 LOG 3
      print('📤 [register] Envoi de la requête...');
      final response = await http.post(
        Uri.parse(_registerUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      ).timeout(Duration(seconds: 60)); ;

      // 👇 LOG 4
      print('📥 [register] Réponse reçue - Status: ${response.statusCode}');
      print('📥 [register] Body: ${response.body}');

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
      // 👇 LOG 5
      print('❌ [register] Exception: $e');
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

          // ✅ MODIFIÉ: Stockage de l'ID Membre (qui est userId dans AuthResponse)
          // C'est cet ID qui sera utilisé par MembreService
          await _membreIdStorageService.saveMembreId(authResponse.userId.toString());

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

  // Méthode de déconnexion pour supprimer le token et l'ID Membre
  Future<void> logout() async {
    await _tokenStorageService.deleteAuthToken();
    // ✅ MODIFIÉ: Suppression de l'ID Membre lors de la déconnexion
    await _membreIdStorageService.deleteMembreId();
  }
}