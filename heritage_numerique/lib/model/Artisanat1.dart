class Artisanat1 {
  // Gardons 'id' non-nullable si c'est la clé primaire.
  final int id;

  // Les autres champs sont rendus optionnels (nullable)
  final String? titre;
  final String? description;
  final String? nomAuteur;
  final String? prenomAuteur;
  final String? emailAuteur;
  final String? roleAuteur;
  final String? lienParenteAuteur;
  final DateTime? dateCreation;
  final String? statut;

  // Les listes doivent aussi être nullable, et leurs contenus doivent gérer le null (si l'API peut envoyer [null])
  final List<String>? urlPhotos;

  final String? urlVideo;
  final String? lieu;
  final String? region;
  final int? idFamille;
  final String? nomFamille;

  Artisanat1({
    required this.id, // Requis
    this.titre,
    this.description,
    this.nomAuteur,
    this.prenomAuteur,
    this.emailAuteur,
    this.roleAuteur,
    this.lienParenteAuteur,
    this.dateCreation,
    this.statut,
    this.urlPhotos,
    this.urlVideo,
    this.lieu,
    this.region,
    this.idFamille,
    this.nomFamille,
  });

  /// Méthode pour créer une instance d'Artisanat1 à partir d'une carte JSON.
  factory Artisanat1.fromJson(Map<String, dynamic> json) {
    // Gestion sécurisée des champs optionnels
    final dateCreationString = json['dateCreation'] as String?; // Notez le '?'

    return Artisanat1(
      id: json['id'] as int, // Supposons que l'ID est toujours présent
      titre: json['titre'] as String?,
      description: json['description'] as String?,
      nomAuteur: json['nomAuteur'] as String?,
      prenomAuteur: json['prenomAuteur'] as String?,
      emailAuteur: json['emailAuteur'] as String?,
      roleAuteur: json['roleAuteur'] as String?,
      lienParenteAuteur: json['lienParenteAuteur'] as String?,
      // Conversion de la date gérée par null-safety
      dateCreation: dateCreationString != null ? DateTime.tryParse(dateCreationString) : null,
      statut: json['statut'] as String?,
      // Conversion de List<dynamic> à List<String>?
      urlPhotos: (json['urlPhotos'] is List)
          ? (json['urlPhotos'] as List)
          .map((e) => e as String) // On suppose que les éléments internes sont des String
          .toList()
          : null,
      urlVideo: json['urlVideo'] as String?,
      lieu: json['lieu'] as String?,
      region: json['region'] as String?,
      idFamille: json['idFamille'] as int?,
      nomFamille: json['nomFamille'] as String?,
    );
  }

  /// Méthode pour convertir l'objet en carte JSON (Pour les requêtes PUT/POST).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Les champs optionnels peuvent être inclus s'ils ne sont pas nuls
      if (titre != null) 'titre': titre,
      if (description != null) 'description': description,
      if (nomAuteur != null) 'nomAuteur': nomAuteur,
      if (prenomAuteur != null) 'prenomAuteur': prenomAuteur,
      if (emailAuteur != null) 'emailAuteur': emailAuteur,
      if (roleAuteur != null) 'roleAuteur': roleAuteur,
      if (lienParenteAuteur != null) 'lienParenteAuteur': lienParenteAuteur,
      // Convertir le DateTime en chaîne ISO 8601 s'il n'est pas nul
      if (dateCreation != null) 'dateCreation': dateCreation!.toIso8601String(),
      if (statut != null) 'statut': statut,
      if (urlPhotos != null) 'urlPhotos': urlPhotos,
      if (urlVideo != null) 'urlVideo': urlVideo,
      if (lieu != null) 'lieu': lieu,
      if (region != null) 'region': region,
      if (idFamille != null) 'idFamille': idFamille,
      if (nomFamille != null) 'nomFamille': nomFamille,
    };
  }
}