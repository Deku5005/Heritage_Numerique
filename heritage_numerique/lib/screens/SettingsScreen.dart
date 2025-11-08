import 'package:flutter/material.dart';
// Importez l'AppDrawer
import 'AppDrawer.dart';
// Importations nécessaires pour l'intégration du service
import 'package:heritage_numerique/model/MemberResponseModel.dart';
// Le fichier MemberService.dart contient la classe FamilleMembreService
import 'package:heritage_numerique/Service/MemberService.dart';
import 'package:heritage_numerique/Service/auth-service.dart';
// Importations nécessaires pour la gestion des invitations
import 'package:heritage_numerique/model/InvitationResponse.dart';
import 'package:heritage_numerique/Service/InvitationService2.dart';


// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _roleAdminColor = Color(0xFFE5B0B0); // Rouge pâle pour Administrateur
const Color _roleTextColor = Color(0xFF7B521A); // Couleur marron foncé pour le texte des rôles
const Color _acceptedColor = Color(0xFFE6F3E6); // Vert pâle pour "Accepté"
const Color _pendingColor = Color(0xFFF7E8D8); // Beige pâle pour "En attente"


// 1. Conversion en StatefulWidget
class SettingsScreen extends StatefulWidget {
  final int familyId;

  const SettingsScreen({super.key, required this.familyId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 2. Déclaration et initialisation des services
  late final AuthService _authService;
  // Correction du type de classe
  late final FamilleMembreService _membreService;
  late final InvitationService _invitationService;


  // 3. Déclaration du Future pour les détails du membre
  // CHANGEMENT: Le Future renvoie la liste complète de la méthode fetchMembresByFamilleId
  late Future<List<MembreResponse>> _membreDetailsListFuture;
  late Future<List<InvitationResponse>> _sentInvitationsFuture;


  @override
  void initState() {
    super.initState();
    // Initialisation des services
    _authService = AuthService();
    _membreService = FamilleMembreService(_authService);
    _invitationService = InvitationService(_authService);


    // CHANGEMENT MAJEUR: Appel de la méthode existante du service
    // Celle-ci retourne une liste (qui contient 1 élément : le profil du membre)
    _membreDetailsListFuture = _membreService.fetchMembresByFamilleId(familleId: widget.familyId);
    _sentInvitationsFuture = _invitationService.fetchFamilyInvitations(widget.familyId);
  }

  // --- Widgets de Construction de l'Écran ---

  @override
  Widget build(BuildContext context) {
    // La page a besoin d'un DefaultTabController pour gérer les onglets 'Envoyées' et 'Reçues'
    return DefaultTabController(
      length: 2, // Nombre d'onglets (Envoyées et Reçues)
      child: Scaffold(
        backgroundColor: _backgroundColor,
        // familyId est passé à AppDrawer
        drawer: AppDrawer(familyId: widget.familyId),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. En-tête (Menu Burger, Titre, Bouton Fermer)
              Builder(
                  builder: (BuildContext innerContext) {
                    return _buildCustomHeader(innerContext, context);
                  }
              ),
              const SizedBox(height: 20),

              // 2. Corps de la page (Titre, Profil, Invitations)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre et Sous-titre
                    const Text(
                      'Paramètres',
                      style: TextStyle(
                        color: _cardTextColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Gérez votre profil et vos préférences',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section Profil (Dynamique - utilise le FutureBuilder)
                    _buildProfileSection(),
                    const SizedBox(height: 20),

                    // Section Invitations (Statique)
                    _buildInvitationsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext innerContext, BuildContext pageContext) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              Scaffold.of(innerContext).openDrawer();
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
            onPressed: () => Navigator.pop(pageContext),
          ),
        ],
      ),
    );
  }

  // Section Profil pour être dynamique
  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profil utilisateur',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _cardTextColor,
          ),
        ),
        const SizedBox(height: 10),
        // CHANGEMENT: FutureBuilder attend une LISTE de MembreResponse
        FutureBuilder<List<MembreResponse>>(
          future: _membreDetailsListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard(); // Afficher le chargement
            } else if (snapshot.hasError) {
              // Afficher l'erreur
              return _buildErrorCard(snapshot.error.toString().replaceFirst('Exception: ', ''));
            } else if (snapshot.hasData) {
              final List<MembreResponse> membres = snapshot.data!;

              // VÉRIFICATION: On s'assure que la liste n'est pas vide et on prend le premier (le profil)
              if (membres.isEmpty) {
                return _buildErrorCard('Profil non trouvé. La famille est vide.');
              }

              final membre = membres.first;
              return _buildProfileCard(membre);
            }
            // Cas par défaut (ne devrait pas arriver souvent)
            return const Text('Aucune donnée de membre disponible.');
          },
        ),
      ],
    );
  }

  // Widget pour la carte de profil dynamique (quand les données sont disponibles)
  Widget _buildProfileCard(MembreResponse membre) {
    // Calcul des initiales (Première lettre du prénom + première lettre du nom)
    final String initiales = '${membre.prenom.isNotEmpty ? membre.prenom[0] : ''}${membre.nom.isNotEmpty ? membre.nom[0] : ''}'.toUpperCase();
    final String nomComplet = '${membre.prenom} ${membre.nom}';
    // Logique simple pour la couleur du rôle
    final Color roleBackgroundColor = membre.roleFamille.toLowerCase() == 'administrateur' ? _roleAdminColor : _searchBackground;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _searchBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information sur votre compte',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Photo/initiales
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _mainAccentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    initiales,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomComplet,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _cardTextColor),
                  ),
                  Text(
                    membre.email,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Rôle actuel:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(width: 8),
              // Étiquette de Rôle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  membre.roleFamille,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _roleTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Affichage du numéro de téléphone et de l'ethnie
          _buildDetailRow(
            icon: Icons.phone,
            label: 'Téléphone:',
            // ✅ Utilise numeroTelephone du modèle
            value: membre.numeroTelephone.isNotEmpty ? membre.numeroTelephone : 'Non spécifié',
          ),
          _buildDetailRow(
            icon: Icons.language,
            label: 'Ethnie:',
            value: membre.ethnie.isNotEmpty ? membre.ethnie : 'Non spécifiée',
          ),
        ],
      ),
    );
  }

  // Widget utilitaire pour afficher une ligne de détail
  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: _mainAccentColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: _cardTextColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Widget d'affichage de chargement
  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 180,
      decoration: BoxDecoration(
        color: _searchBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _mainAccentColor),
            SizedBox(height: 10),
            Text('Chargement du profil...', style: TextStyle(color: _cardTextColor)),
          ],
        ),
      ),
    );
  }

  // Widget d'affichage d'erreur
  Widget _buildErrorCard(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFFEEEEE), // Rouge très pâle pour l'erreur
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 30),
            const SizedBox(height: 10),
            const Text(
              'Erreur de chargement du profil',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Traduit le statut du backend en affichage utilisateur
  String _translateStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACCEPTEE':
        return 'Acceptée';
      case 'EN_ATTENTE':
        return 'En attente';
      case 'REJETEE':
        return 'Rejetée';
      default:
        return status;
    }
  }

  // Section Invitations
  Widget _buildInvitationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invitations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: _cardTextColor,
          ),
        ),
        const SizedBox(height: 10),

        // Conteneur des onglets (TabBar + Contenu)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // TabBar (les deux boutons)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white, // Indicateur blanc
                        border: Border.all(color: Colors.grey.shade300)
                    ),
                    labelColor: _cardTextColor,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Envoyées'),
                      Tab(text: 'Reçues'),
                    ],
                  ),
                ),
              ),

              // TabBarView (Contenu)
              SizedBox(
                height: 350, // Hauteur fixe nécessaire pour TabBarView dans SingleChildScrollView
                child: TabBarView(
                  children: [
                    // Contenu de l'onglet "Envoyées" (Maintenant dynamique)
                    _buildSentInvitationsContent(),
                    // Contenu de l'onglet "Reçues" (Placeholder)
                    _buildReceivedInvitationsContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Contenu de l'onglet "Envoyées" (Utilise FutureBuilder)
  Widget _buildSentInvitationsContent() {
    return FutureBuilder<List<InvitationResponse>>(
      future: _sentInvitationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
        } else if (snapshot.hasError) {
          // Affiche le message d'erreur du service
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Erreur de chargement des invitations: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Aucune invitation envoyée pour le moment.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          );
        } else {
          final invitations = snapshot.data!;
          // Utilise ListView.separated pour afficher les données réelles
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: invitations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              final inv = invitations[index];
              final String status = inv.statut.toUpperCase();

              // La date de création sera formatée pour être plus lisible
              final String formattedDate = '${inv.dateCreation.day.toString().padLeft(2, '0')}/${inv.dateCreation.month.toString().padLeft(2, '0')}/${inv.dateCreation.year}';

              return _buildInvitationCard(
                name: inv.nomInvite,
                email: inv.emailInvite,
                link: inv.lienParente,
                sentDate: formattedDate,
                status: _translateStatus(status),
                // Le bouton Renvoyer s'affiche uniquement si le statut est 'EN_ATTENTE'
                showResendButton: status == 'EN_ATTENTE',
              );
            },
          );
        }
      },
    );
  }

  // Contenu de l'onglet "Reçues" (Placeholder)
  Widget _buildReceivedInvitationsContent() {
    return Center(
      child: Text(
        'Vous n\'avez aucune invitation reçue pour le moment.',
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  // Widget commun pour les cartes d'invitation
  Widget _buildInvitationCard({
    required String name,
    required String email,
    required String link,
    required String sentDate,
    required String status,
    bool showResendButton = false,
  }) {
    Color statusColor;
    Color statusTextColor;

    switch (status.toUpperCase()) {
      case 'ACCEPTÉE':
        statusColor = _acceptedColor;
        statusTextColor = Colors.green.shade800;
        break;
      case 'REJETÉE':
        statusColor = const Color(0xFFFEEEEE); // Rouge très pâle pour l'erreur
        statusTextColor = Colors.red.shade800;
        break;
      case 'EN ATTENTE':
      default:
        statusColor = _pendingColor;
        statusTextColor = _roleTextColor; // Couleur marron par défaut pour Pending
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _cardTextColor),
                  ),
                  Text(
                    email,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              // Étiquette de Statut
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lien de parenté: $link', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text('Membre actif', style: TextStyle(fontSize: 13, color: _cardTextColor, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('Envoyée le : $sentDate', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          if (showResendButton) ...[
            const SizedBox(height: 10),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  // Logique de renvoi de l'invitation
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _mainAccentColor),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text('Renvoyer', style: TextStyle(color: _mainAccentColor, fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }
}