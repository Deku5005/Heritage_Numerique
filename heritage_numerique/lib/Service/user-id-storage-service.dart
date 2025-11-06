import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// NOTE: Le package 'flutter_secure_storage' est requis.

/// Service pour gérer l'accès asynchrone à l'ID de l'enregistrement Membre
/// (l'ID que l'API Membre attend, souvent 'id' dans la réponse de connexion).
class MembreIdStorageService {

  // Instance du stockage sécurisé
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Clé utilisée pour stocker et récupérer l'ID de l'enregistrement Membre
  static const String _membreIdKey = 'membre_id';

  // 1. Sauvegarder l'ID de Membre (l'ID d'enregistrement: ex. 1)
  // L'ID est passé en String (la conversion depuis l'int doit être faite par l'AuthService).
  Future<void> saveMembreId(String membreId) async {
    await _storage.write(key: _membreIdKey, value: membreId);
  }

  // 2. Récupérer l'ID de Membre dynamiquement
  // Retourne l'ID sous forme de chaîne ou null s'il n'existe pas.
  Future<String?> getMembreId() async {
    return await _storage.read(key: _membreIdKey);
  }

  // 3. Supprimer l'ID de Membre (À appeler lors de la déconnexion)
  Future<void> deleteMembreId() async {
    await _storage.delete(key: _membreIdKey);
  }
}