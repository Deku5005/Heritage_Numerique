// lib/screens/quiz_screen.dart

import 'package:flutter/material.dart';
import '../model/quiz.dart';
import '../model/question.dart';
import '../model/proposition.dart';

// *** IMPORTS POUR LA SOUMISSION ***
// Note: Assurez-vous que les chemins (par exemple '../model/...') sont corrects dans votre projet.
import '../model/soumission_reponse.dart';
import '../model/detail_reponse.dart';
import '../service/quiz_service1.dart';

// La classe QuizScreen est maintenant un StatefulWidget
class QuizScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizScreen({super.key, required this.quiz});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // COULEURS
  static const Color _accentColor = Color(0xFFD69301);
  static const Color _cardTextColor = Color(0xFF2E2E2E);
  static const Color _successColor = Colors.green;
  static const Color _infoColor = Color(0xFF9F9646);

  // SERVICE
  final QuizService1 _quizService = QuizService1();

  // ÉTAT DU QUIZ
  // Map pour stocker les sélections de l'utilisateur:
  // Clé: idQuestion (int)
  // Valeur: Liste d'idProposition sélectionné (List<int>)
  final Map<int, List<int>> _selectedResponses = {};

  bool _isSubmitting = false; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    // Initialise l'état des réponses pour chaque question
    for (var question in widget.quiz.questions) {
      _selectedResponses[question.id] = [];
    }
  }

  // --- LOGIQUE DE GESTION DE LA SÉLECTION ---

  void _handlePropositionSelection(Question question, Proposition proposition) {
    setState(() {
      final questionId = question.id;
      final propositionId = proposition.id;

      // Détermine si c'est un choix multiple ou unique
      final bool isMultipleChoice = question.propositions.where((p) => p.estCorrecte).length > 1;

      if (isMultipleChoice) {
        // Logique pour le choix multiple (Checkbox)
        if (_selectedResponses[questionId]!.contains(propositionId)) {
          _selectedResponses[questionId]!.remove(propositionId);
        } else {
          _selectedResponses[questionId]!.add(propositionId);
        }
      } else {
        // Logique pour le choix unique (Radio Button)
        if (_selectedResponses[questionId]!.contains(propositionId)) {
          // Désélectionner
          _selectedResponses[questionId] = [];
        } else {
          // Sélectionner cette proposition uniquement
          _selectedResponses[questionId] = [propositionId];
        }
      }
    });
  }

  // --- LOGIQUE DE SOUMISSION DU QUIZ ---

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. Construire l'objet SoumissionReponse
      List<DetailReponse> detailsReponses = [];

      for (var question in widget.quiz.questions) {
        final selectedIds = _selectedResponses[question.id] ?? [];

        // Pour chaque proposition sélectionnée, créer un DetailReponse
        for (var propId in selectedIds) {
          detailsReponses.add(DetailReponse(
            idQuestion: question.id,
            idProposition: propId,
            reponseVraiFaux: true,
          ));
        }
      }

      final soumission = SoumissionReponse(
        idQuiz: widget.quiz.id,
        reponses: detailsReponses,
        // Temps écoulé
        tempsEcoule: 0,
      );

      // 2. Appeler le service
      // CORRECTION : Supprime l'attente d'une variable 'result' car le service retourne Future<void>
      await _quizService.soumettreReponsesQuiz(soumission);

      // 3. Afficher le résultat de succès et naviguer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soumission du quiz réussie! 🎉'), // Message simplifié
          backgroundColor: _successColor,
        ),
      );
      Navigator.pop(context); // Retour à l'écran précédent

    } catch (e) {
      // 4. Gérer l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de soumission: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.quiz.titre,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _successColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: widget.quiz.questions.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Ce quiz n'a pas de questions. Veuillez contacter l'administrateur.",
            textAlign: TextAlign.center,
          ),
        ),
      )
          : ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildQuizHeader(widget.quiz),
          const SizedBox(height: 25),
          // Affichage de toutes les questions
          ...widget.quiz.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestionCard(
              question: question,
              index: index,
            );
          }),
          const SizedBox(height: 50),
          Center(
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitQuiz, // Désactive pendant la soumission
              icon: _isSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.send, size: 20),
              label: Text(_isSubmitting ? 'Envoi...' : 'Soumettre le Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION DES SECTIONS ---

  Widget _buildQuizHeader(Quiz quiz) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          quiz.description,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _cardTextColor.withOpacity(0.8),
          ),
        ),
        const Divider(height: 15),
        _buildInfoRow(Icons.star, 'Difficulté', quiz.difficulte),
        _buildInfoRow(Icons.timer, 'Temps limite', '${quiz.tempsLimite} minutes'),
        _buildInfoRow(Icons.format_list_numbered, 'Total Questions', '${quiz.nombreQuestions}'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: _infoColor, size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildQuestionCard({
    required Question question,
    required int index,
  }) {
    // Détermine si c'est un choix multiple ou unique basé sur la logique de l'API
    final bool isMultipleChoice = question.propositions.where((p) => p.estCorrecte).length > 1;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre/Texte de la question
            Text(
              'Question ${index + 1} (${question.points} points)',
              style: TextStyle(
                color: _accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              question.texteQuestion,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: _cardTextColor,
              ),
            ),
            const Divider(height: 25),

            // Liste des propositions
            ...question.propositions.asMap().entries.map((entry) {
              final proposition = entry.value;
              final bool isSelected = _selectedResponses[question.id]?.contains(proposition.id) ?? false;

              return _buildPropositionTile(
                question: question,
                proposition: proposition,
                isSelected: isSelected,
                isMultipleChoice: isMultipleChoice,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPropositionTile({
    required Question question,
    required Proposition proposition,
    required bool isSelected,
    required bool isMultipleChoice,
  }) {
    final IconData iconSelected = isMultipleChoice ? Icons.check_box : Icons.radio_button_on;
    final IconData iconUnselected = isMultipleChoice ? Icons.check_box_outline_blank : Icons.radio_button_off;

    return InkWell(
      onTap: () => _handlePropositionSelection(question, proposition),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              isSelected ? iconSelected : iconUnselected,
              color: isSelected ? _successColor : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                proposition.texteProposition,
                style: const TextStyle(fontSize: 15, color: _cardTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}