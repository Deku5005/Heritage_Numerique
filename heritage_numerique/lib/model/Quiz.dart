// lib/models/quiz.dart

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
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      idCreateur: json['idCreateur'] as int,
      nomCreateur: json['nomCreateur'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      difficulte: json['difficulte'] as String,
      tempsLimite: json['tempsLimite'] as int,
      actif: json['actif'] as bool,
      nombreQuestions: json['nombreQuestions'] as int,
      dateCreation: json['dateCreation'] as String,
      quiz: json['quiz'] as String,
    );
  }
}