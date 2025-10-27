import 'dart:convert';

// ------------------------------------------------------------------
// --- CLASSE INVITATION ---
// ------------------------------------------------------------------

class Invitation {
  final int id;
  final int idFamille;
  final String nomFamille;
  final int idEmetteur;
  final String nomEmetteur;
  final String nomAdmin;
  final String nomInvite;
  final String emailInvite;
  final String telephoneInvite;
  final String lienParente;
  final String codeInvitation;
  final String statut;
  final DateTime dateCreation;
  final DateTime dateExpiration;
  final DateTime? dateUtilisation; // Peut être null

  Invitation({
    required this.id,
    required this.idFamille,
    required this.nomFamille,
    required this.idEmetteur,
    required this.nomEmetteur,
    required this.nomAdmin,
    required this.nomInvite,
    required this.emailInvite,
    required this.telephoneInvite,
    required this.lienParente,
    required this.codeInvitation,
    required this.statut,
    required this.dateCreation,
    required this.dateExpiration,
    this.dateUtilisation,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    // Helper pour extraire une String de manière sûre, en retournant '' si null
    String safeString(dynamic value) => (value as String?) ?? '';

    // Helper pour extraire un DateTime de manière sûre
    DateTime safeDateTime(dynamic value) {
      final String? dateString = value as String?;
      return dateString != null ? (DateTime.tryParse(dateString) ?? DateTime.now()) : DateTime.now();
    }

    return Invitation(
      id: (json['id'] as int?) ?? 0,
      idFamille: (json['idFamille'] as int?) ?? 0,

      // ✅ Correction de la gestion des Strings potentiellement nulles
      nomFamille: safeString(json['nomFamille']),

      idEmetteur: (json['idEmetteur'] as int?) ?? 0,

      // ✅ Correction de la gestion des Strings
      nomEmetteur: safeString(json['nomEmetteur']),
      nomAdmin: safeString(json['nomAdmin']),
      nomInvite: safeString(json['nomInvite']),
      emailInvite: safeString(json['emailInvite']),
      telephoneInvite: safeString(json['telephoneInvite']),
      lienParente: safeString(json['lienParente']),
      codeInvitation: safeString(json['codeInvitation']),
      statut: safeString(json['statut']),

      // Gestion des dates
      dateCreation: safeDateTime(json['dateCreation']),
      dateExpiration: safeDateTime(json['dateExpiration']),
      dateUtilisation: json['dateUtilisation'] != null && (json['dateUtilisation'] as String).isNotEmpty
          ? DateTime.tryParse(json['dateUtilisation'] as String)
          : null,
    );
  }

  // ⭐️ CORRECTION: Ajout de la méthode copyWith pour l'immutabilité ⭐️
  Invitation copyWith({
    int? id,
    int? idFamille,
    String? nomFamille,
    int? idEmetteur,
    String? nomEmetteur,
    String? nomAdmin,
    String? nomInvite,
    String? emailInvite,
    String? telephoneInvite,
    String? lienParente,
    String? codeInvitation,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateExpiration,
    DateTime? dateUtilisation,
  }) {
    return Invitation(
      id: id ?? this.id,
      idFamille: idFamille ?? this.idFamille,
      nomFamille: nomFamille ?? this.nomFamille,
      idEmetteur: idEmetteur ?? this.idEmetteur,
      nomEmetteur: nomEmetteur ?? this.nomEmetteur,
      nomAdmin: nomAdmin ?? this.nomAdmin,
      nomInvite: nomInvite ?? this.nomInvite,
      emailInvite: emailInvite ?? this.emailInvite,
      telephoneInvite: telephoneInvite ?? this.telephoneInvite,
      lienParente: lienParente ?? this.lienParente,
      codeInvitation: codeInvitation ?? this.codeInvitation,
      statut: statut ?? this.statut, // <--- C'est le champ le plus important pour votre correction
      dateCreation: dateCreation ?? this.dateCreation,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      dateUtilisation: dateUtilisation ?? this.dateUtilisation,
    );
  }
}

// ------------------------------------------------------------------
// --- CLASSE FAMILLE ---
// ------------------------------------------------------------------

class Famille {
  final int id;
  final String nom;
  final String description;
  final String ethnie;
  final String region;
  final int idCreateur;
  final String nomCreateur;
  final String nomAdmin;
  final DateTime dateCreation;
  final int nombreMembres;

  Famille({
    required this.id,
    required this.nom,
    required this.description,
    required this.ethnie,
    required this.region,
    required this.idCreateur,
    required this.nomCreateur,
    required this.nomAdmin,
    required this.dateCreation,
    required this.nombreMembres,
  });

  factory Famille.fromJson(Map<String, dynamic> json) {
    // Helper pour extraire une String de manière sûre, en retournant '' si null
    String safeString(dynamic value) => (value as String?) ?? '';

    // Helper pour extraire un DateTime de manière sûre
    DateTime safeDateTime(dynamic value) {
      final String? dateString = value as String?;
      return dateString != null ? (DateTime.tryParse(dateString) ?? DateTime.now()) : DateTime.now();
    }

    return Famille(
      id: (json['id'] as int?) ?? 0,

      // ✅ Correction : S'assurer que tous les String sont gérés pour les valeurs null
      nom: safeString(json['nom']),
      description: safeString(json['description']),
      ethnie: safeString(json['ethnie']),
      region: safeString(json['region']),

      idCreateur: (json['idCreateur'] as int?) ?? 0,

      // ✅ Correction de la gestion des Strings
      nomCreateur: safeString(json['nomCreateur']),
      nomAdmin: safeString(json['nomAdmin']),

      dateCreation: safeDateTime(json['dateCreation']),
      nombreMembres: (json['nombreMembres'] as int?) ?? 0,
    );
  }

  // ⭐️ Ajout de la méthode copyWith (si jamais vous devez modifier une famille) ⭐️
  Famille copyWith({
    int? id,
    String? nom,
    String? description,
    String? ethnie,
    String? region,
    int? idCreateur,
    String? nomCreateur,
    String? nomAdmin,
    DateTime? dateCreation,
    int? nombreMembres,
  }) {
    return Famille(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      ethnie: ethnie ?? this.ethnie,
      region: region ?? this.region,
      idCreateur: idCreateur ?? this.idCreateur,
      nomCreateur: nomCreateur ?? this.nomCreateur,
      nomAdmin: nomAdmin ?? this.nomAdmin,
      dateCreation: dateCreation ?? this.dateCreation,
      nombreMembres: nombreMembres ?? this.nombreMembres,
    );
  }
}

// ------------------------------------------------------------------
// --- CLASSE DASHBOARDPERSONNELRESPONSE ---
// ------------------------------------------------------------------

class DashboardPersonnelResponse {
  final int userId;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final int nombreFamillesAppartenance;
  final int nombreInvitationsEnAttente;
  final int nombreInvitationsRecues;
  final int nombreContenusCrees;
  final int nombreQuizCrees;
  final int nombreNotificationsNonLues;
  final List<Invitation> invitationsEnAttente;
  final List<Famille> familles;
  final List<Invitation> invitationsRecues;

  DashboardPersonnelResponse({
    required this.userId,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.nombreFamillesAppartenance,
    required this.nombreInvitationsEnAttente,
    required this.nombreInvitationsRecues,
    required this.nombreContenusCrees,
    required this.nombreQuizCrees,
    required this.nombreNotificationsNonLues,
    required this.invitationsEnAttente,
    required this.familles,
    required this.invitationsRecues,
  });

  factory DashboardPersonnelResponse.fromJson(Map<String, dynamic> json) {
    // Helper pour extraire une String de manière sûre, en retournant '' si null
    String safeString(dynamic value) => (value as String?) ?? '';

    // Gestion des listes pour éviter les exceptions si la clé est absente ou null
    final List<dynamic> invitationsEnAttenteJson = json['invitationsEnAttente'] ?? [];
    final List<dynamic> famillesJson = json['familles'] ?? [];
    final List<dynamic> invitationsRecuesJson = json['invitationsRecues'] ?? [];

    return DashboardPersonnelResponse(
      userId: (json['userId'] as int?) ?? 0,

      // ✅ Correction de la gestion des Strings
      nom: safeString(json['nom']),
      prenom: safeString(json['prenom']),
      email: safeString(json['email']),
      role: safeString(json['role']),

      // Utilisation de (as int?) ?? 0 pour gérer les valeurs null de l'API
      nombreFamillesAppartenance: (json['nombreFamillesAppartenance'] as int?) ?? 0,
      nombreInvitationsEnAttente: (json['nombreInvitationsEnAttente'] as int?) ?? 0,
      nombreInvitationsRecues: (json['nombreInvitationsRecues'] as int?) ?? 0,

      // ✅ Correction des accents dans les clés JSON pour les compteurs (si besoin)
      nombreContenusCrees: (json['nombreContenusCrees'] as int? ?? json['nombreContenusCreés'] as int?) ?? 0,
      nombreQuizCrees: (json['nombreQuizCrees'] as int? ?? json['nombreQuizCreés'] as int?) ?? 0,
      nombreNotificationsNonLues: (json['nombreNotificationsNonLues'] as int?) ?? 0,

      // Mappage des listes d'objets (safe list access)
      invitationsEnAttente: invitationsEnAttenteJson
          .map((i) => Invitation.fromJson(i as Map<String, dynamic>))
          .toList(),
      familles: famillesJson
          .map((f) => Famille.fromJson(f as Map<String, dynamic>))
          .toList(),
      invitationsRecues: invitationsRecuesJson
          .map((i) => Invitation.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  // ⭐️ CORRECTION: Ajout de la méthode copyWith pour l'immutabilité ⭐️
  DashboardPersonnelResponse copyWith({
    int? userId,
    String? nom,
    String? prenom,
    String? email,
    String? role,
    int? nombreFamillesAppartenance,
    int? nombreInvitationsEnAttente,
    int? nombreInvitationsRecues,
    int? nombreContenusCrees,
    int? nombreQuizCrees,
    int? nombreNotificationsNonLues,
    List<Invitation>? invitationsEnAttente,
    List<Famille>? familles,
    List<Invitation>? invitationsRecues,
  }) {
    return DashboardPersonnelResponse(
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      role: role ?? this.role,
      nombreFamillesAppartenance: nombreFamillesAppartenance ?? this.nombreFamillesAppartenance,
      nombreInvitationsEnAttente: nombreInvitationsEnAttente ?? this.nombreInvitationsEnAttente,
      nombreInvitationsRecues: nombreInvitationsRecues ?? this.nombreInvitationsRecues,
      nombreContenusCrees: nombreContenusCrees ?? this.nombreContenusCrees,
      nombreQuizCrees: nombreQuizCrees ?? this.nombreQuizCrees,
      nombreNotificationsNonLues: nombreNotificationsNonLues ?? this.nombreNotificationsNonLues,
      // Note: Pour les listes, on utilise le nouveau paramètre s'il est fourni, sinon la liste actuelle.
      invitationsEnAttente: invitationsEnAttente ?? this.invitationsEnAttente,
      familles: familles ?? this.familles,
      invitationsRecues: invitationsRecues ?? this.invitationsRecues,
    );
  }
}
