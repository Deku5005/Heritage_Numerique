// Modèle de données pour la Devinette (correspond à la réponse de l'API)
class Devinette {
  final int id;
  final String titre;
  final String devinette; // Correspond à 'texteDevinette' pour la création
  final String reponse; // Correspond à 'reponseDevinette' pour la création
  final String nomAuteur;
  final String prenomAuteur;
  final String emailAuteur;
  final String roleAuteur;
  final String lienParenteAuteur;
  final DateTime dateCreation;
  final String statut;
  final String? lieu;
  final String? region;
  final int idFamille;
  final String nomFamille;
  final String? urlPhoto; // Ajouté pour gérer l'image (non spécifié dans JSON mais probable)

  const Devinette({
    required this.id,
    required this.titre,
    required this.devinette,
    required this.reponse,
    required this.nomAuteur,
    required this.prenomAuteur,
    required this.emailAuteur,
    required this.roleAuteur,
    required this.lienParenteAuteur,
    required this.dateCreation,
    required this.statut,
    this.lieu,
    this.region,
    required this.idFamille,
    required this.nomFamille,
    this.urlPhoto, // Rendre optionnel
  });

  // Factory constructor pour créer une instance à partir du JSON (réponse GET)
  factory Devinette.fromJson(Map<String, dynamic> json) {
    return Devinette(
      id: json['id'] as int,
      titre: json['titre'] as String,
      devinette: json['devinette'] as String,
      reponse: json['reponse'] as String,
      nomAuteur: json['nomAuteur'] as String,
      prenomAuteur: json['prenomAuteur'] as String,
      emailAuteur: json['emailAuteur'] as String,
      roleAuteur: json['roleAuteur'] as String,
      lienParenteAuteur: json['lienParenteAuteur'] as String,
      // Conversion de la chaîne de date en objet DateTime
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      statut: json['statut'] as String,
      lieu: json['lieu'] as String?,
      region: json['region'] as String?,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      // Supposons que l'URL de la photo est un champ appelé 'urlPhoto' si elle existe
      urlPhoto: json['urlPhoto'] as String?,
    );
  }
}
