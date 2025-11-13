import 'package:flutter/material.dart';
import 'package:heritage_numerique/Service/FamilyService.dart';
import 'package:heritage_numerique/screens/dashboard_screen.dart';

// --- Constantes de Couleurs (THÈME BLANC ÉLÉGANT) ---
const Color _mainAccentColor = Color(0xFFD4A017);     // Doré clair premium
const Color _backgroundColor = Color(0xFFFFFFFF);     // Blanc pur
const Color _cardTextColor = Color(0xFF1A1A1A);       // Texte sombre élégant
const Color _primaryColor = Color(0xFFD4A017);        // Doré pour labels
const Color _glassColor = Color(0x44FFFFFF);          // Glassmorphism très léger
const Color _borderColor = Color(0x33D4A017);         // Bordure dorée subtile

class CreateFamilyAccountScreen extends StatefulWidget {
  const CreateFamilyAccountScreen({super.key});

  @override
  State<CreateFamilyAccountScreen> createState() => _CreateFamilyAccountScreenState();
}

class _CreateFamilyAccountScreenState extends State<CreateFamilyAccountScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final FamilyService _familyService = FamilyService();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ethnieController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  bool _isLoading = false;

  // Animation Controllers
  late List<AnimationController> _fadeControllers;
  late List<Animation<double>> _fadeAnimations;
  late AnimationController _buttonController;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _fadeControllers = List.generate(4, (_) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    ));

    _fadeAnimations = _fadeControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    for (int i = 0; i < _fadeControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 150 * i), () {
        if (mounted) _fadeControllers[i].forward();
      });
    }

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _buttonScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    for (var c in _fadeControllers) c.dispose();
    _buttonController.dispose();
    _nomController.dispose();
    _descriptionController.dispose();
    _ethnieController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final nom = _nomController.text.trim();
    final description = _descriptionController.text.trim();
    final ethnie = _ethnieController.text.trim();
    final region = _regionController.text.trim();

    try {
      await _familyService.createFamily(nom, description, ethnie, region);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: _mainAccentColor),
              const SizedBox(width: 12),
              Text('Famille créée !', style: TextStyle(color: _mainAccentColor, fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 6,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
              child: child,
            ));
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : ${e.toString().replaceFirst('Exception: ', '')}', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Créer une Famille',
          style: TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        iconTheme: IconThemeData(color: _cardTextColor),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: _cardTextColor),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundColor, Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Titre animé
                  FadeTransition(
                    opacity: _fadeAnimations[0],
                    child: SlideTransition(
                      position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                          .animate(_fadeAnimations[0]),
                      child: Text(
                        'Construisez votre héritage',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _cardTextColor,
                          letterSpacing: 0.5,
                          shadows: [Shadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: Offset(0, 2))],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _fadeAnimations[0],
                    child: Text(
                      'Remplissez les champs pour créer votre arbre familial',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // Champs animés
                  _animatedField(0, _nomController, 'Nom de la Famille', 'Ex: Famille Dolo', Icons.group_add),
                  const SizedBox(height: 20),
                  _animatedField(1, _descriptionController, 'Description', 'Histoire ou devise...', Icons.description, maxLines: 3),
                  const SizedBox(height: 20),
                  _animatedField(2, _ethnieController, 'Ethnie', 'Ex: Bambara, Dogon', Icons.flag),
                  const SizedBox(height: 20),
                  _animatedField(3, _regionController, 'Région', 'Ex: Mopti, Sikasso', Icons.location_on),

                  const SizedBox(height: 60),

                  // Bouton blanc avec bordure dorée + pulsation
                  Center(
                    child: AnimatedBuilder(
                      animation: _buttonScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isLoading ? 1.0 : _buttonScale.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _mainAccentColor, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: _mainAccentColor.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _mainAccentColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isLoading
                              ? _buildLoadingSpinner()
                              : const Text(
                            'Créer le Compte Familial',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _mainAccentColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _animatedField(
      int index,
      TextEditingController controller,
      String label,
      String hint,
      IconData icon, {
        int maxLines = 1,
      }) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(_fadeAnimations[index]),
        child: _glassTextField(controller, label, hint, icon, maxLines),
      ),
    );
  }

  Widget _glassTextField(
      TextEditingController controller,
      String label,
      String hint,
      IconData icon,
      int maxLines,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: _glassColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: _cardTextColor, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              color: controller.text.isNotEmpty ? _mainAccentColor : Colors.grey[400],
              size: 22,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          labelStyle: TextStyle(color: _primaryColor.withOpacity(0.9), fontWeight: FontWeight.w600),
          floatingLabelStyle: TextStyle(color: _mainAccentColor, fontWeight: FontWeight.bold),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        validator: (value) => value!.trim().isEmpty ? 'Champ requis' : null,
      ),
    );
  }

  Widget _buildLoadingSpinner() {
    return SizedBox(
      width: 28,
      height: 28,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        builder: (_, double value, __) {
          return Transform.rotate(
            angle: value * 2 * 3.14159,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _mainAccentColor, width: 3),
              ),
            ),
          );
        },
      ),
    );
  }
}