// NOTE: Ce modèle doit correspondre à la version finale convenue (Utilisateur1)
class Utilisateur1 {
  final int? id;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? numeroTelephone;
  final String? ethnie;
  final String? motDePasse; // Ajouté pour la structure d'update (optionnel) et copyWith
  final String? role;
  final bool? actif;
  final DateTime? dateCreation;
  final DateTime? dateModification;

  Utilisateur1({
    this.id,
    this.nom,
    this.prenom,
    this.email,
    this.numeroTelephone,
    this.ethnie,
    this.motDePasse, // Inclusion pour l'envoi de données et copyWith
    this.role,
    this.actif,
    this.dateCreation,
    this.dateModification,
  });

  // 1. Constructeur factory pour désérialiser le JSON vers l'objet Dart
  factory Utilisateur1.fromJson(Map<String, dynamic> json) {
    return Utilisateur1(
      id: json['id'] as int?,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      numeroTelephone: json['numeroTelephone'] as String?,
      ethnie: json['ethnie'] as String?,
      // Le motDePasse n'est pas inclus ici car il n'est généralement pas renvoyé par l'API de consultation.
      role: json['role'] as String?,
      actif: json['actif'] as bool?,
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'])
          : null,
      dateModification: json['dateModification'] != null
          ? DateTime.tryParse(json['dateModification'])
          : null,
    );
  }

  // 2. Méthode pour sérialiser l'objet Dart vers un Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'numeroTelephone': numeroTelephone,
      'ethnie': ethnie,
      'motDePasse': motDePasse, // Inclus pour les requêtes (comme PUT/update)
      'role': role,
      'actif': actif,
      'dateCreation': dateCreation?.toIso8601String(),
      'dateModification': dateModification?.toIso8601String(),
    };
  }

  // 3. Méthode pour copier l'objet avec des champs modifiés
  Utilisateur1 copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? numeroTelephone,
    String? ethnie,
    String? motDePasse,
    String? role,
    bool? actif,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return Utilisateur1(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      numeroTelephone: numeroTelephone ?? this.numeroTelephone,
      ethnie: ethnie ?? this.ethnie,
      motDePasse: motDePasse ?? this.motDePasse,
      role: role ?? this.role,
      actif: actif ?? this.actif,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}