// lib/models/conte.dart

import 'quiz.dart'; // Importez la classe Quiz

class Conte {
  final int id;
  final String titre;
  final String description;
  final String nomAuteur;
  final String prenomAuteur;
  final String emailAuteur;
  final String roleAuteur;
  final String lienParenteAuteur;
  final String dateCreation;
  final String statut;
  final String urlFichier;
  final String urlPhoto;
  final String lieu;
  final String region;
  final int idFamille;
  final String nomFamille;

  // Propriété Quiz rendue nullable (peut être null)
  final Quiz? quiz;

  Conte({
    required this.id,
    required this.titre,
    required this.description,
    required this.nomAuteur,
    required this.prenomAuteur,
    required this.emailAuteur,
    required this.roleAuteur,
    required this.lienParenteAuteur,
    required this.dateCreation,
    required this.statut,
    required this.urlFichier,
    required this.urlPhoto,
    required this.lieu,
    required this.region,
    required this.idFamille,
    required this.nomFamille,
    this.quiz, // Pas de 'required' car il est nullable
  });

  factory Conte.fromJson(Map<String, dynamic> json) {
    // Vérifie si la clé 'quiz' est présente et non null
    final quizData = json['quiz'];

    return Conte(
      id: json['id'] as int,
      titre: json['titre'] as String,
      description: json['description'] as String,
      nomAuteur: json['nomAuteur'] as String,
      prenomAuteur: json['prenomAuteur'] as String,
      emailAuteur: json['emailAuteur'] as String,
      roleAuteur: json['roleAuteur'] as String,
      lienParenteAuteur: json['lienParenteAuteur'] as String,
      dateCreation: json['dateCreation'] as String,
      statut: json['statut'] as String,
      urlFichier: json['urlFichier'] as String,
      urlPhoto: json['urlPhoto'] as String,
      lieu: json['lieu'] as String,
      region: json['region'] as String,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,

      // Désérialisation du Quiz : si quizData est présent, on utilise fromJson, sinon null.
      quiz: quizData != null ? Quiz.fromJson(quizData as Map<String, dynamic>) : null,
    );
  }
}