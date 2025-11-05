import 'package:flutter/material.dart';

// --- SIMULATION D'IMPORTATION ---
// Dans votre projet réel, cette ligne importera le fichier AppDrawer.dart
import 'AppDrawer.dart';


// --- Constantes de Style ---
const Color _primaryColor = Color(0xFF714D1D); // Brun foncé
const Color _primaryTextColor = Color(0xFF000000);
const Color _secondaryTextColor = Color(0xFF99928F); // Gris pour le sous-titre
const Color _cardBackgroundColor = Color(0xFFFFFFFF);
const Color _shadowColor = Color(0x40000000); // 0px 0px 4px rgba(0, 0, 0, 0.25)
const Color _answerPillColor = Color(0xFFE5E5E5); // Gris clair pour la pilule de réponse (D9D9D9, 0.7)
const Color _answerPillBorderColor = Color(0xFF000000); // Bordure noire

// Structure de données pour une Devinette
class Riddle {
  final String question;
  final String answer;

  Riddle({required this.question, required this.answer});
}

// Liste des devinettes à afficher
final List<Riddle> _riddles = [
  Riddle(
    question: 'Je commence la nuit et termine le matin. Qui suis-je ?',
    answer: 'La lettre N',
  ),
  Riddle(
    question: 'J\'ai des villes mais pas de maisons, des forêts mais pas d\'arbres, de l\'eau mais pas de poissons. Que suis-je ?',
    answer: 'Une carte géographique',
  ),
  Riddle(
    question: 'Je vole sans ailes, je pleure sans yeux. Partout où je vais, l\'obscurité me suit. Qui suis-je ?',
    answer: 'Un nuage',
  ),
];


// --- Le Widget de Carte de Devinette avec État Interne ---
class RiddleCard extends StatefulWidget {
  final Riddle riddle;

  const RiddleCard({super.key, required this.riddle});

  @override
  State<RiddleCard> createState() => _RiddleCardState();
}

class _RiddleCardState extends State<RiddleCard> {
  // État local pour suivre si la réponse est affichée ou non
  bool _isAnswerVisible = false;

  void _toggleAnswerVisibility() {
    setState(() {
      _isAnswerVisible = !_isAnswerVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Le texte du bouton bascule entre "Afficher la réponse" et "Masquer la réponse"
    final String buttonText = _isAnswerVisible ? 'Masquer la réponse' : 'Afficher la réponse';

    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            blurRadius: 4.0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Icône Ampoule
              Container(
                width: 34.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: const Color(0x66D9D9D9), // rgba(217, 217, 217, 0.4)
                  borderRadius: BorderRadius.circular(10.0),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lightbulb_outline,
                  size: 18.0,
                  color: _primaryTextColor,
                ),
              ),
              const SizedBox(width: 15.0),

              // 2. Question de la Devinette
              Expanded(
                child: Text(
                  widget.riddle.question,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 1.4,
                    color: _primaryTextColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18.0),

          // 3. Pilule de Réponse (Affichée conditionnellement)
          if (_isAnswerVisible)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: _answerPillColor.withOpacity(0.7), // Utilisation de l'opacité
                border: Border.all(color: _answerPillBorderColor, width: 1.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                widget.riddle.answer,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.4,
                  color: _primaryTextColor,
                ),
              ),
            )
          else
          // Placeholder d'Opacité si la réponse est masquée
            Container(
              width: double.infinity,
              height: 34.0,
              decoration: BoxDecoration(
                color: const Color(0x40D9D9D9), // Couleur du rectangle masqué
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),

          const SizedBox(height: 15.0),

          // 4. Bouton Afficher/Masquer
          Center(
            child: GestureDetector(
              onTap: _toggleAnswerVisibility,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                decoration: BoxDecoration(
                  color: const Color(0x40D9D9D9), // Couleur du bouton
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isAnswerVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 16,
                      color: _primaryTextColor,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        height: 1.8,
                        color: _primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Page Principale ---
class RiddleScreen extends StatelessWidget {
  const RiddleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: Builder(
          builder: (BuildContext innerContext) {
            return IconButton(
              icon: const Icon(Icons.menu, color: _primaryTextColor),
              onPressed: () {
                Scaffold.of(innerContext).openDrawer();
              },
            );
          },
        ),
        title: Center(
          child: Text(
            'Héritage Numérique',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: _primaryTextColor,
            ),
          ),
        ),
      ),

      // Corps de la page
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Titre principal ---
            const Padding(
              padding: EdgeInsets.only(top: 10.0, left: 7.0, right: 7.0),
              child: Text(
                'Devinettes Mystérieuses',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: _primaryTextColor,
                ),
              ),
            ),

            // --- Sous-titre ---
            const Padding(
              padding: EdgeInsets.only(top: 5.0, bottom: 20.0, left: 7.0, right: 7.0),
              child: Text(
                'Testez votre esprit avec nos énigmes captivantes. Cliquez pour révéler les réponses !',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: _secondaryTextColor,
                ),
              ),
            ),

            // --- Barre de Recherche ---
            Container(
              margin: const EdgeInsets.only(bottom: 25.0),
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: _shadowColor.withOpacity(0.1), width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: _shadowColor.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher contenu...',
                  hintStyle: TextStyle(color: _secondaryTextColor),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: _secondaryTextColor),
                ),
              ),
            ),

            // --- Liste des Devinettes ---
            ..._riddles.map((riddle) {
              return RiddleCard(riddle: riddle);
            }).toList(),

            const SizedBox(height: 30), // Espace en bas pour le scroll
          ],
        ),
      ),
    );
  }
}
