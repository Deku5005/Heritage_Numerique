import 'package:flutter/material.dart';
// Assurez-vous d'importer l'AppDrawer
import 'AppDrawer.dart';

// --- Constantes de Couleurs Globales (utilisées dans les autres écrans) ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _roleAdminColor = Color(0xFFE5B0B0); // Rouge pâle pour Administrateur
const Color _roleContributorColor = Color(0xFFF7E8D8); // Beige/Jaune pâle pour Contributeur
const Color _roleTextColor = Color(0xFF7B521A); // Couleur marron foncé pour le texte des rôles

class ContributionsScreen extends StatelessWidget {
  // 💡 NOUVEAU : Ajout du champ familyId
  final int? familyId;

  // 💡 CORRECTION : Le constructeur doit accepter familyId
  const ContributionsScreen({super.key, required this.familyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // 💡 CORRECTION : familyId est transmis à AppDrawer
      drawer: AppDrawer(familyId: familyId),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête (Menu Burger, Titre, Bouton Fermer)
            Builder(
                builder: (BuildContext innerContext) {
                  return _buildCustomHeader(innerContext);
                }
            ),
            const SizedBox(height: 20),

            // 2. Corps de la page (Titre, Barre de recherche et Liste)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contribution des membres',
                    style: TextStyle(
                      color: _cardTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Découvrez les contributions de chaque membre de la famille',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Barre de recherche
                  _buildSearchBar(),
                  const SizedBox(height: 20),

                  // Liste des Contributions
                  _buildContributionList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets de Construction de l'Écran (Le reste du code est inchangé) ---

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _searchBackground,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher contenu...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildContributionList() {
    // Liste de données statiques pour simuler l'affichage
    final List<Map<String, dynamic>> members = [
      {
        'name': 'Baini Diakité',
        'role': 'Administrateur',
        'revelant_role': true,
        'revelant_name': 'Administrateur',
        'revelant_color': _roleAdminColor,
        'contributions': {'Récits': 4, 'Chants': 1, 'Artisanats': 1, 'Proverbes': 1}
      },
      {
        'name': 'Sekou Diakité',
        'role': 'Contributeur',
        'revelant_role': true,
        'revelant_name': 'Contributeur',
        'revelant_color': _roleContributorColor,
        'contributions': {'Récits': 4, 'Chants': 1, 'Artisanats': 1, 'Proverbes': 1}
      },
      {
        'name': 'Boubacar Diakité',
        'role': 'Contributeur',
        'revelant_role': true,
        'revelant_name': 'Contributeur',
        'revelant_color': _roleContributorColor,
        'contributions': {'Récits': 4, 'Chants': 1, 'Artisanats': 1, 'Proverbes': 1}
      },
      // ... Ajoutez d'autres membres si nécessaire
    ];

    return Column(
      children: members.map((member) {
        return _buildMemberCard(
          name: member['name'],
          role: member['revelant_name'],
          roleColor: member['revelant_color'],
          contributions: member['contributions'],
        );
      }).toList(),
    );
  }

  Widget _buildMemberCard({
    required String name,
    required String role,
    required Color roleColor,
    required Map<String, int> contributions,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Placeholder pour la photo de profil (Cercle avec image)
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/placeholder.jpg'), // Remplacez par une image réelle si vous en avez
                    backgroundColor: Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _cardTextColor,
                      ),
                    ),
                  ),
                  // Étiquette de Rôle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _roleTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Séparateur
            const Divider(height: 1, thickness: 1, color: Color(0xFFF7F2E8)),

            // Détail des contributions
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total des contributions',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      // Bloc total
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0D9D9), // Fond Rouge/Rose pâle
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          contributions.values.fold(0, (sum, count) => sum + count).toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC80000), // Rouge foncé
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Grille des types de contributions
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildContributionItem(
                        icon: Icons.book_outlined,
                        label: 'Récits',
                        count: contributions['Récits'] ?? 0,
                        color: const Color(0xFFE6F3E6), // Vert pâle
                      ),
                      _buildContributionItem(
                        icon: Icons.music_note_outlined,
                        label: 'Chants',
                        count: contributions['Chants'] ?? 0,
                        color: const Color(0xFFEEDDFF), // Violet pâle
                      ),
                      _buildContributionItem(
                        icon: Icons.palette_outlined,
                        label: 'Artisanats',
                        count: contributions['Artisanats'] ?? 0,
                        color: const Color(0xFFF3EAE6), // Beige pâle
                      ),
                      _buildContributionItem(
                        icon: Icons.chat_bubble_outline,
                        label: 'Proverbes',
                        count: contributions['Proverbes'] ?? 0,
                        color: const Color(0xFFF3EAE6), // Beige pâle (Utilisation de la même couleur pour l'alignement visuel)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _cardTextColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _cardTextColor),
          ),
          const SizedBox(width: 8),
          // Nombre de contributions
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _cardTextColor,
            ),
          ),
        ],
      ),
    );
  }
}