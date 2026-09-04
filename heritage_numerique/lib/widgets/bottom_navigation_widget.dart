import 'package:flutter/material.dart';
import 'package:heritage_numerique/Service/token-storage-service.dart';
import 'package:heritage_numerique/screens/dashboard_screen.dart';
import 'package:heritage_numerique/screens/home_screen.dart';
import 'package:heritage_numerique/screens/login_screen.dart';
import 'package:heritage_numerique/screens/public_home_screen.dart';
import 'package:heritage_numerique/screens/public_quiz_screen.dart';
import 'cultural_theme.dart';

/// Widget de navigation inférieure pour l'Espace Public & Connecté (4 onglets selon la maquette)
class BottomNavigationWidget extends StatelessWidget {
  final String currentPage;
  final int? familyId;

  const BottomNavigationWidget({
    super.key,
    required this.currentPage,
    this.familyId,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navItems = [
      {
        'id': 'accueil',
        'label': 'Accueil',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
      },
      {
        'id': 'explorer',
        'label': 'Explorer',
        'icon': Icons.public_outlined,
        'activeIcon': Icons.public,
      },
      {
        'id': 'quiz',
        'label': 'Quiz',
        'icon': Icons.help_outline,
        'activeIcon': Icons.help,
      },
      {
        'id': 'profil',
        'label': 'Profil',
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFEBEBEB), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final isSelected = item['id'] == currentPage;
              return InkWell(
                onTap: () => _handleNavigation(context, item['id'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected
                            ? (item['activeIcon'] as IconData)
                            : (item['icon'] as IconData),
                        size: 24,
                        color: isSelected ? CulturalTheme.primaryOcre : CulturalTheme.textMuted,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? CulturalTheme.primaryOcre : CulturalTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _handleNavigation(BuildContext context, String target) async {
    if (target == currentPage) return;

    Widget destination;
    switch (target) {
      case 'accueil':
        destination = const PublicHomeScreen();
        break;
      case 'explorer':
      case 'decouvrir':
        destination = const HomeScreen();
        break;
      case 'quiz':
        destination = const PublicQuizScreen();
        break;
      case 'profil':
        final token = await TokenStorageService().getAuthToken();
        if (token != null && token.isNotEmpty) {
          destination = const DashboardScreen();
        } else {
          destination = const LoginScreen();
        }
        break;
      default:
        return;
    }

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => destination,
        transitionDuration: Duration.zero,
      ),
    );
  }
}