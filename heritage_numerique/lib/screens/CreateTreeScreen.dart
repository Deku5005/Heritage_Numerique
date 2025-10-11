import 'package:flutter/material.dart';
// Import pour la sélection de fichier
import 'package:file_picker/file_picker.dart'; 
// Importez l'AppDrawer
import 'AppDrawer.dart'; 

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311); 
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8); 
const Color _buttonColor = Color(0xFF7B521A); 
const Color _lightCardColor = Color(0xFFF7F2E8); 


class CreateTreeScreen extends StatefulWidget {
  const CreateTreeScreen({super.key});

  @override
  State<CreateTreeScreen> createState() => _CreateTreeScreenState();
}

class _CreateTreeScreenState extends State<CreateTreeScreen> {
  // --- Gestionnaires d'état pour les champs ---
  // Contrôleur pour afficher la date sélectionnée
  final TextEditingController _dateController = TextEditingController();
  
  // Variable pour stocker le nom du fichier sélectionné
  String _selectedFileName = 'Télécharger la photo'; 

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  // --- Fonctions d'interaction réelles ---

  // 1. Ouvrir le sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _mainAccentColor, // Couleur d'en-tête du sélecteur
            colorScheme: const ColorScheme.light(primary: _mainAccentColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Met à jour l'UI et le contrôleur de texte
      setState(() {
        _dateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  // 2. Ouvrir le sélecteur de fichier
  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Limiter aux images
      allowMultiple: false,
    );

    if (result != null) {
      // Met à jour l'UI pour afficher le nom du fichier
      setState(() {
        _selectedFileName = result.files.single.name;
        // Optionnel : stocker le chemin du fichier (result.files.single.path)
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo sélectionnée: $_selectedFileName')),
      );
    } else {
      // L'utilisateur a annulé la sélection
      // On peut laisser le nom inchangé ou le remettre à l'état initial.
      setState(() {
        _selectedFileName = 'Télécharger la photo';
      });
    }
  }


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
            // 1. En-tête (Menu Burger, Titre, Bouton Fermer)
            Builder(
              builder: (BuildContext innerContext) {
                return _buildCustomHeader(innerContext);
              }
            ), 
            const SizedBox(height: 20),

            // 2. Section du formulaire
            _buildFormSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Widgets de Construction ---

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
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titres
          const Text(
            'Créer l\'arbre généalogique',
            style: TextStyle(color: _cardTextColor, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Construisez votre arbre familial étape par étape en ajoutant les membres de votre famille',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 30),

          // Ligne 1: Nom Complet & Rôle
          Row(
            children: [
              Expanded(child: _buildInputField('Nom Complet', hint: 'Ex: Amadou Diakité')),
              const SizedBox(width: 15),
              Expanded(child: _buildRoleDropdown()),
            ],
          ),

          // Ligne 2: Date de Naissance & Lieu de Naissance
          Row(
            children: [
              // Champ Date de naissance (fonctionnel)
              Expanded(child: _buildDateInputField(context, label: 'Date de naissance', hint: 'jj/mm/aaaa')), 
              const SizedBox(width: 15),
              Expanded(child: _buildInputField('Lieu de naissance', hint: 'Ex: Bamako')),
            ],
          ),

          // Ligne 3: Relation Familiale
          _buildInputField('Relation familiale', hint: 'Ex: parent'),

          // Télécharger la photo (fonctionnel)
          const SizedBox(height: 10),
          _buildPhotoUploadButton(context), 
          const SizedBox(height: 20),

          // Ligne 4: Téléphone & Email
          Row(
            children: [
              Expanded(child: _buildInputField('Téléphone', hint: 'Ex: +223 XX XX XX XX')),
              const SizedBox(width: 15),
              Expanded(child: _buildInputField('Email', hint: 'Ex: eccoseg@gmail.com')),
            ],
          ),

          // Ligne 5: Bibliographie
          _buildBibliographyField('Bibliographie', hint: 'Parlez-nous un peu de cet membre...'),
          const SizedBox(height: 30),

          // Bouton Enregistrer
          Center(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Membre enregistré (logique de sauvegarde à implémenter)')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),

          // Section Membres Ajoutés
          _buildAddedMembersSection(),
        ],
      ),
    );
  }

  // --- Widgets de Formulaire (Adaptés au StatefulWidget) ---

  // Champ de texte standard
  Widget _buildInputField(String label, {required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _searchBackground,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.transparent),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // MODIFIÉ: Champ Date de Naissance (Utilise le sélecteur réel)
  Widget _buildDateInputField(BuildContext context, {required String label, required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: _searchBackground,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextFormField( 
              controller: _dateController, // Utilisez le contrôleur d'état
              readOnly: true, 
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                suffixIcon: const Icon(Icons.calendar_today, color: _mainAccentColor, size: 20),
              ),
              style: const TextStyle(fontSize: 14),
              onTap: () => _selectDate(context), // Appel de la fonction réelle de sélection de date
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le champ Rôle (Dropdown - inchangé)
  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rôle', style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _searchBackground,
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButtonFormField<String>(
              value: 'Membre',
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              ),
              items: <String>['Membre', 'Administrateur', 'Contributeur', 'Lecteur']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14, color: _cardTextColor)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                // Logique de changement de valeur
              },
              icon: const Icon(Icons.keyboard_arrow_down, color: _mainAccentColor),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le champ Bibliographie (multiligne - inchangé)
  Widget _buildBibliographyField(String label, {required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _searchBackground,
              borderRadius: BorderRadius.circular(5),
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
          ),
        ],
      ),
    );
  }

  // MODIFIÉ: Bouton de téléchargement de photo (Utilise le sélecteur réel)
  Widget _buildPhotoUploadButton(BuildContext context) {
    return Center(
      child: InkWell( 
        onTap: _selectFile, // Appel de la fonction réelle de sélection de fichier
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: _mainAccentColor.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.file_upload_outlined, color: _mainAccentColor),
              const SizedBox(width: 8),
              // Affiche le nom du fichier sélectionné
              Text(_selectedFileName, style: const TextStyle(color: _mainAccentColor, fontWeight: FontWeight.bold)), 
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour la section "Membres Ajoutés" (inchangé)
  Widget _buildAddedMembersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _lightCardColor, 
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Membres Ajoutés: 0',
            style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 16),
          ),
          const SizedBox(height: 15),
          Center(
            child: Column(
              children: [
                const Icon(Icons.people_alt_outlined, color: Colors.grey, size: 40),
                const SizedBox(height: 10),
                Text(
                  'Aucun membre ajouté pour le moment. \nCommencez par ajouter le premier membre de votre famille.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}