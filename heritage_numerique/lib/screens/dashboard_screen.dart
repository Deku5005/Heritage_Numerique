// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:heritage_numerique/Service/Auth-service.dart';
import 'package:heritage_numerique/model/dashboard-models.dart';
import 'CreateFamilyAccountScreen.dart';
import 'HomeDashboardScreen.dart';

// --- Constantes de Couleurs ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _buttonOpacityColor = Color(0x87D9D9D9);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Service et Future pour le chargement des données
  final AuthService _authService = AuthService();
  late Future<DashboardPersonnelResponse> _dashboardData;

  // Stocke l'ID de l'utilisateur connecté pour la vérification du rôle.
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _dashboardData = _authService.fetchPersonnelDashboard();
    // ✅ Charge l'ID utilisateur de manière asynchrone pour la vérification des rôles.
    _loadCurrentUserId();
  }

  // Méthode pour charger l'ID utilisateur (Simulation)
  Future<void> _loadCurrentUserId() async {
    // ⚠️ Remplacez ceci par l'ID utilisateur réel stocké après la connexion
    // L'ID utilisateur devrait être stocké dans TokenStorageService au moment du login.
    await Future.delayed(const Duration(milliseconds: 100));
    const simulatedUserId = 42;

    if(mounted) {
      setState(() {
        _currentUserId = simulatedUserId;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Affiche un indicateur de chargement si l'ID utilisateur n'est pas encore chargé
    if (_currentUserId == null) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_mainAccentColor),
          ),
        ),
      );
    }

    // Utilisation d'un FutureBuilder pour gérer l'état de la requête API
    return FutureBuilder<DashboardPersonnelResponse>(
      future: _dashboardData,
      builder: (context, snapshot) {

        // 1. État de Chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_mainAccentColor),
              ),
            ),
          );
        }

        // 2. État d'Erreur
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: _backgroundColor,
            appBar: AppBar(title: const Text('Erreur')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      'Erreur de chargement: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    // Bouton pour réessayer
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dashboardData = _authService.fetchPersonnelDashboard();
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor),
                      child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        // 3. État de Succès (Données disponibles)
        if (snapshot.hasData) {
          final data = snapshot.data!;

          return Scaffold(
            backgroundColor: _backgroundColor,
            body: SingleChildScrollView(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
              child: Column(
                children: [
                  _buildProfileCircle(),
                  const SizedBox(height: 20),
                  _buildWelcomeContainer(data.prenom),
                  const SizedBox(height: 30),
                  _buildStatsContainer(
                      context,
                      data.nombreFamillesAppartenance,
                      data.nombreQuizCrees,
                      data.nombreInvitationsEnAttente
                  ),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Famille (${data.nombreFamillesAppartenance})'),
                  const SizedBox(height: 15),
                  _buildFamilyGrid(context, data.familles),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Invitation (${data.nombreInvitationsEnAttente + data.nombreInvitationsRecues})'),
                  const SizedBox(height: 15),
                  _buildInvitationGrid(context, data.invitationsEnAttente),
                  const SizedBox(height: 30),
                  _buildActionContainer(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          backgroundColor: _backgroundColor,
          body: Center(child: Text('Initialisation du Dashboard...')),
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // --- MÉTHODES DE CONSTRUCTION DE L'UI ---
  // ----------------------------------------------------------------------

  // --- 5. Grille des Familles (Adapté) ---
  Widget _buildFamilyGrid(BuildContext context, List<Famille> familles) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: familles.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        if (index < familles.length) {
          return _buildFamilyCard(context, familles[index]);
        } else {
          return _buildAddFamilyCard(context);
        }
      },
    );
  }

  /// Construction d'une carte de Famille (Réelle)
  Widget _buildFamilyCard(BuildContext context, Famille famille) {
    // ✅ CORRECTION CRUCIALE : Utilisation de l'ID utilisateur chargé
    final bool isAdmin = famille.idCreateur == _currentUserId;

    return GestureDetector(
      onTap: () {
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
            const Icon(Icons.group, color: _mainAccentColor, size: 30),
            Text(
                famille.nom,
                style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)
            ),
            _buildFamilyDetailRow('Admin:', isAdmin ? 'Oui' : 'Non', isLast: false),
            _buildFamilyDetailRow('Membres:', famille.nombreMembres.toString(), isLast: false),
            _buildFamilyDetailRow('Créé le:', '${famille.dateCreation.day}/${famille.dateCreation.month}/${famille.dateCreation.year}', isLast: true),
            InkWell(
              onTap: () {
                // Action pour quitter ou contacter
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
                  isAdmin ? 'Gérer' : 'Quitter',
                  style: const TextStyle(fontSize: 10, color: _mainAccentColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Carte pour Ajouter une Famille
  Widget _buildAddFamilyCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateFamilyAccountScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _mainAccentColor.withOpacity(0.5), style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: _mainAccentColor, size: 35),
            SizedBox(height: 5),
            Text(
              'Créer/Ajouter',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _mainAccentColor),
            ),
          ],
        ),
      ),
    );
  }

  // --- (Le reste des méthodes de l'UI sont inchangées) ---

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

  Widget _buildStatsContainer(BuildContext context, int familyCount, int quizCount, int invitationCount) {
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
          _buildStatItem('Famille', Icons.group, familyCount),
          _buildStatItem('Quiz', Icons.quiz, quizCount),
          _buildStatItem('Invitations', Icons.send, invitationCount),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, IconData icon, int count) {
    return Column(
      children: [
        Icon(icon, color: _mainAccentColor, size: 30),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: _cardTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
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
          Text(
            value,
            style: const TextStyle(fontSize: 8, color: _cardTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationGrid(BuildContext context, List<Invitation> invitationsEnAttente) {
    final itemCount = invitationsEnAttente.isEmpty ? 1 : invitationsEnAttente.length;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        if (invitationsEnAttente.isEmpty) {
          return _buildEmptyInvitationCard();
        }
        return _buildInvitationCard(context, invitationsEnAttente[index]);
      },
    );
  }

  Widget _buildInvitationCard(BuildContext context, Invitation invitation) {
    final bool isPending = invitation.statut == 'EN_ATTENTE';
    IconData statusIcon = Icons.access_time;
    Color statusColor = Colors.orange;

    if (invitation.statut == 'ACCEPTEE') {
      statusIcon = Icons.check;
      statusColor = Colors.green;
    } else if (invitation.statut == 'REFUSEE') {
      statusIcon = Icons.close;
      statusColor = Colors.red;
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
          const Icon(Icons.send, color: _mainAccentColor, size: 30),
          Text(
              invitation.nomFamille,
              style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)
          ),
          _buildFamilyDetailRow('De:', invitation.nomEmetteur, isLast: false),
          _buildFamilyDetailRow('Lien:', invitation.lienParente, isLast: false),
          _buildFamilyDetailRow('Expire le:', '${invitation.dateExpiration.day}/${invitation.dateExpiration.month}', isLast: true),
          isPending
              ? _buildPendingInvitationButtons()
              : _buildActionCircle(statusIcon, statusColor),
        ],
      ),
    );
  }

  Widget _buildEmptyInvitationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, color: Colors.grey, size: 35),
          SizedBox(height: 5),
          Text(
            'Aucune invitation en attente',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCircle() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _mainAccentColor, width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/images/logo_dabo.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPendingInvitationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
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

  Widget _buildActionCircle(IconData icon, Color iconColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _buttonOpacityColor,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

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
                        const SnackBar(content: Text('Découvrir la culture Malienne')),
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