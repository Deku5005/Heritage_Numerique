// traduction_conte_model.dart

import 'dart:convert';

// Fonction d'aide pour la désérialisation
TraductionConte traductionConteFromJson(String str) => TraductionConte.fromJson(json.decode(str));

// Classe de traduction générique pour les champs (titre, contenu, etc.)
class TraductionMap {
  final Map<String, String> traductions;

  TraductionMap({required this.traductions});

  factory TraductionMap.fromJson(Map<String, dynamic> json) {
    // S'assure que toutes les clés sont des strings
    final Map<String, String> result = json.map(
          (key, value) => MapEntry(key, value.toString()),
    );
    return TraductionMap(traductions: result);
  }
}

class TraductionConte {
  final int idConte;
  final String titreOriginal;
  final String descriptionOriginale;
  final String lieuOriginal;
  final String regionOriginale;

  final TraductionMap traductionsTitre;
  final TraductionMap traductionsContenu; // ✅ C'EST LE CONTENU DU FICHIER QUE NOUS VOULONS AFFICHER
  final TraductionMap traductionsDescription;
  final TraductionMap traductionsLieu;
  final TraductionMap traductionsRegion;

  final List<String> languesDisponibles;
  final String langueSource;
  final String statutTraduction;

  TraductionConte({
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

  factory TraductionConte.fromJson(Map<String, dynamic> json) {
    return TraductionConte(
      idConte: json['idConte'] as int,
      titreOriginal: json['titreOriginal'] as String,
      descriptionOriginale: json['descriptionOriginale'] as String,
      lieuOriginal: json['lieuOriginal'] as String,
      regionOriginale: json['regionOriginale'] as String,

      traductionsTitre: TraductionMap.fromJson(json['traductionsTitre'] as Map<String, dynamic>),
      traductionsContenu: TraductionMap.fromJson(json['traductionsContenu'] as Map<String, dynamic>),
      traductionsDescription: TraductionMap.fromJson(json['traductionsDescription'] as Map<String, dynamic>),
      traductionsLieu: TraductionMap.fromJson(json['traductionsLieu'] as Map<String, dynamic>),
      traductionsRegion: TraductionMap.fromJson(json['traductionsRegion'] as Map<String, dynamic>),

      languesDisponibles: List<String>.from(json['languesDisponibles']),
      langueSource: json['langueSource'] as String,
      statutTraduction: json['statutTraduction'] as String,
    );
  }
}