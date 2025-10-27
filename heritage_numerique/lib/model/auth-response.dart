// Aucune modification nécessaire.
class AuthResponse {
  final String accessToken;
  final String tokenType;
  final int userId;
  final String email;
  final String nom;
  final String prenom;
  final String role;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
  });

  /// Méthode factory pour créer une instance à partir du JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    int _safeParseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return AuthResponse(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      userId: _safeParseInt(json['userId']),
      email: json['email'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      role: json['role'] as String,
    );
  }
}