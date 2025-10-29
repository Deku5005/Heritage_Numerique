class FamilyMemberModel {
  final int id;
  final int idUtilisateur;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String ethnie;
  final String roleFamille;
  final String? lienParente; // Rendu optionnel pour refléter la réponse JSON
  final DateTime dateAjout;
  final String statut;
  final int idFamille;
  final String nomFamille;

  // Le champ 'bio' n'est pas dans la réponse de l'API d'ajout, on le retire ou on le laisse optionnel.
  // Je le retire pour coller à la structure de la réponse fournie.

  FamilyMemberModel({
    required this.id,
    required this.idUtilisateur,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.ethnie,
    required this.roleFamille,
    this.lienParente, // Maintenant optionnel
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
      lienParente: json['lienParente'] as String?, // Nom de la clé harmonisé
      dateAjout: DateTime.parse(json['dateAjout'] as String),
      statut: json['statut'] as String,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
    );
  }

  // --- Méthode pour le Request Body (Ajout d'un membre) ---

  // Cette méthode est utilisée pour transformer l'objet en JSON lors de l'appel POST.
  Map<String, dynamic> toJsonForCreation() {
    // Les champs "idUtilisateur", "dateAjout", "statut", "nomFamille", "id"
    // ne sont PAS nécessaires pour la création et sont gérés par le serveur.

    return {
      "idFamille": idFamille, // Requis dans le Request Body
      "nom": nom,
      "prenom": prenom,
      "email": email,
      "telephone": telephone,
      "ethnie": ethnie,
      "lienParente": lienParente ?? '', // Assurer que c'est une chaîne pour l'API
      "roleFamille": roleFamille,
    };
  }
}
