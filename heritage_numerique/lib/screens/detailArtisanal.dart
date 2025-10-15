import 'package:flutter/material.dart';

// --- Constantes de Couleurs Locales ---
const Color _primaryTextColor = Color(0xFF000000);
const Color _tagBgColor = Color(0xFFF3EFEC);
const Color _initialsBgColor = Color(0xFFEFEBE4);
const Color _bambaraTagBg = Color(0xFFDA9E33);

// =============================================================
// MODÈLES DE DONNÉES
// =============================================================

// Modèle de données pour une carte de grille (affichage court)
class ContentCardData {
  final String title;
  final String category;
  final String type;
  final String tag;
  final String author;
  final String time;
  final String imagePath;

  ContentCardData({
    required this.title,
    required this.category,
    required this.type,
    required this.tag,
    required this.author,
    required this.time,
    this.imagePath = 'assets/images/bogolan.jpg',
  });
}

// Modèle de données pour le détail du contenu (affichage long dans le modal)
class ContentDetailData extends ContentCardData {
  final String description;

  ContentDetailData({
    required super.title,
    required super.category,
    required super.type,
    required super.tag,
    required super.author,
    required super.time,
    required this.description,
    super.imagePath = 'assets/images/bogolan.jpg',
  });
}


// =============================================================
// WIDGET DÉTAIL DE CONTENU (Le pop-up)
// =============================================================

class ArtisanatDetailModal extends StatelessWidget {
  final ContentDetailData data;

  const ArtisanatDetailModal({super.key, required this.data});

  Widget _buildTag(String text, {IconData? icon, Color bgColor = Colors.transparent}) {
    // Si c'est le tag Bambara, il a une couleur de fond pleine, sinon il a une bordure.
    final bool isPrimaryTag = bgColor != Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPrimaryTag ? bgColor : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: isPrimaryTag ? bgColor : _tagBgColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: isPrimaryTag ? Colors.white : _primaryTextColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isPrimaryTag ? Colors.white : _primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Hauteur minimale pour que le modal s'affiche bien
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. En-tête (Titre et Bouton Fermer)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _primaryTextColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: _primaryTextColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 2. Tags
          Row(
            children: [
              _buildTag('${data.category} / ${data.type}', icon: Icons.image_outlined, bgColor: Colors.transparent),
              const SizedBox(width: 8),
              _buildTag(data.tag, bgColor: _bambaraTagBg),
            ],
          ),

          const SizedBox(height: 15),

          // 3. Image
          Container(
            height: 226,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(data.imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // 4. Section Contenu Original (Titre)
          const Text(
            'Contenu original',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: _primaryTextColor,
            ),
          ),

          const SizedBox(height: 5),

          // 5. Description
          Text(
            data.description,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 10,
              color: _primaryTextColor,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),

          // 6. Infos Auteur et Temps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Initiale (OD)
                  Container(
                    width: 22,
                    height: 22,
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
                  const SizedBox(width: 8),
                  // Nom de l'auteur
                  Text(
                    data.author,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: _primaryTextColor,
                    ),
                  ),
                ],
              ),

              // Temps
              Text(
                data.time,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 8,
                  color: _primaryTextColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}