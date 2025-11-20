class Membre {
  // --- Champs Minimaux Requis pour la Structure ---
  final int id;
  final List<Membre> enfants; // Reste List<Membre>, mais la liste peut être vide

  // --- Champs Optionnels (String, int) ---
  final String? nomComplet;
  final String? dateNaissance;
  final String? lieuNaissance;
  final String? biographie;
  final String? photoUrl;
  final String? telephone;
  final String? relationFamiliale; // Rendu optionnel
  final String? email;
  final int? idFamille; // Rendu optionnel
  final String? nomFamille; // Rendu optionnel
  final String? dateCreation; // Rendu optionnel
  final int? nombreEnfants; // Rendu optionnel

  // 🔑 Liens Montants
  final int? idPere;
  final int? idMere;

  // 🔑 Champs de positionnement
  final int? niveau;
  final int? positionX;
  final int? positionY;

  // 🔑 Champs pour la compatibilité
  final String? nomPereAPI;
  final String? nomMereAPI;


  Membre({
    required this.id,
    required this.enfants, // La liste elle-même doit exister (même vide)

    this.nomComplet,
    this.dateNaissance,
    this.lieuNaissance,
    this.biographie,
    this.photoUrl,
    this.telephone,
    this.relationFamiliale,
    this.email,
    this.idFamille,
    this.nomFamille,
    this.dateCreation,
    this.nombreEnfants,

    this.idPere,
    this.idMere,
    this.niveau,
    this.positionX,
    this.positionY,
    this.nomPereAPI,
    this.nomMereAPI,
  });

  factory Membre.fromJson(Map<String, dynamic> json) {
    // 🔑 FONCTION CRITIQUE : Convertit de manière sécurisée les valeurs doubles ou int en int?
    int? safeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.round(); // Convertit le double en int (arrondi)
      return null;
    }

    // Gestion récursive de la liste 'enfants'
    final List<Membre> enfantsList = (json['enfants'] as List?)
        ?.map((item) => Membre.fromJson(item as Map<String, dynamic>))
        .toList()
        ?? <Membre>[];

    return Membre(
      // id est obligatoire
      id: safeInt(json['id'])!, // Utilisation de safeInt!

      // Champs String (inchangés)
      nomComplet: json['nomComplet'] as String?,
      dateNaissance: json['dateNaissance'] as String?,
      lieuNaissance: json['lieuNaissance'] as String?,
      biographie: json['biographie'] as String?,
      photoUrl: json['photoUrl'] as String?,
      telephone: json['telephone'] as String?,
      relationFamiliale: json['relationFamiliale'] as String?,
      email: json['email'] as String?,

      // Mappage des champs int en utilisant safeInt
      idFamille: safeInt(json['idFamille']),
      dateCreation: json['dateCreation'] as String?,

      // Liens/Positionnement (Champs les plus susceptibles d'être doubles)
      idPere: safeInt(json['idPere']),
      idMere: safeInt(json['idMere']),
      niveau: safeInt(json['niveau']),
      positionX: safeInt(json['positionX']), // <-- Correction appliquée ici
      positionY: safeInt(json['positionY']), // <-- Correction appliquée ici

      nombreEnfants: safeInt(json['nombreEnfants']), // <-- Correction appliquée ici

      // Compatibilité
      nomFamille: json['nomFamille'] as String?,
      nomPereAPI: json['nomPere'] as String?,
      nomMereAPI: json['nomMere'] as String?,

      // Liste des enfants (résultat de la correction robuste)
      enfants: enfantsList,
    );
  }
}