import 'package:heritage_numerique/api/api_client.dart';
import 'package:flutter/material.dart';

/// Service de configuration et d'initialisation de l'API
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late ApiClient _apiClient;
  
  /// Initialiser le service API
  void initialize() {
    _apiClient = ApiClient();
    _apiClient.initialize();
  }

  /// Obtenir le client API
  ApiClient get apiClient => _apiClient;

  /// Configurer l'URL de base de l'API
  void setBaseUrl(String baseUrl) {
    // Cette méthode peut être étendue pour permettre le changement dynamique de l'URL
    // Pour l'instant, l'URL est définie dans ApiClient
  }

  /// Vérifier la connectivité
  Future<bool> checkConnectivity() async {
    try {
      // Test simple de connectivité
      await _apiClient.get('/health'); // Assurez-vous que votre API a un endpoint /health
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Extension pour les widgets Flutter pour faciliter l'accès à l'API
extension ApiServiceExtension on BuildContext {
  ApiService get apiService => ApiService();
}
