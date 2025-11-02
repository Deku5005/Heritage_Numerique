import 'dart:convert';

// --- Modèle Quiz ---

class Quiz {
  final int id;
  final int idFamille;
  final String nomFamille;
  final int idCreateur;
  final String nomCreateur;
  final String titre;
  final String description;
  final String difficulte;
  final int tempsLimite;
  final bool actif;
  final int nombreQuestions;
  final DateTime dateCreation;
  final String quizData; // Renommé pour éviter le conflit avec le nom de la classe

  Quiz({
    required this.id,
    required this.idFamille,
    required this.nomFamille,
    required this.idCreateur,
    required this.nomCreateur,
    required this.titre,
    required this.description,
    required this.difficulte,
    required this.tempsLimite,
    required this.actif,
    required this.nombreQuestions,
    required this.dateCreation,
    required this.quizData,
  });

  // Factory constructor to create a Quiz from a JSON map
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as int,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      idCreateur: json['idCreateur'] as int,
      nomCreateur: json['nomCreateur'] as String,
      titre: json['titre'] as String,
      description: json['description'] as String,
      difficulte: json['difficulte'] as String,
      tempsLimite: json['tempsLimite'] as int,
      actif: json['actif'] as bool,
      nombreQuestions: json['nombreQuestions'] as int,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      quizData: json['quiz'] as String,
    );
  }

  // Method to convert the Quiz object back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idFamille': idFamille,
      'nomFamille': nomFamille,
      'idCreateur': idCreateur,
      'nomCreateur': nomCreateur,
      'titre': titre,
      'description': description,
      'difficulte': difficulte,
      'tempsLimite': tempsLimite,
      'actif': actif,
      'nombreQuestions': nombreQuestions,
      'dateCreation': dateCreation.toIso8601String(),
      'quiz': quizData,
    };
  }
}

// ----------------------------------------------------
// --- Modèle Récit (CORRIGÉ pour gérer le Quiz null) ---
// ----------------------------------------------------

class Recit {
  final int id;
  final String titre;
  final String description;
  final String nomAuteur;
  final String prenomAuteur;
  final String emailAuteur;
  final String roleAuteur;
  final String lienParenteAuteur;
  final DateTime dateCreation;
  final String statut;
  final String urlFichier;
  final String urlPhoto;
  final String lieu;
  final String region;
  final int idFamille;
  final String nomFamille;
  final Quiz? quiz; // ✅ CORRECTION: Rendu nullable (Quiz?)

  Recit({
    required this.id,
    required this.titre,
    required this.description,
    required this.nomAuteur,
    required this.prenomAuteur,
    required this.emailAuteur,
    required this.roleAuteur,
    required this.lienParenteAuteur,
    required this.dateCreation,
    required this.statut,
    required this.urlFichier,
    required this.urlPhoto,
    required this.lieu,
    required this.region,
    required this.idFamille,
    required this.nomFamille,
    this.quiz, // Rendu optionnel
  });

  // Factory constructor to create a Recit from a JSON map
  factory Recit.fromJson(Map<String, dynamic> json) {
    // 1. Récupérer la valeur de 'quiz'
    final quizJson = json['quiz'];

    return Recit(
      id: json['id'] as int,
      titre: json['titre'] as String,
      description: json['description'] as String,
      nomAuteur: json['nomAuteur'] as String,
      prenomAuteur: json['prenomAuteur'] as String,
      emailAuteur: json['emailAuteur'] as String,
      roleAuteur: json['roleAuteur'] as String,
      lienParenteAuteur: json['lienParenteAuteur'] as String,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      statut: json['statut'] as String,
      urlFichier: json['urlFichier'] as String,
      urlPhoto: json['urlPhoto'] as String,
      lieu: json['lieu'] as String,
      region: json['region'] as String,
      idFamille: json['idFamille'] as int,
      nomFamille: json['nomFamille'] as String,
      // 2. ✅ CORRECTION: Vérifier si quizJson n'est pas null avant de le parser
      quiz: quizJson != null
          ? Quiz.fromJson(quizJson as Map<String, dynamic>)
          : null, // Si null, retourne null
    );
  }

  // Method to convert the Recit object back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'nomAuteur': nomAuteur,
      'prenomAuteur': prenomAuteur,
      'emailAuteur': emailAuteur,
      'roleAuteur': roleAuteur,
      'lienParenteAuteur': lienParenteAuteur,
      'dateCreation': dateCreation.toIso8601String(),
      'statut': statut,
      'urlFichier': urlFichier,
      'urlPhoto': urlPhoto,
      'lieu': lieu,
      'region': region,
      'idFamille': idFamille,
      'nomFamille': nomFamille,
      'quiz': quiz?.toJson(), // Utilisation de l'opérateur '?.' pour gérer le null
    };
  }
}

// --- Fonction d'aide pour la désérialisation de la liste complète ---

/// Converts a raw JSON string (representing a list of recits) into a List<Recit>.
List<Recit> recitsFromJson(String str) {
  final List<dynamic> jsonList = json.decode(str);
  return jsonList.map((json) => Recit.fromJson(json as Map<String, dynamic>)).toList();
}

/// Converts a List<Recit> into a JSON string.
String recitsToJson(List<Recit> data) => json.encode(data.map((x) => x.toJson()).toList());