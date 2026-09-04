// Fichier: lib/model/TraductionDevinette.dart (CORRIGÉ pour la null safety)

import 'dart:convert';

// --- Fonctions de Désérialisation ---

TraductionDevinette traductionDevinetteFromJson(String str) =>
    TraductionDevinette.fromJson(json.decode(str));

String traductionDevinetteToJson(TraductionDevinette data) =>
    json.encode(data.toJson());

// --- Modèle Principal ---

class TraductionDevinette {

  final int idConte;

  // Utilisation de ?? '' pour garantir une String non-null (si l'API renvoie null)
  final String titreOriginal;
  final String descriptionOriginale;
  final String lieuOriginal;
  final String regionOriginale;

  // Utilisation de ?? {} pour garantir une Map non-null (si l'API renvoie null)
  final Map<String, String> traductionsTitre;
  final Map<String, String> traductionsContenu;
  final Map<String, String> traductionsDescription;
  final Map<String, String> traductionsLieu;
  final Map<String, String> traductionsRegion;
  final Map<String, String> traductionsCompletes;

  final List<String> languesDisponibles;
  final String langueSource;
  final String statutTraduction;

  TraductionDevinette({
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

  // --- Constructeur fromJson (Corrigé) ---
  factory TraductionDevinette.fromJson(Map<String, dynamic> json) {

    // Fonction utilitaire pour gérer les Maps potentiellement nulles ou vides
    Map<String, String> safeMap(dynamic map) {
      if (map == null) return {};
      // S'assurer que chaque entrée est MapEntry<String, String>
      return Map.from(map).map((k, v) => MapEntry<String, String>(k.toString(), v.toString()));
    }

    return TraductionDevinette(
      // Les IDs sont généralement non nuls, pas de ?? nécessaire
      idConte: json["idConte"],

      // Utilisation de ?? '' pour garantir une String non-null
      titreOriginal: json["titreOriginal"] ?? '',
      descriptionOriginale: json["descriptionOriginale"] ?? '',
      lieuOriginal: json["lieuOriginal"] ?? '',
      regionOriginale: json["regionOriginale"] ?? '',

      // Utilisation de la fonction _safeMap pour garantir une Map non-null
      traductionsTitre: safeMap(json["traductionsTitre"]),
      traductionsContenu: safeMap(json["traductionsContenu"]),
      traductionsDescription: safeMap(json["traductionsDescription"]),
      traductionsLieu: safeMap(json["traductionsLieu"]),
      traductionsRegion: safeMap(json["traductionsRegion"]),
      traductionsCompletes: safeMap(json["traductionsCompletes"]),

      // Les Listes devraient être gérées avec un test de nullité
      languesDisponibles: List<String>.from(json["languesDisponibles"]?.map((x) => x) ?? []),
      langueSource: json["langueSource"] ?? '',
      statutTraduction: json["statutTraduction"] ?? 'INCONNU',
    );
  }

  // --- Méthode toJson (Optionnelle) ---
  Map<String, dynamic> toJson() => {
    "idConte": idConte,
    "titreOriginal": titreOriginal,
    // ...
  };
}