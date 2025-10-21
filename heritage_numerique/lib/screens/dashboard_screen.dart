import 'package:flutter/material.dart';

// Imports des modèles et services
// *** CORRECTION DES IMPORTS ***
// Nous utilisons le TokenManager et le chemin correct pour auth_service.dart (qui contient fetchDashboardData)
import 'package:heritage_numerique/Services/InscriptionServices.dart';
import 'package:heritage_numerique/Services/token_manager.dart';
import 'package:heritage_numerique/Model/DashboardData.dart'; // Modèle de données du Dashboard
import 'package:heritage_numerique/Model/Famille.dart'; // Modèle Famille

// Écrans de navigation
import 'CreateFamilyAccountScreen.dart';
import 'HomeDashboardScreen.dart';

// --- Constantes de Couleurs ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _buttonOpacityColor = Color(0x87D9D9D9);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);


class DashboardScreen extends StatefulWidget {
  // *** CORRECTION 1 : Suppression de l'accessToken car il est géré par TokenManager ***
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<DashboardData>? _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Charge les données du tableau de bord via l'API, en récupérant le token automatiquement.
  void _loadDashboardData() async {
    // *** CORRECTION 2 : Lecture du token depuis le stockage sécurisé ***
    String? token = await TokenManager.getToken();

    if (token != null && token.isNotEmpty) {
      setState(() {
        _dashboardDataFuture = fetchDashboardData(token);
      });
    } else {
      // Gérer le cas où l'utilisateur n'est pas connecté ou le token a expiré/manque
      setState(() {
        _dashboardDataFuture = Future.error('Vous n\'êtes pas connecté. Jeton d\'accès manquant.');
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FutureBuilder<DashboardData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_mainAccentColor)),
                  SizedBox(height: 10),
                  Text('Chargement du Dashboard...', style: TextStyle(color: _cardTextColor)),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // Affichage en cas d'erreur de chargement
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
                    const SizedBox(height: 20),
                    Text(
                      'Erreur de connexion : ${snapshot.error.toString().replaceAll('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadDashboardData, // Tente de recharger le token et les données
                      style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor, foregroundColor: Colors.white),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            // Affichage normal avec les données chargées
            return _buildDashboardContent(context, snapshot.data!);
          } else {
            return const Center(child: Text('Aucune donnée à afficher.'));
          }
        },
      ),
    );
  }

  // Widget qui construit tout le contenu du tableau de bord
  Widget _buildDashboardContent(BuildContext context, DashboardData data) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
      child: Column(
        children: [
          // 1. Cercle d'en-tête (Logo ou Profil)
          _buildProfileCircle(),
          const SizedBox(height: 20),

          // 2. Conteneur de bienvenue (Bienvenue sur votre dashboard)
          _buildWelcomeContainer(data.prenom),
          const SizedBox(height: 30),

          // 3. Section des Statistiques (Famille, Quiz, Invitations)
          _buildStatsContainer(context, data),
          const SizedBox(height: 30),

          // 4. Titre "Famille"
          _buildSectionTitle('Familles (${data.nombreFamillesAppartenance})'),
          const SizedBox(height: 15),

          // 5. Grille des Familles
          _buildFamilyGrid(context, data.familles),
          const SizedBox(height: 30),

          // 6. Titre "Invitation"
          if (data.nombreInvitationsEnAttente > 0) ...[
            _buildSectionTitle('Invitations (${data.nombreInvitationsEnAttente})'),
            const SizedBox(height: 15),
            // Utilise le nombre réel d'invitations en attente pour simuler la liste
            _buildInvitationGrid(context, data.nombreInvitationsEnAttente),
            const SizedBox(height: 30),
          ],

          // 8. Conteneur d'Actions en Bas
          _buildActionContainer(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- 1. Cercle de Profil (Utilisation de ClipOval avec Image.asset) ---
  Widget _buildProfileCircle() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _mainAccentColor, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo_dabo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Widget de substitution si l'image ne charge pas
            return Center(
              child: Icon(Icons.person, color: _mainAccentColor, size: 40),
            );
          },
        ),
      ),
    );
  }


  // --- 3. Section des Statistiques (Adapté pour utiliser DashboardData) ---
  Widget _buildStatsContainer(BuildContext context, DashboardData data) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Familles', Icons.group, data.nombreFamillesAppartenance),
          _buildStatItem('Contenus', Icons.article, data.nombreContenusCrees),
          _buildStatItem('Quiz', Icons.quiz, data.nombreQuizCrees),
          _buildStatItem('Notifications', Icons.mail_outline, data.nombreNotificationsNonLues),
        ],
      ),
    );
  }

  // --- 5. Grille des Familles (Adapté pour utiliser List<Famille>) ---
  Widget _buildFamilyGrid(BuildContext context, List<Famille> familles) {
    if (familles.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Vous n'appartenez à aucune famille.", style: TextStyle(color: Colors.grey)),
      ));
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: familles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        return _buildFamilyCard(context, familles[index]);
      },
    );
  }

  /// Construction d'une carte de Famille (avec navigation rétablie)
  Widget _buildFamilyCard(BuildContext context, Famille famille) {
    final isCreator = famille.idCreateur == 1; // Simulation
    final memberSince = DateTime.now().difference(DateTime.parse(famille.dateCreation)).inDays;

    return GestureDetector(
      onTap: () {
        // *** NAVIGATION RÉTABLIE : L'écran HomeDashboardScreen doit être prêt ***
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeDashboardScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _mainAccentColor.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.group, color: _mainAccentColor, size: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                famille.nom,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 16),
              ),
            ),

            _buildFamilyDetailRow('Admin:', isCreator ? 'Oui' : 'Non', isLast: false),
            _buildFamilyDetailRow('Membres:', '${famille.nombreMembres}', isLast: false),
            _buildFamilyDetailRow('Depuis:', '$memberSince Jrs', isLast: true),

            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action: Quitter la famille ${famille.nom}')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _mainAccentColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text('Quitter', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Le reste du code est inchangé ---

  Widget _buildWelcomeContainer(String prenom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _mainAccentColor, width: 1.5),
      ),
      child: Text(
        'Bienvenue, $prenom !',
        style: const TextStyle(
          color: _mainAccentColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  /// Construction d'un élément statistique
  Widget _buildStatItem(String title, IconData icon, int count) {
    return Column(
      children: [
        Icon(icon, color: _mainAccentColor, size: 30),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
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
              style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold),
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

  /// Ligne pour les détails de la carte Famille
  Widget _buildFamilyDetailRow(String label, String value, {required bool isLast}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 10, color: _cardTextColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // --- 6. Grille des Invitations (Adapté pour utiliser le nombre réel) ---
  Widget _buildInvitationGrid(BuildContext context, int invitationCount) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: invitationCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        return _buildInvitationCard(context, index, 'Famille X', '2025-10-15');
      },
    );
  }

  /// Construction d'une carte d'Invitation (Adapté)
  Widget _buildInvitationCard(BuildContext context, int index, String familyName, String date) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Icon(Icons.mark_email_unread, color: Colors.orange, size: 30),
          Text(
            'Invitation # ${index + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 14),
          ),
          _buildFamilyDetailRow('Expéditeur:', 'Famille X', isLast: false),
          _buildFamilyDetailRow('Crée le:', date, isLast: true),
          _buildPendingInvitationButtons(context, index),
        ],
      ),
    );
  }

  /// Boutons Accepter/Refuser pour la carte d'invitation en attente
  Widget _buildPendingInvitationButtons(BuildContext context, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Bouton Refuser
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invitation #${index + 1} refusée.')));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: const Text('Refuser', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),

        // Bouton Accepter
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invitation #${index + 1} acceptée.')));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.green, width: 1),
            ),
            child: const Text('Accepter', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
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
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildBottomButton(context, 'Découvrir la culture Malienne', onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigation vers Découverte')),
                      );
                    }),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildBottomButton(context, 'Créer un compte familial', onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateFamilyAccountScreen()),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _buttonOpacityColor,
              ),
              child: const Center(
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: _mainAccentColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}