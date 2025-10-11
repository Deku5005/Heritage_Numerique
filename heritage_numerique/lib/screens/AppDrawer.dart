import 'package:flutter/material.dart';
// Assurez-vous d'importer tous les écrans vers lesquels vous naviguez
import 'HomeDashboardScreen.dart';     
import 'FamilyMembersScreen.dart';   
import 'FamilyTreeScreen.dart'; // NOUVEL ÉCRAN IMPORTÉ
import 'CreateTreeScreen.dart'; // NOUVEL ÉCRAN IMPORTÉ
import 'ContributionsScreen.dart'; // NOUVEL ÉCRAN IMPORTÉ
import 'SettingsScreen.dart'; // NOUVEL ÉCRAN IMPORTÉ
import 'CulturalContentScreen.dart'; // NOUVEL ÉCRAN IMPORTÉ
import 'MusicDashScreen.dart'; // NOUVEL ÉCRAN IMPORTÉ






// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311); 
const Color _drawerBackgroundColor = Color(0xFF2E2E2E);
const Color _drawerTextColor = Colors.white;
const Color _dividerColor = Color(0xFFAA7311);

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // Fonction réutilisable pour naviguer et remplacer l'écran actuel
  void _navigateToReplace(BuildContext context, Widget screen) {
    Navigator.pop(context); // 1. Ferme le tiroir

    // 2. Exécute la navigation juste après la fin de la trame actuelle (Solution pour le problème du double clic)
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
  
  // En-tête du Tiroir
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
                   _navigateToReplace(context, const HomeDashboardScreen()); 
                }),
                
                // 2. Membre Famille (FamilyMembersScreen)
                _buildDrawerItem(Icons.group_outlined, 'Membre Famille', onTap: () {
                  _navigateToReplace(context, const FamilyMembersScreen());
                }),
                
                // 3. Récits
                _buildDrawerItem(Icons.book_outlined, 'Récits', onTap: () {
                    _navigateToReplace(context, const CulturalContentScreen());
                }),
                
                // 4. Artisanat/ Photos
                _buildDrawerItem(Icons.construction_outlined, 'Artisanat/ Photos', onTap: () {}),
                
                // 5. Arbre Généalogique (FamilyTreeScreen)
                _buildDrawerItem(Icons.link, 'Arbre Généalogique', onTap: () {
                  _navigateToReplace(context, const FamilyTreeScreen()); // NOUVEAU
                }),

                // 6. Proverbes
                _buildDrawerItem(Icons.chat_bubble_outline, 'Proverbes', onTap: () {}),

                // 7. Musiques et Chants
                _buildDrawerItem(Icons.music_note_outlined, 'Musiques et Chants', onTap: () {
                    _navigateToReplace(context, const MusicDashScreen());
                }),

                // 8. Contributions
                _buildDrawerItem(Icons.show_chart, 'Contributions', onTap: () {
                    _navigateToReplace(context, const ContributionsScreen());
                }),

                // 9. Créer arbre (Action à définir, peut-être une autre page)
                _buildDrawerItem(Icons.auto_graph_outlined, 'Créer arbre', onTap: () {
                     _navigateToReplace(context, const CreateTreeScreen()); // Changement ici!
                }),

                // 10. Quiz
                _buildDrawerItem(Icons.quiz_outlined, 'Quiz', onTap: () {}),

                // 11. Paramètre
                _buildDrawerItem(Icons.settings_outlined, 'Paramètre', onTap: () {
                     _navigateToReplace(context, const SettingsScreen());
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}