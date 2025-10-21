import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

// IMPORTANT : Assurez-vous que ces chemins d'importation sont corrects.
import 'package:heritage_numerique/Services/InscriptionServices.dart';
import 'package:heritage_numerique/Model/InscriptionReponse.dart';

/// Écran d'inscription pour créer un nouveau compte
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Contrôleurs pour les champs de saisie (Inchangés)
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ethnieController = TextEditingController();
  final _invitationCodeController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  // Couleurs (Inchangées)
  static const Color _accentColor = Color(0xFFA56C00);
  static final Color _gradientColor = const Color(0xFF9F6901).withOpacity(0.52);
  static const Color _standardTextColor = Colors.black;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _ethnieController.dispose();
    _invitationCodeController.dispose();
    super.dispose();
  }

  /// Fonction qui affiche le dialogue de succès et gère la navigation
  void _showSuccessDialogAndNavigate(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Force l'utilisateur à cliquer sur OK
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Succès !', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Se connecter', style: TextStyle(color: _accentColor, fontWeight: FontWeight.bold)),
              onPressed: () {
                // Ferme le dialogue
                Navigator.of(context).pop();
                // Navigue vers la page de connexion après avoir fermé le dialogue
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }


  /// Fonction de soumission de l'inscription (MAJ avec Popup)
  void _registerAccount() async {

    // 1. Validation du formulaire et des conditions (Inchangé)
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez accepter les conditions d\'utilisation'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Préparation des données (Inchangé)
      final String? invitationCode = _invitationCodeController.text.isEmpty
          ? null
          : _invitationCodeController.text;

      // 3. Appel de la fonction d'inscription (Inchangé)
      final InscriptionReponse result = await registerUser(
        nom: _lastNameController.text,
        prenom: _firstNameController.text,
        email: _emailController.text,
        numeroTelephone: _phoneController.text,
        ethnie: _ethnieController.text,
        motDePasse: _passwordController.text,
        codeInvitation: invitationCode,
      );

      // 4. Succès de l'inscription
      if (!mounted) return;

      // *** NOUVEAU : Afficher le POPUP de succès ***
      _showSuccessDialogAndNavigate(result.message ?? 'Votre compte a été créé avec succès !');

    } catch (e) {
      // 5. Échec de l'inscription (Inchangé)
      if (!mounted) return;

      // Affiche un message d'erreur clair (rouge)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec de l\'inscription. Veuillez vérifier vos informations ou la connexion.'),
          backgroundColor: Colors.red,
        ),
      );

      print('ERREUR D\'INSCRIPTION : $e');

    } finally {
      // 6. Arrêter le chargement
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- Le reste de la méthode build (UI) et _buildStyledTextField est inchangé ---

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. ZONE DE L'IMAGE AVEC DÉGRADÉ ---
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_gradientColor, Colors.white],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 40,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: _standardTextColor),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SplashScreen()),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Image.asset(
                        'assets/images/Vieux.png',
                        height: 200,
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          size: 150,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. ZONE DU FORMULAIRE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Heritage Numerique', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _standardTextColor), textAlign: TextAlign.center),
                  const SizedBox(height: 5),
                  const Text('Rejoignez notre communauté culturelle', style: TextStyle(fontSize: 16, color: _accentColor), textAlign: TextAlign.center),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentColor, width: 1.5),
                      boxShadow: [BoxShadow(color: _accentColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Champs du Formulaire
                          _buildStyledTextField(
                            controller: _firstNameController, icon: Icons.person_outline, hintText: 'Prénom',
                            validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer votre prénom' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _lastNameController, icon: Icons.person_outline, hintText: 'Nom',
                            validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer votre nom' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _phoneController, icon: Icons.phone_android_outlined, hintText: 'Numéro de Téléphone', keyboardType: TextInputType.phone,
                            validator: (value) => (value == null || value.isEmpty || !RegExp(r'^\+?[0-9\s]+$').hasMatch(value)) ? 'Veuillez entrer un numéro valide' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _ethnieController, icon: Icons.people_outline, hintText: 'Ethnie',
                            validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer votre ethnie' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _emailController, icon: Icons.email_outlined, hintText: 'Email', keyboardType: TextInputType.emailAddress,
                            validator: (value) => (value == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) ? 'Veuillez entrer un email valide' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _passwordController, icon: Icons.lock_outline, hintText: 'Mot de passe', obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: _accentColor), onPressed: () { setState(() { _isPasswordVisible = !_isPasswordVisible; }); }),
                            validator: (value) => (value == null || value.length < 6) ? 'Le mot de passe doit contenir au moins 6 caractères' : null,
                          ),
                          const SizedBox(height: 20),
                          _buildStyledTextField(
                            controller: _confirmPasswordController, icon: Icons.lock_outline, hintText: 'Confirmer le mot de passe', obscureText: !_isConfirmPasswordVisible,
                            suffixIcon: IconButton(icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: _accentColor), onPressed: () { setState(() { _isConfirmPasswordVisible = !_isConfirmPasswordVisible; }); }),
                            validator: (value) => (value == null || value != _passwordController.text) ? 'Les mots de passe ne correspondent pas' : null,
                          ),
                          const SizedBox(height: 20),

                          _buildStyledTextField(
                            controller: _invitationCodeController, icon: Icons.card_membership_outlined, hintText: 'Code d\'Invitation (Optionnel)',
                          ),
                          const SizedBox(height: 20),

                          // Checkbox
                          Row(
                            children: [
                              Checkbox(value: _acceptTerms, onChanged: (value) { setState(() { _acceptTerms = value ?? false; }); }, activeColor: _accentColor),
                              Expanded(child: GestureDetector(onTap: () { setState(() { _acceptTerms = !_acceptTerms; }); }, child: const Text('J\'accepte les conditions d\'utilisation', style: TextStyle(fontSize: 14)))),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // --- 4. BOUTON D'INSCRIPTION ---
                          SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _registerAccount,
                              style: ElevatedButton.styleFrom(backgroundColor: _accentColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5),
                              child: _isLoading
                                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                  : const Text('S\'inscrire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- 5. LIEN VERS LA CONNEXION et 6. BOUTON GOOGLE ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Déjà un compte? ', style: TextStyle(fontSize: 16, color: _standardTextColor)),
                              GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())); },
                                child: const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _accentColor, decoration: TextDecoration.underline)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: OutlinedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inscription avec Google'))); },
                              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: _accentColor, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [Icon(Icons.g_mobiledata, color: Colors.blue, size: 30), SizedBox(width: 5), Text('S\'inscrire avec Google', style: TextStyle(fontSize: 16, color: _standardTextColor, fontWeight: FontWeight.w500))],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Construit un champ de saisie stylisé
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator ?? (value) => null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
        prefixIcon: Icon(icon, color: _accentColor, size: 24),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _accentColor, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _accentColor, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _accentColor, width: 2.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red, width: 2.5)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}