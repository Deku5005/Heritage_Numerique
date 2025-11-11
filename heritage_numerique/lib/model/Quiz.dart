// lib/models/quiz.dart (CORRIGÉ ET ROBUSTE)

import 'question.dart';

class Quiz {
  final int id;
  final int idFamille;
  final String nomFamille;
  final int idCreateur;
  final String nomCreateur;
  final String titre;
  final String description;
  final String difficulte;
  final int tempsLimite;
  final bool actif;
  final int nombreQuestions;
  final String dateCreation;
  final String quiz;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.idFamille,
    required this.nomFamille,
    required this.idCreateur,
    required this.nomCreateur,
    required this.titre,
    required this.description,
    required this.difficulte,
    required this.tempsLimite,
    required this.actif,
    required this.nombreQuestions,
    required this.dateCreation,
    required this.quiz,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final List<dynamic> questionsJson = json['questions'] ?? [];
    final List<Question> questions = questionsJson
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();

    return Quiz(
      // Utilisation de ?? pour gérer les valeurs nulles
      id: json['id'] as int? ?? 0,
      idFamille: json['idFamille'] as int? ?? 0,
      nomFamille: json['nomFamille'] as String? ?? '',
      idCreateur: json['idCreateur'] as int? ?? 0,
      nomCreateur: json['nomCreateur'] as String? ?? '',
      titre: json['titre'] as String? ?? 'Quiz sans titre',
      description: json['description'] as String? ?? '',
      difficulte: json['difficulte'] as String? ?? '',
      tempsLimite: json['tempsLimite'] as int? ?? 0,
      actif: json['actif'] as bool? ?? false,
      nombreQuestions: json['nombreQuestions'] as int? ?? 0,
      dateCreation: json['dateCreation'] as String? ?? '',
      quiz: json['quiz'] as String? ?? '',
      questions: questions,
    );
  }
}