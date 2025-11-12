/// Représente une Devinette (énigme) récupérée de l'API /api/public/devinettes.
/// Tous les champs sont définis comme optionnels (nullable) pour gérer les données manquantes.
class Devinette1 {
  final int? id;
  final String? titre;
  final String? devinette;
  final String? reponse;
  final String? nomAuteur;
  final String? prenomAuteur;
  final String? emailAuteur;
  final String? roleAuteur;
  final String? lienParenteAuteur;
  final DateTime? dateCreation;
  final String? statut;
  final String? lieu;
  final String? region;
  final int? idFamille;
  final String? nomFamille;

  Devinette1({
    this.id,
    this.titre,
    this.devinette,
    this.reponse,
    this.nomAuteur,
    this.prenomAuteur,
    this.emailAuteur,
    this.roleAuteur,
    this.lienParenteAuteur,
    this.dateCreation,
    this.statut,
    this.lieu,
    this.region,
    this.idFamille,
    this.nomFamille,
  });

  /// Factory constructor pour créer une instance de Devinette1 à partir d'un Map JSON.
  factory Devinette1.fromJson(Map<String, dynamic> json) {
    return Devinette1(
      id: json['id'] as int?,
      titre: json['titre'] as String?,
      devinette: json['devinette'] as String?,
      reponse: json['reponse'] as String?,
      nomAuteur: json['nomAuteur'] as String?,
      prenomAuteur: json['prenomAuteur'] as String?,
      emailAuteur: json['emailAuteur'] as String?,
      roleAuteur: json['roleAuteur'] as String?,
      lienParenteAuteur: json['lienParenteAuteur'] as String?,
      // Tente de convertir la chaîne de date/heure en objet DateTime
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'] as String)
          : null,
      statut: json['statut'] as String?,
      lieu: json['lieu'] as String?,
      region: json['region'] as String?,
      idFamille: json['idFamille'] as int?,
      nomFamille: json['nomFamille'] as String?,
    );
  }
}