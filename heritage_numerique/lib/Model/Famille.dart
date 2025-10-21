// lib/Model/Famille.dart (Créez ce nouveau fichier)

class Famille {
  final int id;
  final String nom;
  final String description;
  final int idCreateur;
  final String nomCreateur;
  final String dateCreation;
  final int nombreMembres;

  Famille({
    required this.id,
    required this.nom,
    required this.description,
    required this.idCreateur,
    required this.nomCreateur,
    required this.dateCreation,
    required this.nombreMembres,
  });

  factory Famille.fromJson(Map<String, dynamic> json) {
    return Famille(
      id: json['id'] as int,
      nom: json['nom'] as String,
      description: json['description'] as String,
      idCreateur: json['idCreateur'] as int,
      nomCreateur: json['nomCreateur'] as String,
      dateCreation: json['dateCreation'] as String,
      nombreMembres: json['nombreMembres'] as int,
    );
  }
}