import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
// 💡 Assurez-vous que l'importation suivante est correcte :
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

// 💡 NOUVELLES COULEURS POUR LES STATUTS
const Color _pendingColor = Colors.orange;
const Color _publishedColor = Colors.green;
const Color _rejectedColor = Color(0xFFD32F2E);


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

  // Filtrage (non implémenté, mais prêt pour les récits)
  // List<Recit> _allRecits = [];
  // List<Recit> _filteredRecits = [];
  // final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recitsFuture = _fetchRecits();
    // _searchController.addListener(_filterRecits);
  }

  // @override
  // void dispose() {
  //   _searchController.removeListener(_filterRecits);
  //   _searchController.dispose();
  //   super.dispose();
  // }

  Future<List<Recit>> _fetchRecits() async {
    if (widget.familyId == null) {
      throw Exception("L'ID de la famille est manquant. Impossible de charger les récits.");
    }
    // Mise à jour de la liste locale si vous ajoutez le filtrage
    return _recitService.fetchRecitsByFamilleId(familleId: widget.familyId!);
  }

  Future<void> _refreshRecits() async {
    if (mounted) {
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
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (BuildContext innerContext) {
                  return _buildCustomHeader(innerContext);
                },
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
                      style: TextStyle(color: Colors.grey, fontSize: 14),
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

  // --- Méthodes de Construction ---
  Widget _buildRecitsFutureBuilder() {
    return FutureBuilder<List<Recit>>(
      future: _recitsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: CircularProgressIndicator(color: _mainAccentColor),
            ),
          );
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
        // 💡 Utiliser le nouveau RecitCard
        return RecitCard(
          recit: recits[index],
          recitService: _recitService,
          onActionComplete: _refreshRecits,
        );
      },
    );
  }

  // NOTE: La méthode _buildRecitCard est supprimée d'ici et transformée en RecitCard StatefulWidget

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const Text(
            'Héritage Numérique',
            style: TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold, fontSize: 20),
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
        ElevatedButton.icon(
          onPressed: () => _showContentCreationModal(context),
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

      ],
    );
  }

  void _showRecitDetailsBottomSheet(BuildContext context, Recit recit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) => RecitDetailScreen(recit: recit),
    );
  }

  void _showContentCreationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: _lightCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        content: _ContentCreationForm(
          familyId: widget.familyId!,
          onContentCreated: _refreshRecits,
        ),
      ),
    );
  }
}


// -------------------------------------------------------------
// NOUVEAU WIDGET : RecitCard (Gestion du Statut et Action de Publication)
// -------------------------------------------------------------
class RecitCard extends StatefulWidget {
  final Recit recit;
  final RecitService recitService;
  final VoidCallback onActionComplete;

  const RecitCard({
    required this.recit,
    required this.recitService,
    required this.onActionComplete,
    super.key,
  });

  @override
  State<RecitCard> createState() => _RecitCardState();
}

class _RecitCardState extends State<RecitCard> {
  // Initialisation à 'BROUILLON' si le statut de l'API est null
  late String _currentApiStatus;
  bool _isRequesting = false;
  final String typeLabel = "Récit / Conte";
  final Color typeColor = _tagRecitColor;

  @override
  void initState() {
    super.initState();
    // Correction de la null safety: utilise 'BROUILLON' si statut est null
    _currentApiStatus = (widget.recit.statut ?? 'BROUILLON').toUpperCase();
  }

  @override
  void didUpdateWidget(covariant RecitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recit.statut != widget.recit.statut) {
      // Correction de la null safety
      _currentApiStatus = (widget.recit.statut ?? 'BROUILLON').toUpperCase();
    }
  }

  // --- Logique de la demande de publication ---
  void _requestPublication() async {
    if (!mounted || _isRequesting) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      // Appel du service de publication
      final responseMap = await widget.recitService.requestPublication(contenuId: widget.recit.id!);
      final String newStatus = responseMap['newStatus']; // Ex: EN_ATTENTE

      if (mounted) {
        setState(() {
          _currentApiStatus = newStatus.toUpperCase(); // MAJ immédiate du statut local
          _isRequesting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande de publication réussie. Statut: $newStatus.'),
            backgroundColor: Colors.green,
          ),
        );

        // Déclencher le rafraîchissement de la liste principale
        widget.onActionComplete();
      }

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

  // --- Affichage du Badge de Statut ---
  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;
    final String status = _currentApiStatus;

    switch (status) {
      case 'BROUILLON':
        color = Colors.grey.shade400;
        text = 'Brouillon';
        icon = Icons.edit;
        break;
      case 'EN_ATTENTE':
        color = _pendingColor;
        text = 'En Attente';
        icon = Icons.schedule;
        break;
      case 'PUBLIE':
        color = _publishedColor;
        text = 'Publié';
        icon = Icons.check_circle;
        break;
      case 'REJETE':
        color = _rejectedColor;
        text = 'Rejeté';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = 'Inconnu';
        icon = Icons.help_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Construction du Bouton d'Action ---
  Widget _buildActionButton() {
    // Si la demande est en cours, afficher le chargement
    if (_isRequesting) {
      return SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(color: _mainAccentColor, strokeWidth: 2)
      );
    }

    // Si c'est un brouillon, afficher le bouton de demande de publication
    if (_currentApiStatus == 'BROUILLON') {
      return ElevatedButton.icon(
        onPressed: _requestPublication,
        icon: const Icon(Icons.send, color: Colors.white, size: 12),
        label: const Text(
          'Publier',
          style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _mainAccentColor,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 0,
        ),
      );
    }

    // Sinon, retourner un widget vide
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    void navigateToDetail() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext sheetContext) => RecitDetailScreen(recit: widget.recit),
      );
    }

    final String imageUrl = widget.recit.urlPhoto;
    final bool hasImage = imageUrl.isNotEmpty;

    return InkWell(
      onTap: navigateToDetail,
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
                // Image/Placeholder
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: hasImage ? Colors.grey.shade300 : _searchBackground,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    image: hasImage
                        ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: !hasImage
                      ? Center(child: Icon(Icons.book, color: Colors.grey.shade500, size: 40))
                      : null,
                ),

                // Tag Type
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      typeLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Bouton Détail
                Positioned(
                  top: 5,
                  right: 5,
                  child: InkWell(
                    onTap: navigateToDetail,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(3.0),
                      child: Icon(Icons.more_vert, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),

            // Contenu Texte et Action
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.recit.titre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _cardTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Ligne Auteur et Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
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
                                    widget.recit.nomAuteur.isNotEmpty ? widget.recit.nomAuteur[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  '${widget.recit.prenomAuteur} ${widget.recit.nomAuteur}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Date
                        Text(
                          '${widget.recit.dateCreation.day}/${widget.recit.dateCreation.month}/${widget.recit.dateCreation.year}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),

                    // 💡 LIGNE STATUT ET BOUTON D'ACTION
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(),
                        _buildActionButton(),
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
}


// =====================================================================
// --- FORMULAIRE DE CRÉATION (_ContentCreationForm - Inchangé) ---
// =====================================================================
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
  static const int DEFAULT_CATEGORY_ID = 1;
  static const int MAX_PHOTO_SIZE_MB = 5;
  static const int MAX_FILE_SIZE_MB = 50;

  File? _selectedPhotoFile;
  File? _selectedContentFile;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _lieuController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  final RecitService _recitService = RecitService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    _lieuController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  // --- Sélection de fichier ---
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

  // --- Soumission ---
  Future<void> _submitConte() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Le titre est obligatoire.');
      return;
    }

    if (_contentController.text.trim().isEmpty && _selectedContentFile == null) {
      setState(() => _errorMessage = 'Veuillez écrire le texte OU joindre un fichier.');
      return;
    }

    final texteConte = _contentController.text.trim().isNotEmpty && _selectedContentFile == null
        ? _contentController.text.trim()
        : null;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _recitService.createConte(
        idFamille: widget.familyId,
        idCategorie: DEFAULT_CATEGORY_ID,
        titre: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        texteConte: texteConte,
        photoPath: _selectedPhotoFile?.path,
        fichierContePath: _selectedContentFile?.path,
        lieu: _lieuController.text.trim().isNotEmpty ? _lieuController.text.trim() : null,
        region: _regionController.text.trim().isNotEmpty ? _regionController.text.trim() : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onContentCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conte créé avec succès !'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Ajouter un Récit/Conte',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 30),

          _buildTextField(_titleController, 'Titre *', 'Ex: Le lièvre et la tortue'),
          _buildTextField(_descriptionController, 'Description (optionnel)', 'Résumé court...', maxLines: 2),
          _buildTextField(_lieuController, 'Lieu (optionnel)', 'Ex: Village de Siby'),
          _buildTextField(_regionController, 'Région (optionnel)', 'Ex: Koulikoro'),

          const SizedBox(height: 15),
          const Text('Photo (max 5 Mo)', style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          _buildFilePicker(
            'photo',
            ['jpg', 'jpeg', 'png'],
            MAX_PHOTO_SIZE_MB,
            _selectedPhotoFile,
            Icons.image,
          ),

          const SizedBox(height: 15),
          const Text('Texte du conte (ou fichier)', style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          _buildTextField(_contentController, 'Écrivez ici (si pas de fichier)', '', maxLines: 6),

          const SizedBox(height: 10),
          const Text('OU joindre un fichier (PDF, audio, max 50 Mo)', style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          _buildFilePicker(
            'fichier',
            ['txt', 'pdf', 'mp3', 'm4a', 'wav'],
            MAX_FILE_SIZE_MB,
            _selectedContentFile,
            Icons.attach_file,
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitConte,
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Créer le Conte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),

          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: _cardTextColor))),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
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
                file?.path.split('/').last ?? 'Choisir fichier',
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
}