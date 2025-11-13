// Fichier : lib/service/ArbreGenealogiqueService.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// 💡 Assurez-vous que les chemins d'importation vers vos modèles sont corrects
import '../model/FamilleModel.dart';
import '../model/membre.dart';
import '../model/MembreDetailsModel.dart'; // 🔑 NOUVEL IMPORTATION
import '../model/ContributionFamilleModel.dart';
import 'Auth-service.dart';

class ArbreGenealogiqueService {
  // 🔑 REMPLACEZ PAR VOTRE URL DE BASE RÉELLE
  static const String _baseUrl = "http://10.0.2.2:8080";

  final AuthService _authService = AuthService();

  // -------------------------------------------------------------------
  // --- Méthode d'utilitaire pour obtenir le Token ---
  // -------------------------------------------------------------------
  Future<String?> _getAuthToken() async {
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      debugPrint("Erreur: Token d'authentification non trouvé.");
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
      final Map<String, dynamic> jsonBody = json.decode(utf8.decode(response.bodyBytes));
      return Famille.fromJson(jsonBody);
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
  // 🔑 --- NOUVELLE MÉTHODE : Récupération des détails d'un membre (GET /api/arbre-généalogique/membre/{membreId}) ---
  // -------------------------------------------------------------------

  /// Récupère les détails complets d'un membre spécifique.
  Future<List<MembreDetail>> fetchMembreDetail({required int membreId}) async {
    final String? token = await _getAuthToken();

    // Utilisez le chemin d'accès correct, en supposant que l'erreur d'encodage 'é' a été corrigée
    // Remplacer "généalogique" par "genealogique" est fortement conseillé.
    final Uri uri = Uri.parse('$_baseUrl/api/arbre-genealogique/membre/$membreId/membres-lies');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Réponse GET Membre Détail $membreId (Status): ${response.statusCode}');

    if (response.statusCode == 200) {
      // 🔑 MODIFICATION CLÉ : Décodage comme une LISTE
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));

      // Mappage de chaque élément de la liste en MembreDetail
      return jsonList.map((json) => MembreDetail.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      String errorMessage = "Échec du chargement des détails du membre $membreId (Statut: ${response.statusCode}).";
      // ... (gestion des erreurs inchangée) ...
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
  // 🔑 --- 2. Récupération de TOUS les membres (GET /api/arbre-genealogique/membres?familleId=...) ---
  // -------------------------------------------------------------------

  /// Récupère la liste de tous les membres pour la sélection des parents.
  Future<List<Membre>> fetchAllMembres({required int familleId}) async {
    final String? token = await _getAuthToken();

    // 🔑 Construction de l'URI avec le paramètre de requête pour filtrer par famille
    final Uri uri = Uri.parse('$_baseUrl/api/arbre-genealogique/famille/$familleId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Réponse GET All Membres (Status): ${response.statusCode}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      // 🔑 Mappage de la liste JSON en List<Membre>
      return jsonList.map((json) => Membre.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      String errorMessage = "Échec du chargement de la liste des membres (Statut: ${response.statusCode}).";
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
  // --- 3. Création d'un Nouveau Membre (POST /api/arbre-genealogique/ajouter-membre) ---
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
    final Uri uri = Uri.parse('$_baseUrl/api/arbre-genealogique/ajouter-membre');

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
          'photo',
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
  // --- 4. Récupération des Contributions (GET /api/contributions/famille/{familleId}) ---
  // -------------------------------------------------------------------

  /// Récupère les statistiques de contributions pour une famille donnée.
  Future<ContributionsFamilleModel> fetchContributionsFamille({required int familleId}) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse('$_baseUrl/api/contributions/famille/$familleId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Réponse GET Contributions (Status): ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return ContributionsFamilleModel.fromJson(jsonResponse);
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