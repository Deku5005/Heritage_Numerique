import 'package:flutter/material.dart';
import '../service/QuizService.dart';
import '../model/QuizModel.dart'; // Importez le fichier contenant QuizDetail
// 💡 AJOUT : Importez votre écran de résultats
import 'package:heritage_numerique/screens/quizResultat.dart';

// Constantes de couleurs basées sur le design
const Color _mainGreen = Color(0xFF008236);
const Color _buttonGreen = Color(0xFF158B4D);
const Color _buttonBrown = Color(0xFF714D1D);
const Color _radioNeutralColor = Color(0xFFF0E5D7);


class QuestionScreen extends StatefulWidget {
  // 💡 NOUVEAU : quizId est requis
  final int quizId;

  // 🎯 CORRECTION : familyId est requis pour le retour vers la bonne famille
  final int familyId;

  const QuestionScreen({
    super.key,
    required this.quizId,
    required this.familyId, // AJOUTÉ
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final QuizService _quizService = QuizService();

  QuizDetail? _quizDetail;
  bool _isLoading = true;
  String? _errorMessage;

  // 💡 NOUVEAU: Chronomètre pour suivre le temps écoulé
  final Stopwatch _stopwatch = Stopwatch();

  // État local pour le suivi de la progression et des réponses
  int _currentQuestionIndex = 0;
  // Map pour stocker la sélection de l'utilisateur: {questionId: propositionId ou bool pour Vrai/Faux}
  final Map<int, dynamic> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _fetchQuizDetails();
    // 💡 Démarre le chronomètre dès que l'écran est initialisé
    _stopwatch.start();
  }

  @override
  void dispose() {
    // 💡 Arrête le chronomètre lorsque l'utilisateur quitte l'écran
    if(_stopwatch.isRunning) {
      _stopwatch.stop();
    }
    super.dispose();
  }

  // --- LOGIQUE API : Récupérer les détails ---
  Future<void> _fetchQuizDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await _quizService.fetchQuizDetails(quizId: widget.quizId);
      setState(() {
        _quizDetail = details;
        _isLoading = false;
        // Initialiser les réponses si nécessaire
      });
    } catch (e) {
      print("Erreur lors de la récupération des détails du quiz: $e");
      setState(() {
        _errorMessage = "Erreur de chargement. Quiz ID: ${widget.quizId}";
        _isLoading = false;
      });
    }
  }

  // --- LOGIQUE INTERNE : Gestion des clics de réponse ---
  void _handleAnswerTap(int questionId, dynamic answerValue) {
    setState(() {
      // Pour les QCM, answerValue est l'ID de la proposition.
      // Pour Vrai/Faux, answerValue est 'true' ou 'false'.
      _userAnswers[questionId] = answerValue;
    });
  }

  // --- LOGIQUE INTERNE : Navigation ---
  void _goToNextQuestion() {
    if (_quizDetail == null) return;

    // Assurez-vous qu'une réponse est sélectionnée avant de continuer
    final currentQuestionId = _quizDetail!.questions[_currentQuestionIndex].id;
    if (!_userAnswers.containsKey(currentQuestionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une réponse avant de continuer.")),
      );
      return;
    }

    if (_currentQuestionIndex < (_quizDetail!.questions.length - 1)) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Si c'est la dernière question, soumettre le quiz
      _submitQuiz();
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  // 💡 CORRECTION: Implémentation de la soumission du quiz et de la navigation
  Future<void> _submitQuiz() async {
    if (_quizDetail == null) return;

    // Arrêter le chronomètre avant la soumission
    _stopwatch.stop();
    // Calculer le temps écoulé en secondes
    final int tempsEcouleSeconds = _stopwatch.elapsed.inSeconds;

    // S'assurer qu'il y a une réponse pour la dernière question
    final lastQuestionId = _quizDetail!.questions.last.id;
    if (!_userAnswers.containsKey(lastQuestionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner une réponse pour la dernière question.")),
      );
      // IMPORTANT: Redémarrer le chronomètre si la soumission échoue ici
      _stopwatch.start();
      return;
    }

    // Afficher l'indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator(color: _buttonGreen));
      },
    );

    try {
      // 1. Préparer les données pour l'API
      final submissionRequest = QuizSubmissionRequest.fromUserAnswers(
        widget.quizId,
        _userAnswers,
        tempsEcouleSeconds, // 💡 NOUVEAU PARAMÈTRE REQUIS
      );

      // 2. Appeler le service API
      final QuizResultResponse result = await _quizService.submitQuiz(submissionRequest);

      // 3. Fermer le dialogue de chargement
      Navigator.pop(context);

      // 4. Naviguer vers l'écran de résultats en passant l'ID pour le retour
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            score: result.score,
            totalQuestions: result.totalQuestions,
            quizId: widget.quizId,
            familyId: widget.familyId, // 🌟 CORRECTION: familyId est maintenant passé
          ),
        ),
      );

    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      Navigator.pop(context);

      // IMPORTANT: Redémarrer le chronomètre si l'API a échoué pour ne pas perdre le temps
      _stopwatch.start();

      print("Erreur lors de la soumission du quiz: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec de la soumission: ${e.toString()}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // --- Gestion de l'état de chargement et d'erreur ---
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _mainGreen)),
      );
    }
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Erreur")),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    // Si _quizDetail est null ici, c'est une erreur logique
    final currentQuiz = _quizDetail!;

    // 🚨 CORRECTION CRITIQUE: Vérifier si la liste de questions est vide
    if (currentQuiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(currentQuiz.titre)),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 60),
                SizedBox(height: 20),
                Text(
                  "Ce quiz ne contient aucune question. Veuillez le vérifier auprès de l'administrateur.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Ligne 207 (environ) est maintenant sécurisée
    final currentQuestion = currentQuiz.questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == (currentQuiz.questions.length - 1);

    // hasAnswerSelected vérifie si une réponse a été donnée pour la question actuelle
    final hasAnswerSelected = _userAnswers.containsKey(currentQuestion.id);

    return Scaffold(
      backgroundColor: Colors.white,

      // --- 1. En-tête (AppBar) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentQuiz.titre, // Titre dynamique
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              Text(
                '${currentQuiz.nombreQuestions} Questions',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Color(0xFF99928F),
                ),
              ),
            ],
          ),
        ),
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
                    _buildQuestionCard(context, currentQuiz, currentQuestion),
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
            child: _buildActionButtons(hasAnswerSelected, isLastQuestion),
          ),
        ],
      ),
    );
  }

  // --- Widget pour la carte de la question (Dynamisé) ---
  Widget _buildQuestionCard(
      BuildContext context, QuizDetail quiz, QuizQuestionDetail question) {

    final int questionNumber = _currentQuestionIndex + 1;
    final int totalQuestions = quiz.nombreQuestions;

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
                'Question $questionNumber/$totalQuestions',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _mainGreen,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context), // Retour à l'écran précédent
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
            padding: const EdgeInsets.only(right: 30.0),
            child: Text(
              question.question, // Texte de question dynamique
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Ligne 3 : Réponses (Dynamique selon QCM ou VRAI_FAUX)
          if (question.typeReponse == 'QCM')
            ...List.generate(question.propositions.length, (index) {
              final proposition = question.propositions[index];
              return _buildAnswerRow(
                context,
                proposition.texte,
                proposition.id, // ID de la proposition pour l'état
                _userAnswers[question.id], // ID de la proposition sélectionnée par l'utilisateur
                question.id,
              );
            }),

          if (question.typeReponse == 'VRAI_FAUX')
            Column(
              children: [
                _buildAnswerRow(
                  context,
                  'Vrai',
                  true, // Valeur 'true' pour l'état
                  _userAnswers[question.id], // Valeur sélectionnée par l'utilisateur
                  question.id,
                ),
                _buildAnswerRow(
                  context,
                  'Faux',
                  false, // Valeur 'false' pour l'état
                  _userAnswers[question.id],
                  question.id,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // --- WIDGET pour une ligne de réponse (Dynamisé pour QCM/VRAI_FAUX) ---
  Widget _buildAnswerRow(
      BuildContext context, String text, dynamic answerValue, dynamic selectedAnswerValue, int questionId) {

    final bool isSelected = answerValue == selectedAnswerValue;
    final Color radioColor = isSelected ? _mainGreen : _radioNeutralColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () => _handleAnswerTap(questionId, answerValue),
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
                  ? const Center(child: Icon(Icons.circle, size: 10, color: Colors.white))
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

  // --- Widget pour les boutons Retour et Suivant (Dynamisé) ---
  Widget _buildActionButtons(bool hasAnswerSelected, bool isLastQuestion) {
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
              onPressed: _currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
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

          // Bouton Suivant / Terminer
          SizedBox(
            width: 140,
            height: 45,
            child: ElevatedButton.icon(
              // On n'active le bouton que si une réponse est sélectionnée
              onPressed: hasAnswerSelected ? _goToNextQuestion : null,
              icon: Icon(
                  isLastQuestion ? Icons.check : Icons.arrow_forward,
                  color: Colors.white,
                  size: 16
              ),
              label: Text(
                isLastQuestion ? 'Terminer' : 'Suivant',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonGreen,
                // Si le bouton est désactivé (pas de réponse), la couleur devient grise
                foregroundColor: hasAnswerSelected ? _buttonGreen : Colors.grey,
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