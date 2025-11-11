// lib/models/soumission_reponse.dart

import 'detail_reponse.dart';

class SoumissionReponse {
  final int idQuiz;
  final List<DetailReponse> reponses;
  final int tempsEcoule;

  SoumissionReponse({
    required this.idQuiz,
    required this.reponses,
    required this.tempsEcoule,
  });

  // Méthode pour convertir l'objet Dart en JSON (Map) pour la requête POST
  Map<String, dynamic> toJson() {
    return {
      "idQuiz": idQuiz,
      // Convertit chaque objet DetailReponse en Map JSON
      "reponses": reponses.map((r) => r.toJson()).toList(),
      "tempsEcoule": tempsEcoule,
    };
  }
}