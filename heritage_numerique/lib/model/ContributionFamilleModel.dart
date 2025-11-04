// Réponse globale de l'endpoint des contributions
class ContributionsFamilleModel {
  final int idFamille;
  final String nomFamille;
  final String descriptionFamille;
  final String ethnieFamille;
  final String regionFamille;
  final int totalMembres;
  final int totalContributions;
  final int totalContes;
  final int totalProverbes;
  final int totalArtisanats;
  final int totalDevinettes;
  final List<ContributionMembreModel> contributionsMembres;

  ContributionsFamilleModel({
    required this.idFamille,
    required this.nomFamille,
    required this.descriptionFamille,
    required this.ethnieFamille,
    required this.regionFamille,
    required this.totalMembres,
    required this.totalContributions,
    required this.totalContes,
    required this.totalProverbes,
    required this.totalArtisanats,
    required this.totalDevinettes,
    required this.contributionsMembres,
  });

  factory ContributionsFamilleModel.fromJson(Map<String, dynamic> json) {
    var list = json['contributionsMembres'] as List;
    List<ContributionMembreModel> membresList = list
        .map((i) => ContributionMembreModel.fromJson(i))
        .toList();

    return ContributionsFamilleModel(
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      descriptionFamille: json['descriptionFamille'] as String,
      ethnieFamille: json['ethnieFamille'] as String,
      regionFamille: json['regionFamille'] as String,
      totalMembres: json['totalMembres'] as int,
      totalContributions: json['totalContributions'] as int,
      totalContes: json['totalContes'] as int,
      totalProverbes: json['totalProverbes'] as int,
      totalArtisanats: json['totalArtisanats'] as int,
      totalDevinettes: json['totalDevinettes'] as int,
      contributionsMembres: membresList,
    );
  }
}

// Modèle pour chaque membre
class ContributionMembreModel {
  final int idMembre;
  final int idUtilisateur;
  final String nom;
  final String prenom;
  final String email;
  final String roleFamille;
  final String lienParente;
  final int totalContributions;
  final int nombreContes;
  final int nombreProverbes;
  final int nombreArtisanats;
  final int nombreDevinettes;
  final String dateAjout;

  ContributionMembreModel({
    required this.idMembre,
    required this.idUtilisateur,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.roleFamille,
    required this.lienParente,
    required this.totalContributions,
    required this.nombreContes,
    required this.nombreProverbes,
    required this.nombreArtisanats,
    required this.nombreDevinettes,
    required this.dateAjout,
  });

  factory ContributionMembreModel.fromJson(Map<String, dynamic> json) {
    return ContributionMembreModel(
      idMembre: json['idMembre'] as int,
      idUtilisateur: json['idUtilisateur'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      roleFamille: json['roleFamille'] as String,
      lienParente: json['lienParente'] as String,
      totalContributions: json['totalContributions'] as int,
      nombreContes: json['nombreContes'] as int,
      nombreProverbes: json['nombreProverbes'] as int,
      nombreArtisanats: json['nombreArtisanats'] as int,
      nombreDevinettes: json['nombreDevinettes'] as int,
      dateAjout: json['dateAjout'] as String,
    );
  }
}