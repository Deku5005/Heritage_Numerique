import 'package:flutter/material.dart';
// Importez l'AppDrawer
import 'AppDrawer.dart'; 

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311); 
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8); 
const Color _roleAdminColor = Color(0xFFE5B0B0); // Rouge pâle pour Administrateur
const Color _roleTextColor = Color(0xFF7B521A); // Couleur marron foncé pour le texte des rôles
const Color _acceptedColor = Color(0xFFE6F3E6); // Vert pâle pour "Accepté"
const Color _pendingColor = Color(0xFFF7E8D8); // Beige pâle pour "En attente"


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // La page a besoin d'un DefaultTabController pour gérer les onglets 'Envoyées' et 'Reçues'
    return DefaultTabController(
      length: 2, // Nombre d'onglets (Envoyées et Reçues)
      child: Scaffold(
        backgroundColor: _backgroundColor,
        drawer: const AppDrawer(),
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
                      'Paramètre',
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
                    
                    // Section Profil
                    _buildProfileSection(),
                    const SizedBox(height: 20),

                    // Section Invitations
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

  // --- Widgets de Construction de l'Écran ---

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
        Container(
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
                  // Placeholder pour la photo/initiales
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _mainAccentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'N',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Niakalé Diakité',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _cardTextColor),
                      ),
                      Text(
                        'niakal@gmail.com',
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
                      color: _roleAdminColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Administrateur',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _roleTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                      Tab(text: 'Envoyées (3)'),
                      Tab(text: 'Reçues (1)'),
                    ],
                  ),
                ),
              ),

              // TabBarView (Contenu)
              SizedBox(
                height: 350, // Hauteur fixe nécessaire pour TabBarView dans SingleChildScrollView
                child: TabBarView(
                  children: [
                    // Contenu de l'onglet "Envoyées"
                    _buildSentInvitationsContent(),
                    // Contenu de l'onglet "Reçues" (Vide pour le moment)
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

  // Contenu de l'onglet "Envoyées"
  Widget _buildSentInvitationsContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Invitation 1: Acceptée
          _buildInvitationCard(
            name: 'Gaoussou Diakité',
            email: 'gaoussou@gmail.com',
            link: 'Neveu',
            sentDate: '08/10/2023',
            status: 'Acceptée',
          ),
          const SizedBox(height: 15),
          // Invitation 2: En attente
          _buildInvitationCard(
            name: 'Bio Diakité',
            email: 'biou@gmail.com',
            link: 'Neveu',
            sentDate: '09/10/2025',
            status: 'En attente',
            showResendButton: true,
          ),
          // Ajoutez d'autres invitations ici si nécessaire
        ],
      ),
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
    Color statusColor = status == 'Acceptée' ? _acceptedColor : _pendingColor;

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
                    color: status == 'Acceptée' ? Colors.green.shade800 : _roleTextColor,
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