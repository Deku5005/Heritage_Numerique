import 'package:flutter/material.dart';

// Import du modèle et des services nécessaires
import '../Service/UtilisateurService1.dart'; // Chemin ajusté
import '../model/utilisateur1.dart'; // Correction du chemin vers models/utilisateur1.dart
import 'package:http/http.dart' as http;


// --- Constantes de Style (Repris de ProfilePage) ---
const Color _primaryColor = Color(0xFF714D1D); // Brun foncé
const Color _primaryTextColor = Color(0xFF000000);
const Color _secondaryTextColor = Color(0xFF99928F); // Gris pour les hints

class EditProfilePage extends StatefulWidget {
  // 1. Recevoir l'objet utilisateur réel via le constructeur
  final Utilisateur1 initialUser;

  // Le constructeur doit accepter initialUser en paramètre nommé et requis
  const EditProfilePage({super.key, required this.initialUser});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Contrôleurs pour les champs de texte
  late final TextEditingController _nameController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _ethnieController;

  // Nouveaux contrôleurs pour le changement de mot de passe
  late final TextEditingController _currentPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  late final UtilisateurService1 _userService;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialisation du service
    _userService = UtilisateurService1();

    // 2. Initialisation des contrôleurs avec les données réelles
    final user = widget.initialUser;

    _nameController = TextEditingController(text: user.nom ?? '');
    _firstNameController = TextEditingController(text: user.prenom ?? '');
    _phoneController = TextEditingController(text: user.numeroTelephone ?? '');
    _emailController = TextEditingController(text: user.email ?? '');
    _ethnieController = TextEditingController(text: user.ethnie ?? '');

    // Initialisation des contrôleurs de mot de passe
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  // Widget pour un champ de formulaire
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool isReadOnly = false,
    bool obscureText = false, // Nouveau paramètre pour masquer le texte
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
              fontSize: 14,
              color: _primaryTextColor,
            ),
          ),
        ),
        // Champ de saisie
        Container(
          height: 36, // Hauteur ajustée
          decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            obscureText: obscureText, // Utilisation du paramètre
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
    _ethnieController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fonction de mise à jour du profil via l'API
  void _updateProfile() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Création de l'objet de mise à jour avec les données du profil
      final Map<String, dynamic> updateData = {
        'nom': _nameController.text,
        'prenom': _firstNameController.text,
        'numeroTelephone': _phoneController.text,
        'email': _emailController.text,
        'ethnie': _ethnieController.text,
      };

      // 2. Logique de Changement de Mot de Passe
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;
      final currentPassword = _currentPasswordController.text;

      // Si au moins un champ de mot de passe est rempli, vérifier la validité
      if (currentPassword.isNotEmpty || newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
        if (newPassword.isEmpty) {
          throw Exception('Le nouveau mot de passe ne peut pas être vide.');
        }
        if (newPassword != confirmPassword) {
          throw Exception('Le nouveau mot de passe et la confirmation ne correspondent pas.');
        }
        // Pour les mises à jour de profil, on envoie le nouveau mot de passe
        // Le backend est censé vérifier l'ancien mot de passe (si demandé)
        // et hasher/mettre à jour le nouveau.
        updateData['motDePasse'] = newPassword;
      }

      // 3. Appel de la méthode de mise à jour
      await _userService.updateProfile(updateData);

      // Succès: affiche un message et retourne à la page précédente avec 'true' pour recharger les données
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès!')),
      );
      // Retourne 'true' pour indiquer à ProfilePage de rafraîchir
      Navigator.of(context).pop(true);

    } catch (e) {
      // Échec: affiche un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la mise à jour du profil : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcul du nom complet pour l'affichage de l'avatar
    final String dynamicUserName = '${_firstNameController.text} ${_nameController.text}'.trim();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 64,
        elevation: 0,
        automaticallyImplyLeading: false,

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
          // Retour simple (sans rechargement si l'utilisateur annule)
          onPressed: () => Navigator.of(context).pop(false),
        ),

        // Titre "Modifier Profil" centré
        title: const Center(
          child: Text(
            'Modifier Profil',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 20,
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
                    dynamicUserName.isNotEmpty ? dynamicUserName[0].toUpperCase() : 'U',
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
                  dynamicUserName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: _primaryTextColor,
                  ),
                ),

                // Email
                Text(
                  widget.initialUser.email ?? 'N/A', // Affiche l'email initial
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _secondaryTextColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // --- Champs de Modification (Nom, Prénom, Ethnie, Téléphone) ---
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
              label: 'Ethnie',
              controller: _ethnieController,
              hintText: 'Ethnie',
            ),

            _buildInputField(
              label: 'Téléphone',
              controller: _phoneController,
              hintText: 'Téléphone',
            ),

            // Email (lecture seule)
            _buildInputField(
              label: 'Email',
              controller: _emailController,
              hintText: 'email@example.com',
              isReadOnly: true,
            ),

            const SizedBox(height: 30),

            // --- Section Changement de Mot de Passe ---
            const Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(
                'Changer le mot de passe',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _primaryColor,
                ),
              ),
            ),

            // Ancien mot de passe
            _buildInputField(
              label: 'Mot de passe actuel',
              controller: _currentPasswordController,
              hintText: 'Entrez votre mot de passe actuel',
              obscureText: true,
            ),

            // Nouveau mot de passe
            _buildInputField(
              label: 'Nouveau mot de passe',
              controller: _newPasswordController,
              hintText: 'Entrez le nouveau mot de passe',
              obscureText: true,
            ),

            // Confirmation du nouveau mot de passe
            _buildInputField(
              label: 'Confirmer le nouveau mot de passe',
              controller: _confirmPasswordController,
              hintText: 'Confirmez le nouveau mot de passe',
              obscureText: true,
            ),


            const SizedBox(height: 50),

            // --- Bouton Enregistrer ---
            Center(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _updateProfile, // Désactivé pendant la sauvegarde
                icon: _isSaving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Icon(Icons.save_outlined, color: Colors.white, size: 24),
                label: Text(
                  _isSaving ? 'Sauvegarde...' : 'Enregistrer',
                  style: const TextStyle(
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