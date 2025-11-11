// lib/models/conte.dart (CORRIGÉ ET ROBUSTE)

import 'quiz.dart';

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
    this.quiz,
  });

  factory Conte.fromJson(Map<String, dynamic> json) {
    final quizData = json['quiz'];

    return Conte(
      // Utilisation de ?? pour gérer les valeurs nulles
      id: json['id'] as int? ?? 0,
      titre: json['titre'] as String? ?? 'Titre inconnu',
      description: json['description'] as String? ?? 'Description non fournie',
      nomAuteur: json['nomAuteur'] as String? ?? '',
      prenomAuteur: json['prenomAuteur'] as String? ?? '',
      emailAuteur: json['emailAuteur'] as String? ?? '',
      roleAuteur: json['roleAuteur'] as String? ?? '',
      lienParenteAuteur: json['lienParenteAuteur'] as String? ?? '',
      dateCreation: json['dateCreation'] as String? ?? '',
      statut: json['statut'] as String? ?? 'Inconnu',
      urlFichier: json['urlFichier'] as String? ?? '',
      urlPhoto: json['urlPhoto'] as String? ?? '',
      lieu: json['lieu'] as String? ?? 'Non spécifié',
      region: json['region'] as String? ?? 'Non spécifiée',
      idFamille: json['idFamille'] as int? ?? 0,
      nomFamille: json['nomFamille'] as String? ?? '',

      quiz: quizData != null ? Quiz.fromJson(quizData as Map<String, dynamic>) : null,
    );
  }
}