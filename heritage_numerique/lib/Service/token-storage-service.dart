// lib/Service/token-storage-service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// NOTE: Le package 'flutter_secure_storage' doit être ajouté à pubspec.yaml

// Service pour gérer l'accès asynchrone au token d'authentification de manière sécurisée.
class TokenStorageService {

  // Instance du stockage sécurisé
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Clé utilisée pour stocker et récupérer le token
  static const String _tokenKey = 'jwt_token';

  // 1. Sauvegarder le token (À appeler après une connexion réussie)
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // 2. Récupérer le token dynamiquement (Utilisé par les services d'API)
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // 3. Supprimer le token (À appeler lors de la déconnexion)
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _tokenKey);
  }
}