import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/quizQuestion.dart';
import 'package:heritage_numerique/screens/quizScreen.dart';
// NOTE: Assurez-vous d'importer le QuizService et les modèles ici
import '../service/QuizService.dart';
import '../model/QuizModel.dart';
import 'AppDrawer.dart';
 // Import pour la création de quiz

// Constantes de couleurs (assumées)
const Color _primaryColor = Color(0xFFBB8F40); // Couleur de progression
const Color _mainGreen = Color(0xFF008236); // Couleur principale pour les boutons

class QuizScreen extends StatefulWidget {
  final int familyId;

  const QuizScreen({super.key, required this.familyId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // Instance du service API
  final QuizService _quizService = QuizService();

  // État de la liste de quiz
  List<QuizOverview> _quizzes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  // --- Fonction de récupération des données API ---
  Future<void> _fetchQuizzes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<QuizOverview> fetchedQuizzes =
      await _quizService.fetchQuizzesByFamilleId(familleId: widget.familyId);

      setState(() {
        _quizzes = fetchedQuizzes;
        _isLoading = false;
      });

    } catch (e) {
      print("Erreur de récupération des quiz: $e");
      setState(() {
        _errorMessage = "Impossible de charger les quiz. Veuillez réessayer.";
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AJOUT DU DRAWER
      drawer: AppDrawer(familyId: widget.familyId),

      // --- 1. En-tête (AppBar) ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        // CORRECTION DRAWER: Utilisation de 'leading' avec un Builder pour obtenir le bon context
        leading: Builder(
          builder: (BuildContext innerContext) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(innerContext).openDrawer();
              },
            );
          },
        ),

        title: const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              // Titre
              Expanded(
                child: Text(
                  'Héritage Numérique',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Ligne d'ombre pour simuler le 'box-shadow'
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

      // --- 2. Corps de la Page ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Carte d'information/promotion (avec bouton 'Créer un quiz') ---
            _buildHeaderCard(context),

            const SizedBox(height: 20),

            // --- Titre de la section Quiz ---
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
              child: Text(
                'Quiz disponibles',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),

            // --- Affichage Conditionnel de la Liste ---
            _buildQuizListContent(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

// ===============================================
// NOUVEAU WIDGETS D'ÉTAT
// ===============================================

  Widget _buildQuizListContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: CircularProgressIndicator(color: _primaryColor),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              // Bouton pour réessayer la récupération
              TextButton(
                onPressed: _fetchQuizzes,
                child: const Text('Recharger les quiz'),
              ),
            ],
          ),
        ),
      );
    }

    // Si la liste est vide
    if (_quizzes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Text("Aucun quiz trouvé pour cette famille."),
        ),
      );
    }

    // Affichage de la liste réelle
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _quizzes.length,
      itemBuilder: (context, index) {
        // Passer l'objet QuizOverview au widget de tuile
        return _buildQuizTile(context, _quizzes[index]);
      },
    );
  }


// ===============================================
// WIDGETS DE CONSTRUCTION (Légèrement modifiés)
// ===============================================

  // Widget pour la carte d'en-tête (inchangé)
  Widget _buildHeaderCard(BuildContext context) {
    const Color cardColor = Color(0xFFE9A000);
    const Color buttonColor = Color(0xFFFFCC33);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          // 1. Carte de fond
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // Image de fond
                Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/images/mali.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: cardColor, alignment: Alignment.center, child: const Text("Image du Mali (Placeholder)", style: TextStyle(color: Colors.white70)));
                    },
                  ),
                ),

                // Contenu du Texte
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Développer votre culture',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tester vos connaissance en culture malienne',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Bouton "Créer un quiz"
          Positioned(
            top: 10.0,
            right: 10.0,
            child: ElevatedButton(
              onPressed: () {
                // Passage de familyId à l'écran de création
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // 💡 NOTE: Assurez-vous que AddQuizScreen accepte familyId
                    builder: (context) => AddQuizScreen(familyId: widget.familyId),
                  ),
                ).then((_) => _fetchQuizzes()); // Recharger après le retour
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Créer un quiz',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour une seule tuile de quiz (MIS À JOUR pour utiliser QuizOverview)
  Widget _buildQuizTile(BuildContext context, QuizOverview data) {
    const Color primaryColor = _primaryColor;
    // NOTE: On simule le score actuel (ici, on pourrait utiliser 0/nombreQuestions
    // ou ajouter un champ 'currentScore' au modèle si l'API le fournissait)
    const int currentScorePlaceholder = 0;
    final int totalQuestions = data.nombreQuestions;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F0E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book, color: primaryColor),
          ),
          // Titre : Utilise le titre du QuizOverview
          title: Text(
            data.titre,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          // Sous-titre : Utilise le nombre de questions
          subtitle: Text(
            '${data.nombreQuestions} Questions',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          // Cercle de progression (simulé)
          trailing: _buildScoreCircle(currentScorePlaceholder, totalQuestions, primaryColor),

          // ACTION : Navigation vers QuestionScreen (à adapter pour le quiz spécifique)
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // 🌟 CORRECTION: Passer familyId à QuestionScreen
                builder: (context) => QuestionScreen(
                  quizId: data.id,
                  familyId: widget.familyId, // ⬅️ AJOUT CRITIQUE
                ),
              ),
            ).then((_) => _fetchQuizzes()); // Recharger la liste après un éventuel retour (ex: après soumission)
          },
        ),
      ),
    );
  }

  // Widget pour le cercle de score (inchangé)
  Widget _buildScoreCircle(int score, int total, Color color) {
    // Évite la division par zéro
    double progress = total > 0 ? score / total : 0;

    return SizedBox(
      width: 45,
      height: 45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle de progression
          SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // Texte du score (0/X)
          Text(
            '$score/$total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}