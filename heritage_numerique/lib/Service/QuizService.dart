import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/QuizModel.dart';
import '../model/ResultatModel.dart'; // NOUVEL IMPORT
import 'Auth-service.dart';

class QuizService {
  static const String _baseUrl = "http://10.0.2.2:8080";
  final AuthService _authService = AuthService();

  Future<String?> _getAuthToken() async {
    final String? token = await _authService.getAuthToken();
    if (token == null) {
      print("Erreur: Token d'authentification non trouvé.");
      throw Exception("Token d'authentification non trouvé. Veuillez vous reconnecter.");
    }
    return token;
  }

  // -------------------------------------------------------------------
  // --- 1. Création d'un Nouveau Quiz (POST vers /api/quiz-contenu/creer) ---
  // -------------------------------------------------------------------

  Future<void> createQuiz({
    required QuizCreationRequest quizData,
  }) async {
    final String? token = await _getAuthToken();
    final Uri uri = Uri.parse(_baseUrl).resolve('/api/quiz-contenu/creer');

    final String requestBody = json.encode(quizData.toJson());

    final http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: requestBody,
    );

    print('Réponse POST /api/quiz-contenu/creer: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');


    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      String errorMessage = "Échec de la création du quiz (Statut: ${response.statusCode}).";
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
  // --- 2. Récupération des Quiz par Famille (GET vers /api/quiz/famille/{familleId}) ---
  // -------------------------------------------------------------------

  Future<List<QuizOverview>> fetchQuizzesByFamilleId({
    required int familleId,
  }) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse(_baseUrl).resolve('/api/quiz/famille/$familleId');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => QuizOverview.fromJson(json)).toList();

    } else {
      String errorMessage = "Échec du chargement des quiz (Statut: ${response.statusCode}).";
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
  // --- 3. Récupération des Détails Complets d'un Quiz (GET) ---
  // -------------------------------------------------------------------

  Future<QuizDetail> fetchQuizDetails({
    required int quizId,
  }) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse(_baseUrl).resolve('/api/quiz/$quizId/questions');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dynamic jsonBody = json.decode(response.body);

      if (jsonBody is List<dynamic>) {

        final List<QuizQuestionDetail> questions = jsonBody
            .map((qJson) => QuizQuestionDetail.fromJson(qJson as Map<String, dynamic>))
            .toList();

        return QuizDetail(
          id: quizId,
          titre: "Quiz #${quizId}",
          description: "Détails non fournis par l'API questions",
          nombreQuestions: questions.length,
          questions: questions,
        );
      }

      throw  FormatException("Format de réponse inattendu. L'API questions devrait renvoyer une liste (ID $quizId).");

    } else {
      String errorMessage = "Échec du chargement des détails du quiz (Statut: ${response.statusCode}).";
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
  // --- 4. Soumission des Réponses au Quiz (POST vers /api/quiz-contenu/repondre) ---
  // -------------------------------------------------------------------

  Future<QuizResultResponse> submitQuiz(
      QuizSubmissionRequest request,
      ) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse(_baseUrl).resolve('/api/quiz-contenu/repondre');

    final String requestBody = json.encode(request.toJson());

    final http.Response response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: requestBody,
    );

    print('Réponse POST /api/quiz-contenu/repondre: ${response.statusCode}');
    print('Corps de la réponse: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = json.decode(response.body);
      return QuizResultResponse.fromJson(jsonBody);

    } else {
      String errorMessage = "Échec de la soumission du quiz (Statut: ${response.statusCode}).";
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
  // 🌟 --- 5. Récupération des Résultats du Quiz (GET vers /api/quiz/{quizId}/resultats) --- 🌟
  // -------------------------------------------------------------------

  /// Récupère l'historique des résultats pour un quiz spécifique.
  Future<List<UserResult>> fetchQuizResults({
    required int quizId,
  }) async {
    final String? token = await _getAuthToken();

    final Uri uri = Uri.parse(_baseUrl).resolve('/api/quiz/$quizId/resultats');

    final http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => UserResult.fromJson(json)).toList();

    } else {
      String errorMessage = "Échec du chargement des résultats (Statut: ${response.statusCode}).";
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