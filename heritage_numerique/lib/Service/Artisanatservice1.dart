// lib/services/artisanat_service1.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// Assurez-vous d'importer le bon modèle
import '../model/artisanat1.dart';

// Adresse de l'émulateur Android
const String _apiBaseUrl = 'http://10.0.2.2:8080';

class ArtisanatService1 { // Nom de la classe changé
  // L'endpoint pour la récupération des artisanats
  final String _endpoint = '/api/public/artisanats';

  /// Récupère la liste des objets Artisanat1 depuis l'API.
  Future<List<Artisanat1>> getArtisanats() async {
    final url = Uri.parse('$_apiBaseUrl$_endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {

        if (response.body.isEmpty) {
          return [];
        }

        final dynamic decodedBody = json.decode(response.body);

        if (decodedBody is List) {
          final List<dynamic> artisanatsJson = decodedBody;

          // Mapping vers la liste d'objets Artisanat1
          return artisanatsJson
              .map((jsonItem) => Artisanat1.fromJson(jsonItem as Map<String, dynamic>))
              .toList();

        } else {
          throw const FormatException("Erreur de format de réponse : l'API n'a pas retourné une liste JSON.");
        }

      } else {
        final String errorMessage = 'Échec du chargement des artisanats. Statut: ${response.statusCode}. Corps de réponse: ${response.body}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erreur réseau ou de désérialisation dans ArtisanatService1: $e');
      rethrow;
    }
  }
}