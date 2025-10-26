import 'package:flutter/material.dart';

// --- Constantes de Style (AJOUTÉES pour corriger l'erreur) ---
// Utilisation du noir comme couleur de texte principale, comme dans le design
const Color _primaryTextColor = Color(0xFF000000);
const Color _primaryColor = Color(0xFF714D1D); // Brun foncé/Or
const Color _secondaryColor = Color(0xFF158B4D); // Vert (pour le bouton "Ajouter une réponse")
const Color _neutralLight = Color(0xFFEEE3CF); // Beige clair (pour les cercles)
const Color _correctAnswerColor = Color(0x7AE5E5E5); // Gris clair avec opacité (pour les cercles d'option correcte)
const Color _iconColor = Color(0xFFB30000); // Rouge foncé pour la corbeille

// --- Énumération pour le type de Quiz ---
enum QuizType { qcm, trueFalse }

// --- Structure de Données pour une Question ---
class QuestionData {
  String questionText = '';
  QuizType type = QuizType.qcm; // Type par défaut
  List<String> answers = ['Reponse 1', 'Reponse 2', 'Reponse 3', 'Reponse 4']; // Options de réponse
  int correctAnswerIndex = 0; // Index de la bonne réponse
  int questionNumber = 1;

  QuestionData(this.questionNumber);
}

// ====================================================================
// WIDGET PRINCIPAL : Gère l'état de la liste des questions
// ====================================================================

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  // Liste qui contient toutes les données de la question
  List<QuestionData> questions = [QuestionData(1)];

  // Index de la question actuellement sélectionnée ou modifiée
  int activeQuestionIndex = 0;

  // Contenu simulé pour le Dropdown (Contes)
  final List<String> availableContes = [
    'Le lion roi des animaux',
    'L\'histoire du lion et du chasseur',
    'Le Baobab magique'
  ];
  String? selectedConte;

  // --- Logique d'état ---

  // 1. Ajouter une nouvelle question
  void _addQuestion() {
    setState(() {
      final newQuestionNumber = questions.length + 1;
      questions.add(QuestionData(newQuestionNumber));
      activeQuestionIndex = questions.length - 1; // Sélectionner la nouvelle question
    });
  }

  // 2. Ajouter une nouvelle option de réponse à la question active
  void _addAnswerOption() {
    setState(() {
      final activeQuestion = questions[activeQuestionIndex];
      // Pour les questions Vrai/Faux, on ne peut pas ajouter d'options
      if (activeQuestion.type == QuizType.trueFalse) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ajouter des options à un Vrai/Faux.')),
        );
      } else {
        activeQuestion.answers.add('Nouvelle réponse ${activeQuestion.answers.length + 1}');
      }
    });
  }

  // 3. Supprimer une option de réponse
  void _removeAnswerOption(int answerIndex) {
    setState(() {
      final activeQuestion = questions[activeQuestionIndex];
      if (activeQuestion.answers.length > 2 && activeQuestion.type == QuizType.qcm) {
        activeQuestion.answers.removeAt(answerIndex);
        // Ajuster l'index de la bonne réponse si elle est supprimée
        if (activeQuestion.correctAnswerIndex == answerIndex) {
          activeQuestion.correctAnswerIndex = 0;
        } else if (activeQuestion.correctAnswerIndex > answerIndex) {
          activeQuestion.correctAnswerIndex--;
        }
      } else {
        // Optionnel : Afficher un message d'erreur si moins de 2 réponses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Un quiz QCM doit avoir au moins deux options de réponse.')),
        );
      }
    });
  }

  // 4. Modifier le type de quiz pour la question active
  void _changeQuizType(QuizType? newType) {
    if (newType != null) {
      setState(() {
        questions[activeQuestionIndex].type = newType;
        // Si on passe en Vrai/Faux, on fixe les options et la bonne réponse
        if (newType == QuizType.trueFalse) {
          questions[activeQuestionIndex].answers = ['Vrai', 'Faux'];
          questions[activeQuestionIndex].correctAnswerIndex = 0; // Vrai par défaut
        }
      });
    }
  }

  // 5. Modifier la bonne réponse pour la question active
  void _setCorrectAnswer(int index) {
    setState(() {
      questions[activeQuestionIndex].correctAnswerIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryTextColor, size: 24),
          onPressed: () {
            // Logique de navigation retour
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Ajouter un nouveau quiz',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: _primaryTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- 1. SÉLECTION DU CONTE (Dropdown) ---
            const Text('Contes',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _primaryTextColor,
                )
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 4,
                      offset: Offset(0, 0)
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedConte,
                  isExpanded: true,
                  hint: const Text('Sélectionner un conte'),
                  icon: const Icon(Icons.keyboard_arrow_down, color: _primaryTextColor),
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: _primaryTextColor
                  ),
                  items: availableContes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedConte = newValue;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. LISTE DES QUESTIONS (QuestionForm) ---
            ...questions.asMap().entries.map((entry) {
              int index = entry.key;
              QuestionData qData = entry.value;
              return Column(
                key: ValueKey(qData.questionNumber), // Clé unique pour le widget
                children: [
                  QuestionForm(
                    question: qData,
                    onQuizTypeChanged: _changeQuizType,
                    onCorrectAnswerSelected: _setCorrectAnswer,
                    onRemoveAnswer: _removeAnswerOption,
                    // Indique à quelle question les boutons d'ajout/suppression s'appliquent
                    isActive: index == activeQuestionIndex,
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),

            // --- 3. BOUTONS D'ACTION (Ajouter Question / Ajouter Réponse / Valider) ---

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton "Ajouter une question"
                _buildActionButton(
                  text: 'Ajouter une question',
                  color: _primaryColor,
                  onPressed: _addQuestion,
                ),

                // Bouton "Ajouter une réponse"
                _buildActionButton(
                  text: 'Ajouter une réponse',
                  color: _secondaryColor,
                  onPressed: _addAnswerOption,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Bouton "Valider"
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Logique de validation et d'enregistrement du quiz
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quiz en cours de validation...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  elevation: 5,
                ),
                child: const Text(
                  'Valider',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Fonction utilitaire pour les boutons d'action
  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        elevation: 3,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ====================================================================
// WIDGET QUESTION FORM : Représente un bloc de question (Question N + ses réponses)
// ====================================================================

class QuestionForm extends StatelessWidget {
  final QuestionData question;
  final Function(QuizType?) onQuizTypeChanged;
  final Function(int) onCorrectAnswerSelected;
  final Function(int) onRemoveAnswer;
  final bool isActive;

  const QuestionForm({
    super.key,
    required this.question,
    required this.onQuizTypeChanged,
    required this.onCorrectAnswerSelected,
    required this.onRemoveAnswer,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Titre de la Question ---
        Text(
          'Questions ${question.questionNumber}',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: _primaryTextColor,
          ),
        ),
        const SizedBox(height: 8),

        // --- Champ de Saisie de la Question ---
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  offset: Offset(0, 0)
              ),
            ],
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Ex: L\'histoire du lion et du chasseur?',
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 20),

        // --- Sélecteur de Type (QCM / Vrai/Faux) ---
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // QCM
            _buildQuizTypeSelector(
              label: 'QCM',
              type: QuizType.qcm,
              currentType: question.type,
              onChanged: onQuizTypeChanged,
            ),
            const SizedBox(width: 30),
            // Vrai/Faux
            _buildQuizTypeSelector(
              label: 'Vrai/Faux',
              type: QuizType.trueFalse,
              currentType: question.type,
              onChanged: onQuizTypeChanged,
            ),
          ],
        ),
        const SizedBox(height: 25),

        // --- Liste des Options de Réponse ---
        ...question.answers.asMap().entries.map((entry) {
          int index = entry.key;
          String answerText = entry.value;

          // Vérifier si c'est la bonne réponse
          bool isCorrect = question.correctAnswerIndex == index;

          return _buildAnswerOption(
            answerText: answerText,
            isCorrect: isCorrect,
            onToggleCorrect: () => onCorrectAnswerSelected(index),
            onRemove: () => onRemoveAnswer(index),
            // On désactive la suppression pour Vrai/Faux
            canRemove: question.type == QuizType.qcm,
          );
        }).toList(),
      ],
    );
  }

  // Widget utilitaire pour le sélecteur QCM/VraiFaux
  Widget _buildQuizTypeSelector({
    required String label,
    required QuizType type,
    required QuizType currentType,
    required Function(QuizType?) onChanged,
  }) {
    final bool isSelected = currentType == type;

    return GestureDetector(
      onTap: () => onChanged(type),
      child: Row(
        children: [
          // Cercle extérieur (grand)
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? _neutralLight : Colors.transparent,
              border: isSelected ? null : Border.all(color: Colors.grey.shade400, width: 1),
            ),
            child: isSelected
                ? Center(
              // Cercle intérieur (petit - simulation de couleur)
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _secondaryColor.withOpacity(0.5),
                ),
              ),
            )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: _primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // Widget utilitaire pour une seule option de réponse
  Widget _buildAnswerOption({
    required String answerText,
    required bool isCorrect,
    required VoidCallback onToggleCorrect,
    required VoidCallback onRemove,
    required bool canRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          // Champ de Saisie de Réponse
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.0),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 4,
                      offset: Offset(0, 0)
                  ),
                ],
              ),
              child: TextField(
                controller: TextEditingController(text: answerText), // Pour démonstration
                decoration: const InputDecoration(
                  hintText: 'Entrer une réponse...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14),
                // Le texte doit être mis à jour dans l'état parent ici en temps réel
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Sélecteur de Bonne Réponse (Grand Cercle)
          GestureDetector(
            onTap: onToggleCorrect,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _neutralLight,
              ),
              child: isCorrect
                  ? Center(
                // Indication de Bonne Réponse (Petit Cercle)
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _secondaryColor.withOpacity(0.5),
                  ),
                ),
              )
                  : null,
            ),
          ),

          const SizedBox(width: 10),

          // Bouton de Suppression (Corbeille)
          GestureDetector(
            onTap: canRemove ? onRemove : null, // Ne fonctionne que si canRemove est vrai
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: canRemove ? Colors.transparent : Colors.grey.shade200, // Grisé si non supprimable
              ),
              child: Icon(
                Icons.delete_outline,
                color: canRemove ? _iconColor : Colors.grey.shade400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
