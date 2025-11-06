// Modèle Dart pour représenter une seule invitation reçue de l'API
// GET /api/invitations/famille/{familleId}
class InvitationResponse {
  final int id;
  final int idFamille;
  final String nomFamille;
  final String nomInvite;
  final String emailInvite;
  final String lienParente;
  final String codeInvitation;
  final String statut; // Ex: 'ACCEPTEE', 'EN_ATTENTE', 'REJETEE'
  final DateTime dateCreation;
  final DateTime dateExpiration;

  InvitationResponse({
    required this.id,
    required this.idFamille,
    required this.nomFamille,
    required this.nomInvite,
    required this.emailInvite,
    required this.lienParente,
    required this.codeInvitation,
    required this.statut,
    required this.dateCreation,
    required this.dateExpiration,
  });

  /// Méthode factory pour créer une instance de InvitationResponse à partir d'un JSON.
  factory InvitationResponse.fromJson(Map<String, dynamic> json) {
    // Fonction utilitaire pour gérer la conversion des IDs (au cas où ils seraient String)
    int _safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return InvitationResponse(
      id: _safeParseInt(json['id']),
      idFamille: _safeParseInt(json['idFamille']),
      nomFamille: json['nomFamille'] as String,
      nomInvite: json['nomInvite'] as String,
      emailInvite: json['emailInvite'] as String,
      lienParente: json['lienParente'] as String,
      codeInvitation: json['codeInvitation'] as String,
      statut: json['statut'] as String,
      // Conversion de la chaîne ISO 8601 en objet DateTime
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateExpiration: DateTime.parse(json['dateExpiration'] as String),
    );
  }
}