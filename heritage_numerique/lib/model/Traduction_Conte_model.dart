// lib/model/traduction_conte_model.dart

class Traductions {
  final Map<String, String> traductions;

  Traductions({required this.traductions});

  factory Traductions.fromJson(Map<String, dynamic> json) {
    // La réponse JSON est directement un Map<String, dynamic>
    final Map<String, String> map = {};
    json.forEach((key, value) {
      if (value is String) {
        map[key] = value;
      }
    });
    return Traductions(traductions: map);
  }
}

class TraductionConteModel {
  final int idConte;
  final String titreOriginal;
  final String descriptionOriginale;
  final String lieuOriginal;
  final String regionOriginale;
  final Traductions traductionsTitre;
  final Traductions traductionsContenu;
  final Traductions traductionsDescription;
  final Traductions traductionsLieu;
  final Traductions traductionsRegion;
  final List<String> languesDisponibles;
  final String langueSource;
  final String statutTraduction;

  TraductionConteModel({
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
    required this.languesDisponibles,
    required this.langueSource,
    required this.statutTraduction,
  });

  factory TraductionConteModel.fromJson(Map<String, dynamic> json) {
    return TraductionConteModel(
      idConte: json['idConte'] as int? ?? 0,
      titreOriginal: json['titreOriginal'] as String? ?? '',
      descriptionOriginale: json['descriptionOriginale'] as String? ?? '',
      lieuOriginal: json['lieuOriginal'] as String? ?? '',
      regionOriginale: json['regionOriginale'] as String? ?? '',

      traductionsTitre: Traductions.fromJson(json['traductionsTitre'] as Map<String, dynamic>? ?? {}),
      traductionsContenu: Traductions.fromJson(json['traductionsContenu'] as Map<String, dynamic>? ?? {}),
      traductionsDescription: Traductions.fromJson(json['traductionsDescription'] as Map<String, dynamic>? ?? {}),
      traductionsLieu: Traductions.fromJson(json['traductionsLieu'] as Map<String, dynamic>? ?? {}),
      traductionsRegion: Traductions.fromJson(json['traductionsRegion'] as Map<String, dynamic>? ?? {}),

      languesDisponibles: (json['languesDisponibles'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      langueSource: json['langueSource'] as String? ?? '',
      statutTraduction: json['statutTraduction'] as String? ?? '',
    );
  }
}