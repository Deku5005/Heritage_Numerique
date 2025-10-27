// lib/Service/family-service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:heritage_numerique/model/dashboard-models.dart';
import 'token-storage-service.dart';

// Remplacez par votre URL de base API réelle
const String _baseUrl = "http://10.0.2.2:8080";

class FamilyService {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<Famille> createFamily(String nom, String description, String ethnie, String region) async {
    final url = Uri.parse('$_baseUrl/api/familles');

    final token = await _tokenStorageService.getAuthToken();

    if (token == null || token.isEmpty) {
      throw Exception("Utilisateur non authentifié. Veuillez vous reconnecter.");
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "nom": nom,
      "description": description,
      "ethnie": ethnie,
      "region": region,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {

        // ✅ NOUVEAU: Vérification si le corps est vide
        if (response.bodyBytes.isEmpty) {
          // Si le serveur enregistre et renvoie un 201 SANS corps,
          // nous devons supposer le succès mais ne pouvons pas construire l'objet.
          // Pour l'instant, on lance une erreur explicite pour identifier la cause.
          throw Exception("Création réussie (201) mais le serveur n'a pas renvoyé l'objet Famille créé. La base de données est mise à jour.");
        }

        try {
          final Map<String, dynamic> responseJson = jsonDecode(utf8.decode(response.bodyBytes));
          // Si l'erreur se produit ici, c'est dans Famille.fromJson que le null n'est pas géré.
          return Famille.fromJson(responseJson);

        } on TypeError catch (e) {
          // Capte l'erreur 'Null is not subtype of String' et la rend explicite.
          throw Exception("Erreur de décodage du modèle Famille (Null or Type mismatch): ${e.toString()}");
        }


      } else {
        String errorMessage = "Erreur du serveur";
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorBody['detail'] ?? errorMessage;
        } catch (_) {}

        throw Exception("Échec de la création de la famille (${response.statusCode}): $errorMessage");
      }
    } catch (e) {
      throw Exception("Échec de la connexion réseau pour la création de famille: $e");
    }
  }
}