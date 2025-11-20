import 'Membre.dart'; // Importation nécessaire pour le type List<Membre>

class Famille {
  // --- Champs Minimaux / Essentiels ---
  final int id;
  final List<Membre> membres; // Mappe la clé 'racines' du JSON

  // --- Champs Optionnels (String, int) ---
  final int? idFamille;
  final String? nomFamille;
  final String? nom;
  final String? description;
  final String? dateCreation;
  final int? nombreMembres;

  Famille({
    required this.id,
    required this.membres, // La liste elle-même doit exister (même si vide)
    this.idFamille,
    this.nomFamille,
    this.nom,
    this.description,
    this.dateCreation,
    this.nombreMembres,
  });

  factory Famille.fromJson(Map<String, dynamic> json) {
    // 🔑 Fonction utilitaire pour gérer la conversion double -> int?
    // C'est la solution à l'erreur "type 'double' is not a subtype of type 'int?'"
    int? safeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.round(); // Convertit le double en int (arrondi)
      return null;
    }

    // 1. Gestion de la liste des membres (Racines)
    final List<Membre> membresData = (json['racines'] as List?) // <-- CORRECTION: utilise 'racines'
        ?.map((item) => Membre.fromJson(item as Map<String, dynamic>))
        .toList()
        ?? <Membre>[]; // Retourne une liste vide si 'racines' est null

    return Famille(
      // 2. Mappage des champs int en utilisant safeInt
      id: safeInt(json['id'])!, // id est obligatoire
      membres: membresData,

      idFamille: safeInt(json['idFamille']),
      nomFamille: json['nomFamille'] as String?,
      nom: json['nom'] as String?,
      description: json['description'] as String?,
      dateCreation: json['dateCreation'] as String?,
      nombreMembres: safeInt(json['nombreMembres']), // <-- Correction appliquée ici
    );
  }
}