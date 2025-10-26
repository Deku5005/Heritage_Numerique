import 'package:flutter/material.dart';
import 'AppDrawer.dart'; // NÉCESSAIRE pour pouvoir utiliser AppDrawer
import 'Profil.dart';
import 'editProfil.dart'; // NOUVEAU : Import pour la navigation

// --- Constantes de Style ---
const Color _primaryColor = Color(0xFF714D1D); // Brun foncé pour l'avatar et le bouton
const Color _primaryTextColor = Color(0xFF000000);
const Color _secondaryTextColor = Color(0xFF99928F); // Gris pour les emails/valeurs
// const Color _dividerColor = Color(0xFFE0E0E0); // Non utilisé après la suppression du tiret

// Constantes pour les données du profil
const String _userName = 'Niakalé Diakité';
const String _userEmail = 'niakale@gmail.com';
const String _userFirstName = 'Niakalé';
const String _userPhone = '+223 77777777';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Widget pour une ligne de détail du profil (Icône + Titre + Valeur)
  Widget _buildProfileDetail({
    required IconData icon,
    required String title,
    required String value,
    bool isPassword = false,
  }) {
    return Padding(
      // Augmenter le padding pour séparer les éléments après la suppression du tiret
      padding: const EdgeInsets.only(bottom: 35.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alignement en haut
        children: [
          // 1. Icône
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 2.0), // Ajustement top pour aligner le texte
            child: Icon(icon, color: _primaryTextColor, size: 28), // Taille de l'icône légèrement augmentée
          ),

          // 2. Texte de la colonne
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _primaryTextColor,
                    height: 1.4,
                  ),
                ),

                Text(
                  isPassword ? '******' : value,
                  style: TextStyle(
                    fontWeight: isPassword ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 14,
                    color: isPassword ? _primaryTextColor : _secondaryTextColor,
                    height: 1.4,
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  // NOUVELLE MÉTHODE : Gère la navigation vers la page de modification
  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // 1. AJOUT DU DRAWER AU SCAFFOLD
      drawer: const AppDrawer(), // Ajouté pour permettre l'ouverture du tiroir

      // App Bar (Utilise la structure de ProverbeCollectionScreen)
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 64,
        elevation: 0,

        // Simuler le box-shadow
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),

        // Supprimer l'implicite leading
        automaticallyImplyLeading: false,


        // 2. UTILISER BUILDER POUR OUVRIR LE DRAWER
        leading: Builder(
          builder: (BuildContext innerContext) { // Utiliser Builder pour obtenir un contexte qui inclut le Scaffold
            return IconButton(
              icon: const Icon(Icons.menu, color: _primaryTextColor),
              onPressed: () {
                // COMMANDE CORRECTE : Ouvre le tiroir
                Scaffold.of(innerContext).openDrawer();
              },
            );
          },
        ),

        // Titre "Héritage Numérique" centré
        title: const Center(
          child: Text(
            'Héritage Numérique',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: _primaryTextColor,
            ),
          ),
        ),

        // Pour équilibrer le leading icon, on peut ajouter un SizedBox vide
        actions: [
          SizedBox(width: AppBar().leadingWidth), // Utilise la même largeur que l'icône leading
        ],
      ),

      // Corps de la page (Profil)
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // --- Titre "Profil" ---
            const Padding(
              padding: EdgeInsets.only(bottom: 30.0),
              child: Text(
                'Profil',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: _primaryTextColor,
                ),
              ),
            ),

            // --- Informations Utilisateur (Avatar + Noms/Email) ---
            Column(
              children: [
                // Avatar
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _userName[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Nom complet
                Text(
                  _userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: _primaryTextColor,
                  ),
                ),

                // Email
                Text(
                  _userEmail,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: _secondaryTextColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // --- Champs de Détail du Profil ---
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Column(
                children: [
                  _buildProfileDetail(
                    icon: Icons.person_outline,
                    title: 'Nom',
                    value: _userFirstName,
                  ),

                  _buildProfileDetail(
                    icon: Icons.person_outline,
                    title: 'Prénom',
                    value: _userFirstName,
                  ),

                  _buildProfileDetail(
                    icon: Icons.phone_outlined,
                    title: 'Téléphone',
                    value: _userPhone,
                  ),

                  _buildProfileDetail(
                    icon: Icons.mail_outline,
                    title: 'Email',
                    value: _userEmail,
                  ),

                  _buildProfileDetail(
                    icon: Icons.lock_outline,
                    title: 'Changer mot d epasse',
                    value: 'placeholder',
                    isPassword: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Bouton Modifier (avec navigation vers EditProfilePage) ---
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToEditProfile(context), // Appel à la fonction de navigation
                icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                label: const Text(
                  'Modifier',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shadowColor: Colors.black.withOpacity(0.25),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  minimumSize: const Size(150, 50),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
