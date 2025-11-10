import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

// Importations de vos fichiers locaux :
import 'package:heritage_numerique/screens/AppDrawer.dart';
import 'package:heritage_numerique/service/ArtisanatService.dart';
import 'package:heritage_numerique/model/ArtisanatModel.dart';
import 'package:heritage_numerique/screens/ArtisanatDetailsPage.dart';


// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _buttonColor = Color(0xFF7B521A);
const Color _lightCardColor = Color(0xFFF7F2E8);
const Color _tagArtisanatColor = Color(0xFFC0A272);
const Color _pendingColor = Colors.orange;
const Color _publishedColor = Colors.green;
const Color _rejectedColor = Color(0xFFD32F2E);

// ----------------------------------------------
// CLASSE WRAPPER : ArtisanatLabApp (Inchangé)
// ----------------------------------------------
class ArtisanatLabApp extends StatelessWidget {
  final int familyId;

  const ArtisanatLabApp({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artisanat ',
      home: ArtisanatLabPage(familyId: familyId),
    );
  }
}

// ----------------------------------------------
// CLASSE PRINCIPALE : ArtisanatLabPage (Inchangé)
// ----------------------------------------------
class ArtisanatLabPage extends StatefulWidget {
  final int familyId;

  const ArtisanatLabPage({super.key, required this.familyId});

  @override
  State<ArtisanatLabPage> createState() => _ArtisanatLabPageState();
}

class _ArtisanatLabPageState extends State<ArtisanatLabPage> {

  final ArtisanatService _artisanatService = ArtisanatService();
  late Future<List<Artisanat>> _artisanatFuture;

  @override
  void initState() {
    super.initState();
    _artisanatFuture = _fetchArtisanat();
  }

  Future<List<Artisanat>> _fetchArtisanat() async {
    try {
      return await _artisanatService.fetchArtisanatByFamilleId(
        familleId: widget.familyId,
      );
    } catch (e) {
      print("Erreur de chargement des contenus Artisanat: $e");
      return [];
    }
  }

  Future<void> _refreshContent() async {
    if (mounted) {
      setState(() {
        _artisanatFuture = _fetchArtisanat();
      });
    }
  }

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
          onContentCreated: _refreshContent,
        ),
      ),
    );
  }

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
                  'Artisanat Malien',
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
        childAspectRatio: 0.68,
      ),
      itemCount: artisanats.length,
      itemBuilder: (context, index) {
        return ContentContainer(
          artisanat: artisanats[index],
          artisanatService: _artisanatService,
          onActionComplete: _refreshContent,
        );
      },
    );
  }

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

// ----------------------------------------------------------------------------------
// FORMULAIRE DE CRÉATION DE CONTENU D'ARTISANAT (Inchangé)
// ----------------------------------------------------------------------------------
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
      setState(() => _errorMessage = 'Échec de la création: ${e.toString().replaceFirst('Exception: ', '')}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

// -------------------------------------------------------------
// WIDGET : ContentContainer (CORRIGÉ : Overflow, Taille Badge et Bouton)
// -------------------------------------------------------------
class ContentContainer extends StatefulWidget {
  final Artisanat artisanat;
  final ArtisanatService artisanatService;
  final VoidCallback onActionComplete;

  const ContentContainer({
    required this.artisanat,
    required this.artisanatService,
    required this.onActionComplete,
    super.key,
  });

  @override
  State<ContentContainer> createState() => _ContentContainerState();
}

class _ContentContainerState extends State<ContentContainer> {

  // Status que nous gérons LOCAUX (en priorité)
  late String _currentApiStatus;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    // Utilisation du statut du contenu comme base
    _currentApiStatus = widget.artisanat.statut.toUpperCase();
  }

  @override
  void didUpdateWidget(covariant ContentContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Réinitialisation de l'état local avec le statut de l'Artisanat (BROUILLON, PUBLIE)
    if (oldWidget.artisanat.statut != widget.artisanat.statut) {
      _currentApiStatus = widget.artisanat.statut.toUpperCase();
    }
  }


  Widget _buildInfoCard(IconData icon, String text, [Color? color]) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        margin: const EdgeInsets.only(right: 4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.0),
          border: Border.all(color: Colors.grey.shade300, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 10, color: color ?? Colors.blue),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 9, color: Colors.grey[800]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _requestPublication() async {
    if (!mounted) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      final responseMap = await widget.artisanatService.requestPublication(contenuId: widget.artisanat.id);
      final String newStatus = responseMap['newStatus'];

      if (mounted) {
        setState(() {
          _currentApiStatus = newStatus.toUpperCase();
          _isRequesting = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demande de publication réussie. Statut: $newStatus.'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      widget.onActionComplete();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la demande: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  // Logique de construction du badge (MODIFIÉ POUR ÊTRE PLUS PETIT)
  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'BROUILLON':
        color = Colors.grey;
        text = 'Brouillon';
        icon = Icons.edit;
        break;
      case 'EN_ATTENTE':
        color = _pendingColor;
        text = 'En Attente...';
        icon = Icons.schedule;
        break;
      case 'PUBLIE':
      case 'APPROUVEE':
        color = _publishedColor;
        text = 'Validé';
        icon = Icons.check_circle;
        break;
      case 'REJETEE':
        color = _rejectedColor;
        text = 'Rejeté';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.info;
        break;
    }

    return Container(
      // Réduction du padding
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Réduction de l'icône
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            // Réduction de la taille de police
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    String displayStatus = _currentApiStatus;

    final bool showPublicationButton = displayStatus == 'BROUILLON';


    final String imageUrl = (widget.artisanat.urlPhotos.isNotEmpty)
        ? widget.artisanat.urlPhotos.first
        : 'assets/images/Tapis.png';

    final String auteurInitiales = (widget.artisanat.prenomAuteur.isNotEmpty && widget.artisanat.nomAuteur.isNotEmpty)
        ? '${widget.artisanat.prenomAuteur[0]}${widget.artisanat.nomAuteur[0]}'
        : '??';

    final String auteurNomComplet = '${widget.artisanat.prenomAuteur} ${widget.artisanat.nomAuteur}';

    final dateDifference = DateTime.now().difference(widget.artisanat.dateCreation);
    String dateDisplay;
    if (dateDifference.inHours < 24) {
      dateDisplay = 'il y a ${dateDifference.inHours} h';
    } else {
      dateDisplay = 'il y a ${dateDifference.inDays} j';
    }


    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtisanatDetailPage(artisanat: widget.artisanat),
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
                      _buildInfoCard(Icons.place, widget.artisanat.region ?? 'Inconnu', Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Titre
                  Text(
                    widget.artisanat.titre,
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
                  const SizedBox(height: 8),

                  // Espace pour le badge ET le bouton (CORRIGÉ POUR ÉVITER L'OVERFLOW)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Badge de statut (toujours affiché)
                      _buildStatusBadge(displayStatus),

                      const Spacer(), // Ajout d'un Spacer pour prendre l'espace restant et repousser le bouton

                      // Bouton de publication (conditionnellement affiché UNIQUEMENT pour BROUILLON)
                      if (showPublicationButton)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ElevatedButton.icon(
                            onPressed: _isRequesting ? null : _requestPublication,
                            // Réduction de la taille de l'icône
                            icon: _isRequesting
                                ? const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1.5))
                                : const Icon(Icons.send, size: 10, color: Colors.white),
                            label: Text(
                                _isRequesting ? 'Envoi...' : 'Publier',
                                // Réduction de la taille de police
                                style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isRequesting ? Colors.blue.shade300 : Colors.blue.shade700,
                              // Réduction du padding
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              elevation: 0,
                              // Réduction de la taille minimale
                              minimumSize: const Size(60, 20),
                            ),
                          ),
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