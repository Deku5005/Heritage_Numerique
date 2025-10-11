import 'package:flutter/material.dart';

// Importez l'AppDrawer pour que le Scaffold le reconnaisse
import 'AppDrawer.dart'; 

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311); 
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _lightCardColor = Color(0xFFF7F2E8); // Couleur de fond pour les statistiques

class FamilyTreeScreen extends StatelessWidget {
  const FamilyTreeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: const AppDrawer(), // Ajout du Drawer au Scaffold
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CORRECTION: Utiliser un Builder pour obtenir un context sous le Scaffold
            Builder(
              builder: (BuildContext innerContext) {
                return _buildCustomHeader(innerContext);
              }
            ),
            const SizedBox(height: 10),

            // Statistiques
            _buildStats(),
            const SizedBox(height: 30),

            // Arbre Généalogique
            Center(
              child: Column(
                children: [
                  // Ligne 1 : Membre racine (Grand-père)
                  _buildMemberCard(
                    name: 'Baini Diakité',
                    role: 'Grand-père',
                    birthYear: 1945,
                    contributions: 12,
                    imageAsset: 'assets/baini.jpg', 
                  ),
                  _buildConnectionLine(),

                  // Ligne 2 : Fille (Niakalé Sidibé)
                  _buildMemberCard(
                    name: 'Niakalé Sidibé',
                    role: 'Fille',
                    birthYear: 1970,
                    contributions: 12,
                    imageAsset: 'assets/niakale.jpg', 
                  ),
                  _buildConnectionLine(),
                  
                  // Ligne 3 : Les fils (Sekou et Boubacar)
                  _buildHorizontalLevel([
                    _buildMemberCard(
                      name: 'Sekou Diakité',
                      role: 'Fils',
                      birthYear: 1960,
                      contributions: 12,
                      imageAsset: 'assets/sekou.jpg', 
                    ),
                    _buildMemberCard(
                      name: 'Boubacar Diakité',
                      role: 'Fils',
                      birthYear: 1965,
                      contributions: 12,
                      imageAsset: 'assets/boubacar.jpg', 
                    ),
                  ]),
                  _buildConnectionLine(isVertical: true, height: 20), 
                  
                  // Ligne 4 : Petits-enfants (Ami et Oumou)
                  _buildHorizontalLevel([
                    _buildMemberCard(
                      name: 'Ami Diakité',
                      role: 'Petite Fille',
                      birthYear: 1970,
                      contributions: 12,
                      imageAsset: 'assets/ami.jpg', 
                    ),
                    _buildMemberCard(
                      name: 'Oumou Diakité',
                      role: 'Petite Fille',
                      birthYear: 1970,
                      contributions: 12,
                      imageAsset: 'assets/oumou.jpg', 
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets de construction de l'Arbre ---

  // En-tête Personnalisé (MODIFIÉ pour avoir le menu burger)
  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icône du menu (hamburger)
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              // Action pour ouvrir le Drawer - Utilisation du context valide (innerContext)
              Scaffold.of(context).openDrawer();
            },
          ),
          // Titre principal
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _cardTextColor,
            ),
          ),
          // Bouton Fermer (maintenu pour le style ou simplement une icône vide si non nécessaire)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context), // Fermer (similaire au retour)
          ),
        ],
      ),
    );
  }

  // Section des statistiques (3 Générations, 7 Membres, Depuis 1945)
  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Arbre Généalogique',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
          ),
          const Text(
            'La Famille Diakité à travers les générations',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBox(label: 'Générations', value: '3'),
              _buildStatBox(label: 'Membres', value: '7'),
              _buildStatBox(label: 'Depuis', value: '1945'),
            ],
          ),
        ],
      ),
    );
  }

  // Boîte de statistique individuelle
  Widget _buildStatBox({required String label, required String value}) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: _lightCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _mainAccentColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: _cardTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // Carte de membre dans l'arbre
  Widget _buildMemberCard({
    required String name,
    required String role,
    required int birthYear,
    required int contributions,
    required String imageAsset,
  }) {
    return Container(
      width: 200, // Largeur fixe pour la carte
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image de profil
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade200, // Placeholder pour l'image
              // NOTE: Utilisez Image.asset ou CachedNetworkImage ici
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 10),
          // Informations du membre
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _cardTextColor),
              ),
              Text(
                '$role',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                'Né en $birthYear',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, size: 12, color: _mainAccentColor),
                  const SizedBox(width: 4),
                  Text(
                    '$contributions Contributions',
                    style: TextStyle(fontSize: 10, color: _mainAccentColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Simule les lignes de connexion verticales (à ajuster manuellement)
  Widget _buildConnectionLine({bool isVertical = false, double height = 30}) {
    if (isVertical) {
      return Container(
        width: 2,
        height: height,
        color: Colors.grey.shade400,
        margin: const EdgeInsets.symmetric(vertical: 5),
      );
    }
    // Ligne verticale simple entre les générations
    return Container(
      width: 2,
      height: 30,
      color: Colors.grey.shade400,
      margin: const EdgeInsets.symmetric(vertical: 5),
    );
  }

  // Structure pour les niveaux horizontaux (frères/sœurs)
  Widget _buildHorizontalLevel(List<Widget> members) {
    return Column(
      children: [
        // Ligne horizontale pour connecter les frères/sœurs
        Container(
          width: 300, // Ajuster cette largeur
          height: 2,
          color: Colors.grey.shade400,
          margin: const EdgeInsets.only(bottom: 10),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: members,
        ),
      ],
    );
  }
}