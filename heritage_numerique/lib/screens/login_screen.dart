import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Nettoyage des imports
import 'package:heritage_numerique/Service/Auth-service.dart';
import 'package:heritage_numerique/model/auth-response.dart';
// import 'package:heritage_numerique/screens/HomeDashboardScreen.dart'; // Non utilisé dans la navigation
import 'registration_screen.dart';
import 'dashboard_screen.dart';



/// Écran de connexion pour accéder au compte
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Contrôleurs pour les champs de saisie
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _invitationCodeController = TextEditingController();

  // Service et état
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Couleurs
  static const Color _accentColor = Color(0xFFA56C00);
  static final Color _gradientColor = const Color(0xFF9F6901).withOpacity(0.52);
  static const Color _standardTextColor = Colors.black;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _invitationCodeController.dispose();
    super.dispose();
  }

  /// Fonction de soumission de la connexion
  void _loginAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Afficher l'indicateur de chargement
    setState(() {
      _isLoading = true;
    });

    try {
      final String? code = _invitationCodeController.text.trim().isNotEmpty
          ? _invitationCodeController.text.trim()
          : null;

      // 1. Appel de la méthode de connexion de l'AuthService
      final AuthResponse authResponse = await _authService.login(
        email: _emailController.text.trim(),
        motDePasse: _passwordController.text,
        codeInvitation: code,
      );

      // 2. ✅ Connexion réussie : Affichage du succès et navigation
      if (mounted) {
        // Afficher un message de succès (avec le prénom si possible)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Connexion réussie ! Bienvenue ${authResponse.prenom}.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2), // Ajout d'une durée
          ),
        );
        // Naviguer vers la page Dashboard en remplaçant l'écran actuel
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // ✅ CORRECTION : Utilisation de const, car l'erreur de "Not a constant expression" était liée au lambda
            // Si la classe DashboardScreen a un constructeur const, cette ligne est correcte.
            builder: (context) =>  DashboardScreen(),
          ),
        );
      }} on Exception catch (e) {

      // 3. ❌ Échec de la connexion
      if (mounted) {
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5), // Laisse le temps de lire l'erreur
          ),
        );
      }
    } finally {
      // 4. Masquer l'indicateur de chargement
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
                  // Icône de retour
                  Positioned(
                    top: 40,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: _standardTextColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Image de l'homme assis
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

            // --- 2. ZONE DU TEXTE (SOUS L'IMAGE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Texte principal en gras: Heritage Numerique
                  const Text(
                    'Heritage Numerique',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _standardTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  // Sous-titre en couleur A56C00
                  const Text(
                    'Préserver et Promouvoir la culture Malienne',
                    style: TextStyle(
                      fontSize: 16,
                      color: _accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // --- 3. CONTENEUR DU FORMULAIRE BLANC AVEC BORDURE ACCENTUÉE ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _accentColor,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Champ Email
                          _buildStyledTextField(
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Veuillez entrer un email valide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Champ Mot de passe
                          _buildStyledTextField(
                            controller: _passwordController,
                            icon: Icons.lock_outline,
                            hintText: 'Mot de passe',
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: _accentColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre mot de passe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Champ Code d'invitation (Optionnel)
                          _buildStyledTextField(
                            controller: _invitationCodeController,
                            icon: Icons.card_giftcard_outlined,
                            hintText: 'Code d\'invitation (Optionnel)',
                          ),

                          const SizedBox(height: 40),

                          // --- 4. BOUTON DE CONNEXION ---
                          SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _loginAccount, // Désactivé si chargement
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                                  : const Text(
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- 5. LIEN VERS L'INSCRIPTION ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Pas de compte? ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _standardTextColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                                  );
                                },
                                child: const Text(
                                  'S\'inscrire',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _accentColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // --- 6. BOUTON GOOGLE ---
                          SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Connexion avec Google (non implémentée)'),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: BorderSide(color: _accentColor, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.g_mobiledata, color: Colors.blue, size: 30),
                                  SizedBox(width: 5),
                                  Text(
                                    'Se connecter avec Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: _standardTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
        prefixIcon: Icon(icon, color: _accentColor, size: 24),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _accentColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _accentColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _accentColor, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}