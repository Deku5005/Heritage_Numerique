import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// Importations dynamiques
import '../model/PrvebeModel.dart'; // Import corrigé
import '../service/ProverbeService.dart';
import 'AppDrawer.dart';
import 'ProverbeDetailsPage.dart';


// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311); // Jaune/Or
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _buttonColor = Color(0xFF7B521A);
const Color _lightCardColor = Color(0xFFF7F2E8);

// ----------------------------------------------
// CLASSE PRINCIPALE : Proverbes (StatefulWidget)
// ----------------------------------------------
class Proverbes extends StatefulWidget {
  final int familyId;

  const Proverbes({super.key, required this.familyId});

  @override
  State<Proverbes> createState() => _ProverbesState();
}

class _ProverbesState extends State<Proverbes> {
  // 1. Initialisation du service et du Future
  final ProverbeService _proverbeService = ProverbeService();
  late Future<List<Proverbe>> _proverbesFuture;

  // Gestion du filtre
  List<Proverbe> _allProverbes = [];
  List<Proverbe> _filteredProverbes = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _proverbesFuture = _fetchProverbes();
    _searchController.addListener(_filterProverbes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProverbes);
    _searchController.dispose();
    super.dispose();
  }

  // 2. Méthode de récupération des données
  Future<List<Proverbe>> _fetchProverbes() async {
    try {
      final List<Proverbe> fetchedProverbes = await _proverbeService.fetchProverbesByFamilleId(
        familleId: widget.familyId,
      );
      // Mettre à jour les listes locales après la récupération
      if(mounted) {
        setState(() {
          _allProverbes = fetchedProverbes;
          _filterProverbes(); // Initialise la liste filtrée
        });
      }
      return fetchedProverbes;
    } catch (e) {
      print("Erreur de chargement des proverbes: $e");
      return [];
    }
  }

  // 3. Fonction de rafraîchissement
  Future<void> _refreshContent() async {
    if (mounted) {
      setState(() {
        _proverbesFuture = _fetchProverbes();
      });
    }
  }

  // 4. Fonction de filtrage
  void _filterProverbes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProverbes = _allProverbes.where((proverbe) {
        // Recherche sur le proverbe lui-même et l'origine/titre
        return proverbe.proverbe.toLowerCase().contains(query) ||
            proverbe.origine.toLowerCase().contains(query) ||
            proverbe.titre.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Affichage du modal de création
  void _showCreationModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: _lightCardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        // Passer l'ID de la famille pour le POST
        content: _ProverbeCreationForm(
          familyId: widget.familyId,
          onProverbeCreated: _refreshContent, // Lier au rafraîchissement
        ),
      ),
    );
  }

  // --- Widget pour un seul Proverbe (Container) ---
  Widget _buildProverbeCard(BuildContext context, Proverbe proverbe) {
    void navigateToDetail() {
      // 💡 Navigation vers la page de détails avec l'objet Proverbe dynamique
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProverbeDetailPage(proverbe: proverbe),
        ),
      );
    }

    // 💡 Déterminer l'URL de l'image (si null, utiliser un placeholder)
    final String imageUrl = proverbe.urlPhoto ?? 'assets/images/placeholder.jpg';

    // isNetworkImage est vrai si une URL est présente ET qu'elle commence par http/https (Asset si non-null et local)
    // NOTE : Si proverbe.urlPhoto est null, imageUrl est l'asset, donc isNetworkImage est false.
    final bool isNetworkImage = imageUrl.startsWith('http');

    // 🔑 PRINT CRITIQUE POUR LE DIAGNOSTIC : AFFICHE L'URL EXACTE
    print("DEBUG URL utilisée: $imageUrl (Réseau: $isNetworkImage)");

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _lightCardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image à gauche (Network ou Asset)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isNetworkImage
                ? Image.network(
              imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              // 💡 AJOUT DU DÉBOGAGE ICI
              errorBuilder: (context, error, stackTrace) {
                print("ERREUR CARTE PROVERBE (URL: $imageUrl): $error");
                // Retourne un Asset en cas d'échec de chargement réseau
                return Image.asset(
                  'assets/images/placeholder.jpg',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                // Afficher un indicateur pendant le chargement réseau
                return Container(
                  width: 90, height: 90,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator(color: _mainAccentColor, strokeWidth: 2)),
                );
              },
            )
                : Image.asset(
              imageUrl, // Utilise l'asset si isNetworkImage est false (donc urlPhoto était null/vide)
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                  width: 90, height: 90, color: Colors.grey,
                  child: const Icon(Icons.image_not_supported, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 15),

          // 2. Texte et Bouton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Texte du Proverbe (le texte du proverbe lui-même)
                    Expanded(
                      child: Text(
                        '«${proverbe.proverbe}»',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _cardTextColor,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Bouton Détail (haut à droite)
                    InkWell(
                      onTap: navigateToDetail,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.more_vert, color: Colors.grey, size: 24),
                      ),
                    ),
                  ],
                ),

                // Trait noir et Origine Proverbe (en jaune)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                  child: Row(
                    children: [
                      // Trait
                      Container(
                        width: 30,
                        height: 1,
                        color: Colors.black,
                        margin: const EdgeInsets.only(right: 8),
                      ),
                      // Texte jaune (Origine)
                      Text(
                        proverbe.origine,
                        style: const TextStyle(
                          color: _mainAccentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Méthode Build Principale ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: AppDrawer(familyId: widget.familyId),
      body: RefreshIndicator(
        onRefresh: _refreshContent, // Permet le rafraîchissement manuel
        color: _mainAccentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Pour que RefreshIndicator fonctionne
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... Header et Search Bar (méthodes non modifiées)
              _buildCustomHeader(context),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'COLLECTION DES PROVERBES',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _cardTextColor),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Cliquez sur un proverbe pour découvrir sa sagesse',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 15),
                    _buildActionButtons(context),
                    const SizedBox(height: 20),

                    // 💡 Utilisation de FutureBuilder pour charger les données
                    FutureBuilder<List<Proverbe>>(
                      future: _proverbesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(color: _mainAccentColor),
                          ));
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Text('Erreur de chargement: ${snapshot.error.toString().split(':')[1]}', style: const TextStyle(color: Colors.red)),
                            ),
                          );
                        } else if (!snapshot.hasData || _filteredProverbes.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: Text(
                                  _searchController.text.isNotEmpty
                                      ? "Aucun proverbe ne correspond à votre recherche."
                                      : "Aucun proverbe trouvé pour cette famille.",
                                  style: const TextStyle(color: _cardTextColor)
                              ),
                            ),
                          );
                        } else {
                          // Afficher la liste filtrée
                          return Column(
                            children: _filteredProverbes.map((proverbe) {
                              return _buildProverbeCard(context, proverbe);
                            }).toList(),
                          );
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

  // Implémentation des autres méthodes (Header, SearchBar, ActionButtons) pour la complétude
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
                'Héritage Numérique',
                style: TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(width: 48),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: _searchBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () => _showCreationModal(context),
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text('Créer Proverbe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------
// FORMULAIRE DE CRÉATION DE PROVERBE (DYNAMIQUE)
// ----------------------------------------------
class _ProverbeCreationForm extends StatefulWidget {
  final VoidCallback onProverbeCreated;
  final int familyId;

  const _ProverbeCreationForm({required this.onProverbeCreated, required this.familyId});

  @override
  State<_ProverbeCreationForm> createState() => __ProverbeCreationFormState();
}

class __ProverbeCreationFormState extends State<_ProverbeCreationForm> {
  static const int MAX_PHOTO_SIZE_MB = 5;

  final ProverbeService _proverbeService = ProverbeService();
  // 💡 Catégorie par défaut corrigée
  final int _idCategorie = 4;

  File? _selectedPhotoFile;
  bool _isLoading = false;
  String? _errorMessage;

  // Contrôleurs pour les champs de proverbe
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _proverbeTextController = TextEditingController();
  final TextEditingController _significationController = TextEditingController();
  final TextEditingController _origineController = TextEditingController();
  final TextEditingController _lieuController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();


  @override
  void dispose() {
    _titreController.dispose();
    _proverbeTextController.dispose();
    _significationController.dispose();
    _origineController.dispose();
    _lieuController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  // --- Sélection de fichier ---
  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSizeMB = file.lengthSync() / (1024 * 1024);

        if (fileSizeMB > MAX_PHOTO_SIZE_MB) {
          setState(() {
            _errorMessage = 'Photo trop volumineuse: ${fileSizeMB.toStringAsFixed(1)} Mo > $MAX_PHOTO_SIZE_MB Mo';
            _selectedPhotoFile = null;
          });
          return;
        }

        setState(() {
          _errorMessage = null;
          _selectedPhotoFile = file;
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur de sélection de photo: $e');
    }
  }

  // --- Logique de Soumission (Utilisation du service) ---
  Future<void> _submitProverbe() async {
    // Validation des champs obligatoires (titre et texteProverbe)
    if (_titreController.text.trim().isEmpty ||
        _proverbeTextController.text.trim().isEmpty ||
        _significationController.text.trim().isEmpty ||
        _origineController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Tous les champs marqués d\'un * sont obligatoires.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _proverbeService.createProverbe(
        idFamille: widget.familyId,
        idCategorie: _idCategorie, // Utilise la catégorie = 4
        titre: _titreController.text.trim(),
        origineProverbe: _origineController.text.trim(),
        significationProverbe: _significationController.text.trim(),
        texteProverbe: _proverbeTextController.text.trim(),
        photoPath: _selectedPhotoFile?.path,
        lieu: _lieuController.text.trim().isNotEmpty ? _lieuController.text.trim() : null,
        region: _regionController.text.trim().isNotEmpty ? _regionController.text.trim() : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onProverbeCreated(); // Déclenche le rafraîchissement
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proverbe créé avec succès !'), backgroundColor: Colors.green),
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

  Widget _buildPhotoPicker() {
    final photoName = _selectedPhotoFile?.path.split('/').last ?? 'Aucune photo sélectionnée';

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Photo de Vignette (max 5 Mo)', style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: Text(
                    photoName,
                    style: const TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPhotoFile != null ? Colors.green.shade600 : _mainAccentColor,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              if (_selectedPhotoFile != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () => setState(() => _selectedPhotoFile = null),
                ),
            ],
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
            'Ajouter un Nouveau Proverbe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 30),

          _buildTextField(_titreController, 'Titre du Proverbe', 'Ex: Le Lion d\'Afrique', isRequired: true),
          _buildTextField(_proverbeTextController, 'Texte du Proverbe', 'Ex: Un vieillard assis voit mieux...', maxLines: 3, isRequired: true),
          _buildTextField(_significationController, 'Signification', 'Ex: Il faut écouter les vieux...', maxLines: 6, isRequired: true),
          _buildTextField(_origineController, 'Origine du Proverbe', 'Ex: Proverbe Maaien', isRequired: true),

          _buildTextField(_lieuController, 'Lieu', 'Ex: Mali'),
          _buildTextField(_regionController, 'Région', 'Ex: Ségou'),

          _buildPhotoPicker(), // Sélecteur d'image dynamique

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitProverbe,
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonColor,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Créer le Proverbe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),

          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: _cardTextColor))),
        ],
      ),
    );
  }
}
