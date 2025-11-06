// Fichier: lib/model/QuizResultModel.dart

class UserResult {
  final int id;
  final User user;
  final int score;
  final int scoreMax;
  final DateTime datePassage;

  UserResult({
    required this.id,
    required this.user,
    required this.score,
    required this.scoreMax,
    required this.datePassage,
  });

  factory UserResult.fromJson(Map<String, dynamic> json) {
    return UserResult(
      id: (json['id'] as int?) ?? 0,
      user: User.fromJson(json['utilisateur'] as Map<String, dynamic>),
      score: (json['score'] as int?) ?? 0,
      scoreMax: (json['scoreMax'] as int?) ?? 0,
      datePassage: DateTime.parse(json['datePassage'] as String),
    );
  }
}

class User {
  final int id;
  final String nom;
  final String prenom;

  User({required this.id, required this.nom, required this.prenom});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as int?) ?? 0,
      nom: (json['nom'] as String?) ?? 'Nom Inconnu',
      prenom: (json['prenom'] as String?) ?? 'Prénom Inconnu',
    );
  }
}