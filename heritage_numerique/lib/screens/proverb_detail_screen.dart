import 'package:flutter/material.dart';

// Constantes de Couleurs
const Color _accentColor = Color(0xFFD69301); // Ocre Vif
const Color _cardTextColor = Color(0xFF2E2E2E); // Gris foncé
const Color _backgroundColor = Colors.white;

class ProverbDetailScreen extends StatefulWidget {
  final String proverbText;
  final String source;
  final String conteur;
  final String langue;

  const ProverbDetailScreen({
    super.key,
    required this.proverbText,
    required this.source,
    required this.conteur,
    required this.langue,
  });

  @override
  State<ProverbDetailScreen> createState() => _ProverbDetailScreenState();
}

class _ProverbDetailScreenState extends State<ProverbDetailScreen> {
  // Langues disponibles
  final List<String> availableLanguages = const ['Français', 'Anglais', 'Bambara'];
  String? _selectedLanguage;

  // Données simulées pour la traduction (En situation réelle, vous feriez un appel API)
  late final Map<String, Map<String, String>> _proverbTranslations;

  @override
  void initState() {
    super.initState();
    // Utiliser la langue du proverbe comme sélection initiale, si elle est dans la liste
    _selectedLanguage = availableLanguages.contains(widget.langue) ? widget.langue : 'Français';

    // Initialisation des traductions simulées basées sur le proverbe original
    _proverbTranslations = {
      'Français': {
        'text': widget.proverbText,
        'conteur': widget.conteur,
        'nom_langue': 'Français',
      },
      'Anglais': {
        'text': 'The proverb: ${widget.proverbText} has been translated. (Translation in English)',
        'conteur': widget.conteur,
        'nom_langue': 'English',
      },
      'Bambara': {
        'text': 'Sègè kòrò ni jòn ba. Traduction simulée en Bambara du proverbe original. (Translation in Bambara)',
        'conteur': widget.conteur,
        'nom_langue': 'Bambara',
      },
    };
  }

  // Fonction pour obtenir le texte du proverbe dans la langue sélectionnée
  String _getTranslatedProverb() {
    return _proverbTranslations[_selectedLanguage]?['text'] ?? widget.proverbText;
  }

  // Fonction pour obtenir le nom de la langue à afficher
  String _getDisplayName() {
    return _proverbTranslations[_selectedLanguage]?['nom_langue'] ?? widget.langue;
  }

  // Fonction pour obtenir le drapeau (simulé)
  Widget _getFlag() {
    String flag = '🇫🇷';
    if (_selectedLanguage == 'Anglais') {
      flag = '🇬🇧';
    } else if (_selectedLanguage == 'Bambara') {
      flag = '🇲🇱';
    }
    return Text(flag, style: const TextStyle(fontSize: 24));
  }


  @override
  Widget build(BuildContext context) {
    final currentProverbText = _getTranslatedProverb();
    final currentLanguageDisplay = _getDisplayName();

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. EN-TÊTE et Titre (Inclut le sélecteur de langue) ---
            _buildHeader(context),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. Bloc du Proverbe ---
                  _buildProverbBlock(currentProverbText),
                  const SizedBox(height: 30),

                  // --- 3. Bloc d'Informations ---
                  _buildInformationCard(widget.conteur, currentLanguageDisplay),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets de Construction ---

  /// Construit l'en-tête (AppBar transparente, titre et sélecteur de langue).
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
      color: _backgroundColor,
      child: Stack(
        alignment: Alignment.topCenter, // Centre les enfants par défaut
        children: [
          // Flèche de retour à gauche (positionné)
          Positioned(
            left: 0,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: _accentColor), // Couleur Ocre pour la flèche
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Titre et Sélecteur de Langue (Centré verticalement)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15.0), // Espace sous l'StatusBar

              // Titre "Proverbe"
              const Text(
                'Proverbe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10), // Espace entre le titre et le sélecteur

              // Sélecteur de langue
              _buildLanguageDropdown(),
            ],
          ),
        ],
      ),
    );
  }

  /// Construit le menu déroulant de sélection de la langue.
  Widget _buildLanguageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          icon: const Icon(Icons.keyboard_arrow_down, color: _accentColor),
          style: const TextStyle(fontSize: 14, color: _cardTextColor),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLanguage = newValue;
            });
          },
          items: availableLanguages.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  _getFlag(),
                  const SizedBox(width: 8),
                  Text(value),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Construit le bloc contenant le texte du proverbe.
  Widget _buildProverbBlock(String text) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0), // Beige clair comme sur l'image
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: _cardTextColor,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  /// Construit la carte des informations (Conteur et Langue).
  Widget _buildInformationCard(String conteur, String langue) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
          ),
          const Divider(color: Colors.grey, height: 20),

          _buildDetailRow('Conteur', conteur),
          _buildDetailRow('Langue', langue),
        ],
      ),
    );
  }

  /// Ligne pour afficher une information (clé/valeur).
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _accentColor),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: _cardTextColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}