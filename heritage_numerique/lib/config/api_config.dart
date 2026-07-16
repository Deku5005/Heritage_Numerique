import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  /// Récupère la base URL de l'API depuis le fichier `.env` ou utilise la valeur de secours.
  static String get baseUrl {
    final String? url = dotenv.env['API_BASE_URL'];
    if (url != null && url.isNotEmpty) {
      return url;
    }
    // Valeur par défaut vers Render
    return "https://heritage-numerique-api.onrender.com";
  }

  /// Convertit un chemin de média relatif en URL absolue.
  static String? ensureFullUrl(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseUrl/$cleanPath';
  }
}
