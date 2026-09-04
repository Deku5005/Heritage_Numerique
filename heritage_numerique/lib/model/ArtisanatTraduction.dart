// Fichier: lib/model/ArtisanatTraduction.dart

import 'dart:convert';

/// Représente la réponse de traduction pour un contenu d'Artisanat.
class ArtisanatTraduction {
  final int idContenu;
  final String titreOriginal;
  final String descriptionOriginale;
  final String? lieuOriginal;
  final String? regionOriginale;

  // Maps des traductions par code de langue (ex: {'fra_Latn': 'Titre en français'})
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

  /// Factory constructor pour créer une instance à partir d'un Map JSON.
  factory ArtisanatTraduction.fromJson(Map<String, dynamic> json) {
    // Fonction utilitaire pour s'assurer qu'un Map est bien de type Map<String, String>
    Map<String, String> parseMap(dynamic map) {
      if (map == null) return {};
      return Map<String, String>.from(map.map((k, v) => MapEntry(k as String, v as String)));
    }

    return ArtisanatTraduction(
      idContenu: json['idConte'] as int, // L'API utilise 'idConte'
      titreOriginal: json['titreOriginal'] as String,
      descriptionOriginale: json['descriptionOriginale'] as String,
      lieuOriginal: json['lieuOriginal'] as String?,
      regionOriginale: json['regionOriginale'] as String?,

      traductionsTitre: parseMap(json['traductionsTitre']),
      traductionsContenu: parseMap(json['traductionsContenu']),
      traductionsDescription: parseMap(json['traductionsDescription']),
      traductionsLieu: parseMap(json['traductionsLieu']),
      traductionsRegion: parseMap(json['traductionsRegion']),
      traductionsCompletes: parseMap(json['traductionsCompletes']),

      languesDisponibles: List<String>.from(json['languesDisponibles'] ?? []),
      langueSource: json['langueSource'] as String,
      statutTraduction: json['statutTraduction'] as String,
    );
  }
}