// lib/models/membre.dart

class Membre {
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
  final String? nomPere;
  final String? nomMere;

  Membre({
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
    this.nomPere, // NOUVEAU
    this.nomMere,
  });

  factory Membre.fromJson(Map<String, dynamic> json) {
    return Membre(
      id: json['id'] as int,
      nomComplet: json['nomComplet'] as String,
      dateNaissance: json['dateNaissance'] as String,
      lieuNaissance: json['lieuNaissance'] as String,
      // Les champs optionnels ou qui peuvent être nuls
      biographie: json['biographie'] as String?,
      photoUrl: json['photoUrl'] as String?,
      telephone: json['telephone'] as String?,
      relationFamiliale: json['relationFamiliale'] as String,
      email: json['email'] as String?,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      dateCreation: json['dateCreation'] as String,
      nomPere: json['nomPere'] as String?, // Mappage
      nomMere: json['nomMere'] as String?,
    );
  }
}