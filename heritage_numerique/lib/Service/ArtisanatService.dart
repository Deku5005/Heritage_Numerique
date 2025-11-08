// Fichier: lib/service/ArtisanatService.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../model/ArtisanatModel.dart'; // Import du modèle mis à jour
import 'Auth-service.dart'; // Import du service d'authentification
import '../model/DemandePublication.dart';

class ArtisanatService {
  // BASE URL : Adresse du serveur local
  static const String _baseUrl = "http://10.0.2.2:8080";

  final AuthService _authService = AuthService();

  // --- Méthode d'utilitaire pour les appels API ---
  Future<String?> _getAuthToken() async {
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      print("Erreur: Token d'authentification non trouvé.");
      throw Exception("Token d'authentification non trouvé. Veuillez vous reconnecter.");
    }
    return token;
  }

  // -------------------------------------------------------------------
  // --- 1. Récupération de la liste des Contenus Artisanat (MIS À JOUR) ---
  // -------------------------------------------------------------------

  /// Récupère la liste des contenus Artisanat associés à un ID de famille spécifique.
  Future<List<Artisanat>> fetchArtisanatByFamilleId({
    required int familleId,
  }) async {
    final String? token = await _getAuthToken();

    // 💡 NOUVEL ENDPOINT : /api/artisanats/famille/{familleId}
    final Uri uri = Uri.parse(_baseUrl).resolve('/api/artisanats/famille/$familleId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Utilisation du désérialiseur mis à jour dans ArtisanatModel.dart
      return artisanatsFromJson(response.body);
    } else {
      String errorMessage = "Échec du chargement des contenus Artisanat (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        print("Réponse du serveur brute en cas d'échec (fetchArtisanat): ${response.body}");
        errorMessage += " Réponse brute: ${response.body}";
      }
      throw Exception(errorMessage);
    }
  }

  // -------------------------------------------------------------------
  // --- 2. Création d'un Nouveau Contenu Artisanat (POST vers /api/contenus/artisanat) ---
  // -------------------------------------------------------------------

  /// Crée un nouveau contenu Artisanat en utilisant un formulaire multipart.
  Future<void> createArtisanat({
    required int idFamille,
    required int idCategorie,
    required String titre,
    required String description,
    String? photoPath,      // Chemin local du fichier photo
    String? videoPath,      // Chemin local du fichier vidéo
    String? lieu,
    String? region,
  }) async {
    await _sendArtisanatRequest(
      method: 'POST',
      uriPath: '/api/contenus/artisanat', // Endpoint POST
      idFamille: idFamille,
      idCategorie: idCategorie,
      titre: titre,
      description: description,
      photoPath: photoPath,
      videoPath: videoPath,
      lieu: lieu,
      region: region,
    );
  }

  // -------------------------------------------------------------------
  // --- 3. Mise à Jour d'un Contenu Artisanat (PUT) ---
  // -------------------------------------------------------------------

  /// Met à jour un contenu Artisanat existant par son ID en utilisant un formulaire multipart.
  Future<void> updateArtisanat({
    required int artisanatId,
    required int idFamille,
    required int idCategorie,
    required String titre,
    required String description,
    String? photoPath,
    String? videoPath,
    String? lieu,
    String? region,
  }) async {
    await _sendArtisanatRequest(
      method: 'PUT',
      uriPath: '/api/contenus/artisanat/$artisanatId', // Endpoint PUT
      idFamille: idFamille,
      idCategorie: idCategorie,
      titre: titre,
      description: description,
      photoPath: photoPath,
      videoPath: videoPath,
      lieu: lieu,
      region: region,
    );
  }


  // --- Méthode Générique pour Création et Mise à Jour ---
  Future<void> _sendArtisanatRequest({
    required String method,
    required String uriPath,
    required int idFamille,
    required int idCategorie,
    required String titre,
    required String description,
    String? photoPath,
    String? videoPath,
    String? lieu,
    String? region,
  }) async {
    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse(_baseUrl).resolve(uriPath);

    final http.MultipartRequest request = http.MultipartRequest(method, uri)
      ..headers['Authorization'] = 'Bearer $token';

    // Ajouter les champs de texte
    request.fields['idFamille'] = idFamille.toString();
    request.fields['idCategorie'] = idCategorie.toString();
    request.fields['titre'] = titre;
    request.fields['description'] = description;

    if (lieu != null && lieu.isNotEmpty) request.fields['lieu'] = lieu;
    if (region != null && region.isNotEmpty) request.fields['region'] = region;

    // Ajouter les fichiers (MultipartFile)
    if (photoPath != null && photoPath.isNotEmpty) {
      final File file = File(photoPath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'photoArtisanat', // NOM DU CHAMP CÔTÉ SERVEUR (Multipart)
          photoPath,
        ));
      }
    }

    if (videoPath != null && videoPath.isNotEmpty) {
      final File file = File(videoPath);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath(
          'videoArtisanat', // NOM DU CHAMP CÔTÉ SERVEUR (Multipart)
          videoPath,
        ));
      }
    }

    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      String action = (method == 'POST') ? 'création' : 'mise à jour';
      String errorMessage = "Échec de la $action du contenu Artisanat (Statut: ${response.statusCode}).";

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
  // --- 4. Suppression d'un Contenu Artisanat ---
  // -------------------------------------------------------------------

  /// Supprime un contenu Artisanat en utilisant l'ID.
  Future<void> deleteArtisanat({
    required int artisanatId,
  }) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse(_baseUrl).resolve('/api/contenus/artisanat/$artisanatId');

    final http.Response response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      String errorMessage = "Échec de la suppression du contenu Artisanat (Statut: ${response.statusCode}).";
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
// --- 5. NOUVELLE MÉTHODE : Demande de Publication (POST) [CORRIGÉE] ---
// -------------------------------------------------------------------

  /// Envoie une demande de publication pour un contenu spécifique et retourne le statut de la demande.
// Signature modifiée pour retourner une Map contenant l'ID du contenu et le nouveau statut.
  Future<Map<String, dynamic>> requestPublication({required int contenuId}) async {
    final String? token = await _getAuthToken();

    final String path = '/api/contenus/$contenuId/demander-publication';
    final Uri uri = Uri.parse(_baseUrl).resolve(path);

    print('DEBUG ARTISANAT SERVICE: Tentative de demande de publication pour Contenu ID $contenuId : $uri');

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

        // Désérialiser la réponse
        final demande = DemandePublication.fromJson(responseBody);

        // Retourner une Map contenant l'ID du contenu et le statut de la DEMANDE
        return {
          'contenuId': demande.idContenu,
          'newStatus': demande.statut, // Ex: "EN_ATTENTE"
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