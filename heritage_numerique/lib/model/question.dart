// lib/models/question.dart (CORRIGÉ ET ROBUSTE)

import 'proposition.dart';

class Question {
  final int id;
  final String texteQuestion;
  final String typeQuestion;
  final int ordre;
  final int points;
  final List<Proposition> propositions;

  Question({
    required this.id,
    required this.texteQuestion,
    required this.typeQuestion,
    required this.ordre,
    required this.points,
    required this.propositions,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final List<dynamic> propositionsJson = json['propositions'] ?? [];
    final List<Proposition> propositions = propositionsJson
        .map((p) => Proposition.fromJson(p as Map<String, dynamic>))
        .toList();

    return Question(
      // Utilisation de ?? pour gérer les valeurs nulles
      id: json['id'] as int? ?? 0,
      texteQuestion: json['texteQuestion'] as String? ?? 'Question inconnue',
      typeQuestion: json['typeQuestion'] as String? ?? 'text',
      ordre: json['ordre'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      propositions: propositions,
    );
  }
}