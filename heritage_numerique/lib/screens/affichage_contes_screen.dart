import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../model/conte.dart'; // Importez le modèle Conte
import '../model/quiz.dart'; // Assurez-vous d'importer le modèle Quiz

/// Écran affichant les détails et le contenu d'un conte traditionnel Malien.
class AffichageContesScreen extends StatefulWidget {

  // *** NOUVEAUX PARAMÈTRES POUR ACCEPTER L'OBJET CONTE DE L'API ***
  final Conte conte;

  const AffichageContesScreen({
    super.key,
    required this.conte,
    // Les anciens paramètres allContent et imagePath ne sont plus nécessaires ici
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
      'duration': 'Fichier/Durée', // Adapté pour le lien
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

  // --- NOUVEAU : Simulation des données multilingues à partir de l'objet Conte ---
  // C'est la clé pour faire fonctionner votre ancien code d'affichage.
  late Map<String, Map<String, String>> _simulatedAllContent;

  @override
  void initState() {
    super.initState();

    // Simuler que le titre et la description de l'API sont en Français.
    // Si votre API supporte réellement plusieurs langues, ce mapping doit être plus complexe.
    final String fullNarratorName = '${widget.conte.prenomAuteur} ${widget.conte.nomAuteur}';

    _simulatedAllContent = {
      'Français': {
        'title': widget.conte.titre,
        'text': widget.conte.description, // Utilise la description comme corps du texte
        'narrator': fullNarratorName,
        'duration': widget.conte.urlFichier, // Utilise l'URL du fichier audio/PDF comme 'durée'
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

    // Initialisation basée sur les langues disponibles dans la simulation
    _selectedLanguage = _simulatedAllContent.keys.firstWhere(
          (lang) => _languages.contains(lang),
      orElse: () => _languages.first,
    );
  }

  /// Fonction utilitaire pour obtenir les données du conte pour la langue sélectionnée
  Map<String, String> _getCurrentTaleData() {
    return _simulatedAllContent[_selectedLanguage] ?? _simulatedAllContent['Français']!;
  }

  /// Fonction utilitaire pour obtenir les libellés traduits
  Map<String, String> _getCurrentLabels() {
    return _infoLabels[_selectedLanguage] ?? _infoLabels['Français']!;
  }


  @override
  Widget build(BuildContext context) {
    // Récupère les données dynamiques du conte
    final currentData = _getCurrentTaleData();
    final title = currentData['title']!;
    final contentText = currentData['text']!;
    final narrator = currentData['narrator']!;
    final duration = currentData['duration']!; // Qui est maintenant l'URL du fichier

    // Récupère les libellés traduits
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

              // --- 1. SÉLECTEUR DE LANGUE (Dropdown) ---
              _buildLanguageSelector(context),
              const SizedBox(height: 15),

              // --- 2. CARTE AUDIO (Lecteur) ---
              _buildAudioCard(context, title, narrator),
              const SizedBox(height: 30),

              // *** AJOUT CLÉ : Affichage Conditionnel du Quiz ***
              if (widget.conte.quiz != null)
                _buildQuizSection(context, widget.conte.quiz!),
              if (widget.conte.quiz != null)
                const SizedBox(height: 30),

              // --- 3. TEXTE DU CONTE (Dynamique) ---
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

              // --- 4. SECTION INFORMATIONS (Dynamique) ---
              _buildInformationSection(currentLabels, narrator, duration),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE STRUCTURE ---

  /// Barre d'application personnalisée pour le titre et le bouton de retour.
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
        title, // Utilise le titre dynamique
        style: const TextStyle(
          color: _cardTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  /// Sélecteur de langue (DropdownButton).
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

  /// Carte pour l'audio/narration.
  Widget _buildAudioCard(BuildContext context, String title, String narrator) {
    // Utilisation de l'URL de l'API pour l'image
    final String fullImageUrl = '$_apiBaseUrl${widget.conte.urlPhoto}';

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
              fullImageUrl, // Image depuis l'API
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

  /// Section pour afficher le Quiz.
  Widget _buildQuizSection(BuildContext context, Quiz quiz) {
    return Card(
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
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Démarrage du quiz: ${quiz.titre}')),
                );
                // Logique de navigation vers l'écran du Quiz (à implémenter)
              },
              icon: const Icon(Icons.start, size: 18),
              label: const Text('Commencer le Quiz'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section des informations complémentaires.
  Widget _buildInformationSection(Map<String, String> labels, String narrator, String urlFichier) {
    // Utilise la date de création de l'objet conte
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
            labels['section_title']!, // Titre de la section (ex: Informations)
            style: const TextStyle(
              color: _cardTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          // Libellés dynamiques
          _buildInfoRow(labels['narrator']!, narrator), // Conteur
          _buildInfoRow(labels['language']!, _selectedLanguage), // Langue
          _buildInfoRow(labels['duration']!, urlFichier), // URL du Fichier
          _buildInfoRow(labels['date']!, date), // Date
        ],
      ),
    );
  }

  /// Ligne d'information pour la section "Informations".
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label, // Le libellé est maintenant traduit
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