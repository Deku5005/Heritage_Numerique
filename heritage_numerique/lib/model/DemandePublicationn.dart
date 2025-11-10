// Fichier: lib/model/DemandePublicationModel.dart

class DemandePublicationn {
  final int id;
  final int idContenu;
  final String titreContenu;
  // NOUVEAUX CHAMPS
  final int idDemandeur;
  final String nomDemandeur;
  // FIN NOUVEAUX CHAMPS
  final String statut;
  final DateTime dateDemande;

  DemandePublicationn({
    required this.id,
    required this.idContenu,
    required this.titreContenu,
    required this.idDemandeur, // Ajouté
    required this.nomDemandeur, // Ajouté
    required this.statut,
    required this.dateDemande,
  });

  factory DemandePublicationn.fromJson(Map<String, dynamic> json) {
    return DemandePublicationn(
      id: json['id'],
      idContenu: json['idContenu'],
      titreContenu: json['titreContenu'],
      // Mappage des nouveaux champs
      idDemandeur: json['idDemandeur'],
      nomDemandeur: json['nomDemandeur'],
      // Fin Mappage
      statut: json['statut'],
      dateDemande: DateTime.parse(json['dateDemande']),
    );
  }
}