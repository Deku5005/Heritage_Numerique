import 'dart:convert';

// --- Fonctions d'aide à la désérialisation ---

// Désérialise la réponse JSON en un objet ArtisanatTraduction
ArtisanatTraduction artisanatTraductionFromJson(String str) => ArtisanatTraduction.fromJson(json.decode(str));

// Sérialise un objet ArtisanatTraduction en chaîne JSON
String artisanatTraductionToJson(ArtisanatTraduction data) => json.encode(data.toJson());

// --- Classe Modèle ---

class ArtisanatTraduction {
  final int idContenu;
  final String titreOriginal;
  final String descriptionOriginale;
  final String? lieuOriginal;
  final String? regionOriginale;
  final Map<String, String> traductionsTitre;
  final Map<String, String> traductionsContenu;
  final Map<String, String> traductionsDescription;
  final Map<String, String> traductionsLieu;
  final Map<String, String> traductionsRegion;
  final Map<String, String> traductionsCompletes;
  final List<String> languesDisponibles;
  final String langueSource;
  final String statutTraduction;

  ArtisanatTraduction({
    required this.idContenu,
    required this.titreOriginal,
    required this.descriptionOriginale,
    this.lieuOriginal,
    this.regionOriginale,
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

  // --- Factory Constructor pour la désérialisation JSON ---
  factory ArtisanatTraduction.fromJson(Map<String, dynamic> json) => ArtisanatTraduction(
    // Utilisation de 'idContenu' pour correspondre au champ 'idConte' du JSON
    idContenu: json["idConte"] as int,
    titreOriginal: json["titreOriginal"] as String,
    descriptionOriginale: json["descriptionOriginale"] as String,
    // Ces champs sont optionnels (peuvent être null)
    lieuOriginal: json["lieuOriginal"] as String?,
    regionOriginale: json["regionOriginale"] as String?,

    traductionsTitre: Map.from(json["traductionsTitre"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsContenu: Map.from(json["traductionsContenu"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsDescription: Map.from(json["traductionsDescription"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsLieu: Map.from(json["traductionsLieu"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsRegion: Map.from(json["traductionsRegion"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsCompletes: Map.from(json["traductionsCompletes"]).map((k, v) => MapEntry<String, String>(k, v)),

    // La liste des langues
    languesDisponibles: List<String>.from(json["languesDisponibles"].map((x) => x)),

    langueSource: json["langueSource"] as String,
    statutTraduction: json["statutTraduction"] as String,
  );

  // --- Méthode pour la sérialisation JSON (si nécessaire) ---
  Map<String, dynamic> toJson() => {
    "idConte": idContenu,
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