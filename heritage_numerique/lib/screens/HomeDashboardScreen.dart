import 'package:flutter/material.dart';
// CORRECTION D'IMPORTATION : Assurez-vous que ce chemin est correct. 
// Si HomeDashboardScreen est dans lib/screens, et AppDrawer est dans lib/screens, utilisez l'importation relative.
import 'AppDrawer.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _welcomeCardBackground = Color(0xFFF7F2E8);

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Clé nécessaire pour que le Scaffold sache comment gérer le Drawer
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: const AppDrawer(), // L'AppDrawer est const

      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête (Menu + Titre)
            _buildCustomHeader(scaffoldKey),
            const SizedBox(height: 20),

            // 2. Carte de Bienvenue 
            _buildWelcomeCard(),
            const SizedBox(height: 30),

            // 3. Grille des Statistiques 
            _buildStatsGrid(),
            const SizedBox(height: 30),

            // 4. Titre "Récents Ajouts"
            _buildSectionTitle('Récents Ajouts'),
            const SizedBox(height: 15),

            // 5. Grille des Récents Ajouts
            _buildRecentAdditionsGrid(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- 1. En-tête Personnalisé (Menu et Titre) ---
  Widget _buildCustomHeader(GlobalKey<ScaffoldState> scaffoldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              // Ouvre le Drawer via la GlobalKey
              scaffoldKey.currentState?.openDrawer();
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Carte de Bienvenue ---
  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16.0),
      // CORRECTION : BoxDecoration est const si tous ses arguments le sont.
      decoration: BoxDecoration(
        color: _welcomeCardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenue dans la mémoire familiale des Diakité',
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Un lieu pour préserver, partager et transmettre votre héritage à travers les générations.',
            style: TextStyle(
              color: _cardTextColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Grille des Statistiques ---
  Widget _buildStatsGrid() {
    const List<Map<String, dynamic>> stats = [
      {'title': 'Famille', 'count': 12, 'icon': Icons.group_outlined},
      {'title': 'Récit', 'count': 24, 'icon': Icons.book_outlined},
      {'title': 'Photos', 'count': 37, 'icon': Icons.photo_outlined},
      {'title': 'Proverbes', 'count': 12, 'icon': Icons.format_quote},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
        ),
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _buildStatItemCard(stat['title'] as String, stat['count'] as int, stat['icon'] as IconData);
        },
      ),
    );
  }

  /// Construction d'une carte d'élément statistique
  Widget _buildStatItemCard(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  color: _cardTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _cardTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: _mainAccentColor, size: 30),
        ],
      ),
    );
  }

  // --- 4. Titre de Section ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: _cardTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- 5. Grille des Récents Ajouts ---
  Widget _buildRecentAdditionsGrid() {
    const List<Map<String, String>> additions = [
      {'type': 'Musique', 'title': 'Chant traditionnel de mariage', 'by': 'OD Oumou Diakité', 'date': 'il y a 2 heures', 'tag': 'Bambara', 'image': 'assets/images/music_drum.jpg'},
      {'type': 'Récit', 'title': 'L\'histoire de notre grand père Amadou', 'by': 'ND Niskale Diakité', 'date': 'il y a 2 heures', 'tag': 'Bambara', 'image': 'assets/images/story_telling.jpg'},
      {'type': 'Proverbe', 'title': 'Proverbe sur la sagesse', 'by': 'ND Niskale Diakité', 'date': 'il y a 3 heures', 'tag': 'Bambara', 'image': 'assets/images/proverb_bg.jpg'},
      {'type': 'Photo', 'title': 'Photo de famille', 'by': 'OD Oumou Diakité', 'date': 'il y a 3 heures', 'tag': 'Photo', 'image': 'assets/images/photo_bg.jpg'},
    ];

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: additions.length,
        itemBuilder: (context, index) {
          final item = additions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 15),
            child: _buildRecentAdditionCard(item),
          );
        },
      ),
    );
  }

  /// Construction d'une carte d'ajout récent
  Widget _buildRecentAdditionCard(Map<String, String> item) {
    Color tagColor = item['type'] == 'Photo' ? Colors.black.withOpacity(0.5) : _mainAccentColor;

    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Type Tag
          Stack(
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  color: Colors.grey.shade300,
                  image: DecorationImage(
                    // L'erreur d'Asset n'est pas corrigée ici, mais elle est gérée par AssetImage
                    image: AssetImage(item['image'] ?? 'assets/images/placeholder.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item['type']!,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    item['tag']!,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          // Texte et Détails
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _cardTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                // --- CORRECTION DU DÉBORDEMENT (OVERFLOW) ICI ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded( // Permet au texte long de l'auteur de se réduire et de tronquer
                      child: Text(
                        item['by']!,
                        maxLines: 1, // Assure que la troncature fonctionne
                        overflow: TextOverflow.ellipsis, // Affiche des points de suspension
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5), // Ajout d'un petit espace
                    Text(
                      item['date']!,
                      style: TextStyle(
                        color: _mainAccentColor.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                // ------------------------------------------------
              ],
            ),
          ),
        ],
      ),
    );
  }
}