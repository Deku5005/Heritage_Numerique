import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../model/FamilleModel.dart';
import 'AppDrawer.dart';
import '../service/ArbreGenealogiqueService.dart';
import '../model/Membre.dart';

import 'package:intl/intl.dart';


// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _buttonColor = Color(0xFF7B521A);
const Color _lightCardColor = Color(0xFFF7F2E8);

// 🔑 Membre factice pour le cas "Non Spécifié / Aucun"
final Membre _noneMemberPlaceholder = Membre(
  id: 0,
  nomComplet: 'Non Spécifié / Aucun',
  dateNaissance: '2000-01-01',
  lieuNaissance: 'N/A',
  relationFamiliale: 'Placeholder',
  idFamille: 0,
  nomFamille: 'N/A',
  dateCreation: '2000-01-01',
);


class CreateTreeScreen extends StatefulWidget {
  final int? familyId;
  final int? parentId; // ID du parent injecté depuis FamilyTreeScreen

  const CreateTreeScreen({super.key, required this.familyId, this.parentId});

  @override
  State<CreateTreeScreen> createState() => _CreateTreeScreenState();
}

class _CreateTreeScreenState extends State<CreateTreeScreen> {

  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de champs de texte
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _lieuNaissanceController = TextEditingController();
  final TextEditingController _relationFamilialeController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _biographieController = TextEditingController();

  // 🔑 Variables d'état pour le sélecteur de Membres
  List<Membre> _allMembres = [];
  Membre? _selectedParent1; // Objet Membre sélectionné
  Membre? _selectedParent2; // Objet Membre sélectionné
  bool _isLoadingMembres = true;

  String _selectedRole = 'Membre';
  String _selectedFileName = 'Télécharger la photo';
  String? _photoFilePath;

  bool _isSaving = false;

  final ArbreGenealogiqueService _apiService = ArbreGenealogiqueService();
  DateTime? _selectedDate;


  @override
  void initState() {
    super.initState();
    _fetchMembresList(); // 🔑 Chargement des membres au démarrage
  }

  // 🔑 FONCTION: Récupérer la liste de tous les membres via fetchFamille
  Future<void> _fetchMembresList() async {
    if (widget.familyId == null) {
      setState(() {
        _isLoadingMembres = false;
      });
      return;
    }
    try {
      // 🔑 1. Appel à fetchFamille pour obtenir l'objet Famille
      final Famille famille = await _apiService.fetchFamille(familleId: widget.familyId!);

      // 🔑 2. Extraction de la liste des Membres (confirmé par le modèle Famille)
      final List<Membre> membres = famille.membres;

      // Ajout du placeholder 'Non Spécifié'
      membres.insert(0, _noneMemberPlaceholder);

      Membre? initialParent1;

      // Gérer l'ID de parent injecté (pré-sélection)
      if (widget.parentId != null) {
        initialParent1 = membres.firstWhere(
              (m) => m.id == widget.parentId,
          orElse: () => _noneMemberPlaceholder,
        );
      }

      setState(() {
        _allMembres = membres; // La liste complète est stockée
        _isLoadingMembres = false;
        // Définir la sélection initiale
        _selectedParent1 = initialParent1 ?? _noneMemberPlaceholder;
        _selectedParent2 = _noneMemberPlaceholder;
      });
    } catch (e) {
      debugPrint('Erreur de chargement des membres via Famille: $e');
      setState(() {
        _isLoadingMembres = false;
        _allMembres = [_noneMemberPlaceholder];
        _selectedParent1 = _noneMemberPlaceholder;
        _selectedParent2 = _noneMemberPlaceholder;
        _showSnackBar('Erreur lors du chargement des membres existants.', Colors.red);
      });
    }
  }


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

  // --- Fonctions d'interaction ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: _mainAccentColor,
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
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _photoFilePath = result.files.single.path;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo sélectionnée: $_selectedFileName')),
      );
    } else {
      setState(() {
        _selectedFileName = 'Télécharger la photo';
        _photoFilePath = null;
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

  // 🔑 LOGIQUE DE SOUMISSION utilisant les IDs des objets Membre sélectionnés
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      _showSnackBar('Veuillez remplir tous les champs obligatoires (Nom, Date et Lieu).', Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (widget.familyId == null) {
        throw Exception("L'ID de famille n'est pas fourni.");
      }

      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      // 🔑 Conversion de l'objet Membre sélectionné en ID (null si placeholder id=0)
      final int? parent1Id = _selectedParent1 != null && _selectedParent1!.id != 0 ? _selectedParent1!.id : null;
      final int? parent2Id = _selectedParent2 != null && _selectedParent2!.id != 0 ? _selectedParent2!.id : null;


      await _apiService.createMembre(
        idFamille: widget.familyId!,
        nomComplet: _fullNameController.text.trim(),
        dateNaissance: formattedDate,
        lieuNaissance: _lieuNaissanceController.text.trim(),
        relationFamiliale: _relationFamilialeController.text.trim().isEmpty
            ? _selectedRole
            : _relationFamilialeController.text.trim(),

        parent1Id: parent1Id,
        parent2Id: parent2Id,

        photoPath: _photoFilePath,
        telephone: _telephoneController.text.trim().isNotEmpty ? _telephoneController.text.trim() : null,
        email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
        biographie: _biographieController.text.trim().isNotEmpty ? _biographieController.text.trim() : null,
      );

      _showSnackBar('Membre ${_fullNameController.text} ajouté avec succès !', Colors.green);
      // Retourne 'true' pour indiquer à l'écran précédent de rafraîchir
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
            'Ajouter un Membre',
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            onPressed: () => Navigator.pop(context, false),
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
              Expanded(child: _buildDateInputField(context, label: 'Date de naissance (*)', hint: 'jj/mm/aaaa')),
              const SizedBox(width: 15),
              Expanded(child: _buildInputField('Lieu de naissance (*)', controller: _lieuNaissanceController, hint: 'Ex: Bamako', isRequired: true)),
            ],
          ),

          // Ligne 3: Relation Familiale
          _buildInputField('Relation familiale', controller: _relationFamilialeController, hint: 'Ex: Mère, Fils, Épouse...'),

          // 🔑 SÉLECTEUR DE MEMBRES POUR PARENTS
          const SizedBox(height: 20),
          const Text(
            'Sélection des parents (si applicable)',
            style: TextStyle(color: _cardTextColor, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 🔑 Parent 1 (Père ou Partenaire)
              Expanded(child: _buildParentSelector(
                label: 'Parent 1 (Père/Partenaire)',
                selectedMember: _selectedParent1,
                // Le parent 1 est désactivé s'il a été injecté
                isDisabled: widget.parentId != null && _selectedParent1 != _noneMemberPlaceholder,
                onChanged: (Membre? newValue) {
                  setState(() {
                    _selectedParent1 = newValue;
                  });
                },
              )),
              const SizedBox(width: 15),
              // 🔑 Parent 2 (Mère ou Partenaire)
              Expanded(child: _buildParentSelector(
                label: 'Parent 2 (Mère/Partenaire)',
                selectedMember: _selectedParent2,
                onChanged: (Membre? newValue) {
                  setState(() {
                    _selectedParent2 = newValue;
                  });
                },
              )),
            ],
          ),
          // Note pour l'ID pré-rempli
          if (widget.parentId != null)
            Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
              child: Text('Note: Le Parent 1 est automatiquement sélectionné (ID: ${widget.parentId}).',
                style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
              ),
            ),
          const SizedBox(height: 10),

          // Télécharger la photo
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
              onPressed: (_isSaving || _isLoadingMembres) ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              child: (_isSaving || _isLoadingMembres)
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

  // 🔑 WIDGET SÉLECTEUR DE MEMBRE (DROPDOWN)
  Widget _buildParentSelector({
    required String label,
    required Membre? selectedMember,
    required ValueChanged<Membre?> onChanged,
    bool isDisabled = false,
  }) {
    // Affichage de chargement
    if (_isLoadingMembres) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
            const SizedBox(height: 5),
            Container(
              height: 48,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _searchBackground, borderRadius: BorderRadius.circular(5)),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: _mainAccentColor, strokeWidth: 2),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Affichage du sélecteur
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
              color: isDisabled ? _searchBackground.withOpacity(0.5) : _searchBackground,
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButtonFormField<Membre>(
              value: selectedMember,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
              ),
              onChanged: isDisabled ? null : onChanged, // Désactivé si `isDisabled` est true

              items: _allMembres.map<DropdownMenuItem<Membre>>((Membre member) {
                // Afficher le nom et l'ID
                final display = member.id == 0 ? member.nomComplet : '${member.nomComplet} (ID: ${member.id})';
                return DropdownMenuItem<Membre>(
                  value: member,
                  child: Text(
                      display,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDisabled ? Colors.grey : _cardTextColor,
                      ),
                      overflow: TextOverflow.ellipsis
                  ),
                );
              }).toList(),
              icon: Icon(Icons.keyboard_arrow_down, color: isDisabled ? Colors.grey : _mainAccentColor),
              style: TextStyle(color: isDisabled ? Colors.grey : _cardTextColor),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET D'INPUT FIELD
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