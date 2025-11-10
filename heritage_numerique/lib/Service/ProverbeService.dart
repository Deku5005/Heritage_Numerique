// Fichier: lib/service/ProverbeService.dart (Complet et Corrigé)

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../model/PrvebeModel.dart'; // Import du modèle Proverbe
import 'Auth-service.dart'; // Import du service d'authentification
import '../model/DemandePublication.dart'; // 💡 AJOUT DE L'IMPORT DU MODÈLE DE DEMANDE

class ProverbeService {
  // BASE URL : Adresse du serveur local
  static const String _baseUrl = "http://10.0.2.2:8080";

  final AuthService _authService = AuthService();

  // --- Méthode d'utilitaire pour obtenir le Token ---
  Future<String?> _getAuthToken() async {
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      print("Erreur: Token d'authentification non trouvé.");
      throw Exception("Token d'authentification non trouvé. Veuillez vous reconnecter.");
    }
    return token;
  }

  // -------------------------------------------------------------------
  // --- 1. Création d'un Nouveau Proverbe (POST vers /api/contenus/proverbe) ---
  // -------------------------------------------------------------------

  /// Crée un nouveau proverbe en utilisant un formulaire multipart.
  Future<void> createProverbe({
    required int idFamille,
    required int idCategorie,
    required String titre,
    required String origineProverbe,
    required String significationProverbe,
    required String texteProverbe,
    String? photoPath, // Chemin local du fichier photo
    String? lieu,
    String? region,
  }) async {
    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse(_baseUrl).resolve('/api/contenus/proverbe');

    // Assurez-vous d'utiliser une requête multipart pour envoyer des fichiers
    final http.MultipartRequest request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    // Ajout des champs de texte
    request.fields['idFamille'] = idFamille.toString();
    request.fields['idCategorie'] = idCategorie.toString();
    request.fields['titre'] = titre;
    request.fields['origineProverbe'] = origineProverbe;
    request.fields['significationProverbe'] = significationProverbe;
    request.fields['texteProverbe'] = texteProverbe;

    if (lieu != null && lieu.isNotEmpty) request.fields['lieu'] = lieu;
    if (region != null && region.isNotEmpty) request.fields['region'] = region;

    // Ajouter le fichier photo (MultipartFile)
    if (photoPath != null && photoPath.isNotEmpty) {
      final File file = File(photoPath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'photoProverbe', // NOM DU CHAMP CÔTÉ SERVEUR (Multipart)
          photoPath,
        ));
      } else {
        print("Avertissement: Le fichier photo spécifié n'existe pas : $photoPath");
      }
    }

    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(streamedResponse);

    print('Réponse POST /api/contenus/proverbe: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');


    if (response.statusCode == 200 || response.statusCode == 201) {
      // Succès
      return;
    } else {
      String errorMessage = "Échec de la création du proverbe (Statut: ${response.statusCode}).";
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
  // --- 2. Récupération des Proverbes par Famille (GET) ---
  // -------------------------------------------------------------------

  /// Récupère la liste des proverbes associés à un ID de famille spécifique.
  Future<List<Proverbe>> fetchProverbesByFamilleId({
    required int familleId,
  }) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse(_baseUrl).resolve('/api/proverbes/famille/$familleId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Utilisation du désérialiseur créé dans ProverbeModel.dart
      return proverbesFromJson(response.body);
    } else {
      String errorMessage = "Échec du chargement des proverbes (Statut: ${response.statusCode}).";
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
  // --- 3. NOUVELLE MÉTHODE : Demande de Publication (POST) ---
  // -------------------------------------------------------------------

  /// Envoie une demande de publication pour un contenu spécifique.
  Future<Map<String, dynamic>> requestPublication({required int contenuId}) async {
    final String? token = await _getAuthToken();

    final String path = '/api/contenus/$contenuId/demander-publication';
    final Uri uri = Uri.parse(_baseUrl).resolve(path);

    print('DEBUG PROVERBE SERVICE: Tentative de demande de publication pour Contenu ID $contenuId : $uri');

    try {
      final http.Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      print('Réponse POST $path: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // 💡 UTILISATION DU MODÈLE DemandePublication comme dans ArtisanatService
        final demande = DemandePublication.fromJson(responseBody);

        // Retourner l'ID du contenu et le statut de la DEMANDE (EN_ATTENTE)
        return {
          'contenuId': demande.idContenu,
          'newStatus': demande.statut.toUpperCase(), // Ex: "EN_ATTENTE"
        };

      } else {
        // Gérer les erreurs
        String errorMessage = "Échec de la demande de publication (Statut: ${response.statusCode}).";
        try {
          final Map<String, dynamic> errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {
          errorMessage += " Réponse brute: ${response.body}";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Échec de la connexion réseau ou erreur de traitement : $e');
    }
  }
}