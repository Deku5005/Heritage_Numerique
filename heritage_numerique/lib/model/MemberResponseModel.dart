// Fichier : lib/model/MemberResponseModel.dart

/// Modèle pour la réponse du profil Membre, basé sur la nouvelle sortie JSON.
class MembreResponse {
  final int id; // L'ID d'enregistrement (anciennement idMembre)
  // final int? idUtilisateur; // Supprimé, n'apparaît plus dans le JSON
  final String nom;
  final String prenom;
  final String email;
  final String numeroTelephone; // Changement de nom : telephone -> numeroTelephone
  final String ethnie;
  final String role; // Nouveau champ : Rôle général
  final bool actif; // Changement de type/nom : statut (String) -> actif (bool)
  final int idFamille;
  final String nomFamille;
  final String roleFamille;
  final String lienParente; // Nouveau champ
  final DateTime dateCreation; // Changement de nom : dateAjout -> dateCreation
  final DateTime dateAjoutFamille; // Nouveau champ

  MembreResponse({
    required this.id,
    // this.idUtilisateur,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.numeroTelephone,
    required this.ethnie,
    required this.role,
    required this.actif,
    required this.idFamille,
    required this.nomFamille,
    required this.roleFamille,
    required this.lienParente,
    required this.dateCreation,
    required this.dateAjoutFamille,
  });

  factory MembreResponse.fromJson(Map<String, dynamic> json) {
    return MembreResponse(
      id: json['id'] ?? 0,
      // idUtilisateur: json['idUtilisateur'], // N'est plus dans le JSON
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      numeroTelephone: json['numeroTelephone'] ?? '', // Mappage du nouveau nom
      ethnie: json['ethnie'] ?? '',
      role: json['role'] ?? '',
      actif: json['actif'] ?? false, // Mappage de 'actif' (booléen)
      idFamille: json['idFamille'] ?? 0,
      nomFamille: json['nomFamille'] ?? '',
      roleFamille: json['roleFamille'] ?? '',
      lienParente: json['lienParente'] ?? '', // Nouveau champ
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : DateTime.now(), // Mappage de 'dateCreation'
      dateAjoutFamille: json['dateAjoutFamille'] != null
          ? DateTime.parse(json['dateAjoutFamille'])
          : DateTime.now(), // Nouveau champ
    );
  }
}