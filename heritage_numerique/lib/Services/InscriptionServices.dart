// lib/Service/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
// Importez le TokenManager
import 'token_manager.dart'; // Assure-toi que token_manager.dart est dans le même répertoire

// Assurez-vous que les chemins d'importation vers vos modèles sont corrects
import 'package:heritage_numerique/Model/InscriptionRequete.dart';
import 'package:heritage_numerique/Model/InscriptionReponse.dart';
import 'package:heritage_numerique/Model/LoginRequete.dart';
import 'package:heritage_numerique/Model/DashboardData.dart';

// URL de base... (URLs inchangées)
const String _registerUrl = 'http://10.0.2.2:8080/api/auth/register';
const String _loginUrl = 'http://10.0.2.2:8080/api/auth/login';
// NOTE: J'ai conservé l'URL que vous avez fournie. Si le backend utilise un autre chemin, ajustez-le.
const String _dashboardUrl = 'http://10.0.2.2:8080/api/dashboard/personnel';


// -----------------------------------------------------------------------------
// 1. FONCTION D'INSCRIPTION (registerUser)
// -----------------------------------------------------------------------------
Future<InscriptionReponse> registerUser({
  required String nom,
  required String prenom,
  required String email,
  required String numeroTelephone,
  required String ethnie,
  required String motDePasse,
  String? codeInvitation,
}) async {

  final requestData = InscriptionRequete(
    nom: nom, prenom: prenom, email: email, numeroTelephone: numeroTelephone,
    ethnie: ethnie, motDePasse: motDePasse, codeInvitation: codeInvitation,
  );

  final response = await http.post(
    Uri.parse(_registerUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestData.toJson()),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final jsonResponse = json.decode(response.body);

    // *** CORRECTION 1 : fromJson au lieu de fromjson ***
    final responseModel = InscriptionReponse.fromJson(jsonResponse);

    // Sauvegarde du token
    if (responseModel.accessToken.isNotEmpty) {
      await TokenManager.saveToken(responseModel.accessToken);
    }

    return responseModel;
  } else {
    String errorMessage = 'Échec de l\'inscription. Statut: ${response.statusCode}';
    try {
      final errorJson = json.decode(response.body);
      if (errorJson['message'] != null) errorMessage = errorJson['message'];
    } catch (_) {}
    throw Exception(errorMessage);
  }
}

// -----------------------------------------------------------------------------
// 2. FONCTION DE CONNEXION (loginUser) - Sauvegarde du Token
// -----------------------------------------------------------------------------
Future<InscriptionReponse> loginUser({
  required String email,
  required String motDePasse,
}) async {

  final requestData = LoginRequete(email: email, motDePasse: motDePasse);

  final response = await http.post(
    Uri.parse(_loginUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestData.toJson()),
  );

  if (response.statusCode == 200) {

    final jsonResponse = json.decode(response.body);

    // *** CORRECTION 2 : fromJson au lieu de fromjson ***
    final responseModel = InscriptionReponse.fromJson(jsonResponse);

    // Sauvegarde du token JWT après connexion réussie
    await TokenManager.saveToken(responseModel.accessToken);

    return responseModel;

  } else {
    String errorMessage = 'Échec de la connexion. Veuillez vérifier vos identifiants.';
    try {
      final errorJson = json.decode(response.body);
      if (errorJson['message'] != null) errorMessage = errorJson['message'];
    } catch (_) {}
    throw Exception(errorMessage);
  }
}

// -----------------------------------------------------------------------------
// 3. FONCTION DASHBOARD (fetchDashboardData)
// -----------------------------------------------------------------------------
/// Récupère les données personnelles du dashboard en utilisant le token JWT.
Future<DashboardData> fetchDashboardData(String accessToken) async {

  final response = await http.get(
    Uri.parse(_dashboardUrl),
    headers: {
      'Content-Type': 'application/json',
      // Token utilisé ici
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    return DashboardData.fromJson(jsonResponse);
  } else {
    // S'assure que même les statuts d'erreur levés par l'API forcent le FutureBuilder à s'arrêter.
    String errorMessage = 'Échec de la récupération du dashboard. Statut: ${response.statusCode}';
    try {
      final errorJson = json.decode(response.body);
      if (errorJson['message'] != null) errorMessage = errorJson['message'];
    } catch (_) {}
    throw Exception(errorMessage);
  }
}