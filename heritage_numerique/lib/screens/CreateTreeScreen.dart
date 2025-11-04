import 'package:flutter/material.dart';
// Import pour la sélection de fichier
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Importez l'AppDrawer
import 'AppDrawer.dart';
// Importez le service d'API
import '../service/ArbreGenealogiqueService.dart';


// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _buttonColor = Color(0xFF7B521A);
const Color _lightCardColor = Color(0xFFF7F2E8);


class CreateTreeScreen extends StatefulWidget {
  final int? familyId; // ID de la famille où ajouter le membre

  const CreateTreeScreen({super.key, required this.familyId});


  @override
  State<CreateTreeScreen> createState() => _CreateTreeScreenState();
}

class _CreateTreeScreenState extends State<CreateTreeScreen> {

  // 🔑 1. CONTROLLERS ET ÉTATS POUR LA COLLECTE DES DONNÉES
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _lieuNaissanceController = TextEditingController();
  final TextEditingController _relationFamilialeController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _biographieController = TextEditingController();

  String _selectedRole = 'Membre'; // Rôle par défaut
  String _selectedFileName = 'Télécharger la photo';
  String? _photoFilePath; // Chemin local du fichier à envoyer

  bool _isSaving = false; // État de chargement pour le bouton

  final ArbreGenealogiqueService _apiService = ArbreGenealogiqueService();
  DateTime? _selectedDate; // Stocke la date réelle


  @override
  void dispose() {
    _fullNameController.dispose();
    _dateController.dispose();
    _lieuNaissanceController.dispose();
    _relationFamilialeController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _biographieController.dispose();
    super.dispose();
  }

  // --- Fonctions d'interaction réelles ---

  // 1. Ouvrir le sélecteur de date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      setState(() {
        _selectedDate = pickedDate;
        // Met à jour l'UI et le contrôleur de texte
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  // 2. Ouvrir le sélecteur de fichier
  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Limiter aux images
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      // Met à jour l'UI pour afficher le nom du fichier
      setState(() {
        _selectedFileName = result.files.single.name;
        _photoFilePath = result.files.single.path; // 🔑 STOCKER LE CHEMIN POUR L'ENVOI API
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo sélectionnée: $_selectedFileName')),
      );
    } else {
      // L'utilisateur a annulé la sélection
      setState(() {
        _selectedFileName = 'Télécharger la photo';
        _photoFilePath = null;
      });
    }
  }

  // 🔑 2. LOGIQUE DE SOUMISSION DU FORMULAIRE ET APPEL API
  Future<void> _submitForm() async {
    // Vérifier la validation du formulaire et la sélection de date
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires (Nom, Date et Lieu).')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.familyId == null) {
        throw Exception("L'ID de famille n'est pas fourni.");
      }

      // Format de date requis par le backend (YYYY-MM-DD)
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      await _apiService.createMembre(
        idFamille: widget.familyId!, // ID de la famille injecté
        nomComplet: _fullNameController.text.trim(),
        dateNaissance: formattedDate,
        lieuNaissance: _lieuNaissanceController.text.trim(),
        relationFamiliale: _relationFamilialeController.text.trim().isEmpty
            ? _selectedRole
            : _relationFamilialeController.text.trim(),

        // Champs optionnels
        photoPath: _photoFilePath,
        telephone: _telephoneController.text.trim().isNotEmpty ? _telephoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        biographie: _biographieController.text.trim().isNotEmpty ? _biographieController.text.trim() : null,
      );

      // Succès: afficher SnackBar et retourner true pour rafraîchir l'arbre
      _showSnackBar('Membre ${_fullNameController.text} ajouté avec succès !', Colors.green);
      // 🔑 SIGNALER À L'ÉCRAN PRÉCÉDENT DE RAFRAÎCHIR
      Navigator.of(context).pop(true);

    } catch (e) {
      _showSnackBar('Erreur lors de l\'ajout du membre: ${e.toString()}', Colors.red);
      debugPrint('Erreur d\'ajout membre: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: AppDrawer(familyId: widget.familyId),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
                builder: (BuildContext innerContext) {
                  return _buildCustomHeader(innerContext);
                }
            ),
            const SizedBox(height: 20),
            // 🔑 Enveloppement dans un Form
            Form(
              key: _formKey,
              child: _buildFormSection(context),
            ),
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
            'Ajouter un Membre', // Titre mis à jour pour la clarté
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            onPressed: () => Navigator.pop(context, false), // Retourne false si l'on ferme
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
            'Ajouter un Nouveau Membre',
            style: TextStyle(color: _cardTextColor, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'Les champs marqués d\'un (*) sont obligatoires.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 30),

          // Ligne 1: Nom Complet (*) & Rôle
          Row(
            children: [
              Expanded(child: _buildInputField('Nom Complet (*)', controller: _fullNameController, hint: 'Ex: Amadou Diakité', isRequired: true)),
              const SizedBox(width: 15),
              Expanded(child: _buildRoleDropdown()),
            ],
          ),

          // Ligne 2: Date de Naissance (*) & Lieu de Naissance (*)
          Row(
            children: [
              // Champ Date de naissance (fonctionnel)
              Expanded(child: _buildDateInputField(context, label: 'Date de naissance (*)', hint: 'jj/mm/aaaa')),
              const SizedBox(width: 15),
              Expanded(child: _buildInputField('Lieu de naissance (*)', controller: _lieuNaissanceController, hint: 'Ex: Bamako', isRequired: true)),
            ],
          ),

          // Ligne 3: Relation Familiale
          _buildInputField('Relation familiale', controller: _relationFamilialeController, hint: 'Ex: Mère, Fils, Épouse...'),

          // Télécharger la photo (fonctionnel)
          const SizedBox(height: 10),
          _buildPhotoUploadButton(context),
          const SizedBox(height: 20),

          // Ligne 4: Téléphone & Email
          Row(
            children: [
              Expanded(child: _buildInputField('Téléphone', controller: _telephoneController, hint: 'Ex: +223 XX XX XX XX', keyboardType: TextInputType.phone)),
              const SizedBox(width: 15),
              Expanded(child: _buildInputField('Email', controller: _emailController, hint: 'Ex: eccoseg@gmail.com', keyboardType: TextInputType.emailAddress)),
            ],
          ),

          // Ligne 5: Bibliographie
          _buildBibliographyField('Biographie', controller: _biographieController, hint: 'Parlez-nous un peu de cet membre...'),
          const SizedBox(height: 30),

          // Bouton Enregistrer
          Center(
            child: ElevatedButton(
              // 🔑 Appel de la fonction de soumission
              onPressed: _isSaving ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: _isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Enregistrer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),

          // Section Membres Ajoutés
          _buildAddedMembersSection(),
        ],
      ),
    );
  }

  // --- Widgets de Formulaire (Mis à jour pour Form/Validation et Controllers) ---

  // Champ de texte standard avec controller et validation
  Widget _buildInputField(String label, {required TextEditingController controller, required String hint, bool isRequired = false, TextInputType keyboardType = TextInputType.text}) {
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
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return 'Ce champ est obligatoire.';
                }
                return null;
              },
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

  // Champ Date de Naissance
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
              controller: _dateController,
              readOnly: true,
              validator: (value) {
                if (_selectedDate == null) {
                  return 'Veuillez sélectionner une date.';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                suffixIcon: const Icon(Icons.calendar_today, color: _mainAccentColor, size: 20),
              ),
              style: const TextStyle(fontSize: 14),
              onTap: () => _selectDate(context),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le champ Rôle (Dropdown)
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
              value: _selectedRole,
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
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
              icon: const Icon(Icons.keyboard_arrow_down, color: _mainAccentColor),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le champ Bibliographie (multiligne)
  Widget _buildBibliographyField(String label, {required TextEditingController controller, required String hint}) {
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
              controller: controller,
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

  // Bouton de téléchargement de photo
  Widget _buildPhotoUploadButton(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: _isSaving ? null : _selectFile,
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
              Text(_selectedFileName, style: const TextStyle(color: _mainAccentColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // Section Membres Ajoutés
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