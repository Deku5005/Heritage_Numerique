import 'package:flutter/material.dart';
// ⚠️ Assurez-vous que le chemin d'importation vers QuizScreen est correct
import 'package:heritage_numerique/screens/quiz.dart';

class QuizResultScreen extends StatelessWidget {
  // Ces champs sont dynamiques et injectés par l'écran précédent
  final int score;
  final int totalQuestions;

  //  PARAMÈTRES POUR LE RETOUR ET L'HISTORIQUE
  final int familyId;
  final int quizId;

  const QuizResultScreen({
    super.key,
    required this.score, // Le score réel
    required this.totalQuestions, // Le total réel
    required this.familyId, // L'ID de la famille pour le retour
    required this.quizId, // L'ID du quiz pour l'historique
  });

  @override
  Widget build(BuildContext context) {
    // La couleur des éléments marron comme dans le design
    const Color brownColor = Color(0xFF714D1D);

    // Déterminer le message de félicitations basé sur le score
    final String felicitationMessage;
    final String encouragementMessage;

    if (score == totalQuestions) {
      felicitationMessage = 'Félicitation ! Parfait !';
      encouragementMessage = 'Un score maximal ! Vous maîtrisez parfaitement ce sujet. Passez au défi suivant !';
    } else if (score >= totalQuestions * 0.75) {
      felicitationMessage = 'Excellent Travail !';
      encouragementMessage = 'Votre connaissance est solide. Réussir à ce niveau est impressionnant, continuez ainsi !';
    } else {
      felicitationMessage = 'Bonne Performance';
      encouragementMessage = 'Rélevez plus de défis pour développer vos connaissances. Vous pouvez toujours vous améliorer !';
    }


    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // --- 1. Cercle de Score ---
            Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: brownColor,
                border: Border.all(
                  color: Colors.black,
                  width: 7,
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
                      // Affichage dynamique du score
                      '$score/$totalQuestions',
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- 2. Texte "Félicitation" (Dynamique) ---
            Text(
              felicitationMessage,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            // --- 3. Message d'encouragement (Dynamique) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                encouragementMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // --- 4. Bouton "Retour" ---
            SizedBox(
              width: 234,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // CORRECTION NAVIGATION: Retourne à l'écran QuizScreen avec le familyId correct.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => QuizScreen(familyId: familyId)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: brownColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Retour',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
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