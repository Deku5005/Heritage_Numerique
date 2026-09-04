import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/ArtisanatLabApp.dart';
import 'package:heritage_numerique/screens/DemandesAdminScreen.dart';
import 'package:heritage_numerique/screens/Profil.dart';
import 'package:heritage_numerique/screens/Proverbes.dart';
import 'package:heritage_numerique/screens/dashboard_screen.dart';
import 'package:heritage_numerique/screens/quiz.dart';
import 'package:heritage_numerique/screens/quizScreen.dart';
// Assurez-vous d'importer tous les écrans vers lesquels vous naviguez
import 'HomeDashboardScreen.dart';
import 'FamilyMembersScreen.dart';
import 'FamilyTreeScreen.dart';
import 'CreateTreeScreen.dart';
import 'ContributionsScreen.dart'; // NÉCESSITE familyId maintenant
import 'SettingsScreen.dart';
import 'CulturalContentScreen.dart';
import 'DevinettesDashScreen.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _drawerBackgroundColor = Color(0xFF2E2E2E);
const Color _drawerTextColor = Colors.white;
const Color _dividerColor = Color(0xFFAA7311);

class AppDrawer extends StatelessWidget {
  // 💡 Le champ familyId est requis
  final int? familyId;

  const AppDrawer({super.key, required this.familyId});

  // Fonction réutilisable pour naviguer et remplacer l'écran actuel
  void _navigateToReplace(BuildContext context, Widget screen) {
    Navigator.pop(context);

    Future.microtask(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    });
  }

  // Fonction réutilisable pour créer un élément de la liste du tiroir
  Widget _buildDrawerItem(IconData icon, String title, {required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: _mainAccentColor, size: 28),
      title: Text(
        title,
        style: const TextStyle(
          color: _drawerTextColor,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  // En-tête du Tiroir (Inchangé)
  Widget _buildDrawerHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 16.0,
        left: 16.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _mainAccentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'H',
                style: TextStyle(
                  color: _drawerTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Héritage',
                style: TextStyle(
                  color: _drawerTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Numérique',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupération sécurisée de l'ID de famille
    final int safeFamilyId = familyId ?? 0;

    // Fonction utilitaire pour vérifier l'ID avant la navigation
    void navigateToFamilyScreen(Widget screen) {
      if (safeFamilyId > 0) {
        // 💡 Retrait de 'const' ici car 'screen' n'est plus constant
        _navigateToReplace(context, screen);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ID de famille non trouvé. Veuillez vous reconnecter.")),
        );
      }
    }

    return Drawer(
      backgroundColor: _drawerBackgroundColor,
      child: Column(
        children: <Widget>[
          _buildDrawerHeader(context),
          const Divider(color: _dividerColor, height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                // 1. Accueil (HomeDashboard)
                _buildDrawerItem(Icons.home_outlined, 'Accueil', onTap: () {
                  // 💡 CORRECTION : HomeDashboardScreen REQUIERT maintenant familyId
                  // Retrait de 'const' et ajout du paramètre familyId.
                  _navigateToReplace(context, HomeDashboardScreen(familyId: safeFamilyId));
                }),

                // 2. Membre Famille (FamilyMembersScreen)
                _buildDrawerItem(Icons.group_outlined, 'Membre Famille', onTap: () {
                  navigateToFamilyScreen(FamilyMembersScreen(familleId: safeFamilyId));
                }),

                // 3. Récits
                _buildDrawerItem(Icons.book_outlined, 'Récits', onTap: () {
                  // 💡 CORRECTION : Ajout de familyId et retrait de 'const'
                  _navigateToReplace(context, CulturalContentScreen(familyId: safeFamilyId));
                }),

                // 4. Artisanat/ Photos
                _buildDrawerItem(Icons.construction_outlined, 'Artisanat/ Photos', onTap: () {
                  // Action non définie
                  _navigateToReplace(context, ArtisanatLabApp(familyId: safeFamilyId));
                }),

                // 5. Arbre Généalogique (FamilyTreeScreen)
                _buildDrawerItem(Icons.link, 'Arbre Généalogique', onTap: () {
                  // 💡 Retrait de 'const'
                  navigateToFamilyScreen(FamilyTreeScreen(familyId: safeFamilyId));
                }),

                // 6. Proverbes
                _buildDrawerItem(Icons.chat_bubble_outline, 'Proverbes', onTap: () {
                  _navigateToReplace(context, Proverbes(familyId: safeFamilyId));
                  // Action non définie
                }),

                // 7. Musiques et Chants
                _buildDrawerItem(Icons.music_note_outlined, 'Devinettes', onTap: () {
                  // 💡 CORRECTION : Ajout de familyId et retrait de 'const'
                  _navigateToReplace(context, DevinettesDashScreen(familyId: safeFamilyId));
                }),

                // 8. Contributions (ContributionsScreen)
                _buildDrawerItem(Icons.show_chart, 'Contributions', onTap: () {
                  // 💡 Retrait de 'const'
                  navigateToFamilyScreen(ContributionsScreen(familyId: safeFamilyId));
                }),

                // 9. Créer arbre (CreateTreeScreen)
                _buildDrawerItem(Icons.auto_graph_outlined, 'Créer arbre', onTap: () {
                  // 💡 Retrait de 'const'
                  navigateToFamilyScreen(CreateTreeScreen(familyId: safeFamilyId));
                }),

                // 10. Quiz
                _buildDrawerItem(Icons.quiz_outlined, 'Quiz', onTap: () {
                  // 💡 Retrait de 'const'
                  _navigateToReplace(context, QuizScreen(familyId: safeFamilyId));
                }),

                _buildDrawerItem(Icons.quiz_outlined, 'QuizCreation', onTap: () {
                  // 💡 Retrait de 'const'
                  _navigateToReplace(context, AddQuizScreen(familyId: safeFamilyId));
                }),

                // 12. Profil
                _buildDrawerItem(Icons.person, 'Profil', onTap: () {
                  // 💡 C'est ici que AppDrawer appelle ProfilePage avec familyId
                  _navigateToReplace(context, ProfilePage(familyId: safeFamilyId));
                }),

                // 13. Profil
                _buildDrawerItem(Icons.pending_actions, 'Mes demandes', onTap: () {
                  // 💡 C'est ici que AppDrawer appelle DemandesAdminScreen avec familyId
                  _navigateToReplace(context, DemandesAdminScreen(familyId: safeFamilyId));
                }),

                // 13. Profil
                _buildDrawerItem(Icons.dashboard_customize_outlined, 'Mon dashboard', onTap: () {
                  // 💡 C'est ici que AppDrawer appelle DemandesAdminScreen avec familyId
                  _navigateToReplace(context, DashboardScreen());
                }),

                // 14. Paramètre
                _buildDrawerItem(Icons.settings_outlined, 'Paramètre', onTap: () {
                  // 💡 Retrait de 'const'
                  _navigateToReplace(context, SettingsScreen(familyId: safeFamilyId));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}