import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'splash_screen.dart';
import 'package:heritage_numerique/models/auth_models.dart';
import 'package:heritage_numerique/repositories/auth_repository.dart';

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
  final _phoneController = TextEditingController();
  final _ethnieController = TextEditingController();
  final _codeInvitationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;
  
  // Repository pour l'authentification
  final AuthRepository _authRepository = AuthRepository();

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
    _codeInvitationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Fonction de soumission de l'inscription
  Future<void> _registerAccount() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Créer la requête d'inscription
        final registerRequest = RegisterRequest(
          nom: _lastNameController.text.trim(),
          prenom: _firstNameController.text.trim(),
          email: _emailController.text.trim(),
          numeroTelephone: _phoneController.text.trim(),
          ethnie: _ethnieController.text.trim(),
          motDePasse: _passwordController.text,
          codeInvitation: _codeInvitationController.text.trim().isNotEmpty 
              ? _codeInvitationController.text.trim() 
              : null,
        );

        // Appeler l'API d'inscription
        final response = await _authRepository.register(registerRequest);

        if (response.success && response.data != null) {
          // Sauvegarder les données d'authentification
          await _authRepository.saveAuthData(response.data!);
          
          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inscription réussie ! Bienvenue ${response.data!.fullName}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Naviguer vers la page d'accueil (Dashboard)
          // TODO: Remplacer par votre écran de dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SplashScreen()),
          );
        } else {
          // Afficher l'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Erreur lors de l\'inscription'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        // Gérer les erreurs de connexion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: Colors.red,
        ),
      );
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
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SplashScreen()),
                      ),
                    ),
                  ),
                  // Image de la femme avec le bébé
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
                    'Rejoignez notre communauté culturelle',
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
                          // Champ Prénom
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
                          
                          // Champ Nom
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
                          
                          // Champ Numéro de téléphone
                          _buildStyledTextField(
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            hintText: 'Numéro de téléphone',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre numéro de téléphone';
                              }
                              if (value.length < 8) {
                                return 'Le numéro de téléphone doit contenir au moins 8 chiffres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Champ Ethnie
                          _buildStyledTextField(
                            controller: _ethnieController,
                            icon: Icons.people_outline,
                            hintText: 'Ethnie',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre ethnie';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Champ Code d'invitation (optionnel)
                          _buildStyledTextField(
                            controller: _codeInvitationController,
                            icon: Icons.card_giftcard_outlined,
                            hintText: 'Code d\'invitation (optionnel)',
                            validator: (value) {
                              // Pas de validation requise car optionnel
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
                              if (value.length < 6) {
                                return 'Le mot de passe doit contenir au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Champ Confirmer mot de passe
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
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
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Inscription avec Google'),
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