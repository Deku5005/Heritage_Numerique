// NOTE: Ce modèle sert à désérialiser la réponse de l'API de changement de rôle,
// qui renvoie les informations de la famille mise à jour.

class FamilyModel {
  final int id;
  final String nom;
  final String description;
  final String ethnie;
  final String region;
  final int idCreateur;
  final String nomCreateur;
  final String nomAdmin;
  final DateTime dateCreation;
  final int nombreMembres;

  FamilyModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.ethnie,
    required this.region,
    required this.idCreateur,
    required this.nomCreateur,
    required this.nomAdmin,
    required this.dateCreation,
    required this.nombreMembres,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'] as int,
      nom: json['nom'] as String,
      description: json['description'] as String,
      ethnie: json['ethnie'] as String,
      region: json['region'] as String,
      idCreateur: json['idCreateur'] as int,
      nomCreateur: json['nomCreateur'] as String,
      nomAdmin: json['nomAdmin'] as String,
      // Utilise DateTime.parse pour convertir la chaîne ISO 8601 en objet DateTime.
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      nombreMembres: json['nombreMembres'] as int,
    );
  }
}
