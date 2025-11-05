import 'package:flutter/material.dart';

// Assurez-vous d'importer votre AppDrawer correctement
import 'AppDrawer.dart';

// --- Constantes de Couleurs ---
const Color _searchBgColor = Color(0xFFFCF8F1); // Couleur de fond demandée
const Color _searchBorderColor = Color(0xFFEAE6DF);
const Color _primaryTextColor = Color(0xFF000000);
const Color _secondaryTextColor = Color(0xFF99928F);
const Color _accentTextColor = Color(0xFF49521D);
// L'ancienne couleur _featuredTileBg a été remplacée par _searchBgColor

class MusicDashScreen extends StatelessWidget {
  const MusicDashScreen({super.key});

  // Fonction pour simuler la tuile d'un élément de la collection
  Widget _buildMusicListItem(String title, String author) {
    // La taille de police de l'auteur a été augmentée à 12 (CORRIGÉ)
    const double authorFontSize = 12.0;

    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              // Simulate image and play button
              color: Colors.grey[300],
              image: const DecorationImage(
                image: AssetImage('assets/images/african-traditional-music-instruments.jpg'), // Remplacez par votre chemin d'image
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color.fromRGBO(0, 0, 0, 0.8),
            ),
          ),
          subtitle: Text(
            author,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: authorFontSize, // Taille ajustée
              color: _accentTextColor,
            ),
          ),
          onTap: () {
            // Action de lecture
          },
        ),
        // Ligne de séparation
        const Divider(height: 0, indent: 25, endIndent: 25, color: Color.fromRGBO(80, 80, 80, 0.2)),
      ],
    );
  }

  // Fonction pour simuler la tuile de la vidéo mise en avant
  Widget _buildFeaturedVideoTile() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _searchBgColor, // Couleur ajustée pour correspondre à la barre de recherche (CORRIGÉ)
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Conteneur Média
          Container(
            width: 90,
            height: 80,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey[400],
              image: const DecorationImage(
                image: AssetImage('assets/images/african-traditional-music-instruments.jpg'), // Remplacez par votre chemin d'image
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              // Bouton Play
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.play_arrow, color: Color(0xFF0D99FF), size: 16),
              ),
            ),
          ),

          // Texte et Progression
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chant de mariage traditionnel',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _primaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Enregistrer par oumou Diakite lors du mariage de son petit fils à 2002...',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.2,
                    color: _accentTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                // Barre de progression (simulée)
                Row(
                  children: [
                    const Text('3:45', style: TextStyle(fontSize: 10, color: _accentTextColor)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0.3, // Simule 30% de progression
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(_accentTextColor),
                        minHeight: 3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AJOUT DU DRAWER
      drawer: const AppDrawer(),

      // --- AppBar Standard "Héritage Numérique" ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        // Bouton Menu (leading)
        leading: Builder(
          builder: (BuildContext innerContext) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(innerContext).openDrawer();
              },
            );
          },
        ),

        // Titre "Héritage Numérique" centré
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              const SizedBox(width: 40),
              Expanded(
                child: Center(
                  child: Text(
                    'Héritage Numérique',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),

        // Ligne d'ombre (box-shadow)
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),

      // --- Corps de la page (Contenus) ---
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Zone de titre et description ---
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contenus culturels',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: _primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Explorez les mélodies et chants traditionnels de la famille',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: _secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  // Icône de fermeture (X)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      // Action de fermeture/retour
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // --- Champ de Recherche ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 35,
                decoration: BoxDecoration(
                  color: _searchBgColor,
                  border: Border.all(color: _searchBorderColor, width: 1),
                  borderRadius: BorderRadius.circular(5), // Taille ajustée pour le design
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher contenu...',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10, // Taille ajustée pour le design
                      color: Color(0xFF6E6967),
                    ),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF6E6967)),
                    border: InputBorder.none,
                    // contentPadding ajusté pour aligner le texte avec l'icône (CORRIGÉ)
                    contentPadding: EdgeInsets.only(top: 00.0, bottom: 15.0),
                  ),
                  style: TextStyle(fontSize: 12), // Taille du texte saisi
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Tuile Vidéo Mise en Avant ---
            _buildFeaturedVideoTile(),

            const SizedBox(height: 25),

            // --- Collection Musicale (Conteneur Blanc) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre Collection
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0, top: 15.0, bottom: 5.0),
                      child: Text(
                        'Collection musicale',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color.fromRGBO(0, 0, 0, 0.8),
                        ),
                      ),
                    ),
                    const Divider(height: 0, indent: 25, endIndent: 25, color: Color.fromRGBO(80, 80, 80, 0.2)),

                    // Liste des éléments
                    _buildMusicListItem('Chant de mariage traditionnel', 'Oumar Diakité'),
                    _buildMusicListItem('Chant de mariage traditionnel', 'Oumar Diakité'),
                    _buildMusicListItem('Chant de mariage traditionnel', 'Oumar Diakité'),
                    // Ajouter d'autres éléments ici...
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}