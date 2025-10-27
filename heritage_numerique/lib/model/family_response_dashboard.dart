// lib/model/family_dashboard_response.dart

class FamilyDashboardResponse {
  final int idFamille;
  final String nomFamille;
  final int nombreMembres;
  final int nombreInvitationsEnAttente;
  final int nombreContenusPrives;
  final int nombreContenusPublics;
  final int nombreQuizActifs;
  final int nombreNotificationsNonLues;
  final int nombreArbreGenealogiques;

  FamilyDashboardResponse({
    required this.idFamille,
    required this.nomFamille,
    required this.nombreMembres,
    required this.nombreInvitationsEnAttente,
    required this.nombreContenusPrives,
    required this.nombreContenusPublics,
    required this.nombreQuizActifs,
    required this.nombreNotificationsNonLues,
    required this.nombreArbreGenealogiques,
  });

  factory FamilyDashboardResponse.fromJson(Map<String, dynamic> json) {
    return FamilyDashboardResponse(
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      nombreMembres: json['nombreMembres'] as int,
      nombreInvitationsEnAttente: json['nombreInvitationsEnAttente'] as int,
      nombreContenusPrives: json['nombreContenusPrives'] as int,
      nombreContenusPublics: json['nombreContenusPublics'] as int,
      nombreQuizActifs: json['nombreQuizActifs'] as int,
      nombreNotificationsNonLues: json['nombreNotificationsNonLues'] as int,
      nombreArbreGenealogiques: json['nombreArbreGenealogiques'] as int,
    );
  }
}