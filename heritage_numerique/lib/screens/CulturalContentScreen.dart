import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// ⚠️ VÉRIFIEZ ET AJUSTEZ CES CHEMINS SI NÉCESSAIRE
import 'package:heritage_numerique/model/Recits_model.dart';
import '../service/RecitService.dart';
import 'AppDrawer.dart';
import 'RecitDetailScreen.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _buttonColor = Color(0xFF7B521A);
const Color _lightCardColor = Color(0xFFF7F2E8);
const Color _tagRecitColor = Color(0xFFC0A272);
// ... Les autres couleurs (Artisanat, Proverbe) si elles sont utilisées

// --- CulturalContentScreen : Widget d'État ---
class CulturalContentScreen extends StatefulWidget {
  final int? familyId;

  const CulturalContentScreen({super.key, required this.familyId});

  @override
  State<CulturalContentScreen> createState() => _CulturalContentScreenState();
}

class _CulturalContentScreenState extends State<CulturalContentScreen> {
  late Future<List<Recit>> _recitsFuture;
  final RecitService _recitService = RecitService();

  @override
  void initState() {
    super.initState();
    _recitsFuture = _fetchRecits();
  }

  Future<List<Recit>> _fetchRecits() async {
    if (widget.familyId == null) {
      throw Exception("L'ID de la famille est manquant. Impossible de charger les récits.");
    }
    return _recitService.fetchRecitsByFamilleId(familleId: widget.familyId!);
  }

  Future<void> _refreshRecits() async {
    if(mounted) {
      setState(() {
        _recitsFuture = _fetchRecits();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: AppDrawer(familyId: widget.familyId),
      body: RefreshIndicator(
        onRefresh: _refreshRecits,
        color: _mainAccentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      'Récits, musiques, artisanat et proverbes de votre famille',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildSearchBar(),
                    const SizedBox(height: 15),

                    _buildActionButtons(context),
                    const SizedBox(height: 20),

                    _buildRecitsFutureBuilder(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Méthodes de Construction (inchangées) ---

  Widget _buildRecitsFutureBuilder() {
    return FutureBuilder<List<Recit>>(
      future: _recitsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: CircularProgressIndicator(color: _mainAccentColor),
          ));
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Erreur de chargement des récits: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 50, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text(
                    'Aucun récit trouvé pour cette famille. Ajoutez-en un !',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        } else {
          final List<Recit> recits = snapshot.data!;
          return _buildContentGrid(recits);
        }
      },
    );
  }

  Widget _buildContentGrid(List<Recit> recits) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return _buildRecitCard(recits[index]);
      },
    );
  }

  Widget _buildRecitCard(Recit recit) {
    const Color typeColor = _tagRecitColor;
    const String typeLabel = "Récit / Conte";

    return InkWell(
      onTap: () {
        _showRecitDetailsBottomSheet(context, recit);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: recit.urlPhoto.isNotEmpty ? Colors.grey.shade300 : _searchBackground,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    image: recit.urlPhoto.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(recit.urlPhoto),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: recit.urlPhoto.isEmpty
                      ? Center(
                    child: Icon(Icons.book, color: Colors.grey.shade500, size: 40),
                  )
                      : null,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      typeLabel,
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),om),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Text(
                      'Langue',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recit.titre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _cardTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: _mainAccentColor.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              recit.nomAuteur.isNotEmpty ? recit.nomAuteur[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${recit.prenomAuteur} ${recit.nomAuteur}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${recit.dateCreation.day}/${recit.dateCreation.month}/${recit.dateCreation.year}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


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
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Bouton Ajouter un contenu
        ElevatedButton.icon(
          onPressed: () {
            // Utilisation d'un type par défaut dans la modale, car le sélecteur a été retiré
            _showContentCreationModal(context);
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


  // --- Logique des Modales ---

  void _showRecitDetailsBottomSheet(BuildContext context, Recit recit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return RecitDetailScreen(recit: recit);
      },
    );
  }

  // MODALE 2 : Formulaire de création de contenu
  void _showContentCreationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: _lightCardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          content: _ContentCreationForm(
            familyId: widget.familyId!,
            onContentCreated: _refreshRecits,
          ),
        );
      },
    );
  }

} // Fin de _CulturalContentScreenState

// --------------------------------------------------------------------
// --- WIDGET : _ContentCreationForm (Le formulaire d'ajout) ---
// --------------------------------------------------------------------

class _ContentCreationForm extends StatefulWidget {
  final int familyId;
  final VoidCallback onContentCreated;

  const _ContentCreationForm({
    required this.familyId,
    required this.onContentCreated,
  });

  @override
  State<_ContentCreationForm> createState() => _ContentCreationFormState();
}

class _ContentCreationFormState extends State<_ContentCreationForm> {
  // ⚠️ CATEGORIE FIXE : Utilisée par défaut pour la création de Conte/Récit.
  static const int DEFAULT_CATEGORY_ID = 1;

  File? _selectedPhotoFile; // photoPath (pour 'photoConte')
  File? _selectedContentFile; // fichierContePath (pour 'fichierConte')

  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController(); // Correspond à texteConte
  final TextEditingController _lieuController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  final RecitService _recitService = RecitService();

  final List<String> _availableLangs = ['Français', 'Bambara', 'Anglais'];
  String _selectedLanguageName = 'Français';

  static const int MAX_PHOTO_SIZE_MB = 5;
  static const int MAX_FILE_SIZE_MB = 50;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _lieuController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  // --- Logique de sélection de fichiers ---

  Future<void> _pickFile({
    required String type,
    required List<String> allowedExtensions,
    required int maxSizeMB,
  }) async {
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );
    } catch (e) {
      setState(() { _errorMessage = 'Erreur lors de la sélection du fichier: $e'; });
      return;
    }

    if (result != null) {
      final PlatformFile platformFile = result.files.first;
      final String? filePath = platformFile.path;

      if (filePath != null) {
        final File file = File(filePath);
        final int fileSizeMB = file.lengthSync() ~/ (1024 * 1024);

        if (fileSizeMB > maxSizeMB) {
          setState(() {
            _errorMessage = 'Le fichier dépasse la taille maximale de $maxSizeMB Mo. Taille actuelle : ${fileSizeMB} Mo.';
            if (type == 'photo') {
              _selectedPhotoFile = null;
            } else {
              _selectedContentFile = null;
            }
          });
          return;
        }

        print("Fichier choisi ($type): $filePath");

        setState(() {
          _errorMessage = null;
          if (type == 'photo') {
            _selectedPhotoFile = file;
          } else {
            _selectedContentFile = file;
          }
        });
      }
    }
  }


  // --- Logique de soumission ---

  Future<void> _submitConte() async {
    // 1. Validation minimale
    if (_titleController.text.isEmpty) {
      setState(() { _errorMessage = 'Veuillez remplir le **Titre** du contenu.'; });
      return;
    }

    // 2. Validation du contenu: doit avoir du texte OU un fichier.
    if (_contentController.text.isEmpty && _selectedContentFile == null) {
      setState(() { _errorMessage = 'Veuillez soit écrire le texte du conte, soit joindre un fichier de conte (texte, pdf, audio).'; });
      return;
    }

    // N'envoie texteConte QUE s'il est rempli ET si aucun fichier de contenu n'est joint (pour éviter les conflits)
    String? texteConteValue = _contentController.text.trim().isNotEmpty && _selectedContentFile == null
        ? _contentController.text.trim()
        : null;


    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 3. Appel du service (avec les deux chemins de fichiers potentiels)
      await _recitService.createConte(
        idFamille: widget.familyId,
        idCategorie: DEFAULT_CATEGORY_ID,
        titre: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        texteConte: texteConteValue,
        photoPath: _selectedPhotoFile?.path, // Chemin pour photoConte
        fichierContePath: _selectedContentFile?.path, // Chemin pour fichierConte
        lieu: _lieuController.text.trim().isNotEmpty ? _lieuController.text.trim() : null,
        region: _regionController.text.trim().isNotEmpty ? _regionController.text.trim() : null,
      );

      // 4. Succès
      if(mounted) {
        Navigator.of(context).pop();
        widget.onContentCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contenu créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      // 5. Échec: Afficher l'erreur
      print('Erreur de soumission du conte: $e');
      if(mounted) {
        setState(() {
          // Affiche le message d'erreur brut du serveur (très utile pour l'upload !)
          _errorMessage = e.toString().replaceFirst('Exception: ', 'Erreur du Serveur: ');
        });
      }
    } finally {
      // 6. Arrêter le chargement
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // --- Construction du Widget ---

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre de la modale
            const Text(
              'Ajouter un Récit/Conte',
              style: TextStyle(
                color: _cardTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 20),

            // Champ Titre
            _buildTextField(
              controller: _titleController,
              label: 'Titre du Conte *',
              hint: 'Ex: Le mythe du baobab',
            ),

            // Champ Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Courte Description (Optionnel)',
              hint: 'Une phrase résumant le conte...',
              maxLines: 2,
            ),

            // Champ Lieu
            _buildTextField(
              controller: _lieuController,
              label: 'Lieu de Provenance (Optionnel)',
              hint: 'Ex: Village de Fana',
            ),

            // Champ Région
            _buildTextField(
              controller: _regionController,
              label: 'Région (Optionnel)',
              hint: 'Ex: Koulikoro',
            ),

            // Sélecteur de Langue (Mocké)
            _buildDropdownField(
              label: 'Langue Principale * (Mocké)',
              value: _selectedLanguageName,
              items: _availableLangs,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() { _selectedLanguageName = newValue; });
                }
              },
            ),

            // --- Section Fichier Photo (photoConte) ---
            const SizedBox(height: 15),
            const Text('Photo d\'Illustration (Champ: photoConte)', style: TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold)),
            _buildFilePickerButton(
              label: 'Choisir Photo (Max ${MAX_PHOTO_SIZE_MB} Mo)',
              icon: Icons.image,
              file: _selectedPhotoFile,
              onPressed: () => _pickFile(
                type: 'photo',
                allowedExtensions: ['jpg', 'jpeg', 'png'],
                maxSizeMB: MAX_PHOTO_SIZE_MB,
              ),
              onClear: () => setState(() { _selectedPhotoFile = null; }),
            ),

            // --- Section Texte du Contenu (texteConte) ---
            _buildTextField(
              controller: _contentController,
              label: 'Texte du Conte (si pas de fichier joint)',
              hint: 'Écrivez votre récit...',
              maxLines: 5,
            ),

            // --- Section Fichier de Contenu (fichierConte) ---
            const SizedBox(height: 15),
            const Text(
              'Fichier du Conte (Audio/Texte, Champ: fichierConte)',
              style: TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold),
            ),
            _buildFilePickerButton(
              label: 'Choisir Fichier Audio/Texte (Max ${MAX_FILE_SIZE_MB} Mo)',
              icon: Icons.attach_file,
              file: _selectedContentFile,
              onPressed: () => _pickFile(
                type: 'contenu',
                allowedExtensions: ['txt', 'pdf', 'mp3', 'm4a', 'wav'],
                maxSizeMB: MAX_FILE_SIZE_MB,
              ),
              onClear: () => setState(() { _selectedContentFile = null; }),
            ),

            // Message d'erreur
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Color(0xFFC70039), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 20),

            // Bouton de Soumission
            ElevatedButton(
              onPressed: _isLoading ? null : _submitConte,
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                'Créer le Contenu',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            // Bouton Annuler
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: _cardTextColor)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets de formulaire réutilisables ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                icon: const Icon(Icons.keyboard_arrow_down, color: _mainAccentColor),
                style: const TextStyle(color: _cardTextColor, fontSize: 14),
                dropdownColor: Colors.white,
                items: items.map<DropdownMenuItem<String>>((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePickerButton({
    required String label,
    required IconData icon,
    required File? file,
    required VoidCallback onPressed,
    required VoidCallback onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: Colors.white),
              label: Text(
                file != null ? file.path.split('/').last : label,
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: file != null ? Colors.green.shade600 : _mainAccentColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          if (file != null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: onClear,
              ),
            ),
        ],
      ),
    );
  }
}