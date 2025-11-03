import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

// Importations de vos fichiers locaux :
import 'package:heritage_numerique/screens/AppDrawer.dart';
import 'package:heritage_numerique/service/ArtisanatService.dart';
import 'package:heritage_numerique/model/ArtisanatModel.dart';

// 💡 Importation de la nouvelle page de détails
import 'package:heritage_numerique/screens/ArtisanatDetailsPage.dart';


// --- Constantes de Couleurs Globales (tirées de CulturalContentScreen) ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _buttonColor = Color(0xFF7B521A); // Couleur du bouton "Créer contenu"
const Color _lightCardColor = Color(0xFFF7F2E8);
const Color _tagArtisanatColor = Color(0xFFC0A272); // Couleur pour les tags

// ----------------------------------------------
// CLASSE WRAPPER : ArtisanatLabApp (Point d'entrée de navigation)
// ----------------------------------------------
class ArtisanatLabApp extends StatelessWidget {
  final int familyId;

  const ArtisanatLabApp({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artisanat Lab',
      home: ArtisanatLabPage(familyId: familyId),
    );
  }
}

// ----------------------------------------------
// CLASSE PRINCIPALE : ArtisanatLabPage (StatefulWidget)
// ----------------------------------------------
class ArtisanatLabPage extends StatefulWidget {
  final int familyId;

  const ArtisanatLabPage({super.key, required this.familyId});

  @override
  State<ArtisanatLabPage> createState() => _ArtisanatLabPageState();
}

class _ArtisanatLabPageState extends State<ArtisanatLabPage> {
  // 1. Initialisation du service et du Future
  final ArtisanatService _artisanatService = ArtisanatService();
  late Future<List<Artisanat>> _artisanatFuture;

  @override
  void initState() {
    super.initState();
    // 2. Charger les données au démarrage
    _artisanatFuture = _fetchArtisanat();
  }

  // 3. Méthode de récupération des données
  Future<List<Artisanat>> _fetchArtisanat() async {
    try {
      // NOTE: Le token d'auth est géré à l'intérieur du service via AuthService
      return await _artisanatService.fetchArtisanatByFamilleId(
        familleId: widget.familyId,
      );
    } catch (e) {
      // Gérer l'erreur de chargement ici (ex: afficher un message)
      print("Erreur de chargement des contenus Artisanat: $e");
      // Renvoie une liste vide pour éviter le crash
      return [];
    }
  }

  // 4. Fonction de rafraîchissement
  Future<void> _refreshContent() async {
    if (mounted) {
      setState(() {
        _artisanatFuture = _fetchArtisanat();
      });
    }
  }

  // Affichage du modal de création (Bouton "Créer contenu")
  void _showContentCreationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: _lightCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        content: _ArtisanatCreationForm(
          familyId: widget.familyId,
          onContentCreated: _refreshContent, // Lier au rafraîchissement
        ),
      ),
    );
  }

  // --- Méthodes de construction de l'UI ---

  Widget _buildCustomHeader(BuildContext context) {
    return Builder(
        builder: (BuildContext innerContext) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
                  onPressed: () => Scaffold.of(innerContext).openDrawer(),
                ),
                const Text(
                  'Artisanat Laba',
                  style: TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(width: 48),
              ],
            ),
          );
        }
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
        ElevatedButton.icon(
          onPressed: () => _showContentCreationModal(context),
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text('Créer contenu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
        const Spacer(),
        // Bouton de filtrage
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
              items: <String>['Tous types', 'Artisanat', 'Photos', 'Vidéo']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: _cardTextColor, fontSize: 14)),
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

  Widget _buildArtisanatGrid(List<Artisanat> artisanats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        // Ajustement du ratio pour laisser plus de place en hauteur (réduit le dépassement)
        childAspectRatio: 0.75,
      ),
      itemCount: artisanats.length,
      itemBuilder: (context, index) {
        return ContentContainer(
          artisanat: artisanats[index],
        );
      },
    );
  }

  // --- Méthode Build Principale ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: AppDrawer(familyId: widget.familyId),
      body: RefreshIndicator(
        onRefresh: _refreshContent,
        color: _mainAccentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomHeader(context),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 15),
                    _buildActionButtons(context),
                    const SizedBox(height: 20),

                    // Utilisation de FutureBuilder pour gérer l'état de chargement
                    FutureBuilder<List<Artisanat>>(
                      future: _artisanatFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Erreur de chargement: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30.0),
                              child: Text('Aucun contenu Artisanat trouvé pour cette famille.', style: TextStyle(color: _cardTextColor)),
                            ),
                          );
                        } else {
                          // Afficher la grille avec les données
                          return _buildArtisanatGrid(snapshot.data!);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---
// FORMULAIRE DE CRÉATION DE CONTENU D'ARTISANAT
// ---
class _ArtisanatCreationForm extends StatefulWidget {
  final int familyId;
  final VoidCallback onContentCreated;

  const _ArtisanatCreationForm({
    required this.familyId,
    required this.onContentCreated,
  });

  @override
  State<_ArtisanatCreationForm> createState() => __ArtisanatCreationFormState();
}

class __ArtisanatCreationFormState extends State<_ArtisanatCreationForm> {
  static const int MAX_PHOTO_SIZE_MB = 5;
  static const int MAX_FILE_SIZE_MB = 50;

  File? _selectedPhotoFile;
  File? _selectedContentFile;
  bool _isLoading = false;
  String? _errorMessage;

  final ArtisanatService _artisanatService = ArtisanatService();

  // Catégorie 2 par défaut comme demandé
  final int _defaultIdCategorie = 2;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _lieuController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _lieuController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  // --- Sélection de fichier (Réutilisée) ---
  Future<void> _pickFile({
    required String type,
    required List<String> allowedExtensions,
    required int maxSizeMB,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSizeMB = file.lengthSync() ~/ (1024 * 1024);

        if (fileSizeMB > maxSizeMB) {
          setState(() {
            _errorMessage = 'Fichier trop volumineux: ${fileSizeMB} Mo > $maxSizeMB Mo';
            if (type == 'photo') _selectedPhotoFile = null;
            else _selectedContentFile = null;
          });
          return;
        }

        setState(() {
          _errorMessage = null;
          if (type == 'photo') {
            _selectedPhotoFile = file;
          } else {
            _selectedContentFile = file;
          }
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur de sélection: $e');
    }
  }

  // --- Logique de Soumission (Intégration du service) ---
  Future<void> _submitArtisanat() async {
    if (_titleController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Le titre et la description sont obligatoires.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _artisanatService.createArtisanat(
        idFamille: widget.familyId,
        idCategorie: _defaultIdCategorie,
        titre: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        photoPath: _selectedPhotoFile?.path,
        videoPath: _selectedContentFile?.path,
        lieu: _lieuController.text.trim().isNotEmpty ? _lieuController.text.trim() : null,
        region: _regionController.text.trim().isNotEmpty ? _regionController.text.trim() : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onContentCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contenu Artisanat créé avec succès !'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      // Afficher l'erreur du service API
      setState(() => _errorMessage = 'Échec de la création: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Widgets Utilitaires pour le Formulaire ---
  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ${isRequired ? '*' : ''}', style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(String type, List<String> exts, int maxMB, File? file, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _pickFile(type: type, allowedExtensions: exts, maxSizeMB: maxMB),
              icon: Icon(icon, color: Colors.white),
              label: Text(
                file?.path.split('/').last ?? (type == 'photo' ? 'Choisir Photo' : 'Choisir Vidéo/Doc'),
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: file != null ? Colors.green.shade600 : _mainAccentColor,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          if (file != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: () => setState(() => type == 'photo' ? _selectedPhotoFile = null : _selectedContentFile = null),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ajouter un Contenu Artisanat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 30),

          _buildTextField(_titleController, 'Nom de l\'Artisanat', 'Ex: Bogolan Traditionnel', isRequired: true),
          _buildTextField(_descriptionController, 'Description courte', 'Résumé du produit/technique...', maxLines: 2, isRequired: true),
          _buildTextField(_contentController, 'Étapes de Fabrication / Détails', 'Détails des étapes de conception...', maxLines: 6),
          _buildTextField(_lieuController, 'Lieu de création', 'Ex: Village de Ségou'),
          _buildTextField(_regionController, 'Région', 'Ex: Mopti'),

          const SizedBox(height: 15),
          const Text('Photo Principale (max 5 Mo)', style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          _buildFilePicker(
            'photo',
            ['jpg', 'jpeg', 'png'],
            MAX_PHOTO_SIZE_MB,
            _selectedPhotoFile,
            Icons.image,
          ),

          const SizedBox(height: 15),
          const Text('Joindre Vidéo (max 50 Mo)', style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          _buildFilePicker(
            'fichier',
            ['mp4', 'mov'],
            MAX_FILE_SIZE_MB,
            _selectedContentFile,
            Icons.videocam,
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitArtisanat,
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Créer l\'Artisanat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),

          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: _cardTextColor))),
        ],
      ),
    );
  }
}

// ---
// WIDGET : ContentContainer (Carte d'artisanat DYNAMIQUE - CLICQUABLE)
// ---
class ContentContainer extends StatelessWidget {
  final Artisanat artisanat;
  const ContentContainer({required this.artisanat, super.key});

  Widget _buildInfoCard(IconData icon, String text, [Color? color]) {
    return Flexible( // Utilisation de Flexible pour éviter le dépassement horizontal
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        margin: const EdgeInsets.only(right: 4.0), // Marge entre les cards
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.grey.shade300, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 10, color: color ?? Colors.blue), // Icône plus petite
            const SizedBox(width: 2),
            Flexible( // Flexible pour le texte
              child: Text(
                text,
                style: TextStyle(fontSize: 9, color: Colors.grey[800]), // Texte plus petit
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // URL de l'image (prend la première photo ou utilise un placeholder)
    final String imageUrl = (artisanat.urlPhotos.isNotEmpty)
        ? artisanat.urlPhotos.first
        : 'assets/images/Tapis.png';

    final String auteurInitiales = (artisanat.prenomAuteur.isNotEmpty && artisanat.nomAuteur.isNotEmpty)
        ? '${artisanat.prenomAuteur[0]}${artisanat.nomAuteur[0]}'
        : '??';

    final String auteurNomComplet = '${artisanat.prenomAuteur} ${artisanat.nomAuteur}';

    // Pour la date
    final dateDifference = DateTime.now().difference(artisanat.dateCreation);
    String dateDisplay;
    if (dateDifference.inHours < 24) {
      dateDisplay = 'il y a ${dateDifference.inHours} h';
    } else {
      dateDisplay = 'il y a ${dateDifference.inDays} j';
    }

    return GestureDetector( // 💡 Rendre la carte cliquable
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtisanatDetailPage(artisanat: artisanat),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Photo
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: Image.asset('assets/images/Tapis.png', fit: BoxFit.cover),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(color: Colors.grey.shade200);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Ligne des deux petits cards blancs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _buildInfoCard(Icons.palette, 'Artisanat', Colors.blue),
                      _buildInfoCard(Icons.place, artisanat.region ?? 'Inconnu', Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Titre
                  Text(
                    artisanat.titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Auteur et date
                  Row(
                    children: <Widget>[
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: _buttonColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          auteurInitiales,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          auteurNomComplet,
                          style: const TextStyle(fontSize: 10, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateDisplay,
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
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
}