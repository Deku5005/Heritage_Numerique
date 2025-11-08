// Fichier: lib/model/DemandePublicationModel.dart

class DemandePublication {
  final int id;
  final int idContenu;
  final String titreContenu;
  final String statut;
  final DateTime dateDemande;

  DemandePublication({
    required this.id,
    required this.idContenu,
    required this.titreContenu,
    required this.statut,
    required this.dateDemande,
  });

  factory DemandePublication.fromJson(Map<String, dynamic> json) {
    return DemandePublication(
      id: json['id'],
      idContenu: json['idContenu'],
      titreContenu: json['titreContenu'],
      statut: json['statut'],
      dateDemande: DateTime.parse(json['dateDemande']),
    );
  }
}