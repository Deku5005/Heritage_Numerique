import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../model/conte.dart';
import '../model/quiz.dart';
import '../model/question.dart';
import '../model/proposition.dart';

// *** AJOUT NÉCESSAIRE ***
// Assurez-vous que le chemin ci-dessous correspond à l'emplacement réel de QuizScreen
import '../screens/quizscreenn.dart';

/// Écran affichant les détails et le contenu d'un conte traditionnel Malien,
/// y compris le quiz et les questions associées s'ils existent.
class AffichageContesScreen extends StatefulWidget {

  final Conte conte;

  const AffichageContesScreen({
    super.key,
    required this.conte,
  });

  @override
  State<AffichageContesScreen> createState() => _AffichageContesScreenState();
}

class _AffichageContesScreenState extends State<AffichageContesScreen> {

  // COULEURS
  static const Color _accentColor = Color(0xFFD69301);
  static const Color _cardTextColor = Color(0xFF2E2E2E);
  static const Color _actionColor = Color(0xFF9F9646);

  // URL de base pour charger les médias depuis l'API
  static const String _apiBaseUrl = 'http://10.0.2.2:8080';

  // Liste des langues disponibles (pour le sélecteur)
  final List<String> _languages = const ['Français', 'Bambara', 'Anglais'];

  // État actuel de la langue sélectionnée
  late String _selectedLanguage;

  // Dictionnaire pour traduire les libellés d'information
  final Map<String, Map<String, String>> _infoLabels = const {
    'Français': {
      'section_title': 'Informations',
      'narrator': 'Conteur',
      'language': 'Langue sélectionnée',
      'duration': 'Fichier/Durée',
      'date': 'Date de publication',
    },
    'Bambara': {
      'section_title': 'Kunnafoni',
      'narrator': 'Jeli (Conteur)',
      'language': 'Kan min bɛ sɔrɔ',
      'duration': 'Loncɛ/Fasi',
      'date': 'Tuma min na a bɔra',
    },
    'Anglais': {
      'section_title': 'Information',
      'narrator': 'Narrator',
      'language': 'Selected Language',
      'duration': 'File/Duration',
      'date': 'Publication Date',
    },
  };

  // Simulation des données multilingues
  late Map<String, Map<String, String>> _simulatedAllContent;

  @override
  void initState() {
    super.initState();

    final String fullNarratorName = '${widget.conte.prenomAuteur} ${widget.conte.nomAuteur}';

    _simulatedAllContent = {
      'Français': {
        'title': widget.conte.titre,
        'text': widget.conte.description,
        'narrator': fullNarratorName,
        'duration': widget.conte.urlFichier,
      },
      // Simuler des traductions pour que le sélecteur fonctionne
      'Bambara': {
        'title': 'Tige dɔ Mali kɔnɔ',
        'text': 'A kɔrɔyɛlɛma kura...',
        'narrator': 'Jeli',
        'duration': 'Fasi Bamanankan',
      },
      'Anglais': {
        'title': 'Tale from Mali',
        'text': 'A new English translation...',
        'narrator': 'Narrator',
        'duration': 'English File Link',
      },
    };

    _selectedLanguage = _simulatedAllContent.keys.firstWhere(
          (lang) => _languages.contains(lang),
      orElse: () => _languages.first,
    );
  }

  // --- Fonctions Utilitaires ---

  Map<String, String> _getCurrentTaleData() {
    return _simulatedAllContent[_selectedLanguage] ?? _simulatedAllContent['Français']!;
  }

  Map<String, String> _getCurrentLabels() {
    return _infoLabels[_selectedLanguage] ?? _infoLabels['Français']!;
  }


  @override
  Widget build(BuildContext context) {
    final currentData = _getCurrentTaleData();
    final title = currentData['title']!;
    final contentText = currentData['text']!;
    final narrator = currentData['narrator']!;
    final duration = currentData['duration']!;
    final currentLabels = _getCurrentLabels();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'contes'),
      appBar: _buildAppBar(context, title),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              _buildLanguageSelector(context),
              const SizedBox(height: 15),

              _buildAudioCard(context, title, narrator),
              const SizedBox(height: 30),

              // *** LOGIQUE D'AFFICHAGE DU QUIZ ET DES QUESTIONS ***
              if (widget.conte.quiz != null)
                _buildQuizSection(context, widget.conte.quiz!),
              if (widget.conte.quiz != null)
                const SizedBox(height: 30),
              // *************************************************

              // --- TEXTE DU CONTE ---
              Text(
                contentText,
                style: const TextStyle(
                  color: _cardTextColor,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30),

              // --- SECTION INFORMATIONS ---
              _buildInformationSection(currentLabels, narrator, duration),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE STRUCTURE ---

  AppBar _buildAppBar(BuildContext context, String title) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: _accentColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: _cardTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    final availableLanguages = _languages.where((lang) => _simulatedAllContent.containsKey(lang)).toList();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
              ),
            ]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag, color: _accentColor, size: 16),
            const SizedBox(width: 8),

            DropdownButton<String>(
              value: _selectedLanguage,
              icon: const Icon(Icons.keyboard_arrow_down, color: _accentColor),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold),
              underline: Container(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
              items: availableLanguages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCard(BuildContext context, String title, String narrator) {
    String imageUrl = widget.conte.urlPhoto;
    if (imageUrl.isNotEmpty && !imageUrl.toLowerCase().startsWith('http')) {
      final String sanitizedPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
      imageUrl = '$_apiBaseUrl/$sanitizedPath';
    }
    final String fullImageUrl = imageUrl;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Image du conte (petit) - Chargée par réseau
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              fullImageUrl,
              width: 80,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.headphones, color: _actionColor),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Texte et conteur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _cardTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Narration par $narrator',
                  style: TextStyle(
                    color: _cardTextColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Bouton Play
          Container(
            decoration: const BoxDecoration(
              color: _actionColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Démarrage de la lecture audio pour le fichier: ${widget.conte.urlFichier}'),
                    backgroundColor: _actionColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Section pour afficher le Quiz, les Questions et les Propositions.
  Widget _buildQuizSection(BuildContext context, Quiz quiz) {
    // Vérifie si la liste de questions n'est pas vide
    final bool hasQuestions = quiz.questions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. CARTE RÉSUMÉ DU QUIZ ---
        Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 20),
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.quiz, color: Colors.green, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Testez vos connaissances !',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, height: 20),
                Text('Titre du Quiz: ${quiz.titre}'),
                Text('Difficulté: ${quiz.difficulte}'),
                Text('Nombre de questions: ${quiz.nombreQuestions}'),
                const SizedBox(height: 15),
                // Le bouton de démarrage n'est affiché que si le quiz a des questions
                if (hasQuestions)
                  ElevatedButton.icon(
                    onPressed: () {
                      // *** LOGIQUE CORRIGÉE : NAVIGATION VERS QUIZSCREEN ***
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            quiz: quiz, // Passe l'objet Quiz complet
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.start, size: 18),
                    label: const Text('Commencer le Quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  )
                else
                  const Text('Aucune question n\'est encore attachée à ce quiz.', style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),

        // --- 2. AFFICHAGE DES QUESTIONS ET PROPOSITIONS (Pour le débogage/visualisation) ---
        if (hasQuestions)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aperçu des Questions (À des fins de débogage/développement)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cardTextColor),
              ),
              const SizedBox(height: 10),

              // Itération sur la liste des questions
              ...quiz.questions.asMap().entries.map((entry) {
                final int index = entry.key;
                final Question question = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre de la Question
                      Text(
                        '${index + 1}. ${question.texteQuestion} (Points: ${question.points})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _accentColor),
                      ),
                      const SizedBox(height: 8),

                      // Itération sur la liste des propositions
                      ...question.propositions.map((proposition) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 10.0, bottom: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                proposition.estCorrecte ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: proposition.estCorrecte ? Colors.green : Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  proposition.texteProposition,
                                  style: TextStyle(
                                    color: proposition.estCorrecte ? Colors.green.shade800 : _cardTextColor,
                                    fontStyle: proposition.estCorrecte ? FontStyle.italic : FontStyle.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
      ],
    );
  }

  Widget _buildInformationSection(Map<String, String> labels, String narrator, String urlFichier) {
    final String date = widget.conte.dateCreation.split('T').first;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labels['section_title']!,
            style: const TextStyle(
              color: _cardTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildInfoRow(labels['narrator']!, narrator),
          _buildInfoRow(labels['language']!, _selectedLanguage),
          _buildInfoRow(labels['duration']!, urlFichier),
          _buildInfoRow(labels['date']!, date),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: _actionColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _cardTextColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}