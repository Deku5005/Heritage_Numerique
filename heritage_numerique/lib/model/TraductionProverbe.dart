// Fichier: lib/model/TraductionProverbe.dart

import 'dart:convert';

// --- Fonctions de Désérialisation ---

TraductionProverbe traductionProverbeFromJson(String str) =>
    TraductionProverbe.fromJson(json.decode(str));

String traductionProverbeToJson(TraductionProverbe data) =>
    json.encode(data.toJson());

// --- Modèle Principal ---

class TraductionProverbe {
  // L'ID est nommé 'idConte' dans la réponse JSON, nous allons le refléter
  final int idConte;

  final String titreOriginal;
  final String descriptionOriginale;
  final String lieuOriginal;
  final String regionOriginale;

  // Les champs de traduction utilisent un Map<String, String> pour stocker les langues (ex: "bam_Latn": "valeur")
  final Map<String, String> traductionsTitre;
  final Map<String, String> traductionsContenu;
  final Map<String, String> traductionsDescription;
  final Map<String, String> traductionsLieu;
  final Map<String, String> traductionsRegion;
  final Map<String, String> traductionsCompletes;

  final List<String> languesDisponibles;
  final String langueSource;
  final String statutTraduction;

  TraductionProverbe({
    required this.idConte,
    required this.titreOriginal,
    required this.descriptionOriginale,
    required this.lieuOriginal,
    required this.regionOriginale,
    required this.traductionsTitre,
    required this.traductionsContenu,
    required this.traductionsDescription,
    required this.traductionsLieu,
    required this.traductionsRegion,
    required this.traductionsCompletes,
    required this.languesDisponibles,
    required this.langueSource,
    required this.statutTraduction,
  });

  // --- Constructeur fromJson ---
  factory TraductionProverbe.fromJson(Map<String, dynamic> json) => TraductionProverbe(
    idConte: json["idConte"],
    titreOriginal: json["titreOriginal"],
    descriptionOriginale: json["descriptionOriginale"],
    lieuOriginal: json["lieuOriginal"],
    regionOriginale: json["regionOriginale"],

    // Désérialisation des Maps de traduction
    traductionsTitre: Map.from(json["traductionsTitre"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsContenu: Map.from(json["traductionsContenu"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsDescription: Map.from(json["traductionsDescription"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsLieu: Map.from(json["traductionsLieu"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsRegion: Map.from(json["traductionsRegion"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsCompletes: Map.from(json["traductionsCompletes"]).map((k, v) => MapEntry<String, String>(k, v)),

    // Désérialisation de la liste
    languesDisponibles: List<String>.from(json["languesDisponibles"].map((x) => x)),
    langueSource: json["langueSource"],
    statutTraduction: json["statutTraduction"],
  );

  // --- Méthode toJson (Optionnelle, mais bonne pratique) ---
  Map<String, dynamic> toJson() => {
    "idConte": idConte,
    "titreOriginal": titreOriginal,
    "descriptionOriginale": descriptionOriginale,
    "lieuOriginal": lieuOriginal,
    "regionOriginale": regionOriginale,

    "traductionsTitre": Map.from(traductionsTitre).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "traductionsContenu": Map.from(traductionsContenu).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "traductionsDescription": Map.from(traductionsDescription).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "traductionsLieu": Map.from(traductionsLieu).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "traductionsRegion": Map.from(traductionsRegion).map((k, v) => MapEntry<String, dynamic>(k, v)),
    "traductionsCompletes": Map.from(traductionsCompletes).map((k, v) => MapEntry<String, dynamic>(k, v)),

    "languesDisponibles": List<dynamic>.from(languesDisponibles.map((x) => x)),
    "langueSource": langueSource,
    "statutTraduction": statutTraduction,
  };
}