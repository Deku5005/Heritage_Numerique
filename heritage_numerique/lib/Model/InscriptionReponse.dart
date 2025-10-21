//classe responsable de la reponse de l'inscription
class InscriptionReponse{
  final String accessToken;
  final String tokenType;
  final int userId;
  final String email;
  final String nom;
  final String prenom;
  final String role;
  // Le point d'interrogation (?) rend ce champ optionnel (nullable),
  // car il n'est présent que pour l'inscription avec invitation.
  final String? message;

  InscriptionReponse({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.role,
    this.message, // Champ optionnel dans le constructeur
  });

  //La methode  factory qui permet de transformer les jsons en objet Dart

  factory InscriptionReponse.fromJson(Map<String, dynamic> json){
    return InscriptionReponse(
      accessToken: json['accessToken'] as String,
      tokenType: json['tokenType'] as String,
      userId: json['userId'] as int,
      email: json['email'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      role: json['role'] as String,
      // On lit le champ 'message' s'il existe. Si non, il sera 'null'.
      message: json['message'] as String?,
    );
  }

}