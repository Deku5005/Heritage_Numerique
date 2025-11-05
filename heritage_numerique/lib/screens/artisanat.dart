import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/detailArtisanal.dart';

import 'AppDrawer.dart';



// --- Constantes de Couleurs Globales ---
const Color _cardBgColor = Color(0xFFFEFBF8);
const Color _cardBorderColor = Color(0xFFD7CBBB);
const Color _searchBgColor = Color(0xFFFCF8F1);
const Color _searchBorderColor = Color(0xFFEAE6DF);
const Color _primaryTextColor = Color(0xFF000000);
const Color _secondaryTextColor = Color(0xFF99928F);
const Color _tagBgColor = Color(0xFFF3EFEC);
const Color _initialsBgColor = Color(0xFFEFEBE4);


// =============================================================
// DONNÉES DE DÉMONSTRATION
// =============================================================
final List<ContentCardData> contentList = [
  ContentCardData(title: 'Artisanat Bogolan familiale', category: 'Artisanat', type: 'photo', tag: 'Bambara', author: 'Oumou Diakité', time: 'Il y a 2 heures'),
  ContentCardData(title: 'Artisanat Bogolan familiale', category: 'Artisanat', type: 'photo', tag: 'Dogon', author: 'Oumou Diakité', time: 'Il y a 2 heures'),
  ContentCardData(title: 'Artisanat Bogolan familiale', category: 'Artisanat', type: 'photo', tag: 'Bambara', author: 'Oumou Diakité', time: 'Il y a 2 heures'),
  ContentCardData(title: 'Artisanat Bogolan familiale', category: 'Artisanat', type: 'photo', tag: 'Dogon', author: 'Oumou Diakité', time: 'Il y a 2 heures'),
];


// =============================================================
// ÉCRAN PRINCIPAL
// =============================================================

class ContenuArtisanalScreen extends StatelessWidget {
  const ContenuArtisanalScreen({super.key});

  // Fonction pour afficher le modal de détail
  void _showContentDetailModal(BuildContext context, ContentDetailData detailData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ArtisanatDetailModal(data: detailData),
        );
      },
    );
  }

  // Fonction pour construire chaque carte de contenu (pour la grille)
  Widget _buildContentCard(ContentCardData data) {
    // Widget utilitaire pour les tags de la grille
    Widget _buildGridTag(String text, {IconData? icon}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: _tagBgColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              const Icon(Icons.photo, size: 8, color: _primaryTextColor), // Utiliser l'icône Book
              const SizedBox(width: 3),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _primaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardBgColor,
        border: Border.all(color: _cardBorderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image de fond
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              image: DecorationImage(
                image: AssetImage(data.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Tags en dessous de l'image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGridTag('${data.category} / ${data.type}', icon: Icons.photo),
                _buildGridTag(data.tag),
              ],
            ),
          ),

          // 3. Titre
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              data.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: _primaryTextColor,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Spacer(),

          // 4. Infos Auteur et Temps
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Initiale (OD) + Nom de l'auteur
                Row(
                  children: [
                    Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _initialsBgColor,
                      ),
                      child: const Center(
                        child: Text(
                          'OD',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: _primaryTextColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 70,
                      child: Text(
                        data.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: _primaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Temps
                Text(
                  data.time,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    color: _primaryTextColor,
                  ),
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

      drawer: const AppDrawer(),

      // --- AppBar Standard "Héritage Numérique" ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

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
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contenus culturels',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: _primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Récits, musiques, artisanat et proverbes de votre famille',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _secondaryTextColor,
                    ),
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
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher contenu...',
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF6E6967),
                    ),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF6E6967)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 0.0, bottom: 15.0),
                  ),
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Grille de Contenu ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.95, // Ratio pour compacter la carte
                ),
                itemCount: contentList.length,
                itemBuilder: (context, index) {
                  final cardData = contentList[index];

                  // Construction des données complètes pour le modal
                  final detailData = ContentDetailData(
                    title: 'Motif Bogolan familial',
                    category: cardData.category,
                    type: cardData.type,
                    tag: cardData.tag,
                    description: 'Tissu bogolan avec le symbole de notre famille',
                    author: cardData.author,
                    time: cardData.time,
                    imagePath: cardData.imagePath,
                  );

                  return GestureDetector(
                    onTap: () {
                      _showContentDetailModal(context, detailData);
                    },
                    child: _buildContentCard(cardData),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}