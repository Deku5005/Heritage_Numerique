// Fichier: lib/services/DevinetteApiService.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/DevinetteModel.dart'; // Import du modèle créé
import 'Auth-service.dart'; // 💡 AJOUT : Import du service d'authentification

// Base URL de votre API (inspirée de l'exemple Proverbe)
const String _baseUrl = 'http://10.0.2.2:8080';

class DevinetteApiService {
  // 💡 SUPPRESSION : Le jeton n'est plus injecté directement, mais obtenu via AuthService.
  // final String authToken;

  final AuthService _authService = AuthService(); // Instance du service d'auth

  // 💡 REMPLACEMENT : Le constructeur n'a plus besoin du authToken en paramètre
  DevinetteApiService();

  // --- Méthode d'utilitaire pour obtenir le Token ---
  Future<String?> _getAuthToken() async {
    // 💡 NOTE : Ceci suppose que vous avez une méthode getAuthToken() dans votre AuthService
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      print("Erreur: Token d'authentification non trouvé.");
      throw Exception("Token d'authentification non trouvé. Veuillez vous reconnecter.");
    }
    return token;
  }

  // --- 1. RÉCUPÉRATION DES DEVINETTES PAR FAMILLE (GET) ---
  Future<List<Devinette>> fetchDevinettesByFamily(int familyId) async {
    final String? token = await _getAuthToken();
    final url = Uri.parse(_baseUrl).resolve('/api/devinettes/famille/$familyId');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Utilisation du jeton
      });

      if (response.statusCode == 200) {
        // La réponse est une liste d'objets JSON
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((jsonItem) => Devinette.fromJson(jsonItem)).toList();
      } else {
        String errorMessage = "Échec du chargement des devinettes (Statut: ${response.statusCode}).";
        try {
          final Map<String, dynamic> errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {
          errorMessage += " Réponse brute: ${response.body}";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erreur lors de la récupération des devinettes: $e');
      rethrow;
    }
  }

  // --- 2. CRÉATION D'UNE NOUVELLE DEVINETTE (POST - multipart/form-data) ---
  Future<void> createDevinette({
    required int idFamille,
    required int idCategorie,
    required String titre,
    required String texteDevinette,
    required String reponseDevinette,
    String? lieu,
    String? region,
    File? photoDevinetteFile, // Le fichier photo optionnel
  }) async {
    final String? token = await _getAuthToken();
    final url = Uri.parse(_baseUrl).resolve('/api/contenus/devinette');

    // Créer une requête de type multipart/form-data
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token'; // Utilisation du jeton

    // Ajouter les champs de texte obligatoires et optionnels
    request.fields['idFamille'] = idFamille.toString();
    request.fields['idCategorie'] = idCategorie.toString();
    request.fields['titre'] = titre;
    request.fields['texteDevinette'] = texteDevinette;
    request.fields['reponseDevinette'] = reponseDevinette;

    if (lieu != null && lieu.isNotEmpty) {
      request.fields['lieu'] = lieu;
    }
    if (region != null && region.isNotEmpty) {
      request.fields['region'] = region;
    }

    // Ajouter le fichier si présent
    if (photoDevinetteFile != null) {
      // Créer un MultipartFile à partir du fichier
      request.files.add(await http.MultipartFile.fromPath(
        'photoDevinette', // Nom du champ dans le corps de la requête (Request body)
        photoDevinetteFile.path,
        // contentType: MediaType('image', 'jpeg'), // Le type mime est souvent déduit ou géré par le backend
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Réponse POST /api/contenus/devinette: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Succès de la création
        return;
      } else {
        // Échec de la création
        String errorMessage = "Échec de la création de la devinette (Statut: ${response.statusCode}).";
        try {
          final Map<String, dynamic> errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {
          errorMessage += " Réponse brute: ${response.body}";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erreur réseau ou d\'envoi lors de la création de la devinette: $e');
      rethrow;
    }
  }
}
