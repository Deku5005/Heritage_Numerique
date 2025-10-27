/// Configuration de l'API
class ApiConfig {
  // URL de base de votre API Spring Boot
  // Changez cette URL selon votre configuration
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Pour les tests avec un émulateur Android, utilisez :
  // static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  // Pour les tests avec un appareil physique, utilisez l'IP de votre machine :
  // static const String baseUrl = 'http://192.168.1.100:8080/api';
  
  // Pour la production, utilisez votre domaine :
  // static const String baseUrl = 'https://votre-domaine.com/api';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
