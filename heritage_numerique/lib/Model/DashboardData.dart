// lib/Model/DashboardData.dart (Créez ce nouveau fichier)

import 'Famille.dart'; // N'oubliez pas d'importer le modèle Famille

class DashboardData {
  final int userId;
  final String nom;
  final String prenom;
  final String email;
  final String role;
  final int nombreFamillesAppartenance;
  final int nombreInvitationsEnAttente;
  final int nombreContenusCrees;
  final int nombreQuizCrees;
  final int nombreNotificationsNonLues;
  final List<dynamic> invitationsEnAttente; // Laisser dynamic car c'est un tableau vide
  final List<Famille> familles;

  DashboardData({
    required this.userId,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
    required this.nombreFamillesAppartenance,
    required this.nombreInvitationsEnAttente,
    required this.nombreContenusCrees,
    required this.nombreQuizCrees,
    required this.nombreNotificationsNonLues,
    required this.invitationsEnAttente,
    required this.familles,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // Mapping de la liste des familles
    final List<dynamic> famillesList = json['familles'] as List<dynamic>;
    final List<Famille> famillesObj = famillesList.map((f) => Famille.fromJson(f as Map<String, dynamic>)).toList();

    return DashboardData(
      userId: json['userId'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      nombreFamillesAppartenance: json['nombreFamillesAppartenance'] as int,
      nombreInvitationsEnAttente: json['nombreInvitationsEnAttente'] as int,
      nombreContenusCrees: json['nombreContenusCreés'] as int,
      nombreQuizCrees: json['nombreQuizCreés'] as int,
      nombreNotificationsNonLues: json['nombreNotificationsNonLues'] as int,
      invitationsEnAttente: json['invitationsEnAttente'] as List<dynamic>,
      familles: famillesObj,
    );
  }
}