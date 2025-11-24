import 'dart:convert';

// Fonction d'aide pour la désérialisation
DevinetteTraduction devinetteTraductionFromJson(String str) => DevinetteTraduction.fromJson(json.decode(str));

class DevinetteTraduction {
  // Remarquez que la clé est 'idConte' (potentiellement une devinette ou un conte)
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

  DevinetteTraduction({
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

  factory DevinetteTraduction.fromJson(Map<String, dynamic> json) => DevinetteTraduction(
    idContenu: json["idConte"], // <-- Utilise "idConte"
    titreOriginal: json["titreOriginal"],
    descriptionOriginale: json["descriptionOriginale"],
    lieuOriginal: json["lieuOriginal"],
    regionOriginale: json["regionOriginale"],

    traductionsTitre: Map.from(json["traductionsTitre"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsContenu: Map.from(json["traductionsContenu"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsDescription: Map.from(json["traductionsDescription"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsLieu: Map.from(json["traductionsLieu"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsRegion: Map.from(json["traductionsRegion"]).map((k, v) => MapEntry<String, String>(k, v)),
    traductionsCompletes: Map.from(json["traductionsCompletes"]).map((k, v) => MapEntry<String, String>(k, v)),

    languesDisponibles: List<String>.from(json["languesDisponibles"].map((x) => x)),
    langueSource: json["langueSource"],
    statutTraduction: json["statutTraduction"],
  );
}