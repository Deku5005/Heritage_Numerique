import 'package:flutter/material.dart';
import 'dart:async';
// Assurez-vous d'avoir ajouté cette dépendance dans pubspec.yaml
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// Imports de vos fichiers (vérifiez les chemins)
import '../model/conte.dart';
import '../Service/conteService.dart'; // VÉRIFIEZ LE CHEMIN
import '../widgets/bottom_navigation_widget.dart';
import 'affichage_contes_screen.dart'; // Écran de destination
import '../config/api_config.dart';

/// Écran affichant la liste des contes.
class ContesScreen extends StatefulWidget {
  const ContesScreen({super.key});

  @override
  State<ContesScreen> createState() => _ContesScreenState();
}

class _ContesScreenState extends State<ContesScreen> {

  final ConteService _conteService = ConteService();
  late Future<List<Conte>> _contesFuture;

  // Constantes de style
  static const Color _accentColor = Color(0xFFD69301); // Or foncé/brun doré
  static const Color _secondaryColor = Color(0xFF9F9646); // Vert olive
  static const Color _cardTextColor = Color(0xFF2E2E2E);
  static const Color _backgroundColor = Colors.white;

  // URL DE BASE POUR LES IMAGES (centralisée via ApiConfig)
  static String get _apiBaseUrlForImages => ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _contesFuture = _conteService.getContes();
  }

  // ----------------------------------------------------
  // --- MÉTHODE DE CONSTRUCTION PRINCIPALE ---
  // ----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // BottomNavigationBar réactivée
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'contes'),
      body: CustomScrollView(
        slivers: [
          _buildModernHeader(),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildSearchBar(),
                  const SizedBox(height: 25),
                  const Text(
                    'Découvrez nos Récits',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _cardTextColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            sliver: _buildContesFutureBuilder(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // --- WIDGETS D'INTERFACE ---
  // ----------------------------------------------------

  Widget _buildModernHeader() {
    return SliverAppBar(
      backgroundColor: _backgroundColor,
      expandedHeight: 150.0,
      floating: true,
      pinned: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 12),
        title: Text(
          'Contes Traditionnels',
          style: TextStyle(
            color: _cardTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _accentColor.withOpacity(0.1),
                _backgroundColor
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
              child: Icon(
                  Icons.format_quote_rounded,
                  size: 50,
                  color: _accentColor.withOpacity(0.3)
              )
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ]
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un titre, un auteur...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          suffixIcon: Icon(Icons.search, color: _secondaryColor),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // --- LOGIQUE DE CHARGEMENT API ET GRILLE ---
  // ----------------------------------------------------

  Widget _buildContesFutureBuilder(BuildContext context) {
    return FutureBuilder<List<Conte>>(
      future: _contesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Erreur FutureBuilder: ${snapshot.error}');
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  '⚠️ Erreur de chargement des contes. Veuillez vérifier votre connexion ou l\'adresse du serveur.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: CircularProgressIndicator(color: _accentColor),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          final List<Conte> contes = snapshot.data!;
          if (contes.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Text('Aucun conte trouvé pour l\'instant.', style: TextStyle(fontStyle: FontStyle.italic)),
                ),
              ),
            );
          }
          return _buildAnimatedTalesGrid(context, contes);
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildAnimatedTalesGrid(BuildContext context, List<Conte> contes) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final conte = contes[index];

          return AnimationConfiguration.staggeredGrid(
            position: index,
            columnCount: 2,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildTaleCard(context, conte),
              ),
            ),
          );
        },
        childCount: contes.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
    );
  }

  // ----------------------------------------------------
  // --- CARTE DE CONTE (CORRIGÉE) ---
  // ----------------------------------------------------

  Widget _buildTaleCard(BuildContext context, Conte conte) {
    String imageUrl = conte.urlPhoto;
    if (imageUrl.isNotEmpty && !imageUrl.toLowerCase().startsWith('http')) {
      final String sanitizedPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
      imageUrl = '$_apiBaseUrlForImages/$sanitizedPath';
    }
    final String fullImageUrl = imageUrl;

    final String title = conte.titre;
    final String narrator = '${conte.prenomAuteur} ${conte.nomAuteur}'.trim().isNotEmpty
        ? 'par ${conte.prenomAuteur} ${conte.nomAuteur}'
        : 'Auteur inconnu';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AffichageContesScreen(conte: conte),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du conte (prend toute la largeur)
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                // Pas de Padding ici pour que l'image prenne toute la largeur
                child: _buildCardImage(fullImageUrl, title),
              ),
            ),

            // Contenu textuel enrichi
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: _cardTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          narrator,
                          style: TextStyle(
                            color: _cardTextColor.withOpacity(0.7),
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildReadChip(),
                        if (conte.quiz != null)
                          const Tooltip(
                            message: 'Quiz disponible',
                            child: Icon(Icons.quiz, color: Colors.green, size: 18),
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

  // ----------------------------------------------------
  // --- WIDGET D'IMAGE (CORRIGÉ) ---
  // ----------------------------------------------------

  Widget _buildCardImage(String fullImageUrl, String title) {
    return Image.network(
      fullImageUrl,
      width: double.infinity, // 🎯 CORRECTION : Assure que l'image remplit la largeur
      fit: BoxFit.cover,
      alignment: Alignment.center,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: double.infinity, // 🎯 CORRECTION : Conteneur de chargement max largeur
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              color: _accentColor.withOpacity(0.8),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: double.infinity, // 🎯 CORRECTION : Conteneur d'erreur max largeur
          color: Colors.grey[300],
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, size: 30, color: _accentColor.withOpacity(0.8)),
                const SizedBox(height: 4),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _cardTextColor.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _accentColor.withOpacity(0.5)),
      ),
      child: const Text(
        'Lire le conte',
        style: TextStyle(
          color: _accentColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}