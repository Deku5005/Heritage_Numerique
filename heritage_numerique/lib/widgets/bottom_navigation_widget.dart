import 'package:flutter/material.dart';
import '../screens/contes_screen.dart';
import '../screens/artisans_screen.dart';
import '../screens/music_screen.dart';
import '../screens/proverb_screen.dart';

/// Widget de navigation inférieure partagé pour toutes les pages
class BottomNavigationWidget extends StatelessWidget {
  final String currentPage;
  
  const BottomNavigationWidget({
    super.key,
    required this.currentPage,
  });

  // Couleur principale Ocre Vif (D69301)
  static const Color _accentColor = Color(0xFFD69301);

  @override
  Widget build(BuildContext context) {
    // Liste des éléments de la barre de navigation
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.menu_book, 'label': 'Contes', 'page': 'contes'},
      {'icon': Icons.music_note, 'label': 'Musique', 'page': 'music'},
      {'icon': Icons.handyman, 'label': 'Artisanat', 'page': 'artisans'},
      {'icon': Icons.chat_bubble, 'label': 'Proverbe', 'page': 'proverb'},
      {'icon': Icons.person, 'label': 'Profil', 'page': 'profil'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: navItems.map((item) {
            final isSelected = item['page'] == currentPage;
            return GestureDetector(
              onTap: () => _navigateToPage(context, item['page'] as String),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 24,
                    color: isSelected ? _accentColor : Colors.grey,
                  ),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? _accentColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Navigation vers la page correspondante
  void _navigateToPage(BuildContext context, String page) {
    // Ne naviguer que si ce n'est pas la page actuelle
    if (page == currentPage) return;

    Widget targetScreen;
    switch (page) {
      case 'contes':
        targetScreen = const ContesScreen();
        break;
      case 'music':
        targetScreen = const MusicScreen();
        break;
      case 'artisans':
        targetScreen = const ArtisansScreen();
        break;
      case 'proverb':
        targetScreen = const ProverbScreen();
        break;
      case 'profil':
        // Pour l'instant, afficher un message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Section Profil en développement'),
            backgroundColor: _accentColor,
          ),
        );
        return;
      default:
        return;
    }

    // Navigation vers la page cible
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }
}
