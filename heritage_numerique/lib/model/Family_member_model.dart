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

      // ✅ Sécurité ajoutée pour toutes les Strings non-nullable du modèle :
      nom: (json['nom'] as String?) ?? 'N/A',
      prenom: (json['prenom'] as String?) ?? 'N/A',
      email: (json['email'] as String?) ?? 'N/A',
      telephone: (json['telephone'] as String?) ?? 'N/A',
      ethnie: (json['ethnie'] as String?) ?? 'N/A',

      // ✅ C'EST ICI QUE LE CRASH SE PRODUIT AVEC UN NULL
      roleFamille: (json['roleFamille'] as String?) ?? 'LECTEUR',

      lienParente: json['lienParente'] as String?, // Reste String?

      dateAjout: DateTime.tryParse(json['dateAjout'] as String? ?? '') ?? DateTime(0),

      // ✅ C'EST ICI QUE LE CRASH SE PRODUIT AVEC UN NULL
      statut: (json['statut'] as String?) ?? 'INCONNU',

      idFamille: json['idFamille'] as int,
      nomFamille: (json['nomFamille'] as String?) ?? 'N/A',
    );
  }

  /// Méthode pour le Request Body (non utilisée ici).
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