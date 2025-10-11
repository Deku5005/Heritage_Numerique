import 'package:flutter/material.dart';

// --- Constantes de Couleurs ---
// AA7311 est la couleur Ocre (Golden/Brownish Yellow)
const Color _mainAccentColor = Color(0xFFAA7311); 
// D9D9D9 avec 53% d'opacité (gris clair transparent)
const Color _buttonOpacityColor = Color(0x87D9D9D9); 
// Couleur blanche pour le fond
const Color _backgroundColor = Colors.white;
// Couleur du texte principal
const Color _cardTextColor = Color(0xFF2E2E2E);


class CreateFamilyAccountScreen extends StatelessWidget {
  const CreateFamilyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // Utilisation d'un CustomScrollView pour une structure plus complexe
      body: CustomScrollView(
        slivers: [
          // 1. AppBar Personnalisée (Héritage Numérique)
          SliverAppBar(
            backgroundColor: _backgroundColor,
            automaticallyImplyLeading: false, // Supprime le bouton retour par défaut
            pinned: true,
            toolbarHeight: 80, // Hauteur ajustée pour le titre
            title: Row(
              children: [
                // Icône du menu (hamburger)
                IconButton(
                  icon: const Icon(Icons.menu, color: _cardTextColor),
                  onPressed: () {
                    // Action pour ouvrir le tiroir de navigation
                  },
                ),
                const Spacer(),
                // Titre centré
                const Text(
                  'Héritage Numérique',
                  style: TextStyle(
                    color: _cardTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const Spacer(flex: 2), // Espace pour centrer le titre
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icône de retour (flèche gauche)
                    InkWell(
                      onTap: () {
                        // Action de retour
                        Navigator.pop(context); 
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Icon(Icons.arrow_back, color: _mainAccentColor, size: 28),
                      ),
                    ),
                    const Text(
                      'Créer Votre Compte Familial',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Commencez à préserver votre patrimoine familial',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          // 2. Corps du formulaire (SliverList)
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildFormCard(),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Conteneur principal du formulaire ---
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Nom famille', 'Ex: Dolo'),
          const SizedBox(height: 20),
          _buildTextField('Votre nom complet', 'Ex: Oumar Dolo'),
          const SizedBox(height: 20),
          _buildTextField('Votre email', 'Ex: dolo@gmail.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 20),
          _buildTextField('Mot de passe', 'Ex: dolo@1223', isPassword: true),
          const SizedBox(height: 40),
          
          // Bouton Créer (couleur ocre)
          _buildCreateButton(),
        ],
      ),
    );
  }

  // --- Champ de texte personnalisé ---
  Widget _buildTextField(String label, String hint, {TextInputType keyboardType = TextInputType.text, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _cardTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _mainAccentColor.withOpacity(0.5), fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            // Fond du champ
            fillColor: Colors.white, 
            filled: true,
            // Bordure
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: _mainAccentColor.withOpacity(0.5), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: const BorderSide(color: _mainAccentColor, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  // --- Bouton Créer ---
  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Logique pour créer le compte
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _mainAccentColor, // Couleur de fond ocre
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 5,
        ),
        child: const Text(
          'Créer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}