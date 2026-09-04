import 'dart:convert';
import 'package:heritage_numerique/model/DemandePublication.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:heritage_numerique/model/Recits_model.dart';
import '../model/Traduction-conte-model.dart';
import 'Auth-service.dart';

class RecitService {
  // BASE URL : Adresse du serveur local
  // Assurez-vous que cette IP est correcte (10.0.2.2 pour l'émulateur Android)
  static const String _baseUrl = "http://10.0.2.2:8080";

  final AuthService _authService = AuthService();

  // --- Méthode d'utilitaire pour les appels API ---
  Future<String?> _getAuthToken() async {
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      // ⚠️ IMPORTANT: Utiliser print pour les erreurs de débogage dans la console
      print("Erreur: Token d'authentification non trouvé.");
      throw Exception("Token d'authentification non trouvé. Veuillez vous reconnecter.");
    }
    return token;
  }

  // -------------------------------------------------------------------
  // --- 1. Récupération de la liste des Récits ---
  // -------------------------------------------------------------------

  /// Récupère la liste des récits associés à un ID de famille spécifique.
  Future<List<Recit>> fetchRecitsByFamilleId({
    required int familleId,
  }) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse(_baseUrl).resolve('/api/contes/famille/$familleId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return recitsFromJson(response.body);
    } else {
      String errorMessage = "Échec du chargement des récits (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        print("Réponse du serveur brute en cas d'échec (fetchRecits): ${response.body}");
        errorMessage += " Réponse brute: ${response.body}";
      }
      throw Exception(errorMessage);
    }
  }

  // -------------------------------------------------------------------
  // --- 2. Récupération du Contenu Traduit ---
  // -------------------------------------------------------------------

  /// Récupère la traduction d'un conte pour une langue donnée.
  Future<TraductionConte> fetchConteTraduction({
    required int conteId,
    required String langueCode,
  }) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse(_baseUrl).resolve('/api/traduction/conte/$conteId/$langueCode');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return traductionConteFromJson(response.body);
    } else {
      String errorMessage = "Échec du chargement de la traduction du conte (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        print("Réponse du serveur brute en cas d'échec (fetchTraduction): ${response.body}");
        errorMessage += " Réponse brute: ${response.body}";
      }
      throw Exception(errorMessage);
    }
  }

  // -------------------------------------------------------------------
  // --- 3. Création d'un Nouveau Contenu de Conte (multipart/form-data) ---
  // -------------------------------------------------------------------

  /// Crée un nouveau conte en utilisant un formulaire multipart pour les données et le fichier.
  Future<void> createConte({
    required int idFamille,
    required int idCategorie,
    required String titre,
    String? description,
    String? texteConte,
    String? photoPath, // Chemin local du fichier photo à uploader
    String? fichierContePath, // Optionnel si l'utilisateur télécharge un fichier de conte
    String? lieu,
    String? region,
  }) async {
    await _sendConteRequest(
      method: 'POST',
      uriPath: '/api/contenus/conte',
      idFamille: idFamille,
      idCategorie: idCategorie,
      titre: titre,
      description: description,
      texteConte: texteConte,
      photoPath: photoPath,
      fichierContePath: fichierContePath,
      lieu: lieu,
      region: region,
    );
  }

  // -------------------------------------------------------------------
  // --- 4. Mise à Jour d'un Contenu de Conte (multipart/form-data) ---
  // -------------------------------------------------------------------

  /// Met à jour un conte existant par son ID en utilisant un formulaire multipart.
  Future<void> updateConte({
    required int conteId, // ID du conte à mettre à jour
    required int idFamille,
    required int idCategorie,
    required String titre,
    String? description,
    String? texteConte,
    String? photoPath, // Nouveau chemin local du fichier photo
    String? fichierContePath,
    String? lieu,
    String? region,
  }) async {
    await _sendConteRequest(
      method: 'PUT',
      uriPath: '/api/contenus/conte/$conteId', // Ajout de l'ID dans l'URI
      idFamille: idFamille,
      idCategorie: idCategorie,
      titre: titre,
      description: description,
      texteConte: texteConte,
      photoPath: photoPath,
      fichierContePath: fichierContePath,
      lieu: lieu,
      region: region,
    );
  }

  // --- Méthode Générique pour Création et Mise à Jour (pour éviter la duplication) ---
  Future<void> _sendConteRequest({
    required String method, // 'POST' ou 'PUT'
    required String uriPath,
    required int idFamille,
    required int idCategorie,
    required String titre,
    String? description,
    String? texteConte,
    String? photoPath,
    String? fichierContePath,
    String? lieu,
    String? region, // Optionnel, seulement pour la mise à jour (mais déjà dans uriPath)
  }) async {
    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse(_baseUrl).resolve(uriPath);

    // ⚠️ Remarque : Pour le débogage, assurez-vous que cette URI est correcte
    print("URL de la requête ($method): $uri");

    // Utilisation de MultipartRequest pour gérer l'upload de fichiers
    final http.MultipartRequest request = http.MultipartRequest(method, uri)
      ..headers['Authorization'] = 'Bearer $token';

    // Ajouter les champs de texte
    request.fields['idFamille'] = idFamille.toString();
    request.fields['idCategorie'] = idCategorie.toString();
    request.fields['titre'] = titre;

    if (description != null) request.fields['description'] = description;
    if (texteConte != null) request.fields['texteConte'] = texteConte;
    if (lieu != null) request.fields['lieu'] = lieu;
    if (region != null) request.fields['region'] = region;

    // ⚠️ Log des champs de texte envoyés
    print("Champs de texte envoyés: ${request.fields}");

    // Ajouter le fichier photo (photoConte) s'il est disponible
    if (photoPath != null && photoPath.isNotEmpty) {
      try {
        final File file = File(photoPath);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'photoConte', // NOM DU CHAMP CÔTÉ SERVEUR
            photoPath,
          ));
          print("Fichier photo ajouté: ${file.path}, Taille: ${file.lengthSync()} octets");
        } else {
          print("Avertissement: Le fichier photo spécifié n'existe pas au chemin: $photoPath. Il ne sera pas uploadé.");
        }
      } catch (e) {
        throw Exception("Erreur lors de la préparation du fichier photo: $e");
      }
    }

    // Ajouter 'fichierConte' ici si vous en avez un :
    if (fichierContePath != null && fichierContePath.isNotEmpty) {
      try {
        final File file = File(fichierContePath);
        if (await file.exists()) {
          request.files.add(await http.MultipartFile.fromPath(
            'fichierConte', // NOM DU CHAMP CÔTÉ SERVEUR
            fichierContePath,
          ));
          print("Fichier conte ajouté: ${file.path}, Taille: ${file.lengthSync()} octets");
        } else {
          print("Avertissement: Le fichier conte spécifié n'existe pas au chemin: $fichierContePath. Il ne sera pas uploadé.");
        }
      } catch (e) {
        throw Exception("Erreur lors de la préparation du fichier conte: $e");
      }
    }


    // Envoyer la requête
    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Succès: Contenu créé ou mis à jour.
      print("Création/Mise à jour réussie. Statut: ${response.statusCode}");
      return;
    } else {
      // Échec: Tenter d'extraire le message d'erreur
      String action = (method == 'POST') ? 'création' : 'mise à jour';
      String errorMessage = "Échec de la $action du conte (Statut: ${response.statusCode}).";

      try {
        // Tente de décoder le JSON si le serveur renvoie un corps d'erreur structuré
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        // Capture l'erreur si le corps n'est pas du JSON (ex: erreur 500 HTML)
        // 🚨 CECI EST LE LOG CRITIQUE POUR LE DÉBOGAGE
        print("🚨 Réponse du serveur brute en cas d'échec de l'upload: ${response.body}");
        errorMessage += " Réponse brute (non JSON): ${response.body}";
      }
      throw Exception(errorMessage);
    }
  }


  // -------------------------------------------------------------------
  // --- 5. Suppression d'un Conte ---
  // -------------------------------------------------------------------

  /// Supprime un conte en utilisant l'ID du conte.
  Future<void> deleteConte({
    required int conteId,
  }) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse(_baseUrl).resolve('/api/contenus/conte/$conteId');

    final http.Response response = await http.delete(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    // Un statut 204 No Content est courant pour une suppression réussie
    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      String errorMessage = "Échec de la suppression du conte (Statut: ${response.statusCode}).";
      try {
        final Map<String, dynamic> errorBody = json.decode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (_) {
        print("Réponse du serveur brute en cas d'échec (deleteConte): ${response.body}");
        errorMessage += " Réponse brute: ${response.body}";
      }
      throw Exception(errorMessage);
    }
  }

  // -------------------------------------------------------------------
  // --- 6. NOUVELLE MÉTHODE : Demande de Publication (POST) ---
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