import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/quizQuestion.dart';
import 'package:heritage_numerique/screens/quizScreen.dart'; // NOUVEL IMPORT
import 'AppDrawer.dart';

// Définition du modèle de données pour une tuile de quiz
class QuizTileData {
  final String title;
  final int totalQuestions;
  final int currentScore;

  QuizTileData({
    required this.title,
    required this.totalQuestions,
    required this.currentScore,
  });
}

// Données de démonstration pour la liste
final List<QuizTileData> quizList = [
  QuizTileData(title: 'Chant de mariage traditionnel', totalQuestions: 7, currentScore: 5),
  QuizTileData(title: 'Chant de mariage traditionnel', totalQuestions: 7, currentScore: 5),
  QuizTileData(title: 'Chant de mariage traditionnel', totalQuestions: 36, currentScore: 5),
];

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AJOUT DU DRAWER
      drawer: const AppDrawer(),

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
                // Ouvre le tiroir
                Scaffold.of(innerContext).openDrawer();
              },
            );
          },
        ),

        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              // Titre
              const Expanded(
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
            // --- Carte d'information/promotion (Image de fond) et Bouton ---
            _buildHeaderCard(context),

            const SizedBox(height: 20),

            // --- Titre de la section Quiz ---
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
              child: Text(
                'Quiz pour les contes',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),

            // --- Liste des Tuiles de Quiz ---
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: quizList.length,
              itemBuilder: (context, index) {
                // Le context utilisé ici est le bon pour la navigation
                return _buildQuizTile(context, quizList[index]);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

// ===============================================
// WIDGETS DE CONSTRUCTION
// ===============================================

  // Widget pour (Image Seule en fond) - MODIFIÉ pour inclure le bouton
  Widget _buildHeaderCard(BuildContext context) {
    const Color cardColor = Color(0xFFE9A000);
    const Color buttonColor = Color(0xFFFFCC33); // Couleur jaune-orange du bouton

    return Padding(
      padding: const EdgeInsets.all(16.0), // Le padding est appliqué au Stack entier
      child: Stack(
        alignment: Alignment.topRight, // Aligne le bouton en haut à droite
        children: [
          // 1. Carte de fond (maintenant directement à l'intérieur du Stack)
          Container(
            height: 140,
            width: double.infinity, // S'assure qu'il prend toute la largeur disponible
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
                    'assets/images/mali.png', // Assurez-vous que ce chemin est valide
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
          // Utilisation de Positioned pour un contrôle précis
          Positioned(
            top: 10.0,
            right: 10.0,
            child: ElevatedButton(
              onPressed: () {
                // Logique de navigation vers AddQuizScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddQuizScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor, // Couleur jaune
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
                  color: Colors.black, // Texte noir sur fond jaune
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour une seule tuile de quiz (MODIFIÉ pour la navigation)
  Widget _buildQuizTile(BuildContext context, QuizTileData data) {
    const Color primaryColor = Color(0xFFBB8F40);

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
          // Icône du livre
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F0E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.menu_book, color: primaryColor),
          ),
          // Titre et Sous-titre
          title: Text(
            data.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${data.totalQuestions} Questions',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          // Score / Cercle de progression
          trailing: _buildScoreCircle(data.currentScore, data.totalQuestions, primaryColor),

          // ACTION : Navigation vers QuestionScreen
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // Lance l'écran de question
                builder: (context) => const QuestionScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget pour le cercle de score
  Widget _buildScoreCircle(int score, int total, Color color) {
    double progress = score / total;

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
          // Texte du score (5/7)
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
