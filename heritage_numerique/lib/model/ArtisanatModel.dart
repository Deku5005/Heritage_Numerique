import 'dart:io';
import 'dart:convert';

// ⚠️ Définition de la BASE URL pour la désérialisation si l'API renvoie des chemins relatifs
const String _baseUrl = "http://10.0.2.2:8080";

// --- Désérialisation de la liste (utilitaire) ---
List<Artisanat> artisanatsFromJson(String str) =>
    List<Artisanat>.from(json.decode(str).map((x) => Artisanat.fromJson(x)));

Artisanat artisanatFromJson(String str) => Artisanat.fromJson(json.decode(str));


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
    String _normalizeUrl(String? url) {
      if (url == null || url.isEmpty) return url ?? '';

      // Si l'URL est déjà complète (http/https), retourne-la (avec nettoyage)
      if (url.startsWith('http')) {
        // Nettoie l'erreur de double barre oblique si elle existe dans l'URL complète
        return url.replaceAll('//uploads', '/uploads');
      } else {
        // Si c'est un chemin relatif (/uploads/...), résout-le avec la base URL
        // Le `resolve` gère correctement l'ajout du slash si nécessaire.
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

      // 🛑 CORRECTION APPLIQUÉE ICI : Normalisation de l'URL de la vidéo
      urlVideo: _normalizeUrl(json['urlVideo'] as String?),

      lieu: json['lieu'] as String?,
      region: json['region'] as String?,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,

      // Gère la liste d'URL et normalise chaque élément
      urlPhotos: (json['urlPhotos'] as List<dynamic>?)
          ?.map((e) => _normalizeUrl(e.toString())) // Utilisation de _normalizeUrl
          .toList() ?? [],
    );
  }

  // 💡 AJOUT : Méthode copyWith pour gérer l'immutabilité (CORRECTION ERREUR 1)
  Artisanat copyWith({
    int? id,
    String? titre,
    String? description,
    String? nomAuteur,
    String? prenomAuteur,
    String? emailAuteur,
    String? roleAuteur,
    String? lienParenteAuteur,
    DateTime? dateCreation,
    String? statut,
    List<String>? urlPhotos,
    String? urlVideo,
    String? lieu,
    String? region,
    int? idFamille,
    String? nomFamille,
  }) {
    return Artisanat(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      nomAuteur: nomAuteur ?? this.nomAuteur,
      prenomAuteur: prenomAuteur ?? this.prenomAuteur,
      emailAuteur: emailAuteur ?? this.emailAuteur,
      roleAuteur: roleAuteur ?? this.roleAuteur,
      lienParenteAuteur: lienParenteAuteur ?? this.lienParenteAuteur,
      dateCreation: dateCreation ?? this.dateCreation,
      statut: statut ?? this.statut,
      urlPhotos: urlPhotos ?? this.urlPhotos,
      urlVideo: urlVideo ?? this.urlVideo,
      lieu: lieu ?? this.lieu,
      region: region ?? this.region,
      idFamille: idFamille ?? this.idFamille,
      nomFamille: nomFamille ?? this.nomFamille,
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