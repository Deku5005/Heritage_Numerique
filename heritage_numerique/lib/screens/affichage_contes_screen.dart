import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';

/// Écran affichant les détails et le contenu d'un conte traditionnel Malien.
class AffichageContesScreen extends StatefulWidget {
  final Map<String, Map<String, String>> allContent;
  final String imagePath;

  const AffichageContesScreen({
    super.key,
    required this.allContent,
    required this.imagePath,
  });
  
  @override
  State<AffichageContesScreen> createState() => _AffichageContesScreenState();
}

class _AffichageContesScreenState extends State<AffichageContesScreen> {
  
  // COULEURS
  static const Color _accentColor = Color(0xFFD69301);
  static const Color _cardTextColor = Color(0xFF2E2E2E);
  static const Color _actionColor = Color(0xFF9F9646); 

  // Liste des langues disponibles
  final List<String> _languages = const ['Français', 'Bambara', 'Anglais'];
  
  // État actuel de la langue sélectionnée
  late String _selectedLanguage;

  // NOUVEAU : Dictionnaire pour traduire les libellés d'information (les parties en couleur)
  final Map<String, Map<String, String>> _infoLabels = const {
    'Français': {
      'section_title': 'Informations',
      'narrator': 'Conteur',
      'language': 'Langue sélectionnée',
      'duration': 'Durée',
      'date': 'Date de publication',
    },
    'Bambara': {
      'section_title': 'Kunnafoni', // Informations
      'narrator': 'Jeli (Conteur)', // Griot/Narrateur
      'language': 'Kan min bɛ sɔrɔ', // Langue sélectionnée
      'duration': 'Loncɛ', // Durée
      'date': 'Tuma min na a bɔra', // Date de publication
    },
    'Anglais': {
      'section_title': 'Information',
      'narrator': 'Narrator',
      'language': 'Selected Language',
      'duration': 'Duration',
      'date': 'Publication Date',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.allContent.keys.firstWhere(
      (lang) => _languages.contains(lang),
      orElse: () => _languages.first,
    );
  }

  /// Fonction utilitaire pour obtenir les données du conte pour la langue sélectionnée
  Map<String, String> _getCurrentTaleData() {
    return widget.allContent[_selectedLanguage] ?? widget.allContent['Français']!;
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
    final duration = currentData['duration']!;
    
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
              _buildInformationSection(currentLabels, narrator, duration), // Passe les libellés traduits
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
    // ... (Code de _buildAppBar inchangé)
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
    // ... (Code de _buildLanguageSelector inchangé)
    final availableLanguages = _languages.where((lang) => widget.allContent.containsKey(lang)).toList();

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
    // ... (Code de _buildAudioCard inchangé)
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.15), 
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          // Image du conte (petit)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              widget.imagePath,
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
            decoration: BoxDecoration(
              color: _actionColor, 
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Démarrage de la lecture audio en $_selectedLanguage...'),
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

  /// Section des informations complémentaires.
  Widget _buildInformationSection(Map<String, String> labels, String narrator, String duration) {
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
          _buildInfoRow(labels['duration']!, duration), // Durée
          _buildInfoRow(labels['date']!, '01/01/2024'), // Date
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