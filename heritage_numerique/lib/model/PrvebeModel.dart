// Fichier: lib/model/ProverbeModel.dart

import 'dart:convert';
import 'dart:developer'; // Ajouté pour le log plus précis (log plutôt que print)
import '../config/api_config.dart';

// 💡 ATTENTION : ADRESSE DU SERVEUR (centralisée via ApiConfig)
// La valeur est lue depuis le fichier .env à l'initialisation de l'application.
String get _baseUrl => ApiConfig.baseUrl;

// --- Fonction pour garantir une URL Absolue ---
String? _ensureFullUrl(String? path) {
  if (path == null || path.isEmpty) {
    return null;
  }

  // Si l'URL est déjà une URL complète (commence par http/https), on la retourne telle quelle.
  if (path.startsWith('http') || path.startsWith('https')) {
    return path;
  }

  // Le chemin dans la BDD est censé être /uploads/images/NOM_FICHIER.jpg
  // On retire le slash initial si présent pour éviter un double slash dans l'URL finale.
  final String cleanPath = path.startsWith('/') ? path.substring(1) : path;

  // On concatène la base URL et le chemin nettoyé.
  // Résultat attendu : http://10.0.2.2:8080/uploads/images/NOM_FICHIER.jpg
  final String fullUrl = '$_baseUrl/$cleanPath';

  // Log pour aider au diagnostic final
  log('ProverbeModel: URL BDD reçue: $path -> URL complète générée: $fullUrl');

  return fullUrl;
}

// --- Fonctions de Désérialisation ---
List<Proverbe> proverbesFromJson(String str) =>
    List<Proverbe>.from(json.decode(str).map((x) => Proverbe.fromJson(x)));

// --- Classe Modèle ---
class Proverbe {
  final int id;
  final String titre;
  final String proverbe;
  final String signification;
  final String origine;
  final String? nomAuteur;
  final String? prenomAuteur;
  final String? emailAuteur;
  final String? roleAuteur;
  final String? lienParenteAuteur;
  final DateTime dateCreation;
  final String? statut;
  final String? lieu;
  final String? region;
  final int idFamille;
  final String? nomFamille;
  final String? urlPhoto; // L'URL de photo finale (complète)

  Proverbe({
    required this.id,
    required this.titre,
    required this.proverbe,
    required this.signification,
    required this.origine,
    this.nomAuteur,
    this.prenomAuteur,
    this.emailAuteur,
    this.roleAuteur,
    this.lienParenteAuteur,
    required this.dateCreation,
    this.statut,
    required this.idFamille,
    this.nomFamille,
    this.lieu,
    this.region,
    this.urlPhoto,
  });

  // Factory constructor pour la conversion JSON -> Objet
  factory Proverbe.fromJson(Map<String, dynamic> json) {
    return Proverbe(
      id: json['id'] as int,
      titre: json['titre'] as String,
      proverbe: json['proverbe'] as String,
      signification: json['signification'] as String,
      origine: json['origine'] as String,
      nomAuteur: json['nomAuteur'] as String?,
      prenomAuteur: json['prenomAuteur'] as String?,
      emailAuteur: json['emailAuteur'] as String?,
      roleAuteur: json['roleAuteur'] as String?,
      lienParenteAuteur: json['lienParenteAuteur'] as String?,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      statut: json['statut'] as String?,
      lieu: json['lieu'] as String?,
      region: json['region'] as String?,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String?,
      // 🔑 POINT DE CORRECTION : Assure que l'URL est absolue et prend la valeur du champ 'urlPhoto'
      urlPhoto: _ensureFullUrl(json['urlPhoto'] as String?),
    );
  }
}
