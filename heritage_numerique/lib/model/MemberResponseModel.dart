// Fichier : lib/model/MemberResponseModel.dart

/// Modèle pour la réponse du profil Membre, basé sur la sortie Swagger.
class MembreResponse {
  final int idMembre; // L'ID d'enregistrement (id: 1)
  final int idUtilisateur; // L'ID du compte utilisateur (idUtilisateur: 2)
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String ethnie;
  final String roleFamille;
  final String statut;
  final int idFamille;
  final String nomFamille;
  final DateTime dateAjout; // Stocké comme DateTime

  MembreResponse({
    required this.idMembre,
    required this.idUtilisateur,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.ethnie,
    required this.roleFamille,
    required this.statut,
    required this.idFamille,
    required this.nomFamille,
    required this.dateAjout,
  });

  factory MembreResponse.fromJson(Map<String, dynamic> json) {
    return MembreResponse(
      idMembre: json['id'], // Mappage de 'id' à idMembre (l'ID d'enregistrement)
      idUtilisateur: json['idUtilisateur'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      ethnie: json['ethnie'] ?? '',
      roleFamille: json['roleFamille'] ?? 'MEMBRE',
      statut: json['statut'] ?? 'INCONNU',
      idFamille: json['idFamille'] ?? 0,
      nomFamille: json['nomFamille'] ?? '',
      dateAjout: DateTime.parse(json['dateAjout']),
    );
  }
}