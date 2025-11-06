// Fichier: lib/model/QuizModel.dart

// =======================================================================
// 1. MODÈLES DE CRÉATION DE QUIZ (POUR POST)
// =======================================================================

class Proposition {
  final String texte;
  final bool estCorrecte;
  final int? ordre;
  final int? idQuestion;

  Proposition({
    required this.texte,
    required this.estCorrecte,
    this.ordre,
    this.idQuestion,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'texte': texte,
      'estCorrecte': estCorrecte,
    };
    if (ordre != null) {
      data['ordre'] = ordre;
    }
    if (idQuestion != null) {
      data['idQuestion'] = idQuestion;
    }
    return data;
  }
}

class QuestionCreation {
  final String question;
  final String typeReponse; // Ex: "QCM", "VRAI_FAUX"
  final List<Proposition> propositions;
  final bool? reponseVraiFaux; // Requis si typeReponse est "VRAI_FAUX"

  QuestionCreation({
    required this.question,
    required this.typeReponse,
    this.propositions = const [],
    this.reponseVraiFaux,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'question': question,
      'typeReponse': typeReponse,
    };

    if (typeReponse == 'QCM') {
      data['propositions'] = propositions.map((p) => p.toJson()).toList();
    } else if (typeReponse == 'VRAI_FAUX') {
      data['reponseVraiFaux'] = reponseVraiFaux;
    }

    return data;
  }
}

class QuizCreationRequest {
  final int idContenu;
  final String titre;
  final String description;
  final List<QuestionCreation> questions;

  QuizCreationRequest({
    required this.idContenu,
    required this.titre,
    required this.description,
    required this.questions,
  });

  Map<String, dynamic> toJson() {
    return {
      'idContenu': idContenu,
      'titre': titre,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

// =======================================================================
// 2. MODÈLES DE LECTURE DU QUIZ
// =======================================================================

class QuizOverview {
  final int id;
  final int idFamille;
  final String nomFamille;
  final int idCreateur;
  final String nomCreateur;
  final String titre;
  final String description;
  final String difficulte; // Ex: "MOYEN"
  final bool actif;
  final int nombreQuestions;
  final DateTime dateCreation;

  QuizOverview({
    required this.id,
    required this.idFamille,
    required this.nomFamille,
    required this.idCreateur,
    required this.nomCreateur,
    required this.titre,
    required this.description,
    required this.difficulte,
    required this.actif,
    required this.nombreQuestions,
    required this.dateCreation,
  });

  factory QuizOverview.fromJson(Map<String, dynamic> json) {
    return QuizOverview(
      id: (json['id'] as int?) ?? 0,
      idFamille: (json['idFamille'] as int?) ?? 0,
      nomFamille: (json['nomFamille'] as String?) ?? 'Famille Inconnue',
      idCreateur: (json['idCreateur'] as int?) ?? 0,
      nomCreateur: (json['nomCreateur'] as String?) ?? 'Créateur Inconnu',
      titre: (json['titre'] as String?) ?? 'Titre Inconnu',
      description: (json['description'] as String?) ?? 'Description Indisponible',
      difficulte: (json['difficulte'] as String?) ?? 'INCONNU',
      actif: json['actif'] as bool,
      nombreQuestions: (json['nombreQuestions'] as int?) ?? 0,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
    );
  }
}

// --- Modèle de Proposition Détaillée ---
class QuizProposition {
  final int id;
  final String texte;
  final bool estCorrecte;

  QuizProposition({required this.id, required this.texte, required this.estCorrecte});

  factory QuizProposition.fromJson(Map<String, dynamic> json) {
    return QuizProposition(
      id: (json['id'] as int?) ?? 0,
      // 🚨 CORRECTION CLÉ JSON: utilise 'texteProposition' au lieu de 'texte'
      texte: (json['texteProposition'] as String?) ?? 'Proposition sans texte',
      // 💡 CORRECTION NULL-SAFE: gère l'absence de clé 'estCorrecte' ou la valeur null
      estCorrecte: (json['estCorrecte'] as bool?) ?? false,
    );
  }
}

// --- Modèle de Question Détaillée ---
class QuizQuestionDetail {
  final int id;
  final String question;
  final String typeReponse;
  final List<QuizProposition> propositions;
  final bool? reponseVraiFaux;

  QuizQuestionDetail({
    required this.id,
    required this.question,
    required this.typeReponse,
    required this.propositions,
    this.reponseVraiFaux,
  });

  factory QuizQuestionDetail.fromJson(Map<String, dynamic> json) {
    return QuizQuestionDetail(
      id: (json['id'] as int?) ?? 0,
      // 🚨 CORRECTION CLÉ JSON: utilise 'texteQuestion' au lieu de 'question'
      question: (json['texteQuestion'] as String?) ?? 'Question sans texte',
      // 🚨 CORRECTION CLÉ JSON: utilise 'typeQuestion' au lieu de 'typeReponse'
      typeReponse: (json['typeQuestion'] as String?) ?? 'INCONNU',
      propositions: (json['propositions'] as List<dynamic>?)
          ?.map((p) => QuizProposition.fromJson(p))
          .toList() ?? [],
      reponseVraiFaux: json['reponseVraiFaux'] as bool?,
    );
  }
}

// --- Modèle Principal de Détail du Quiz ---
class QuizDetail {
  final int id;
  final String titre;
  final String description;
  final int nombreQuestions;
  final List<QuizQuestionDetail> questions;

  QuizDetail({
    required this.id,
    required this.titre,
    required this.description,
    required this.nombreQuestions,
    required this.questions,
  });

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    return QuizDetail(
      id: (json['id'] as int?) ?? 0,
      titre: (json['titre'] as String?) ?? 'Titre Inconnu',
      description: (json['description'] as String?) ?? 'Description Indisponible',
      nombreQuestions: (json['nombreQuestions'] as int?) ?? 0,
      // Le champ 'questions' est souvent une liste à la racine de la réponse de l'endpoint
      questions: (json['questions'] as List<dynamic>?)
          ?.map((q) => QuizQuestionDetail.fromJson(q))
          .toList() ?? [],
    );
  }
}

// =======================================================================
// 3. MODÈLES DE SOUMISSION ET RÉSULTAT DU QUIZ
// =======================================================================

/// Représente la réponse de l'utilisateur à une seule question, formatée pour l'API.
class UserResponse {
  final int idQuestion;
  final int? idProposition;
  final bool? reponseVraiFaux;

  UserResponse({
    required this.idQuestion,
    this.idProposition,
    this.reponseVraiFaux,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'idQuestion': idQuestion,
    };
    if (idProposition != null) {
      data['idProposition'] = idProposition;
    }
    if (reponseVraiFaux != null) {
      data['reponseVraiFaux'] = reponseVraiFaux;
    }
    return data;
  }
}

/// Représente le corps de la requête pour soumettre les réponses d'un quiz.
class QuizSubmissionRequest {
  final int idQuiz;
  final List<UserResponse> reponses;
  final int tempsEcoule;

  QuizSubmissionRequest({
    required this.idQuiz,
    required this.reponses,
    required this.tempsEcoule,
  });

  /// Construit la requête à partir de la Map des réponses utilisateur.
  factory QuizSubmissionRequest.fromUserAnswers(int quizId, Map<int, dynamic> userAnswers, int elapsedTimeInSeconds) {
    final responses = userAnswers.entries.map((entry) {
      final questionId = entry.key;
      final answerValue = entry.value;

      if (answerValue is int) {
        return UserResponse(
          idQuestion: questionId,
          idProposition: answerValue,
        );
      } else if (answerValue is bool) {
        return UserResponse(
          idQuestion: questionId,
          reponseVraiFaux: answerValue,
        );
      }
      throw Exception("Type de réponse utilisateur non supporté pour la soumission.");
    }).toList();

    return QuizSubmissionRequest(
      idQuiz: quizId,
      reponses: responses,
      tempsEcoule: elapsedTimeInSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idQuiz': idQuiz,
      'reponses': reponses.map((r) => r.toJson()).toList(),
      'tempsEcoule': tempsEcoule,
    };
  }
}

/// Représente la réponse reçue de l'API après la soumission, contenant le score.
class QuizResultResponse {
  final int score;
  final int totalQuestions;

  QuizResultResponse({required this.score, required this.totalQuestions});

  factory QuizResultResponse.fromJson(Map<String, dynamic> json) {
    return QuizResultResponse(
      score: (json['score'] as int?) ?? 0,
      totalQuestions: (json['totalQuestions'] as int?) ?? 0,
    );
  }
}