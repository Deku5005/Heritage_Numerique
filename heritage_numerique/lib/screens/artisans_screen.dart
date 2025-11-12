import 'package:flutter/material.dart';
import 'dart:async';

import '../widgets/bottom_navigation_widget.dart';
import 'Artisan_detail_screen.dart';
import '../model/artisanat1.dart';
import '../Service/Artisanatservice1.dart';

class ArtisansScreen extends StatefulWidget {
  const ArtisansScreen({super.key});

  @override
  State<ArtisansScreen> createState() => _ArtisansScreenState();
}

class _ArtisansScreenState extends State<ArtisansScreen> {
  // 1. Déclaration des dépendances et de l'état
  final ArtisanatService1 _artisanatService = ArtisanatService1();
  List<Artisanat1> _artisanats = [];
  bool _isLoading = true;
  String? _errorMessage;

  // URL DE BASE POUR LES IMAGES (Nécessaire pour les chemins relatifs)
  static const String _apiBaseUrlForImages = 'http://10.0.2.2:8080';

  // Couleurs statiques
  static const Color _accentColor = Color(0xFFD69301);
  static const Color _cardTextColor = Color(0xFF2E2E2E);

  @override
  void initState() {
    super.initState();
    _fetchArtisanats();
  }

  Future<void> _fetchArtisanats() async {
    try {
      final data = await _artisanatService.getArtisanats();
      setState(() {
        _artisanats = data;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les données: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Erreur de chargement des artisanats: $e');
    }
  }

  // 2. LOGIQUE POUR COMPLÉTER LES URLS RELATIVES
  String _getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    // Si l'URL est déjà complète (contient http), on la renvoie telle quelle.
    if (relativePath.toLowerCase().startsWith('http')) {
      return relativePath;
    }

    // Supprime le '/' initial si présent (pour éviter //)
    final String sanitizedPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;

    return '$_apiBaseUrlForImages/$sanitizedPath';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'artisans'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildCraftsGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Construction de l'en-tête (Méthode inchangée)
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image locale
                Image.asset(
                  'assets/images/mali_craftsman.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _accentColor.withOpacity(0.2),
                    child: const Center(child: Text('Artisanat', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.5)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    "L'artisanat Malien",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.8))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.9)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            centerTitle: true,
            title: const Text(
              'Artisanat',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Construction de la barre de recherche. (Méthode inchangée)
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: _accentColor),
          hintText: 'Rechercher des artisans',
          hintStyle: TextStyle(color: _cardTextColor.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }

  /// 3. Construction de la grille d'artisanat. (Mis à jour pour l'état et l'URL)
  Widget _buildCraftsGrid() {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(color: _accentColor),
      ));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            'Erreur de chargement: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_artisanats.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text('Aucun artisanat trouvé.', style: TextStyle(fontSize: 16, color: _cardTextColor)),
      ));
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _artisanats.length,
      // CHANGEMENT : childAspectRatio ajusté de 0.65 à 0.75
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75, // Ajusté pour le retrait des deux cartes
      ),
      itemBuilder: (context, index) {
        final artisanat = _artisanats[index];

        // --- CORRECTION NULL-SAFETY ---
        // Liste sécurisée (utilise une liste vide si urlPhotos est null)
        final List<String> safeUrlPhotos = artisanat.urlPhotos ?? [];

        // 1. Construction de l'URL principale
        final String primaryImagePath = safeUrlPhotos.isNotEmpty ? safeUrlPhotos.first : '';
        final String fullPrimaryImageUrl = _getFullImageUrl(primaryImagePath);

        // Les petites images ne sont plus nécessaires, mais on récupère l'URL complète
        // pour passer l'objet complet à l'écran de détail
        final List<String> smallImagePaths = safeUrlPhotos.skip(1).take(2).toList();
        final List<String> fullSmallImageUrls = smallImagePaths.map((path) => _getFullImageUrl(path)).toList();

        return _buildCraftCard(
          context,
          fullPrimaryImageUrl,
          artisanat.description ?? 'Description non disponible',
          artisanat.titre ?? 'Artisanat sans titre',
          // fullSmallImageUrls n'est plus utilisé par _buildCraftCard, mais on le garde en paramètre si besoin futur.
          fullSmallImageUrls,
          artisanat,
        );
      },
    );
  }

  /// 4. Construction d'une seule carte d'artisanat.
  Widget _buildCraftCard(
      BuildContext context,
      String primaryImageUrl,
      String description,
      String categoryTitle,
      List<String> smallImageUrls, // Reste pour la compatibilité, mais non utilisé
      Artisanat1 artisanat,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4.1. IMAGE PRINCIPALE
          Expanded(
            flex: 6,
            child: _buildPrimaryImage(primaryImageUrl, categoryTitle),
          ),

          // 4.2. DESCRIPTION
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Text(
              description,
              style: TextStyle(
                color: _cardTextColor.withOpacity(0.6),
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12), // Espacement ajusté

          // 4.3. BOUTON DÉCOUVRIR
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: _buildDiscoverButton(context, artisanat),
          ),
        ],
      ),
    );
  }

  /// Bouton DÉCOUVRIR pour la navigation.
  Widget _buildDiscoverButton(BuildContext context, Artisanat1 artisanat) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtisanDetailScreen(
              artisanData: artisanat,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.brush, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Découvrir l\'artisan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section d'image principale. (Utilise Image.network)
  Widget _buildPrimaryImage(String imageUrl, String categoryTitle) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Container(
        color: Colors.grey[300],
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty) // Charger l'image depuis l'URL
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: _accentColor,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.image_not_supported, size: 40, color: _cardTextColor.withOpacity(0.5)),
                ),
              )
            else // Afficher un placeholder si l'URL est vide
              Center(
                child: Icon(Icons.brush, size: 40, color: _cardTextColor.withOpacity(0.5)),
              ),
            // Tag "PRODUIT"
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  categoryTitle.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Les méthodes _buildSmallImageRow et _buildSmallImageCard ont été retirées.
}