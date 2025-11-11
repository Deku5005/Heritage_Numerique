// lib/models/proposition.dart (CORRIGÉ ET ROBUSTE)

class Proposition {
  final int id;
  final String texteProposition;
  final bool estCorrecte;
  final int ordre;

  Proposition({
    required this.id,
    required this.texteProposition,
    required this.estCorrecte,
    required this.ordre,
  });

  factory Proposition.fromJson(Map<String, dynamic> json) {
    return Proposition(
      // Utilisation de ?? pour gérer les valeurs nulles
      id: json['id'] as int? ?? 0,
      texteProposition: json['texteProposition'] as String? ?? 'Proposition vide',
      estCorrecte: json['estCorrecte'] as bool? ?? false,
      ordre: json['ordre'] as int? ?? 0,
    );
  }
}