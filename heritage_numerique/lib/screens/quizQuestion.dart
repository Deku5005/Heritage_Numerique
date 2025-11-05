import 'package:flutter/material.dart';

// Constantes de couleurs basées sur le design
const Color _mainGreen = Color(0xFF008236);
const Color _buttonGreen = Color(0xFF158B4D);
const Color _buttonBrown = Color(0xFF714D1D);
// Le beige neutre pour les boutons radio non sélectionnés
const Color _radioNeutralColor = Color(0xFFF0E5D7);

// Représente une réponse possible
class QuizAnswer {
  final String text;
  final bool isSelected;

  QuizAnswer(this.text, {this.isSelected = false});
}

// Représente l'état d'une question
class QuizQuestion {
  final String questionText;
  final List<QuizAnswer> answers;
  final int totalQuestions;
  final int currentQuestionNumber;
  final String quizTitle; // Ajouté pour le titre "Conte"

  QuizQuestion({
    required this.questionText,
    required this.answers,
    required this.totalQuestions,
    required this.currentQuestionNumber,
    required this.quizTitle,
  });
}

// Données de démonstration
final QuizQuestion demoQuestion = QuizQuestion(
  quizTitle: "Conte",
  questionText: "La question qui doit être posée s’affiche ici ?",
  totalQuestions: 30,
  currentQuestionNumber: 1,
  answers: [
    QuizAnswer("Réponse1", isSelected: false),
    QuizAnswer("Réponse2", isSelected: true), // Celle-ci est sélectionnée dans l'image
    QuizAnswer("Réponse3", isSelected: false),
  ],
);

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  // Simule l'état sélectionné. -1 signifie aucune sélection.
  late int selectedAnswerIndex;

  @override
  void initState() {
    super.initState();
    selectedAnswerIndex = demoQuestion.answers.indexWhere((a) => a.isSelected);
  }

  void _handleAnswerTap(int index) {
    setState(() {
      selectedAnswerIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // --- 1. En-tête (AppBar) - CORRIGÉ pour Centrage et Taille ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // On laisse le leading gérer le bouton de retour
        automaticallyImplyLeading: false,

        // Flèche de retour à gauche (Leading)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        // Titre CORRIGÉ (Centré et Alignement)
        title: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                demoQuestion.quizTitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 24, // Taille ajustée pour être plus grande
                  color: Colors.black,
                ),
              ),
              Text(
                '${demoQuestion.answers.length} Question', // Affichera '3 Question' pour la démo
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF99928F),
                ),
              ),
            ],
          ),
        ),

        // Ligne d'ombre sous l'AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),

      // --- 2. Corps (Question Card et Boutons) ---
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 80.0),
              child: Center(
                child: Column(
                  children: [
                    // --- Carte de Question Modale ---
                    _buildQuestionCard(context, demoQuestion),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          // --- 3. Boutons d'Action (Positionnés en bas) ---
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  // --- Widget pour la carte de la question ---
  Widget _buildQuestionCard(BuildContext context, QuizQuestion question) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Ligne 1 : Question X/XX et bouton Fermer (X)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${question.currentQuestionNumber}/${question.totalQuestions}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _mainGreen,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Action pour fermer/quitter
                },
                child: const Text(
                  'X',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF99928F),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Ligne 2 : Texte de la question
          Padding(
            padding: const EdgeInsets.only(right: 30.0), // Pour l'alignement
            child: Text(
              question.questionText,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Ligne 3 : Réponses (Utilise le nouveau widget)
          ...List.generate(question.answers.length, (index) {
            return _buildAnswerRow(
              context,
              question.answers[index].text,
              index,
              selectedAnswerIndex,
            );
          }),
        ],
      ),
    );
  }

  // --- NOUVEAU WIDGET pour une ligne de réponse (Radio OUTSIDE Card) ---
  Widget _buildAnswerRow(BuildContext context, String text, int index, int selectedIndex) {
    final bool isSelected = index == selectedIndex;
    final Color radioColor = isSelected ? _mainGreen : _radioNeutralColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => _handleAnswerTap(index),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Cercle de sélection (Radio Button Simulé - Gauche)
            Container(
              width: 25,
              height: 25,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: radioColor,
                border: Border.all(
                  color: isSelected ? _mainGreen : _radioNeutralColor,
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? const Center(child: Icon(Icons.circle, size: 10, color: Colors.white)) // Point central
                  : null,
            ),

            // 2. Carte de Réponse (Droite)
            Expanded(
              child: Container(
                height: 40,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 3,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget pour les boutons Retour et Suivant ---
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // Bouton Retour
          SizedBox(
            width: 140,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: () {
                // Action de retour
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
              label: const Text(
                'Retour',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonBrown,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),

          // Bouton Suivant
          SizedBox(
            width: 140,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: selectedAnswerIndex != -1 ? () {
                // Action Suivant
              } : null,
              icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              label: const Text(
                'Suivant',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}