import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// NOTE: Assurez-vous que ces chemins d'importation sont corrects
import 'package:heritage_numerique/Service/Auth-service.dart';
import 'package:heritage_numerique/model/auth-response.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

/// Écran d'inscription pour créer un nouveau compte
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Contrôleurs pour les champs de saisie
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();     // numeroTelephone
  final _ethnieController = TextEditingController();    // ethnie
  final _invitationCodeController = TextEditingController(); // codeInvitation (Optionnel)
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // États de l'UI
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

  // Service d'API
  final AuthService _authService = AuthService();

  // Couleurs
  static const Color _accentColor = Color(0xFFA56C00);
  static final Color _gradientColor = const Color(0xFF9F6901).withOpacity(0.52);
  static const Color _standardTextColor = Colors.black;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ethnieController.dispose();
    _invitationCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Fonction de soumission de l'inscription
  void _registerAccount() async {
    // 1. Validation du formulaire
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

    // 2. Afficher l'indicateur de chargement
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Appel de l'API avec les données des contrôleurs
      await _authService.register(
        nom: _lastNameController.text.trim(),
        prenom: _firstNameController.text.trim(),
        email: _emailController.text.trim(),
        numeroTelephone: _phoneController.text.trim(),
        ethnie: _ethnieController.text.trim(),
        motDePasse: _passwordController.text,
        codeInvitation: _invitationCodeController.text.trim().isNotEmpty
            ? _invitationCodeController.text.trim()
            : null,
      );

      // 4. ✅ Succès de l'inscription et décodage JSON réussi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Veuillez vous connecter.'),
            backgroundColor: Colors.green,
          ),
        );

        // Redirection vers la page de connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }

    } on Exception catch (e) {
      // 5. ❌ Échec de l'inscription (inclut les erreurs de type/format du 200 ou les erreurs 4xx/5xx)
      if (mounted) {
        // Le replaceFirst est pour supprimer le préfixe 'Exception: '
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 6. Arrêter l'indicateur de chargement
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

            // --- 2. ZONE DU TEXTE (SOUS L'IMAGE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  const Text(
                    'Rejoignez notre communauté culturelle',
                    style: TextStyle(
                      fontSize: 16,
                      color: _accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // --- 3. CONTENEUR DU FORMULAIRE ---
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
                          // Prénom (prenom)
                          _buildStyledTextField(
                            controller: _firstNameController,
                            icon: Icons.person_outline,
                            hintText: 'Prénom',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre prénom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Nom (nom)
                          _buildStyledTextField(
                            controller: _lastNameController,
                            icon: Icons.person_outline,
                            hintText: 'Nom',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre nom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Email (email)
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

                          // Numéro de Téléphone (numeroTelephone)
                          _buildStyledTextField(
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            hintText: 'Numéro de Téléphone',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre numéro de téléphone';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Ethnie (ethnie)
                          _buildStyledTextField(
                            controller: _ethnieController,
                            icon: Icons.public_outlined,
                            hintText: 'Ethnie',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre ethnie';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Code d'invitation (codeInvitation - optionnel)
                          _buildStyledTextField(
                            controller: _invitationCodeController,
                            icon: Icons.card_giftcard_outlined,
                            hintText: 'Code d\'invitation (Optionnel)',
                          ),
                          const SizedBox(height: 20),

                          // Mot de passe (motDePasse)
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
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Confirmer mot de passe
                          _buildStyledTextField(
                            controller: _confirmPasswordController,
                            icon: Icons.lock_outline,
                            hintText: 'Confirmer le mot de passe',
                            obscureText: !_isConfirmPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: _accentColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez confirmer votre mot de passe';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Checkbox pour accepter les conditions
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                                activeColor: _accentColor,
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _acceptTerms = !_acceptTerms;
                                    });
                                  },
                                  child: const Text(
                                    'J\'accepte les conditions d\'utilisation',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // --- 4. BOUTON D'INSCRIPTION ---
                          SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _registerAccount,
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
                                'S\'inscrire',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- 5. LIEN VERS LA CONNEXION ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Déjà un compte? ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _standardTextColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                                child: const Text(
                                  'Se connecter',
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
                                    content: Text('Inscription avec Google (non implémentée)'),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.g_mobiledata, color: Colors.blue, size: 30),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'S\'inscrire avec Google',
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