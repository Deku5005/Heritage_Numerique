import 'package:flutter/material.dart';
// ⚠️ VÉRIFIEZ ET AJUSTEZ CES CHEMINS DANS VOTRE PROJET
import '../model/conte.dart'; // Importez votre modèle de Conte (équivalent à Recit)
import '../model/traduction_conte_model.dart'; // Importez le nouveau modèle de Traduction
import '../Service/conteService.dart'; // Importez le service mis à jour
import '../widgets/bottom_navigation_widget.dart';
import '../screens/quizscreenn.dart'; // Si vous avez un écran de quiz

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _serviceErrorColor = Colors.red;
const Color _quizButtonColor = Color(0xFF6A994E); // Vert amical

// ✅ BASE URL UTILISÉE POUR CONSTRUIRE L'URL DE L'IMAGE
const String _imageHostUrl = "http://10.0.2.2:8080";

// Renommé pour être plus cohérent avec votre structure de projet
class AffichageContesScreen extends StatefulWidget {
  final Conte conte; // Utilisation de votre modèle Conte

  const AffichageContesScreen({super.key, required this.conte});

  @override
  State<AffichageContesScreen> createState() => _AffichageContesScreenState();
}

class _AffichageContesScreenState extends State<AffichageContesScreen> {

  // Liste des codes courts utilisés dans l'UI (fr, bm, en)
  final List<String> _availableLangs = ['fr', 'bm', 'en'];

  // Langue par défaut pour le premier appel : le code court 'fr'
  String _selectedLanguageCodeUI = 'fr';
  // Utilisation du modèle et du service que nous avons définis
  late Future<TraductionConteModel> _traductionFuture;
  final ConteService _conteService = ConteService(); // Utilisation de ConteService

  @override
  void initState() {
    super.initState();
    // 1. Initialise le chargement avec le code UI par défaut ('fr')
    _traductionFuture = _fetchTranslation(_selectedLanguageCodeUI);
  }

  /// 🎯 Mappe le code court de l'interface utilisateur (UI) vers le code long
  /// utilisé comme clé dans la réponse JSON de l'API (ex: 'bam_Latn').
  String _mapUiCodeToApiJsonKey(String uiCode) {
    switch (uiCode) {
    // Pour l'affichage, on cherche la clé correspondante dans le JSON
      case 'fr': return 'fra_Latn';
      case 'bm': return 'bam_Latn'; // Clé confirmée par votre réponse API
      case 'en': return 'eng_Latn';
      default: return uiCode; // Fallback
    }
  }

  // Méthode pour appeler le service avec une langue donnée
  Future<TraductionConteModel> _fetchTranslation(String uiLanguageCode) {
    // Appel au ConteService mis à jour
    return _conteService.getConteTraduction(
      conteId: widget.conte.id,
      langCode: uiLanguageCode, // Le service attend le code court pour l'URL
    );
  }

  // Méthode pour changer de langue et recharger le contenu
  void _changeLanguageAndReload(String newLanguageCodeUI) {
    if (newLanguageCodeUI != _selectedLanguageCodeUI) {
      setState(() {
        _selectedLanguageCodeUI = newLanguageCodeUI;
        // Assigne un nouveau Future, provoquant le rechargement
        _traductionFuture = _fetchTranslation(newLanguageCodeUI);
      });
    }
  }

  // Mappage du code court UI pour l'affichage du nom de la langue
  String _mapLanguageCodeToName(String code) {
    switch(code) {
      case 'fr': return 'Français';
      case 'bm': return 'Bambara';
      case 'en': return 'Anglais';
      default: return code;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // Ajout de la BottomNavigationBar
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'contes'),
      appBar: AppBar(
        // Hauteur de l'AppBar réduite car le titre sera centré
        toolbarHeight: 60.0,
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _cardTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        // Titre dans l'AppBar classique
        title: _buildAppBarTitle(),
      ),

      // Le FutureBuilder englobe le contenu pour gérer l'état de chargement
      body: FutureBuilder<TraductionConteModel>(
        future: _traductionFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
          }

          // Gère les erreurs
          if (snapshot.hasError) {
            // Affichage simple de l'erreur, le contenu par défaut sera utilisé pour le fallback
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Erreur de chargement de la traduction. Affichage du contenu original. Erreur: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _serviceErrorColor, fontSize: 14),
                ),
              ),
            );
          }

          // Les données sont soit présentes (snapshot.hasData), soit nulles/non chargées
          final TraductionConteModel? data = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. SÉLECTEUR DE LANGUE (Modernisé)
                _buildLanguageSelector(),
                const SizedBox(height: 15),

                // 2. Image et Lecteur Audio du Conte
                _buildRecitImage(),
                const SizedBox(height: 20),

                // 3. Contenu du Récit (avec traduction si disponible)
                _buildRecitContentSection(data),
                const SizedBox(height: 20),

                // 4. Section Quiz (avant les infos additionnelles)
                if (widget.conte.quiz != null && widget.conte.quiz!.questions.isNotEmpty)
                  _buildQuizButton(),
                if (widget.conte.quiz != null && widget.conte.quiz!.questions.isNotEmpty)
                  const SizedBox(height: 20),

                // 5. Informations additionnelles
                _buildAdditionalInfoSection(data),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Widget _buildAppBarTitle() {
    return FutureBuilder<TraductionConteModel>(
      future: _traductionFuture,
      builder: (context, snapshot) {
        // 🎯 On utilise le code long (clé JSON) pour lire la traduction
        final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);

        // Fallback au titre original du Conte
        final String title = snapshot.hasData && snapshot.data != null
            ? snapshot.data!.traductionsTitre.traductions[jsonKey] ?? widget.conte.titre
            : widget.conte.titre; // Utilise le titre du Conte par défaut

        return Text(
          title,
          style: const TextStyle(
            color: _cardTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _buildLanguageSelector() {
    final String selectedLanguageName = _mapLanguageCodeToName(_selectedLanguageCodeUI);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _mainAccentColor, width: 1.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedLanguageCodeUI,
            icon: const Icon(Icons.arrow_drop_down, color: _mainAccentColor),
            items: _availableLangs
                .map<DropdownMenuItem<String>>((String code) {
              final String displayName = _mapLanguageCodeToName(code);
              return DropdownMenuItem<String>(
                value: code,
                child: Text(displayName, style: const TextStyle(color: _cardTextColor, fontSize: 14)),
              );
            }).toList(),
            onChanged: (String? newCode) {
              if (newCode != null) {
                _changeLanguageAndReload(newCode);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecitImage() {
    String imagePath = widget.conte.urlPhoto;
    String finalUrl = imagePath;

    // Logique pour construire l'URL complète
    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      // Assure que le chemin est bien formé (sans double slash)
      final String sanitizedPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
      finalUrl = '$_imageHostUrl/$sanitizedPath';
    }

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          finalUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: _mainAccentColor,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 50, color: _serviceErrorColor),
                  const SizedBox(height: 8),
                  const Text('Image introuvable', style: TextStyle(color: _serviceErrorColor, fontSize: 12)),
                  Text('URL TENTÉE: $finalUrl',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecitContentSection(TraductionConteModel? data) {
    // 🎯 On utilise le code long (clé JSON) pour lire la traduction
    final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);

    // 1. Détermine le contenu à afficher
    String content = widget.conte.contenuFichier; // Contenu d'origine (fallback)

    // 2. Si les données de traduction sont présentes, tente de lire la traduction
    if (data != null) {
      // Utilisation de traductionsContenu qui contient le texte complet
      content = data.traductionsContenu.traductions[jsonKey] ?? widget.conte.contenuFichier;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: const TextStyle(
          color: _cardTextColor,
          fontSize: 16,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildQuizButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // Naviguer vers l'écran du Quiz
          Navigator.push(
            context,
            MaterialPageRoute(
              // Assurez-vous que QuizScreen est correctement importé
              builder: (context) => QuizScreen(quiz: widget.conte.quiz!),
            ),
          );
        },
        icon: const Icon(Icons.school, size: 24),
        label: const Text('Commencer le Quiz !', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _quizButtonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(TraductionConteModel? data) {
    // 🎯 On utilise le code long (clé JSON) pour lire la traduction
    final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);

    // Initialisation avec les valeurs originales (fallback)
    String lieu = widget.conte.lieu;
    String region = widget.conte.region;

    // Si les données de traduction sont présentes, tente de lire la traduction
    if (data != null) {
      lieu = data.traductionsLieu.traductions[jsonKey] ?? widget.conte.lieu;
      region = data.traductionsRegion.traductions[jsonKey] ?? widget.conte.region;
    }

    // Libellés d'information pour la section
    final Map<String, String> labels = {
      'fr': {'title': 'Informations sur le Conte', 'lieu': 'Lieu', 'region': 'Région'},
      'bm': {'title': 'Kunnafoni', 'lieu': 'Yɔrɔ', 'region': 'Jamanan'},
      'en': {'title': 'Tale Information', 'lieu': 'Location', 'region': 'Region'},
    }[_selectedLanguageCodeUI] ?? {'title': 'Informations sur le Conte', 'lieu': 'Lieu', 'region': 'Région'};


    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labels['title']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _mainAccentColor),
            ),
            const Divider(height: 20, color: Colors.grey),
            _buildInfoRow('Conteur', '${widget.conte.prenomAuteur} ${widget.conte.nomAuteur}'),
            _buildInfoRow('Famille', widget.conte.nomFamille),
            _buildInfoRow(labels['lieu']!, lieu),
            _buildInfoRow(labels['region']!, region),
            _buildInfoRow('Création', widget.conte.dateCreation.split('T').first),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: _cardTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _cardTextColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}