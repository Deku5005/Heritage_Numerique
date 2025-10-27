import 'package:json_annotation/json_annotation.dart';
import 'package:heritage_numerique/models/base_model.dart';

part 'auth_models.g.dart';

/// Modèle pour la requête d'inscription
@JsonSerializable()
class RegisterRequest extends BaseModel {
  final String nom;
  final String prenom;
  final String email;
  final String numeroTelephone;
  final String ethnie;
  final String motDePasse;
  final String? codeInvitation; // Optionnel

  RegisterRequest({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.numeroTelephone,
    required this.ethnie,
    required this.motDePasse,
    this.codeInvitation,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

/// Modèle pour la réponse d'authentification (inscription/connexion)
@JsonSerializable()
class AuthResponse extends BaseModel {
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

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  /// Vérifier si l'utilisateur est un membre
  bool get isMember => role == 'ROLE_MEMBRE';

  /// Vérifier si l'utilisateur est un administrateur
  bool get isAdmin => role == 'ROLE_ADMIN';

  /// Obtenir le nom complet
  String get fullName => '$prenom $nom';
}

/// Modèle pour la requête de connexion (pour plus tard)
@JsonSerializable()
class LoginRequest extends BaseModel {
  final String email;
  final String motDePasse;

  LoginRequest({
    required this.email,
    required this.motDePasse,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
