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
  static const String _apiBaseUrlForImages = 'http://192.168.43.22:8080';

  // Couleurs statiques
  static const Color _accentColor = Color(0xFFD69301); // Ocre
  static const Color _cardTextColor = Color(0xFF2E2E2E); // Gris foncé
  static const Color _modernBackground = Color(0xFFF9F9F9); // Fond très clair

  @override
  void initState() {
    super.initState();
    _fetchArtisanats();
  }

  Future<void> _fetchArtisanats() async {
    try {
      // Simulation d'un délai pour voir le chargement (optionnel)
      await Future.delayed(const Duration(milliseconds: 500));
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
    if (relativePath.toLowerCase().startsWith('http')) {
      return relativePath;
    }

    final String sanitizedPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return '$_apiBaseUrlForImages/$sanitizedPath';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _modernBackground, // Utilisation du fond clair moderne
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'artisans'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0), // Padding légèrement augmenté
              child: Column(
                children: [
                  const SizedBox(height: 25), // Espacement augmenté
                  _buildSearchBar(),
                  const SizedBox(height: 25), // Espacement augmenté
                  _buildCraftsGrid(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Construction de l'en-tête (Mis à jour pour une meilleure lisibilité)
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 280, // Hauteur augmentée
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)), // Rayon augmenté
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image locale
                Image.asset(
                  'assets/images/artisanat.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _accentColor.withOpacity(0.2),
                    child: const Center(child: Text('Artisanat', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold))), // Taille augmentée
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.6)], // Opacité ajustée
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30, // Position ajustée
                  left: 20,
                  child: Text(
                    "L'artisanat Malien",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32, // Taille augmentée
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.9))],
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
                  color: Colors.black.withOpacity(0.3), // Fond plus opaque
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(1)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            centerTitle: true,
            title: const Text(
              'Artisanat',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Construction de la barre de recherche. (Taille et style ajustés)
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25), // Rayon augmenté
        border: Border.all(color: _accentColor.withOpacity(0.5), width: 1.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: TextField(
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: _accentColor, size: 24),
          hintText: 'Rechercher des artisans ou des produits...',
          hintStyle: TextStyle(color: _cardTextColor.withOpacity(0.7), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        ),
      ),
    );
  }

  /// 3. Construction de la grille d'artisanat.
  Widget _buildCraftsGrid() {
    // ... (Logique de chargement et d'erreur inchangée)
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
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ),
      );
    }

    if (_artisanats.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text('Aucun artisanat trouvé.', style: TextStyle(fontSize: 18, color: _cardTextColor)),
      ));
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _artisanats.length,
      // Ratio ajusté pour le nouveau design
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16, // Espacement augmenté
        mainAxisSpacing: 16, // Espacement augmenté
        childAspectRatio: 0.72, // Ratio légèrement réduit pour le contenu
      ),
      itemBuilder: (context, index) {
        final artisanat = _artisanats[index];
        final List<String> safeUrlPhotos = artisanat.urlPhotos ?? [];
        final String primaryImagePath = safeUrlPhotos.isNotEmpty ? safeUrlPhotos.first : '';
        final String fullPrimaryImageUrl = _getFullImageUrl(primaryImagePath);

        // Les URLs de petites images sont toujours calculées mais non utilisées dans la carte
        final List<String> smallImagePaths = safeUrlPhotos.skip(1).take(2).toList();
        final List<String> fullSmallImageUrls = smallImagePaths.map((path) => _getFullImageUrl(path)).toList();

        return _buildCraftCard(
          context,
          fullPrimaryImageUrl,
          artisanat.description ?? 'Description non disponible',
          artisanat.titre ?? 'Artisanat sans titre',
          fullSmallImageUrls,
          artisanat,
        );
      },
    );
  }

  /// 4. Construction d'une seule carte d'artisanat (VERSION MODERNE).
  Widget _buildCraftCard(
      BuildContext context,
      String primaryImageUrl,
      String description,
      String categoryTitle,
      List<String> smallImageUrls,
      Artisanat1 artisanat,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Rayon augmenté
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08), // Ombre plus douce
              blurRadius: 10,
              offset: const Offset(0, 5)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4.1. IMAGE PRINCIPALE (Flex: 6)
          Expanded(
            flex: 6,
            child: _buildPrimaryImage(primaryImageUrl, categoryTitle),
          ),

          // 4.2. DESCRIPTION ET TITRE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITRE DU PRODUIT
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    color: _cardTextColor,
                    fontSize: 16, // Taille augmentée
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // DESCRIPTION
                Text(
                  description,
                  style: TextStyle(
                    color: _cardTextColor.withOpacity(0.7),
                    fontSize: 12, // Taille augmentée
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),

          // 4.3. BOUTON DÉCOUVRIR (Flex: 1)
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            child: _buildDiscoverButton(context, artisanat),
          ),
        ],
      ),
    );
  }

  /// Bouton DÉCOUVRIR (Modernisé).
  Widget _buildDiscoverButton(BuildContext context, Artisanat1 artisanat) {
    return InkWell( // Remplacer GestureDetector par InkWell pour un effet de ripple visuel
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
        padding: const EdgeInsets.symmetric(vertical: 10), // Padding augmenté
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(15), // Rayon plus grand
          boxShadow: [
            BoxShadow(
              color: _accentColor.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Voir l\'artisan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13, // Taille ajustée
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section d'image principale. (Style de tag modernisé)
  Widget _buildPrimaryImage(String imageUrl, String categoryTitle) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), // Rayon correspondant au conteneur
      child: Container(
        color: Colors.grey[300],
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
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
                  child: Icon(Icons.image_not_supported, size: 48, color: _cardTextColor.withOpacity(0.5)),
                ),
              )
            else
              Center(
                child: Icon(Icons.brush, size: 48, color: _cardTextColor.withOpacity(0.5)),
              ),
            // Tag "PRODUIT" (Modernisé en forme de badge)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Fond blanc semi-transparent
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _accentColor.withOpacity(0.5), width: 1),
                ),
                child: Text(
                  categoryTitle.toUpperCase(),
                  style: TextStyle(color: _accentColor, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}