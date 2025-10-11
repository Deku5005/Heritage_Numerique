import 'package:flutter/material.dart';
// Importez l'AppDrawer (ajustez le chemin si nécessaire)
import 'AppDrawer.dart'; 

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311); 
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8); 
const Color _buttonColor = Color(0xFF7B521A); 
const Color _lightCardColor = Color(0xFFF7F2E8); 
const Color _tagRecitColor = Color(0xFFC0A272); 
const Color _tagArtisanatColor = Color(0xFF6B8E23); 
const Color _tagProverbeColor = Color(0xFF8B4513); 
const Color _tagMusicColor = Color(0xFF90703B); 


class MusicDashScreen extends StatelessWidget { 
  const MusicDashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête (Menu Burger, Titre)
            Builder(
              builder: (BuildContext innerContext) {
                return _buildCustomHeader(innerContext);
              }
            ), 
            const SizedBox(height: 20),

            // 2. Corps de la page (Titre, Recherche, Actions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre et Sous-titre
                  const Text(
                    'Contenus culturels',
                    style: TextStyle(
                      color: _cardTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Explorez les mélodies et chants traditionnels de la famille',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Barre de recherche
                  _buildSearchBar(),
                  const SizedBox(height: 15),

                  // Boutons d'action (Ajouter et Filtrer)
                  _buildActionButtons(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // 3. Zone de Lecture Principale (Card)
            _buildMainMusicCard(context),
            const SizedBox(height: 20),

            // 4. Titre de la collection et Collection musicale
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Collection musicale',
                    style: TextStyle(
                      color: _cardTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildMusicList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------
  // --- LOGIQUE DES MODALES (START) ---
  // ------------------------------------

  // MODALE 1 (Bottom Sheet) : Sélection du type de contenu
  void _showContentTypeSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête (Titre et Bouton Fermer)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ajouter un contenu',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Choisissez un type de contenu', style: TextStyle(color: _buttonColor, fontSize: 14)),
              const SizedBox(height: 15),
              
              // Grille des options de contenu
              SizedBox(
                width: double.infinity,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: [
                    _buildContentOptionButton(
                      context, 'Récit/ Conte', Icons.book_outlined,
                      onTap: () {
                        Navigator.of(sheetContext).pop(); 
                        _showContentCreationModal(context, 'Récit/ Conte'); 
                      },
                    ),
                    _buildContentOptionButton(
                      context, 'Musique/Chant', Icons.music_note_outlined,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _showContentCreationModal(context, 'Musique/Chant');
                      },
                    ),
                    _buildContentOptionButton(
                      context, 'Artisanat/ Photo', Icons.image_outlined,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _showContentCreationModal(context, 'Artisanat/ Photo');
                      },
                    ),
                    _buildContentOptionButton(
                      context, 'Proverbe', Icons.format_quote_outlined,
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        _showContentCreationModal(context, 'Proverbe');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // MODALE 2 (AlertDialog) : Formulaire de création de contenu
  void _showContentCreationModal(BuildContext context, String contentType) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: _lightCardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de la modale avec bouton Fermer
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                  
                  // Champs du formulaire
                  const Text(
                    'Type de contenu',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildContentDropdown(initialValue: contentType),
                  const SizedBox(height: 15),

                  const Text(
                    'Titre',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildTextField(hint: 'Ex: L\'Histoire du lion et du chasseur'),
                  const SizedBox(height: 15),

                  const Text(
                    'Langue',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildLanguageDropdown(),
                  const SizedBox(height: 15),

                  const Text(
                    'Contenu / Description',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildMultiLineField(hint: 'Écrivez votre récit, les paroles, la description...'),
                  const SizedBox(height: 15),

                  const Text(
                    'Fichier média (optionnel)',
                    style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  _buildMediaUploadField(context),
                  const SizedBox(height: 15),

                  // Section de traduction automatique
                  _buildTranslationSection(),
                  const SizedBox(height: 20),

                  // Bouton Enregistrer
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Contenu ($contentType) en cours d\'enregistrement...')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Enregistrer le contenu', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // ------------------------------------
  // --- LOGIQUE DES MODALES (END) ---
  // ------------------------------------


  // ------------------------------------
  // --- Widgets de Construction de l'Écran ---
  // ------------------------------------

  Widget _buildCustomHeader(BuildContext context) { 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _searchBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher contenu...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Bouton Ajouter un contenu (APPEL DE LA BOTTOM SHEET)
        ElevatedButton.icon(
          onPressed: () {
            _showContentTypeSelectionBottomSheet(context); // L'appel de la modale est ici
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text('Ajouter un contenu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
        const Spacer(),
        // Bouton Tous types (Dropdown)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: 'Tous types',
              icon: const Icon(Icons.keyboard_arrow_down, color: _mainAccentColor),
              items: <String>['Tous types', 'Récit', 'Musique', 'Artisanat', 'Proverbe']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list, color: _mainAccentColor, size: 18),
                      const SizedBox(width: 5),
                      Text(value, style: const TextStyle(color: _cardTextColor, fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Logique de filtrage ici
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainMusicCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: _lightCardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image et Tag
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/music_placeholder.jpg'), 
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                // Tag Musique
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _tagMusicColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Musique / Chant',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            
            // Détails du Chant
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chant de mariage traditionnel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _cardTextColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Description
                  Text(
                    'Enregistré par Oumarou Diakité lors du mariage de son petit-fils à 2002...',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // Barre de progression (simulation)
                  Row(
                    children: [
                      const Text('2:45', style: TextStyle(fontSize: 12, color: _cardTextColor)),
                      Expanded(
                        child: Slider(
                          value: 0.6,
                          min: 0,
                          max: 1.0,
                          onChanged: (double value) {},
                          activeColor: _mainAccentColor,
                          inactiveColor: Colors.grey.shade300,
                        ),
                      ),
                      const Text('4:20', style: TextStyle(fontSize: 12, color: _cardTextColor)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicList() {
    final List<Map<String, dynamic>> musicItems = [
      {'title': 'Chant de mariage traditionnel', 'author': 'Oumar Diakité'},
      {'title': 'Chant de mariage traditionnel', 'author': 'Oumar Diakité'},
      {'title': 'Chant de mariage traditionnel', 'author': 'Oumar Diakité'},
      {'title': 'Chant du griot familial', 'author': 'Niakalé Sidibé'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: musicItems.length,
      itemBuilder: (context, index) {
        return _buildMusicListItem(musicItems[index]);
      },
    );
  }

  Widget _buildMusicListItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Image/Thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: _searchBackground,
                image: const DecorationImage(
                  image: AssetImage('assets/images/music_thumb.jpg'), 
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 30),
              ),
            ),
            const SizedBox(width: 15),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _cardTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['author']!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            // Plus d'options
            const Icon(Icons.more_vert, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- Widgets pour la Modale 1 (Bottom Sheet) ---

  Widget _buildContentOptionButton(BuildContext context, String label, IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: _mainAccentColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: _mainAccentColor),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: _cardTextColor),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets de formulaire pour la Modale 2 (AlertDialog) ---

  Widget _buildTextField({required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildMultiLineField({required String hint}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        maxLines: 4,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildContentDropdown({required String initialValue}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: initialValue,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        ),
        items: <String>['Récit/ Conte', 'Musique/Chant', 'Artisanat/ Photo', 'Proverbe']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 14, color: _cardTextColor)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          // Logique de changement de type
        },
        icon: const Icon(Icons.keyboard_arrow_down, color: _mainAccentColor),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: 'Français',
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        ),
        items: <String>['Français', 'Bambara', 'Anglais']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(fontSize: 14, color: _cardTextColor)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          // Logique de changement de langue
        },
        icon: const Icon(Icons.keyboard_arrow_down, color: _mainAccentColor),
      ),
    );
  }

  Widget _buildMediaUploadField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ouvrir le sélecteur de fichier (utiliser file_picker)')),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Choisir un fichier', style: TextStyle(color: _mainAccentColor, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Aucun fichier choisi', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Images, audio ou vidéo (max 50 MB)',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTranslationSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _mainAccentColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.translate, color: _mainAccentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Traduction automatique',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 14),
                ),
                const Text(
                  'Activer la traduction pour rendre ce contenu accessible dans d\'autres langues',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique d'activation de la traduction
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _searchBackground,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            child: const Text('Traduire automatique', style: TextStyle(color: _cardTextColor, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}