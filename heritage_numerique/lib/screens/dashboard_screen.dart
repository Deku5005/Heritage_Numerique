import 'package:flutter/material.dart';
import 'CreateFamilyAccountScreen.dart';
import 'HomeDashboardScreen.dart';

// --- Constantes de Couleurs ---
// AA7311 est la couleur Ocre (Golden/Brownish Yellow)
const Color _mainAccentColor = Color(0xFFAA7311); 
// D9D9D9 avec 53% d'opacité (gris clair transparent)
const Color _buttonOpacityColor = Color(0x87D9D9D9); 
// Couleur blanche pour le fond
const Color _backgroundColor = Colors.white;
// Couleurs supplémentaires réutilisées pour les détails de carte
const Color _cardTextColor = Color(0xFF2E2E2E);


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Données simulées
  final int familyCount = 3;
  final int quizCount = 12;
  final int invitationCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
        child: Column(
          children: [
            // 1. Cercle d'en-tête (Logo ou Profil)
            _buildProfileCircle(),
            const SizedBox(height: 20),

            // 2. Conteneur de bienvenue (Bienvenue sur votre dashboard)
            _buildWelcomeContainer(),
            const SizedBox(height: 30),

            // 3. Section des Statistiques (Famille, Quiz, Invitations)
            _buildStatsContainer(context),
            const SizedBox(height: 30),

            // 4. Titre "Famille"
            _buildSectionTitle('Famille'),
            const SizedBox(height: 15),
            
            // 5. Grille des membres de la Famille
            _buildFamilyGrid(),
            const SizedBox(height: 30),

            // 6. Titre "Invitation"
            _buildSectionTitle('Invitation'),
            const SizedBox(height: 15),

            // 7. Grille des Invitations (Pending, Accepted, Denied)
            _buildInvitationGrid(context),
            const SizedBox(height: 30),

            // 8. Conteneur d'Actions en Bas
            _buildActionContainer(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- 1. Cercle de Profil ---
  Widget _buildProfileCircle() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _mainAccentColor, width: 2),
        image: const DecorationImage(
          // Image simulée pour le logo ou l'avatar
          image: AssetImage('assets/images/logo_dabo.png'), 
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // --- 2. Conteneur de Bienvenue ---
  Widget _buildWelcomeContainer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _mainAccentColor, width: 1.5),
        // L'écriture 'Bienvenue sur votre dashboard' est dedans
      ),
      child: const Text(
        'Bienvenue sur votre dashboard',
        style: TextStyle(
          color: _mainAccentColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // --- 3. Section des Statistiques (Famille, Quiz, Invitations) ---
  Widget _buildStatsContainer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8), // Fond légèrement cassé pour la carte
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          // BoxShadow de tous les côtés
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Famille', Icons.group, familyCount),
          _buildStatItem('Quiz', Icons.quiz, quizCount),
          _buildStatItem('Invitations', Icons.send, invitationCount),
        ],
      ),
    );
  }

  /// Construction d'un élément statistique
  Widget _buildStatItem(String title, IconData icon, int count) {
    return Column(
      children: [
        // Icône
        Icon(icon, color: _mainAccentColor, size: 30),
        const SizedBox(height: 8),
        
        // Titre
        Text(
          title,
          style: const TextStyle(
            color: _cardTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        
        // Bouton de comptage (D9D9D9 53% opacité)
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: _buttonOpacityColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: _cardTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 4. Titre de Section ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: _cardTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // --- 5. Grille des Membres de la Famille ---
  Widget _buildFamilyGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3, // 3 containers Famille
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7, // Ajusté pour le contenu vertical
      ),
      itemBuilder: (context, index) {
        return _buildFamilyCard(context, index);
      },
    );
  }
  
  /// Construction d'une carte de Membre de la Famille
  Widget _buildFamilyCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        // Navigation vers HomeDashboardScreen lors du clic sur la carte
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeDashboardScreen()),
        );
      },
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Icône Famille
            const Icon(Icons.group, color: _mainAccentColor, size: 30),
            
            // Texte DOLÒ
            const Text('DOLÒ', style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
            
            // Texte de statut (noir à gauche, D9D9D9 à droite)
            _buildFamilyDetailRow('Admin de la famille:', 'Oui', isLast: false),
            _buildFamilyDetailRow('Membre depuis:', '15 Jrs', isLast: false),
            _buildFamilyDetailRow('Rôle:', 'Mère', isLast: true),

            // Bouton d'action (simulé - doit être blanc)
            InkWell(
              onTap: () {
                if (index == 1) {
                  // Naviguer vers la page de création de compte familial
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateFamilyAccountScreen()),
                  );
                }
                // Pour les autres boutons, ne rien faire (empêche la navigation vers HomeDashboard)
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                     BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  index == 0 ? 'Quitter' : index == 1 ? 'Ajouter' : 'Contacter',
                  style: const TextStyle(fontSize: 10, color: _mainAccentColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ligne pour les détails de la carte Famille
  Widget _buildFamilyDetailRow(String label, String value, {required bool isLast}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: Colors.black),
          ),
          // MODIFICATION: J'ai corrigé l'utilisation de _buttonOpacityColor ici
          Text(
            value,
            style: TextStyle(fontSize: 8, color: _buttonOpacityColor),
          ),
        ],
      ),
    );
  }


  // --- 6. Grille des Invitations ---
  Widget _buildInvitationGrid(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3, // 3 containers Invitation
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7, 
      ),
      itemBuilder: (context, index) {
        return _buildInvitationCard(context, index);
      },
    );
  }

  /// Construction d'une carte d'Invitation
  Widget _buildInvitationCard(BuildContext context, int index) {
    IconData buttonIcon;
    Color iconColor;

    if (index == 0) { // En Attente
      buttonIcon = Icons.close;
      iconColor = Colors.red;
    } else if (index == 1) { // Acceptée
      buttonIcon = Icons.check;
      iconColor = Colors.green;
    } else { // Refusée
      buttonIcon = Icons.cancel;
      iconColor = Colors.grey;
    }

    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Icône d'Invitation
          const Icon(Icons.send, color: _mainAccentColor, size: 30),
          
          // Détails de l'invitation (noir à gauche, D9D9D9 à droite)
          _buildFamilyDetailRow('Membre de la famille:', 'Oui', isLast: false),
          _buildFamilyDetailRow('Admin de la famille:', 'Non', isLast: false),
          _buildFamilyDetailRow('Crée le:', '06/03/24', isLast: true),

          // Bouton d'action basé sur l'état
          index == 0 ? _buildPendingInvitationButtons() : _buildActionCircle(buttonIcon, iconColor),
        ],
      ),
    );
  }

  /// Boutons Accepter/Refuser pour la carte d'invitation en attente
  Widget _buildPendingInvitationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Bouton Refuser (Blanc)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
               BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text('Refuser', style: TextStyle(fontSize: 10, color: _cardTextColor)),
        ),
        
        // Bouton Accepter (Blanc)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
               BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Text('Accepter', style: TextStyle(fontSize: 10, color: _cardTextColor)),
        ),
      ],
    );
  }
  
  /// Cercle de validation/refus pour les cartes non en attente
  Widget _buildActionCircle(IconData icon, Color iconColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _buttonOpacityColor, // D9D9D9 53% opacité
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  // --- 7. Conteneur d'Actions en Bas ---
  Widget _buildActionContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Boutons d'action
            Row(
              children: [
                _buildBottomButton(context, 'Découvrir la culture Malienne', onTap: () {
                  // Action pour découvrir la culture Malienne
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Découvrir la culture Malienne')),
                  );
                }),
                const SizedBox(width: 10),
                _buildBottomButton(context, 'Créer un compte familial', onTap: () {
                  // Navigation vers CreateFamilyAccountScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateFamilyAccountScreen()),
                  );
                }),
              ],
            ),
            
            // Cercle avec icône/image (Arbre)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _buttonOpacityColor,
                image: const DecorationImage(
                  // Image simulée pour l'arbre
                  image: AssetImage('assets/images/tree_icon.png'), 
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                 // Icône de substitution si l'image n'est pas trouvée
                child: Icon(Icons.park, color: _mainAccentColor), 
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construction d'un bouton d'action en bas
  Widget _buildBottomButton(BuildContext context, String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          // CORRECTION DEMANDÉE : Couleur de fond AA7311
          color: _mainAccentColor, 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white, // Texte en blanc
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}