import 'package:flutter/material.dart';
import 'package:heritage_numerique/Service/FamilyService.dart';

// ✅ Nous conservons uniquement celui-ci pour DashboardScreen
import 'package:heritage_numerique/screens/dashboard_screen.dart';

// --- Constantes de Couleurs ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _primaryColor = Color(0xFF004D40);

class CreateFamilyAccountScreen extends StatefulWidget {
  const CreateFamilyAccountScreen({super.key});

  @override
  State<CreateFamilyAccountScreen> createState() => _CreateFamilyAccountScreenState();
}

class _CreateFamilyAccountScreenState extends State<CreateFamilyAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final FamilyService _familyService = FamilyService();

  // Contrôleurs pour les champs de texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ethnieController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _ethnieController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  // ===============================================
  // ✅ LOGIQUE DE SOUMISSION, SUCCÈS ET REDIRECTION
  // ===============================================
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String nom = _nomController.text.trim();
    final String description = _descriptionController.text.trim();
    final String ethnie = _ethnieController.text.trim();
    final String region = _regionController.text.trim();

    try {
      // 1. Appel au service de création de famille
      await _familyService.createFamily(nom, description, ethnie, region);

      // 2. ✅ POPUP DE SUCCÈS
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Famille créée avec succès !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // 3. ✅ CORRECTION : REDIRECTION VERS DashboardScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          // Utilisation de DashboardScreen comme souhaité
          builder: (context) => const DashboardScreen(),
        ),
      );

    } catch (e) {
      // 4. GESTION DES ERREURS
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec de la création: ${e.toString().replaceFirst('Exception: ', '')}',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===============================================
  // WIDGET BUILD
  // ===============================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Créer un Compte Familial',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _mainAccentColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Entrez les détails de votre nouvelle famille',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // 1. Nom de la Famille
              _buildTextFormField(
                controller: _nomController,
                label: 'Nom de la Famille',
                hint: 'Ex: Famille Dolo',
                icon: Icons.group_add,
              ),
              const SizedBox(height: 20),

              // 2. Description
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Histoire ou devise de la famille',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // 3. Ethnie
              _buildTextFormField(
                controller: _ethnieController,
                label: 'Ethnie',
                hint: 'Ex: Bambara, Dogon, Peul',
                icon: Icons.flag,
              ),
              const SizedBox(height: 20),

              // 4. Région
              _buildTextFormField(
                controller: _regionController,
                label: 'Région',
                hint: 'Ex: Mopti, Sikasso',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 40),

              // Bouton de Soumission
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _mainAccentColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Text(
                  'Créer le Compte Familial',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================
  // WIDGETS D'AIDE
  // ===============================================
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _mainAccentColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer le $label.';
        }
        return null;
      },
    );
  }
}