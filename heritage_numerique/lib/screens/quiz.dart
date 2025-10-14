import 'package:flutter/material.dart';

// Assurez-vous que le chemin d'importation de votre AppDrawer est correct
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

        // CORRECTION MAJEURE: Utilisation de 'leading' avec un Builder pour ouvrir le Drawer
        leading: Builder(
          builder: (BuildContext innerContext) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                // Utilise l'innerContext qui est enfant du Scaffold pour ouvrir le Drawer
                Scaffold.of(innerContext).openDrawer();
              },
            );
          },
        ),

        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              // L'IconButton a été déplacé dans 'leading'

              // Titre
              Expanded(
                child: Text(
                  'Héritage Numérique',
                  style: const TextStyle(
                    fontFamily: 'Inter',
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
            // --- Carte d'information/promotion (Image de fond) ---
            _buildHeaderCard(context),

            const SizedBox(height: 20),

            // --- Titre de la section Quiz ---
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 10.0),
              child: Text(
                'Quiz pour les contes',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
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
                return _buildQuizTile(quizList[index]);
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

  // Widget pour la carte orange en haut (Image Seule en fond)
  Widget _buildHeaderCard(BuildContext context) {
    const Color cardColor = Color(0xFFE9A000);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // 1. Image de fond (CORRIGÉE : Utilisation de Opacity)
            Opacity(
              opacity: 0.8, // Opacité appliquée via le widget Opacity
              child: Image.asset(
                'assets/images/mali.png',
                fit: BoxFit.cover,
              ),
            ),

            // 2. Contenu du Texte
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tester vos connaissance en culture malienne',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Développer votre culture',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour une seule tuile de quiz
  Widget _buildQuizTile(QuizTileData data) {
    const Color primaryColor = Color(0xFFE9A000);

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
            '${data.totalQuestions} Question',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          // Score / Cercle de progression
          trailing: _buildScoreCircle(data.currentScore, data.totalQuestions, primaryColor),
          onTap: () {
            // Action
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