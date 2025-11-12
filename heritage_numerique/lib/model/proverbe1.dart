class Proverbe1 {
  final int? id;
  final String? titre;
  final String? proverbe;
  final String? signification;
  final String? origine;
  final String? nomAuteur;
  final String? prenomAuteur;
  final String? emailAuteur;
  final String? roleAuteur;
  final String? lienParenteAuteur;
  final DateTime? dateCreation;
  final String? statut;
  final String? urlPhoto;
  final int? idFamille;
  final String? nomFamille;

  Proverbe1({
    this.id,
    this.titre,
    this.proverbe,
    this.signification,
    this.origine,
    this.nomAuteur,
    this.prenomAuteur,
    this.emailAuteur,
    this.roleAuteur,
    this.lienParenteAuteur,
    this.dateCreation,
    this.statut,
    this.urlPhoto,
    this.idFamille,
    this.nomFamille,
  });

  factory Proverbe1.fromJson(Map<String, dynamic> json) {
    // La plupart des champs sont des String ou des int simples.
    // dateCreation est converti en DateTime.
    return Proverbe1(
      id: json['id'] as int?,
      titre: json['titre'] as String?,
      proverbe: json['proverbe'] as String?,
      signification: json['signification'] as String?,
      origine: json['origine'] as String?,
      nomAuteur: json['nomAuteur'] as String?,
      prenomAuteur: json['prenomAuteur'] as String?,
      emailAuteur: json['emailAuteur'] as String?,
      roleAuteur: json['roleAuteur'] as String?,
      lienParenteAuteur: json['lienParenteAuteur'] as String?,

      // Conversion sécurisée en DateTime, retourne null si la valeur est null ou invalide
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'] as String)
          : null,

      statut: json['statut'] as String?,
      urlPhoto: json['urlPhoto'] as String?,
      idFamille: json['idFamille'] as int?,
      nomFamille: json['nomFamille'] as String?,
    );
  }
}