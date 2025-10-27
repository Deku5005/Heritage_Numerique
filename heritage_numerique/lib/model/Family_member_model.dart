class FamilyMemberModel {
  final int id;
  final int idUtilisateur;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String ethnie;
  final String roleFamille;
  final DateTime dateAjout;
  final String statut;
  final int idFamille;
  final String nomFamille;

  // Note: 'lienDeParenté' et 'bio' sont ajoutés ici pour la vue détaillée
  final String? lienDeParente;
  final String? bio;

  FamilyMemberModel({
    required this.id,
    required this.idUtilisateur,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.ethnie,
    required this.roleFamille,
    required this.dateAjout,
    required this.statut,
    required this.idFamille,
    required this.nomFamille,
    this.lienDeParente,
    this.bio,
  });

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
      // Conversion de la chaîne de date en objet DateTime
      dateAjout: DateTime.parse(json['dateAjout'] as String),
      statut: json['statut'] as String,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      // Ces champs sont optionnels dans la liste, mais disponibles dans le détail
      lienDeParente: json['lienDeParente'] as String?,
      bio: json['bio'] as String?,
    );
  }
}
