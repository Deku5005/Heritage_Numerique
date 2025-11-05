import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/quiz.dart'; // Importation de QuizScreen

class QuizResultScreen extends StatelessWidget {
  // Vous pouvez passer le score réel ici
  final int score;
  final int totalQuestions;

  const QuizResultScreen({
    super.key,
    this.score = 29, // Valeur par défaut pour l'exemple
    this.totalQuestions = 30, // Valeur par défaut
  });

  @override
  Widget build(BuildContext context) {
    // La couleur des éléments marron comme dans le design
    const Color brownColor = Color(0xFF714D1D);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center( // Centre tout le contenu de la page verticalement et horizontalement
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centre les éléments de la colonne
          children: <Widget>[
            // --- 1. Cercle de Score ---
            Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brownColor,
                border: Border.all(
                  color: Colors.black, // Bordure noire comme sur le design
                  width: 7, // Épaisseur de la bordure
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Votre Score',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$score/$totalQuestions', // Affiche le score (ex: 29/30)
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700, // Plus gras pour le score
                        fontSize: 20, // Plus grand pour le score
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40), // Espace entre le cercle et le texte

            // --- 2. Texte "Félicitation" ---
            const Text(
              'Félicitation',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10), // Espace entre les deux textes

            // --- 3. Message d'encouragement ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0), // Pour centrer et limiter la largeur
              child: Text(
                'Rélevez plus de défi développez vos connaissances',
                textAlign: TextAlign.center, // Centre le texte
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 50), // Espace avant le bouton

            // --- 4. Bouton "Retour" ---
            SizedBox(
              width: 234, // Largeur du bouton
              height: 48, // Hauteur du bouton
              child: ElevatedButton(
                onPressed: () {
                  // Navigue vers QuizScreen et remplace l'écran actuel
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brownColor, // Couleur de fond du bouton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3), // Bordure arrondie
                  ),
                  elevation: 0, // Pas d'ombre
                ),
                child: const Text(
                  'Retour',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16, // Taille de police du bouton
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}