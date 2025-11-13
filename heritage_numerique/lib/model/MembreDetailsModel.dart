// Fichier : lib/model/MembreDetail.dart

class MembreDetail {
  final int id;
  final String nomComplet;
  final String dateNaissance;
  final String lieuNaissance;
  final String? biographie;
  final String? photoUrl;
  final String? telephone;
  final String relationFamiliale;
  final String? email;
  final int idFamille;
  final String nomFamille;
  final String dateCreation;
  // Note: nomPere et nomMere ne sont pas dans votre JSON de détail,
  // donc ils ne sont pas inclus ici, contrairement à Membre.dart précédent.

  MembreDetail({
    required this.id,
    required this.nomComplet,
    required this.dateNaissance,
    required this.lieuNaissance,
    this.biographie,
    this.photoUrl,
    this.telephone,
    required this.relationFamiliale,
    this.email,
    required this.idFamille,
    required this.nomFamille,
    required this.dateCreation,
  });

  factory MembreDetail.fromJson(Map<String, dynamic> json) {
    // 🔑 Assurer la robustesse en utilisant des valeurs par défaut pour les champs requis
    // et en utilisant le casting sécurisé pour les champs optionnels (String?)
    return MembreDetail(
      id: (json['id'] as int?) ?? 0,
      nomComplet: (json['nomComplet'] as String?) ?? '',
      dateNaissance: (json['dateNaissance'] as String?) ?? '',
      lieuNaissance: (json['lieuNaissance'] as String?) ?? '',

      // Champs optionnels
      biographie: json['biographie'] as String?,
      photoUrl: json['photoUrl'] as String?,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,

      // Champs requis
      relationFamiliale: (json['relationFamiliale'] as String?) ?? '',
      idFamille: (json['idFamille'] as int?) ?? 0,
      nomFamille: (json['nomFamille'] as String?) ?? '',
      dateCreation: (json['dateCreation'] as String?) ?? '',
    );
  }
}