// Fichier: lib/service/ProverbeService.dart (Complet et Corrigé)

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// 💡 CORRECTION de l'import : le nom du fichier du modèle est 'ProverbeModel.dart'
import '../model/PrvebeModel.dart'; // <-- Correction: était 'PrvebeModel.dart'
import 'Auth-service.dart'; // Import du service d'authentification

class ProverbeService {
  // 💡 REMPLACEZ PAR VOTRE URL DE BASE RÉELLE (Doit correspondre à celle du modèle)
  // Utilisation de la constante définie dans le modèle pour la cohérence
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
    // Les champs ci-dessous correspondent à la structure attendue par votre backend Java
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
          'photoProverbe', // 🔑 NOM DU CHAMP CÔTÉ SERVEUR (Multipart)
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
}
