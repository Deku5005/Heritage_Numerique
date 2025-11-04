// lib/models/famille.dart
import 'Membre.dart'; // Importation nécessaire pour le type List<Membre>

class Famille {
  final int id;
  final int idFamille;
  final String nomFamille;
  final String nom;
  final String description;
  final String dateCreation;
  final List<Membre> membres; // Utilisation du modèle importé
  final int nombreMembres;

  Famille({
    required this.id,
    required this.idFamille,
    required this.nomFamille,
    required this.nom,
    required this.description,
    required this.dateCreation,
    required this.membres,
    required this.nombreMembres,
  });

  factory Famille.fromJson(Map<String, dynamic> json) {
    // Conversion de la liste de JSON en liste d'objets Membre
    var membresList = json['membres'] as List;
    List<Membre> membresData = membresList.map((i) => Membre.fromJson(i)).toList();

    return Famille(
      id: json['id'] as int,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      dateCreation: json['dateCreation'] as String,
      membres: membresData,
      nombreMembres: json['nombreMembres'] as int,
    );
  }
}