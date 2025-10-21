import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- IMPORTS API AJOUTÉS ---
import 'package:heritage_numerique/Services/InscriptionServices.dart';
import 'package:heritage_numerique/Model/InscriptionReponse.dart';
// Assurez-vous que ces chemins correspondent à la structure de votre projet.
// ---------------------------

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
  bool _isPasswordVisible = false;

  // *** NOUVEL ÉTAT POUR LE BOUTON ***
  bool _isLoading = false;

  // Couleurs
  static const Color _accentColor = Color(0xFFA56C00);
  static final Color _gradientColor = const Color(0xFF9F6901).withOpacity(0.52);
  static const Color _standardTextColor = Colors.black;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Fonction de soumission de la connexion (MAJ AVEC APPEL API)
  void _loginAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Démarrer le chargement
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Appel à l'API de connexion
      final InscriptionReponse result = await loginUser(
        email: _emailController.text,
        motDePasse: _passwordController.text,
      );

      // 3. Succès de la connexion
      if (!mounted) return;

      // *** IMPORTANT : Stockez le token ici (ex: SharedPreferences) ***
      print('Token reçu : ${result.accessToken}');

      // Message de succès (SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion réussie !'),
          backgroundColor: Colors.green,
        ),
      );

      // Naviguer vers la page Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );

    } catch (e) {
      // 4. Échec de la connexion (API ou réseau)
      if (!mounted) return;

      // Message d'erreur utilisateur
      String userMessage = 'Email ou mot de passe incorrect.';

      // Vous pouvez utiliser 'e.toString()' pour des messages d'erreur API plus spécifiques si nécessaire
      print('ERREUR DE CONNEXION DÉTAILLÉE : $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessage),
          backgroundColor: Colors.red,
        ),
      );

    } finally {
      // 5. Arrêter le chargement
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
            // --- 1. ZONE DE L'IMAGE AVEC DÉGRADÉ --- (Inchangé)
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
                      onPressed: () => Navigator.pop(context),
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

            // --- 2. ZONE DU TEXTE ET DU FORMULAIRE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Heritage Numerique', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _standardTextColor), textAlign: TextAlign.center),
                  const SizedBox(height: 5),
                  const Text('Préserver et Promouvoir la culture Malienne', style: TextStyle(fontSize: 16, color: _accentColor), textAlign: TextAlign.center),
                  const SizedBox(height: 30),

                  // --- 3. CONTENEUR DU FORMULAIRE ---
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
                          // Champ Email (Inchangé)
                          _buildStyledTextField(
                            controller: _emailController, icon: Icons.email_outlined, hintText: 'Email', keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Veuillez entrer un email valide';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Champ Mot de passe (Inchangé)
                          _buildStyledTextField(
                            controller: _passwordController, icon: Icons.lock_outline, hintText: 'Mot de passe', obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: _accentColor),
                              onPressed: () { setState(() { _isPasswordVisible = !_isPasswordVisible; }); },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Veuillez entrer votre mot de passe';
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          // --- 4. BOUTON DE CONNEXION (MAJ pour _isLoading) ---
                          SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _loginAccount, // Désactivé si en chargement
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3), // Indicateur de chargement
                              )
                                  : const Text(
                                'Connexion',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- 5. LIEN VERS L'INSCRIPTION et 6. BOUTON GOOGLE (Inchangés) ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Pas de compte? ', style: TextStyle(fontSize: 16, color: _standardTextColor)),
                              GestureDetector(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationScreen())); },
                                child: const Text('S\'inscrire', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _accentColor, decoration: TextDecoration.underline)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connexion avec Google'))); },
                              style: OutlinedButton.styleFrom(backgroundColor: Colors.white, side: BorderSide(color: _accentColor, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
                              child: const Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [Icon(Icons.g_mobiledata, color: Colors.blue, size: 30), SizedBox(width: 5), Text('Se connecter avec Google', style: TextStyle(fontSize: 16, color: _standardTextColor, fontWeight: FontWeight.w500))],
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

  /// Construit un champ de saisie stylisé (Inchangé)
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