// Fichier: lib/model/ArtisanatModel.dart

import 'dart:io';
import 'dart:convert';

// --- Désérialisation de la liste (utilitaire) ---
List<Artisanat> artisanatsFromJson(String str) =>
    List<Artisanat>.from(json.decode(str).map((x) => Artisanat.fromJson(x)));


class Artisanat {
  final int id;
  final String titre;
  final String description;
  final String nomAuteur;
  final String prenomAuteur;
  final String? emailAuteur;
  final String? roleAuteur;
  final String? lienParenteAuteur;
  final DateTime dateCreation;
  final String statut;
  final List<String> urlPhotos; // Liste des URLs des photos
  final String? urlVideo;
  final String? lieu;
  final String? region;
  final int idFamille;
  final String nomFamille;

  Artisanat({
    required this.id,
    required this.titre,
    required this.description,
    required this.nomAuteur,
    required this.prenomAuteur,
    this.emailAuteur,
    this.roleAuteur,
    this.lienParenteAuteur,
    required this.dateCreation,
    required this.statut,
    required this.urlPhotos,
    this.urlVideo,
    this.lieu,
    this.region,
    required this.idFamille,
    required this.nomFamille,
  });

  // Méthode de désérialisation (Factory fromJson)
  factory Artisanat.fromJson(Map<String, dynamic> json) {
    return Artisanat(
      id: json['id'] as int,
      titre: json['titre'] as String,
      description: json['description'] as String,
      nomAuteur: json['nomAuteur'] as String,
      prenomAuteur: json['prenomAuteur'] as String,
      emailAuteur: json['emailAuteur'] as String?,
      roleAuteur: json['roleAuteur'] as String?,
      lienParenteAuteur: json['lienParenteAuteur'] as String?,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      statut: json['statut'] as String,
      // Gère l'URL de la vidéo (peut être null ou une chaîne vide)
      urlVideo: json['urlVideo'] as String?,
      lieu: json['lieu'] as String?,
      region: json['region'] as String?,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      // 💡 Gère la liste d'URL, garantissant qu'elle est une liste de chaînes
      urlPhotos: (json['urlPhotos'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

// 💡 Modèle de charge utile pour la CRÉATION (inchangé, basé sur les exigences POST)
class ArtisanatCreationPayload {
  final int idFamille;
  final int idCategorie;
  final String titre;
  final String description;
  final String? lieu;
  final String? region;
  final String? photoArtisanatPath; // Chemin local du fichier photo
  final String? videoArtisanatPath; // Chemin local du fichier vidéo

  ArtisanatCreationPayload({
    required this.idFamille,
    required this.idCategorie,
    required this.titre,
    required this.description,
    this.lieu,
    this.region,
    this.photoArtisanatPath,
    this.videoArtisanatPath,
  });
}