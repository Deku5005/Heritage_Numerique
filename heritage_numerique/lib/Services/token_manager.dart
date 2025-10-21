// lib/Service/token_manager.dart

import 'package:shared_preferences/shared_preferences.dart'; // Doit fonctionner après le 'clean'

class TokenManager {
  static const String _tokenKey = 'accessToken';

  /// Sauvegarde le token d'accès après une connexion réussie.
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('Token sauvegardé: $token');
  }

  /// Récupère le token d'accès sauvegardé.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Supprime le token (pour la déconnexion).
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('Token supprimé.');
  }
}