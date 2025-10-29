class FamilyMemberModel {
  final int id;
  final int idUtilisateur;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String ethnie;
  final String roleFamille;
  final String? lienParente;
  final DateTime dateAjout;
  final String statut;
  final int idFamille;
  final String nomFamille;
  // NOTE: 'bio' a été retiré pour coller aux champs vus dans les APIs précédentes.

  FamilyMemberModel({
    required this.id,
    required this.idUtilisateur,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.ethnie,
    required this.roleFamille,
    this.lienParente,
    required this.dateAjout,
    required this.statut,
    required this.idFamille,
    required this.nomFamille,
  });

  /// Constructeur de fabrique pour créer une instance à partir d'un Map JSON (Réponse API).
  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] as int,
      idUtilisateur: json['idUtilisateur'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      ethnie: json['ethnie'] as String,
      roleFamille: json['roleFamille'] as String,
      lienParente: json['lienParente'] as String?,
      // Utilisation d'une date par défaut ou de 'DateTime.tryParse' pour la robustesse
      dateAjout: DateTime.tryParse(json['dateAjout'] as String? ?? '') ?? DateTime(0),
      statut: json['statut'] as String,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
    );
  }

  /// Méthode pour le Request Body (Ajout d'un membre - non utilisé ici, mais maintenu).
  Map<String, dynamic> toJsonForCreation() {
    return {
      "idFamille": idFamille,
      "nom": nom,
      "prenom": prenom,
      "email": email,
      "telephone": telephone,
      "ethnie": ethnie,
      "lienParente": lienParente ?? '',
      "roleFamille": roleFamille,
    };
  }
}
