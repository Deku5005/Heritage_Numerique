import 'package:flutter/material.dart';

// --- Constantes de Style (Repris de ProfilePage) ---
const Color _primaryColor = Color(0xFF714D1D); // Brun foncé
const Color _primaryTextColor = Color(0xFF000000);
const Color _secondaryTextColor = Color(0xFF99928F); // Gris pour les hints

// Constantes pour les données du profil (Utilisées comme valeurs initiales/hints)
const String _userName = 'Niakalé Diakité';
const String _userEmail = 'niakale@gmail.com';
const String _userFirstName = 'Niakalé';
const String _userPhone = '+223 77777777';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Contrôleurs pour les champs de texte
  final TextEditingController _nameController = TextEditingController(text: _userFirstName);
  final TextEditingController _firstNameController = TextEditingController(text: _userFirstName);
  final TextEditingController _phoneController = TextEditingController(text: _userPhone);
  final TextEditingController _emailController = TextEditingController(text: _userEmail);

  // Widget pour un champ de formulaire
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre du champ
        Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 4.0, bottom: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 14, // Légèrement augmenté pour la clarté
              color: _primaryTextColor,
            ),
          ),
        ),
        // Champ de saisie
        Container(
          height: 36, // Hauteur ajustée pour correspondre au design
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _primaryTextColor,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _secondaryTextColor.withOpacity(0.6),
              ),
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: _primaryColor.withOpacity(0.8), width: 1.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile(BuildContext context) {
    // Logique de sauvegarde ici (par exemple, appel API ou mise à jour de l'état)
    print('Nom: ${_nameController.text}');
    print('Prénom: ${_firstNameController.text}');
    print('Téléphone: ${_phoneController.text}');
    print('Email: ${_emailController.text}');

    // Après la sauvegarde, on revient à la page de profil
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 64,
        elevation: 0,
        automaticallyImplyLeading: false, // On gère le retour manuellement

        // Conteneur pour simuler l'ombre sous l'App Bar
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

        // Bouton de retour (Flèche)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryTextColor),
          onPressed: () => Navigator.of(context).pop(), // Retour à la page précédente
        ),

        // Titre "Modifier Profil" centré
        title: const Center(
          child: Text(
            'Modifier Profil',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 20, // Ajusté à 20px
              color: _primaryTextColor,
            ),
          ),
        ),

      ),

      // Corps de la page
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // --- Informations Utilisateur (Avatar + Noms/Email) ---
            Column(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _userName[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
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
                    fontSize: 14,
                    color: _secondaryTextColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- Champs de Modification ---
            _buildInputField(
              label: 'Nom',
              controller: _nameController,
              hintText: 'nom',
            ),

            _buildInputField(
              label: 'Prénom',
              controller: _firstNameController,
              hintText: 'prenom',
            ),

            _buildInputField(
              label: 'Téléphone',
              controller: _phoneController,
              hintText: '+223 77777777',
            ),

            _buildInputField(
              label: 'Email',
              controller: _emailController,
              hintText: 'niakale@gmail.com',
            ),

            // NOTE : Le champ "Changer mot de passe" serait une action ou un champ masqué, non un champ de texte standard sur cette page.

            const SizedBox(height: 50),

            // --- Bouton Enregistrer ---
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _saveProfile(context),
                icon: const Icon(Icons.save_outlined, color: Colors.white, size: 24),
                label: const Text(
                  'Enregistrer',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
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
                  minimumSize: const Size(150, 50), // Taille ajustée
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