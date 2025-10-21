// lib/Model/LoginRequete.dart (Créez ce nouveau fichier)

class LoginRequete {
  final String email;
  final String motDePasse;

  LoginRequete({
    required this.email,
    required this.motDePasse,
  });

  // Convertit l'objet Dart en Map JSON pour l'envoi HTTP
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'motDePasse': motDePasse,
    };
  }
}