// lib/models/detail_reponse.dart

class DetailReponse {
  final int idQuestion;
  final int idProposition;
  final bool reponseVraiFaux;

  DetailReponse({
    required this.idQuestion,
    required this.idProposition,
    required this.reponseVraiFaux,
  });

  // Méthode pour convertir l'objet Dart en JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      "idQuestion": idQuestion,
      "idProposition": idProposition,
      "reponseVraiFaux": reponseVraiFaux,
    };
  }
}