import 'package:flutter/material.dart';
import '../service/QuizService.dart';
import '../service/RecitService.dart';
import '../model/QuizModel.dart';
import '../model/Recits_model.dart'; // 🌟 Confirmé : Utilisation de votre nom de fichier Recits_model.dart


// --- Constantes de Style ---
const Color _primaryTextColor = Color(0xFF000000);
const Color _primaryColor = Color(0xFF714D1D); // Brun foncé/Or
const Color _secondaryColor = Color(0xFF158B4D); // Vert
const Color _neutralLight = Color(0xFFEEE3CF); // Beige clair
const Color _iconColor = Color(0xFFB30000); // Rouge foncé pour la corbeille

// --- Énumération pour le type de Quiz ---
enum QuizType { qcm, trueFalse }

// --- Structure de Données pour une Question (Avec Contrôleurs) ---
class QuestionData {
  final TextEditingController questionTextController;
  QuizType type;
  List<TextEditingController> answerControllers;
  int correctAnswerIndex;
  // Correction : Rendu non-final pour permettre la mise à jour
  int questionNumber;

  QuestionData(this.questionNumber)
      : questionTextController = TextEditingController(),
        type = QuizType.qcm,
        answerControllers = [
          TextEditingController(text: 'Option A'),
          TextEditingController(text: 'Option B'),
        ],
        correctAnswerIndex = 0;

  // Pour libérer les ressources
  void dispose() {
    questionTextController.dispose();
    for (var c in answerControllers) {
      c.dispose();
    }
  }
}

// ====================================================================
// WIDGET PRINCIPAL : Gère l'état de la liste des questions
// ====================================================================

class AddQuizScreen extends StatefulWidget {
  // familyId est requis pour la création et la récupération des récits
  final int familyId;

  const AddQuizScreen({super.key, required this.familyId});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final QuizService _quizService = QuizService();
  final RecitService _recitService = RecitService();

  // Contrôleurs du Quiz
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // État des Questions
  List<QuestionData> questions = [QuestionData(1)];
  int activeQuestionIndex = 0;

  // État du Dropdown (Récits dynamiques)
  List<Recit> _availableRecits = [];
  bool _isLoadingRecits = true;
  String? _recitError;
  String? selectedConteTitle;
  int? selectedConteId;

  @override
  void initState() {
    super.initState();
    _fetchRecits();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (var q in questions) {
      q.dispose(); // Utilise la méthode dispose définie dans QuestionData
    }
    super.dispose();
  }

  // --- LOGIQUE API : Récupérer les Récits (Contenus) ---
  Future<void> _fetchRecits() async {
    setState(() {
      _isLoadingRecits = true;
      _recitError = null;
    });

    try {
      final List<Recit> fetchedRecits =
      await _recitService.fetchRecitsByFamilleId(familleId: widget.familyId);

      setState(() {
        _availableRecits = fetchedRecits;
        _isLoadingRecits = false;
      });

      if (_availableRecits.isEmpty) {
        _recitError = "Aucun contenu (conte) disponible pour cette famille.";
      }

    } catch (e) {
      print("Erreur de récupération des récits: $e");
      setState(() {
        _recitError = "Impossible de charger la liste des contenus.";
        _isLoadingRecits = false;
      });
    }
  }

  // 1. Ajouter une nouvelle question
  void _addQuestion() {
    setState(() {
      final newQuestionNumber = questions.length + 1;
      questions.add(QuestionData(newQuestionNumber));
      activeQuestionIndex = questions.length - 1;
    });
  }

  // 2. Ajouter une nouvelle option de réponse à la question active
  void _addAnswerOption() {
    setState(() {
      final activeQuestion = questions[activeQuestionIndex];
      if (activeQuestion.type == QuizType.trueFalse) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ajouter des options à un Vrai/Faux.')),
        );
      } else if (activeQuestion.answerControllers.length < 5) {
        activeQuestion.answerControllers.add(
            TextEditingController(text: 'Option ${activeQuestion.answerControllers.length + 1}')
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Limite de 5 options atteinte.')),
        );
      }
    });
  }

  // 3. Supprimer une option de réponse
  void _removeAnswerOption(int answerIndex) {
    setState(() {
      final activeQuestion = questions[activeQuestionIndex];
      if (activeQuestion.answerControllers.length > 2 && activeQuestion.type == QuizType.qcm) {
        activeQuestion.answerControllers[answerIndex].dispose();
        activeQuestion.answerControllers.removeAt(answerIndex);

        if (activeQuestion.correctAnswerIndex == answerIndex) {
          activeQuestion.correctAnswerIndex = 0;
        } else if (activeQuestion.correctAnswerIndex > answerIndex) {
          activeQuestion.correctAnswerIndex--;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Un QCM doit avoir au moins deux options.')),
        );
      }
    });
  }

  // 4. Modifier le type de quiz pour la question active
  void _changeQuizType(QuizType? newType) {
    if (newType != null) {
      setState(() {
        final activeQuestion = questions[activeQuestionIndex];
        activeQuestion.type = newType;

        if (newType == QuizType.trueFalse) {
          for (var c in activeQuestion.answerControllers) { c.dispose(); }
          activeQuestion.answerControllers = [
            TextEditingController(text: 'Vrai'),
            TextEditingController(text: 'Faux'),
          ];
          activeQuestion.correctAnswerIndex = 0;
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

  // 6. Supprimer une question
  void _removeQuestion(int indexToRemove) {
    if (questions.length > 1) {
      setState(() {
        final questionToRemove = questions.removeAt(indexToRemove);
        questionToRemove.dispose(); // Libérer les ressources

        if (activeQuestionIndex >= questions.length) {
          activeQuestionIndex = questions.length - 1;
        }

        // Correction : questionNumber est mis à jour
        for (int i = 0; i < questions.length; i++) {
          questions[i].questionNumber = i + 1;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le quiz doit contenir au moins une question.')),
      );
    }
  }

  // --- LOGIQUE DE SOUMISSION API ---
  Future<void> _submitQuiz() async {
    if (selectedConteId == null || _titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le titre, la description et sélectionner un contenu.')),
      );
      return;
    }

    try {
      final List<QuestionCreation> apiQuestions = [];

      for (var qData in questions) {
        if (qData.questionTextController.text.trim().isEmpty) {
          throw Exception("Veuillez saisir le texte de la question ${qData.questionNumber}.");
        }

        final List<Proposition> apiPropositions = [];
        bool? vraiFauxReponse;

        if (qData.type == QuizType.qcm) {
          for (int i = 0; i < qData.answerControllers.length; i++) {
            if (qData.answerControllers[i].text.trim().isEmpty) continue;

            apiPropositions.add(Proposition(
              texte: qData.answerControllers[i].text,
              estCorrecte: i == qData.correctAnswerIndex,
              ordre: i + 1,
            ));
          }
          if (apiPropositions.length < 2) {
            throw Exception("La question ${qData.questionNumber} doit avoir au moins deux options valides.");
          }
        } else { // VRAI_FAUX
          vraiFauxReponse = qData.correctAnswerIndex == 0 ? true : false;
        }

        apiQuestions.add(QuestionCreation(
          question: qData.questionTextController.text,
          typeReponse: qData.type == QuizType.qcm ? 'QCM' : 'VRAI_FAUX',
          propositions: qData.type == QuizType.qcm ? apiPropositions : [],
          reponseVraiFaux: qData.type == QuizType.trueFalse ? vraiFauxReponse : null,
        ));
      }

      final request = QuizCreationRequest(
        idContenu: selectedConteId!,
        titre: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        questions: apiQuestions,
      );

      await _quizService.createQuiz(quizData: request);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz créé avec succès !')),
      );

      // Le Navigator.pop(context) ici ramènera à l'écran précédent
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la création du quiz: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final QuestionData activeQuestion = questions[activeQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryTextColor, size: 24),
          onPressed: () => Navigator.pop(context),
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
            // --- Titre et Description du Quiz ---
            _buildTextField(controller: _titleController, label: 'Titre du Quiz'),
            const SizedBox(height: 15),
            _buildTextField(controller: _descriptionController, label: 'Description'),
            const SizedBox(height: 15),

            // --- 1. SÉLECTION DU CONTE (Dropdown DYNAMIQUE) ---
            _buildDropdown(),

            const SizedBox(height: 30),

            // --- 2. LISTE DES QUESTIONS (QuestionForm) ---
            ...questions.asMap().entries.map((entry) {
              int index = entry.key;
              QuestionData qData = entry.value;
              return Column(
                key: ValueKey(qData.questionNumber),
                children: [
                  QuestionForm(
                    question: qData,
                    onQuizTypeChanged: _changeQuizType,
                    onCorrectAnswerSelected: _setCorrectAnswer,
                    onRemoveAnswer: _removeAnswerOption,
                    onActivate: () {
                      setState(() { activeQuestionIndex = index; });
                    },
                    onRemoveQuestion: () => _removeQuestion(index),
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
                _buildActionButton(
                  text: 'Ajouter une question',
                  color: _primaryColor,
                  onPressed: _addQuestion,
                ),
                _buildActionButton(
                  text: 'Ajouter une réponse',
                  color: activeQuestion.type == QuizType.qcm ? _secondaryColor : Colors.grey,
                  onPressed: activeQuestion.type == QuizType.qcm ? _addAnswerOption : () {},
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Bouton "Valider"
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _submitQuiz,
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

  // --- Fonction utilitaire pour le Dropdown (Dynamique) ---
  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contenu associé',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: _primaryTextColor,
            )),
        const SizedBox(height: 8),

        if (_isLoadingRecits)
          const Center(child: LinearProgressIndicator(color: _primaryColor)),

        if (_recitError != null)
          Text(_recitError!, style: const TextStyle(color: _iconColor)),

        if (!_isLoadingRecits && _recitError == null && _availableRecits.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: const [
                BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 0)),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedConteTitle,
                isExpanded: true,
                hint: const Text('Sélectionner un conte/contenu'),
                icon: const Icon(Icons.keyboard_arrow_down, color: _primaryTextColor),
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: _primaryTextColor),

                items: _availableRecits.map((Recit recit) {
                  return DropdownMenuItem<String>(
                    value: recit.titre,
                    child: Text(recit.titre),
                  );
                }).toList(),

                onChanged: (String? newValue) {
                  setState(() {
                    selectedConteTitle = newValue;
                    // ✅ CORRECTION APPLIQUÉE : Fournir tous les champs requis pour le Recit de secours
                    selectedConteId = _availableRecits.firstWhere(
                          (recit) => recit.titre == newValue,
                      orElse: () => Recit(
                        id: 0,
                        titre: '',
                        description: '',
                        nomAuteur: '',
                        prenomAuteur: '',
                        emailAuteur: '',
                        roleAuteur: '',
                        lienParenteAuteur: '',
                        dateCreation: DateTime.now(),
                        statut: '',
                        urlFichier: '',
                        urlPhoto: '',
                        lieu: '',
                        region: '',
                        idFamille: 0,
                        nomFamille: '',
                        quiz: null,
                      ),
                    ).id;
                  });
                },
              ),
            ),
          ),
        // Afficher un message si la liste est vide après le chargement
        if (!_isLoadingRecits && _availableRecits.isEmpty)
          const Text("Aucun contenu disponible.", style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  // --- Fonction utilitaire pour les champs de texte Titre/Description ---
  Widget _buildTextField({required TextEditingController controller, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: _primaryTextColor,
            )),
        const SizedBox(height: 8),
        Container(
          height: label == 'Description' ? 80 : 40,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.0),
            boxShadow: const [
              BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 0)),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: label == 'Description' ? null : 1,
            decoration: InputDecoration(
              hintText: 'Entrez le $label...',
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
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
// WIDGET QUESTION FORM : Représente un bloc de question (INCHANGÉ)
// ====================================================================

class QuestionForm extends StatelessWidget {
  final QuestionData question;
  final Function(QuizType?) onQuizTypeChanged;
  final Function(int) onCorrectAnswerSelected;
  final Function(int) onRemoveAnswer;
  final VoidCallback onActivate;
  final VoidCallback onRemoveQuestion;
  final bool isActive;

  const QuestionForm({
    super.key,
    required this.question,
    required this.onQuizTypeChanged,
    required this.onCorrectAnswerSelected,
    required this.onRemoveAnswer,
    required this.onActivate,
    required this.onRemoveQuestion,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Si ce n'est pas la question active, on affiche un résumé cliquable
    if (!isActive) {
      return GestureDetector(
        onTap: onActivate,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${question.questionNumber}: ${question.questionTextController.text.isEmpty ? 'Non définie' : question.questionTextController.text}',
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
              const Icon(Icons.edit, size: 20, color: _primaryColor),
            ],
          ),
        ),
      );
    }

    // Affichage détaillé de la question active
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _neutralLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Titre de la Question et Bouton Supprimer ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Questions ${question.questionNumber}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _primaryTextColor,
                ),
              ),
              GestureDetector(
                onTap: onRemoveQuestion,
                child: const Icon(Icons.delete_forever, color: _iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // --- Champ de Saisie de la Question ---
          _buildQuestionTextField(question.questionTextController),
          const SizedBox(height: 20),

          // --- Sélecteur de Type (QCM / Vrai/Faux) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildQuizTypeSelector(
                label: 'QCM',
                type: QuizType.qcm,
                currentType: question.type,
                onChanged: onQuizTypeChanged,
              ),
              const SizedBox(width: 30),
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
          ...question.answerControllers.asMap().entries.map((entry) {
            int index = entry.key;
            TextEditingController controller = entry.value;

            bool isCorrect = question.correctAnswerIndex == index;

            return _buildAnswerOption(
              controller: controller,
              isCorrect: isCorrect,
              onToggleCorrect: () => onCorrectAnswerSelected(index),
              onRemove: () => onRemoveAnswer(index),
              canRemove: question.type == QuizType.qcm && question.answerControllers.length > 2,
            );
          }).toList(),
        ],
      ),
    );
  }

  // Widget utilitaire pour le champ de texte de la question
  Widget _buildQuestionTextField(TextEditingController controller) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: const [
          BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 0)),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Ex: L\'histoire du lion et du chasseur?',
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 14),
      ),
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
    required TextEditingController controller,
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
                  BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 0)),
                ],
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Entrer une réponse...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14),
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
            onTap: canRemove ? onRemove : null,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: canRemove ? Colors.transparent : Colors.grey.shade200,
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