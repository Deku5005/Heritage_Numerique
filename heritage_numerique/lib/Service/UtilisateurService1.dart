import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // N'est plus nécessaire ici si les services de stockage l'importent

// =================================================================
// IMPORTS DES CLASSES EXISTANTES (À AJUSTER SELON VOTRE STRUCTURE DE PROJET)
// =================================================================

// 1. Modèle Utilisateur1 (doit contenir fromJson, toJson, etc.)
// => Chemin ajusté pour correspondre à la structure lib/models/utilisateur1.dart
import '../model/utilisateur1.dart';

// 2. Services de Stockage
// => Chemins ajustés
import 'token-storage-service.dart';
import 'user-id-storage-service.dart'; // Utilisation du nom MembreIdStorageService


// =================================================================
// SERVICE D'APPEL API : UtilisateurService1
// =================================================================

class UtilisateurService1 {
  // REMPLACER avec l'URL de base de votre API
  final String _baseUrl = 'http://10.0.2.2:8080/api/utilisateurs';

  // Injection des dépendances des services de stockage
  final TokenStorageService _tokenStorage;
  final MembreIdStorageService _membreIdStorage;

  UtilisateurService1({
    TokenStorageService? tokenStorage,
    MembreIdStorageService? membreIdStorage,
  }) : _tokenStorage = tokenStorage ?? TokenStorageService(),
        _membreIdStorage = membreIdStorage ?? MembreIdStorageService();


  /// Récupère un utilisateur par son ID en utilisant le token JWT pour l'authentification.
  Future<Utilisateur1> getUtilisateur(int id) async {
    final String url = '$_baseUrl/$id';

    // 1. Récupérer le token d'authentification
    final String? token = await _tokenStorage.getAuthToken();

    if (token == null) {
      throw Exception('Token d\'authentification manquant. L\'utilisateur n\'est pas connecté.');
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      // Ajouter le token JWT dans l'en-tête d'autorisation
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      // 2. Vérifier le code de statut de la réponse
      if (response.statusCode == 200) {
        // Décodage du corps de la réponse JSON
        // Utilisation de utf8.decode(response.bodyBytes) pour gérer les caractères spéciaux (accents, etc.)
        final Map<String, dynamic> jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));

        // Création et retour de l'objet Utilisateur1
        return Utilisateur1.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        // Gérer spécifiquement l'erreur d'authentification
        throw Exception('Non autorisé (401). Le token est invalide ou expiré.');
      } else {
        // Gérer les autres erreurs HTTP
        throw Exception(
            'Échec de la récupération de l\'utilisateur $id. Code statut: ${response.statusCode}. Corps de réponse: ${response.body}'
        );
      }
    } catch (e) {
      // Gérer les erreurs de connexion, de timeout ou de parsing
      throw Exception('Erreur lors de l\'appel API pour Utilisateur $id: $e');
    }
  }

  /// Fonction utilitaire pour récupérer l'utilisateur actuellement connecté (via l'ID stocké)
  Future<Utilisateur1> getCurrentUser() async {
    final String? idString = await _membreIdStorage.getMembreId();

    if (idString == null) {
      throw Exception("ID d'utilisateur connecté manquant dans le stockage sécurisé. Veuillez vous reconnecter.");
    }

    final int? id = int.tryParse(idString);
    if (id == null) {
      throw Exception("L'ID stocké ('$idString') n'est pas un nombre valide.");
    }

    return getUtilisateur(id);
  }

  /// Met à jour le profil de l'utilisateur actuellement connecté.
  /// [updateData] est un Map contenant les champs à modifier (nom, prenom, numeroTelephone, ethnie, motDePasse, etc.).
  Future<void> updateProfile(Map<String, dynamic> updateData) async {
    // 1. Récupérer l'ID de l'utilisateur connecté
    final String? idString = await _membreIdStorage.getMembreId();
    if (idString == null) {
      throw Exception("ID d'utilisateur connecté manquant pour la mise à jour.");
    }
    final int? id = int.tryParse(idString);
    if (id == null) {
      throw Exception("L'ID stocké ('$idString') n'est pas un nombre valide.");
    }

    final String url = '$_baseUrl/$id';

    // 2. Récupérer le token d'authentification
    final String? token = await _tokenStorage.getAuthToken();

    if (token == null) {
      throw Exception('Token d\'authentification manquant. L\'utilisateur n\'est pas connecté.');
    }

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      // Ajouter le token JWT dans l'en-tête d'autorisation
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        // 3. Envoyer les données de mise à jour au format JSON
        body: jsonEncode(updateData),
      );

      // 4. Vérifier le code de statut de la réponse
      // L'API peut retourner 200 OK ou 204 No Content pour une mise à jour réussie.
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Mise à jour réussie. Retourne sans erreur.
        return;
      } else if (response.statusCode == 400) {
        // 400 Bad Request: Erreur de validation ou format de données incorrect.
        final errorBody = jsonDecode(response.body);
        throw Exception('Erreur de validation lors de la mise à jour: ${errorBody['message'] ?? response.body}');
      } else if (response.statusCode == 401) {
        // Gérer spécifiquement l'erreur d'authentification
        throw Exception('Non autorisé (401). Le token est invalide ou expiré.');
      } else {
        // Gérer les autres erreurs HTTP
        throw Exception(
            'Échec de la mise à jour du profil. Code statut: ${response.statusCode}. Corps de réponse: ${response.body}'
        );
      }
    } catch (e) {
      // Gérer les erreurs de connexion, de timeout ou de parsing
      throw Exception('Erreur lors de l\'appel API pour la mise à jour du profil: $e');
    }
  }
}