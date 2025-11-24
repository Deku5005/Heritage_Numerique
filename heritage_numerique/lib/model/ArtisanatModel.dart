// Fichier: lib/model/ArtisanatModel.dart (CORRIGÉ pour la normalisation d'URL)

import 'dart:io';
import 'dart:convert';

// ⚠️ Définition de la BASE URL pour la désérialisation si l'API renvoie des chemins relatifs
const String _baseUrl = "http://10.0.2.2:8080";

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

    // Fonction utilitaire locale pour nettoyer et normaliser l'URL
    String _normalizeUrl(String url) {
      if (url.startsWith('http')) {
        // Nettoie l'erreur de double barre oblique si elle existe dans l'URL complète
        return url.replaceAll('//uploads', '/uploads');
      } else {
        // Résout le chemin relatif pour obtenir l'URL complète
        final Uri fullUri = Uri.parse(_baseUrl).resolve(url);
        return fullUri.toString();
      }
    }

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
      urlVideo: json['urlVideo'] as String?,
      lieu: json['lieu'] as String?,
      region: json['region'] as String?,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      // Gère la liste d'URL et normalise chaque élément
      urlPhotos: (json['urlPhotos'] as List<dynamic>?)
          ?.map((e) => _normalizeUrl(e.toString()))
          .toList() ?? [],
    );
  }
}

// 💡 Modèle de charge utile pour la CRÉATION (inchangé)
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