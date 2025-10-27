import 'package:heritage_numerique/models/auth_models.dart';
import 'package:heritage_numerique/repositories/base_repository.dart';
import 'package:heritage_numerique/api/api_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository pour toutes les opérations d'authentification
class AuthRepository extends BaseRepository {
  
  /// Inscription d'un nouvel utilisateur
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    return await post<AuthResponse>(
      '/auth/register',
      data: request.toJson(),
      fromJson: (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Connexion d'un utilisateur (pour plus tard)
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    return await post<AuthResponse>(
      '/auth/login',
      data: request.toJson(),
      fromJson: (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Sauvegarder les informations d'authentification
  Future<void> saveAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', authResponse.accessToken);
    await prefs.setString('token_type', authResponse.tokenType);
    await prefs.setInt('user_id', authResponse.userId);
    await prefs.setString('user_email', authResponse.email);
    await prefs.setString('user_nom', authResponse.nom);
    await prefs.setString('user_prenom', authResponse.prenom);
    await prefs.setString('user_role', authResponse.role);
  }

  /// Récupérer les informations d'authentification sauvegardées
  Future<AuthResponse?> getSavedAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final token = prefs.getString('auth_token');
    final tokenType = prefs.getString('token_type');
    final userId = prefs.getInt('user_id');
    final email = prefs.getString('user_email');
    final nom = prefs.getString('user_nom');
    final prenom = prefs.getString('user_prenom');
    final role = prefs.getString('user_role');

    if (token != null && tokenType != null && userId != null && 
        email != null && nom != null && prenom != null && role != null) {
      return AuthResponse(
        accessToken: token,
        tokenType: tokenType,
        userId: userId,
        email: email,
        nom: nom,
        prenom: prenom,
        role: role,
      );
    }
    
    return null;
  }

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final authData = await getSavedAuthData();
    return authData != null;
  }

  /// Déconnexion - supprimer toutes les données d'authentification
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('token_type');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_nom');
    await prefs.remove('user_prenom');
    await prefs.remove('user_role');
  }

  /// Obtenir le token d'authentification actuel
  Future<String?> getCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Obtenir l'ID de l'utilisateur actuel
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  /// Obtenir le rôle de l'utilisateur actuel
  Future<String?> getCurrentUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }
}
