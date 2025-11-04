import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // Pour 'debugPrint' au lieu de 'print' en prod
// 💡 Assurez-vous que les chemins d'importation vers vos modèles sont corrects
import '../model/FamilleModel.dart';
import '../model/Membre.dart';
import '../model/ContributionFamilleModel.dart'; // 🔑 Import du nouveau modèle de contributions
// 💡 Assurez-vous que le chemin d'importation vers votre service d'authentification est correct
import 'Auth-service.dart';

class ArbreGenealogiqueService {
  // 🔑 REMPLACEZ PAR VOTRE URL DE BASE RÉELLE
  static const String _baseUrl = "http://10.0.2.2:8080";

  final AuthService _authService = AuthService();

  // -------------------------------------------------------------------
  // --- Méthode d'utilitaire pour obtenir le Token (Héritée du modèle) ---
  // -------------------------------------------------------------------
  Future<String?> _getAuthToken() async {
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      debugPrint("Erreur: Token d'authentification non trouvé.");
      // 🔑 Il est préférable de jeter une exception pour forcer la gestion de la déconnexion
      throw Exception("Token d'authentification non trouvé. Veuillez vous reconnecter.");
    }
    return token;
  }

  // -------------------------------------------------------------------
  // --- 1. Récupération de l'Arbre Généalogique (GET /api/arbre-genealogique/famille/{familleId}) ---
  // -------------------------------------------------------------------

  /// Récupère l'arbre généalogique complet pour une famille donnée.
  Future<Famille> fetchFamille({required int familleId}) async {
    final String? token = await _getAuthToken();

    // Construction de l'URI avec l'ID de la famille
    final Uri uri = Uri.parse('$_baseUrl/api/arbre-genealogique/famille/$familleId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Réponse GET Famille (Status): ${response.statusCode}');

    if (response.statusCode == 200) {
      // Décodage du JSON, en gérant l'encodage si nécessaire
      final Map<String, dynamic> jsonBody = json.decode(utf8.decode(response.bodyBytes));
      return Famille.fromJson(jsonBody); // Utilisation du modèle Famille
    } else {
      String errorMessage = "Échec du chargement de la famille (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage += " Réponse brute: ${response.body}";
      }
      throw Exception(errorMessage);
    }
  }

  // -------------------------------------------------------------------
  // --- 2. Création d'un Nouveau Membre (POST /api/arbre-genealogique/ajouter-membre) ---
  // -------------------------------------------------------------------

  /// Crée un nouveau membre en utilisant un formulaire multipart/form-data.
  Future<void> createMembre({
    // Champs requis
    required String nomComplet,
    required String dateNaissance, // Format YYYY-MM-DD
    required String lieuNaissance,
    required String relationFamiliale,
    required int idFamille,
    // Champs optionnels
    String? photoPath, // Chemin local du fichier photo
    String? telephone,
    String? email,
    String? biographie,
    int? parent1Id,
    int? parent2Id,
  }) async {
    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse('$_baseUrl/api/arbre-genealogique/ajouter-membre'); // Construction plus propre

    // 💡 Configuration de la requête multipart pour le fichier
    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    // Ajout des champs de texte requis
    request.fields['nomComplet'] = nomComplet;
    request.fields['dateNaissance'] = dateNaissance;
    request.fields['lieuNaissance'] = lieuNaissance;
    request.fields['relationFamiliale'] = relationFamiliale;
    request.fields['idFamille'] = idFamille.toString();

    // Ajout des champs de texte optionnels
    if (telephone != null && telephone.isNotEmpty) request.fields['telephone'] = telephone;
    if (email != null && email.isNotEmpty) request.fields['email'] = email;
    if (biographie != null && biographie.isNotEmpty) request.fields['biographie'] = biographie;
    // Les IDs parents sont des entiers optionnels, convertis en String
    if (parent1Id != null) request.fields['parent1Id'] = parent1Id.toString();
    if (parent2Id != null) request.fields['parent2Id'] = parent2Id.toString();

    // Ajouter le fichier photo
    if (photoPath != null && photoPath.isNotEmpty) {
      final File file = File(photoPath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo', // 🔑 NOM DU CHAMP CÔTÉ SERVEUR (d'après votre API)
          photoPath,
        ));
      } else {
        debugPrint("Avertissement: Le fichier photo spécifié n'existe pas : $photoPath");
      }
    }

    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(streamedResponse);

    debugPrint('Réponse POST Nouveau Membre (Status): ${response.statusCode}');
    debugPrint('Corps de la réponse: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Succès
      return;
    } else {
      String errorMessage = "Échec de la création du membre (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage += " Réponse brute: ${response.body}";
      }
      throw Exception(errorMessage);
    }
  }

  // -------------------------------------------------------------------
  // --- 3. Récupération des Contributions (GET /api/contributions/famille/{familleId}) ---
  // -------------------------------------------------------------------

  /// Récupère les statistiques de contributions pour une famille donnée.
  Future<ContributionsFamilleModel> fetchContributionsFamille({required int familleId}) async {
    final String? token = await _getAuthToken();

    // Construction de l'URI
    final Uri uri = Uri.parse('$_baseUrl/api/contributions/famille/$familleId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 🔑 Nécessite l'authentification
      },
    );

    debugPrint('Réponse GET Contributions (Status): ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return ContributionsFamilleModel.fromJson(jsonResponse); // Utilisation du modèle
    } else {
      String errorMessage = "Échec du chargement des contributions (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        errorMessage += " Réponse brute: ${response.body}";
      }
      throw Exception(errorMessage);
    }
  }
}