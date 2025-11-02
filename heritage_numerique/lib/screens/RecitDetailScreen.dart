import 'package:flutter/material.dart';
// ⚠️ VÉRIFIEZ ET AJUSTEZ CES CHEMINS SI NÉCESSAIRE
import 'package:heritage_numerique/model/Recits_model.dart';
import 'package:heritage_numerique/model/Traduction-conte-model.dart';
import 'package:heritage_numerique/service/RecitService.dart';


// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _serviceErrorColor = Colors.red;

// ✅ BASE URL UTILISÉE POUR CONSTRUIRE L'URL DE L'IMAGE
// Assurez-vous que cette adresse correspond à votre serveur (e.g., pour un émulateur)
const String _imageHostUrl = "http://10.0.2.2:8080";

class RecitDetailScreen extends StatefulWidget {
  // L'objet Recit contient DÉJÀ urlPhoto et vient de l'écran précédent.
  final Recit recit;

  const RecitDetailScreen({super.key, required this.recit});

  @override
  State<RecitDetailScreen> createState() => _RecitDetailScreenState();
}

class _RecitDetailScreenState extends State<RecitDetailScreen> {
  // Langue par défaut pour le premier appel : le code source ('fr')
  String _selectedLanguage = 'fr';
  late Future<TraductionConte> _traductionFuture;
  final RecitService _recitService = RecitService();

  // Liste des langues supportées (utilisée par le dropdown)
  final List<String> _availableLangs = ['fr', 'bm', 'en'];

  @override
  void initState() {
    super.initState();
    // 1. Initialise le chargement avec la langue par défaut ('fr')
    _traductionFuture = _fetchTranslation('fr');
  }

  // Méthode pour appeler le service avec une langue donnée
  Future<TraductionConte> _fetchTranslation(String languageCode) {
    return _recitService.fetchConteTraduction(
      conteId: widget.recit.id,
      langueCode: languageCode,
    );
  }

  // Méthode pour changer de langue et recharger le contenu
  void _changeLanguageAndReload(String newLanguage) {
    if (newLanguage != _selectedLanguage) {
      // 2. setState() déclenche un nouveau build
      setState(() {
        _selectedLanguage = newLanguage;
        // 3. Assigne un nouveau Future au FutureBuilder, provoquant un rechargement
        _traductionFuture = _fetchTranslation(newLanguage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        // AJUSTEMENT : Augmentation de la hauteur pour un meilleur dégagement
        toolbarHeight: 135.0,
        backgroundColor: _backgroundColor,
        elevation: 0,
        // Bouton de retour par défaut (<-) : laissé pour la navigation.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _cardTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),

        // Le titre doit aussi être dynamique
        title: _buildAppBarTitle(),
        centerTitle: false,
        actions: [
          // 1. MENU DÉROULANT LANGUE
          _buildLanguageDropdown(),
          const SizedBox(width: 10),

          // Bouton Quiz (si présent dans le récit)
          if (widget.recit.quiz != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                backgroundColor: _mainAccentColor,
                label: const Text('Quiz', style: TextStyle(color: Colors.white, fontSize: 12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lancer le Quiz !')),
                  );
                },
              ),
            ),

          // 2. BOUTON FERMER (ajoute une icône X pour fermer clairement la vue)
          IconButton(
            icon: const Icon(Icons.close, color: _cardTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      // Le FutureBuilder englobe maintenant le contenu pour gérer l'état de chargement du récit.
      body: FutureBuilder<TraductionConte>(
        future: _traductionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  // Afficher l'erreur pour le diagnostic
                  'Erreur de chargement du contenu : ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _serviceErrorColor, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Aucun contenu de récit disponible.'));
          } else {
            // Affichage des données réelles
            final TraductionConte data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image du Récit (plus de contournement PDF nécessaire)
                  _buildRecitImage(),
                  const SizedBox(height: 20),

                  // 2. Contenu du Récit
                  _buildRecitContentSection(data),
                  const SizedBox(height: 20),

                  // 3. Informations additionnelles
                  _buildAdditionalInfoSection(data),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Widget _buildAppBarTitle() {
    return FutureBuilder<TraductionConte>(
      future: _traductionFuture,
      builder: (context, snapshot) {
        // Fallback au titre original du Recit si la traduction n'est pas chargée
        final String title = snapshot.hasData
        // ✅ Utilise le titre traduit correspondant à la langue sélectionnée
            ? snapshot.data!.traductionsTitre.traductions[_selectedLanguage] ?? widget.recit.titre
            : widget.recit.titre;

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

  Widget _buildLanguageDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedLanguage,
        icon: const Icon(Icons.keyboard_arrow_down, color: _mainAccentColor),
        items: _availableLangs
            .map<DropdownMenuItem<String>>((String value) {
          final String displayName = _mapLanguageCodeToName(value);
          return DropdownMenuItem<String>(
            value: value,
            child: Text(displayName, style: const TextStyle(color: _cardTextColor, fontSize: 14)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            // ✅ C'EST ICI QUE LE RECHARGEMENT EST DÉCLENCHÉ !
            _changeLanguageAndReload(newValue);
          }
        },
      ),
    );
  }

  String _mapLanguageCodeToName(String code) {
    switch(code) {
      case 'fr': return 'Français';
      case 'bm': return 'Bambara';
      case 'en': return 'Anglais';
      default: return code;
    }
  }

  // ✅ LOGIQUE DE CONSTRUCTION D'URL CORRIGÉE ET SIMPLIFIÉE
  Widget _buildRecitImage() {
    String imagePath = widget.recit.urlPhoto;

    // Si le chemin d'image reçu est vide, on affiche le placeholder
    if (imagePath.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey.shade500),
        ),
      );
    }

    // 1. DÉTERMINER L'URL COMPLÈTE
    String finalUrl = imagePath;

    // Si le chemin n'est pas déjà une URL absolue (commence par "http"), on le préfixe.
    if (!imagePath.startsWith('http')) {

      // Utiliser Uri.parse().resolve(imagePath).toString() est la méthode la plus sûre
      // pour gérer si imagePath commence ou non par un slash.
      finalUrl = Uri.parse(_imageHostUrl).resolve(imagePath).toString();
    }

    // Afficher l'image en utilisant l'URL COMPLÈTE
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          finalUrl, // ✅ Utilise l'URL correcte
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
            // Affichage de l'erreur pour le diagnostic
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 50, color: _serviceErrorColor),
                  const SizedBox(height: 8),
                  const Text('Image introuvable', style: TextStyle(color: _serviceErrorColor, fontSize: 12)),
                  // 🚨 Diagnostic : Affiche l'URL exacte TENTÉE
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

  Widget _buildRecitContentSection(TraductionConte data) {
    // Utilise la traduction du contenu, ou la description originale si la traduction est manquante
    final String content = data.traductionsContenu.traductions[_selectedLanguage] ??
        data.descriptionOriginale;

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

  Widget _buildAdditionalInfoSection(TraductionConte data) {
    // ✅ Utilise la traduction pour le Lieu
    final String lieu = data.traductionsLieu.traductions[_selectedLanguage] ?? data.lieuOriginal;
    // ✅ Utilise la traduction pour la Région
    final String region = data.traductionsRegion.traductions[_selectedLanguage] ?? data.regionOriginale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Auteur: ${widget.recit.prenomAuteur} ${widget.recit.nomAuteur}', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
        Text('Famille: ${widget.recit.nomFamille}', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
        Text('Lieu: $lieu', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
        Text('Région: $region', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
        Text('Date de création: ${widget.recit.dateCreation.day}/${widget.recit.dateCreation.month}/${widget.recit.dateCreation.year}', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
      ],
    );
  }
}
