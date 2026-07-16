// Fichier : lib/service/ArbreGenealogiqueService.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

// 🔑 CORRECTION IMPORT 1: On suppose que le modèle de Famille est Famille.dart (ou FamillyModel.dart, à vérifier)
// J'utilise Famille.dart pour uniformiser, mais si FamilleModel.dart est votre nom final, remettez-le.
import '../model/FamilleModel.dart';
// 🔑 CORRECTION IMPORT 2: Changement de 'membre.dart' (minuscule) à 'Membre.dart' (Majuscule)
import '../model/Membre.dart';
import '../model/MembreDetailsModel.dart';
import '../model/ContributionFamilleModel.dart';
import 'Auth-service.dart';

class ArbreGenealogiqueService {
  static String get _baseUrl => ApiConfig.baseUrl;

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
  // 🔑 --- 1. Récupération de l'Arbre Généalogique (GET /famille/{familleId}/hierarchique) ---
  // -------------------------------------------------------------------

  /// Récupère l'arbre généalogique complet et hiérarchisé pour une famille donnée.
  Future<Famille> fetchArbreHierarchique({required int familleId}) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse('$_baseUrl/api/arbre-genealogique/famille/$familleId/hierarchique');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint('Réponse GET Arbre Hiérarchique (Status): ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(utf8.decode(response.bodyBytes));
      return Famille.fromJson(jsonBody);
    } else {
      String errorMessage = "Échec du chargement de l'arbre (Statut: ${response.statusCode}).";
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
  // --- 2. Récupération des détails d'un membre (GET /membre/{membreId}/membres-lies) ---
  // -------------------------------------------------------------------

  /// Récupère les détails complets d'un membre spécifique et ses liens.
  Future<List<MembreDetail>> fetchMembreDetail({required int membreId}) async {
    final String? token = await _getAuthToken();
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
      final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => MembreDetail.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      String errorMessage = "Échec du chargement des détails du membre $membreId (Statut: ${response.statusCode}).";
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
  // 🔑 --- 3. Récupération de TOUS les membres (pour les menus déroulants) ---
  // -------------------------------------------------------------------

  /// Utilise fetchArbreHierarchique pour obtenir la structure arborescente puis l'aplatit.
  Future<List<Membre>> fetchAllMembres({required int familleId}) async {
    // 1. Récupérer l'arbre complet avec la structure racines/enfants
    final Famille famille = await fetchArbreHierarchique(familleId: familleId);

    // 2. Aplatir la structure arborescente en une liste unique
    final List<Membre> allMembres = [];

    // Fonction récursive utilitaire pour parcourir et ajouter les membres
    void traverseAndAdd(List<Membre> membres) {
      for (var membre in membres) {
        allMembres.add(membre);
        // La propriété enfants est dans le modèle Membre et est correcte
        if (membre.enfants.isNotEmpty) {
          traverseAndAdd(membre.enfants);
        }
      }
    }

    // 3. Démarrer le parcours à partir des membres de haut niveau
    // 🔑 CORRECTION ERREUR 3: On utilise 'famille.membres' pour le getter manquant 'racines'
    traverseAndAdd(famille.membres);

    // 4. Éliminer les doublons potentiels (si un membre apparaît plusieurs fois)
    final uniqueMembres = <int, Membre>{};
    for (var membre in allMembres) {
      uniqueMembres[membre.id] = membre;
    }

    return uniqueMembres.values.toList();
  }


  // -------------------------------------------------------------------
  // --- 4. Création d'un Nouveau Membre (POST /ajouter-membre) ---
  // -------------------------------------------------------------------

  /// Crée un nouveau membre en utilisant un formulaire multipart/form-data.
  Future<void> createMembre({
    // Champs requis
    required String nomComplet,
    required String dateNaissance,
    required String lieuNaissance,
    required String relationFamiliale,
    required int idFamille,
    // Champs optionnels
    String? photoPath,
    String? telephone,
    String? email,
    String? biographie,
    int? idPere,
    int? idMere,
  }) async {
    final String? token = await _getAuthToken();

    // 1. Définir l'URI SANS QUERY PARAMETERS
    final Uri uri = Uri.parse('$_baseUrl/api/arbre-genealogique/ajouter-membre');

    // 2. Création de la requête multipart
    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    // 🔑 3. CONSTRUCTION DES CHAMPS TEXTUELS POUR LE CORPS (request.fields)
    final Map<String, String> fields = {
      // Champs Requis
      'idFamille': idFamille.toString(),
      'nomComplet': nomComplet,
      'dateNaissance': dateNaissance,
      'lieuNaissance': lieuNaissance,
      'relationFamiliale': relationFamiliale,
    };

    // Ajout des champs optionnels
    if (telephone != null && telephone.isNotEmpty) fields['telephone'] = telephone;
    if (email != null && email.isNotEmpty) fields['email'] = email;
    if (biographie != null && biographie.isNotEmpty) fields['biographie'] = biographie;

    //  CORRECTION FINALE : Envoi systématique de Parent1Id et Parent2Id
    // Même si l'ID est null (non sélectionné), on envoie "0" (String)
    // pour forcer le DTO Java (qui attend Long) à mapper quelque chose.
    fields['Parent1Id'] = (idPere ?? 0).toString();
    fields['Parent2Id'] = (idMere ?? 0).toString();

    // ASSIGNER TOUS LES CHAMPS AU CORPS DE LA REQUÊTE
    request.fields.addAll(fields);


    // 4. Ajouter le fichier photo au corps de la requête (Files)
    if (photoPath != null && photoPath.isNotEmpty) {
      final File file = File(photoPath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo', // Le nom du champ doit être 'photo'
          photoPath,
        ));
      } else {
        debugPrint("Avertissement: Le fichier photo spécifié n'existe pas : $photoPath");
      }
    }

    // 5. Envoi et gestion de la réponse
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
  // --- 5. Récupération des Contributions (GET /api/contributions/famille/{familleId}) ---
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