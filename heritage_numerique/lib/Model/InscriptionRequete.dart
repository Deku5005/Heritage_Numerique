// register_request.dart

class InscriptionRequete {
  final String nom;
  final String prenom;
  final String email;
  final String numeroTelephone;
  final String ethnie;
  final String motDePasse;
  // Champ optionnel pour le code d'invitation.
  final String? codeInvitation;

  InscriptionRequete({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.numeroTelephone,
    required this.ethnie,
    required this.motDePasse,
    this.codeInvitation, // Champ optionnel
  });

  // Cette méthode transforme l'objet Dart en JSON (Map) pour l'API Spring Boot.
  Map<String, dynamic> toJson() {
    // 1. On commence par les champs obligatoires.
    final Map<String, dynamic> jsonMap = {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'numeroTelephone': numeroTelephone,
      'ethnie': ethnie,
      'motDePasse': motDePasse,
    };

    // 2. Si un code d'invitation est fourni (non null et non vide), on l'ajoute.
    // Sinon, on ne l'inclut pas, gérant ainsi l'inscription simple.
    if (codeInvitation != null && codeInvitation!.isNotEmpty) {
      jsonMap['codeInvitation'] = codeInvitation;
    }

    return jsonMap;
  }
}