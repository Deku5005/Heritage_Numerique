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
const String _imageHostUrl = "http://10.0.2.2:8080";

class RecitDetailScreen extends StatefulWidget {
  final Recit recit;

  const RecitDetailScreen({super.key, required this.recit});

  @override
  State<RecitDetailScreen> createState() => _RecitDetailScreenState();
}

class _RecitDetailScreenState extends State<RecitDetailScreen> {
  // Liste des codes courts utilisés dans l'UI (fr, bm, en)
  final List<String> _availableLangs = ['fr', 'bm', 'en'];

  // Langue par défaut pour le premier appel : le code court 'fr'
  String _selectedLanguageCodeUI = 'fr';
  late Future<TraductionConte> _traductionFuture;
  final RecitService _recitService = RecitService();


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
  Future<TraductionConte> _fetchTranslation(String uiLanguageCode) {
    // 🎯 On utilise le code UI court (ex: 'bm') pour l'URL de l'endpoint
    // car votre endpoint le demande (/api/traduction/conte/{conteId}/bm)

    return _recitService.fetchConteTraduction(
      conteId: widget.recit.id,
      // Le service attend le code court pour l'URL
      langueCode: uiLanguageCode,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        toolbarHeight: 135.0,
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _cardTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: _buildAppBarTitle(),
        centerTitle: false,
        actions: [
          // 1. MENU DÉROULANT LANGUE
          _buildLanguageDropdown(),
          const SizedBox(width: 10),

          // Bouton Quiz
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

          // 2. BOUTON FERMER
          IconButton(
            icon: const Icon(Icons.close, color: _cardTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      // Le FutureBuilder englobe le contenu pour gérer l'état de chargement
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
                  // 1. Image du Récit
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
        // 🎯 On utilise le code long (clé JSON) pour lire la traduction
        final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);

        // Fallback au titre original du Recit si la traduction n'est pas chargée
        final String title = snapshot.hasData
        // ✅ Utilise la clé JSON mappée (ex: "bam_Latn")
            ? snapshot.data!.traductionsTitre.traductions[jsonKey] ?? widget.recit.titre
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
        // Utilise le code court UI pour l'affichage du Dropdown
        value: _selectedLanguageCodeUI,
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
            // Le rechargement est déclenché ici
            _changeLanguageAndReload(newValue);
          }
        },
      ),
    );
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

    // DÉTERMINER L'URL COMPLÈTE
    String finalUrl = imagePath;

    // Si le chemin n'est pas déjà une URL absolue, on le préfixe.
    if (!imagePath.startsWith('http')) {
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
    // 🎯 On utilise le code long (clé JSON) pour lire la traduction
    final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);

    // Utilise la traduction du contenu avec la clé JSON (ex: "bam_Latn")
    final String content = data.traductionsContenu.traductions[jsonKey] ??
        data.descriptionOriginale; // Fallback

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
    // 🎯 On utilise le code long (clé JSON) pour lire la traduction
    final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);

    // ✅ Utilise la traduction pour le Lieu
    final String lieu = data.traductionsLieu.traductions[jsonKey] ?? data.lieuOriginal;
    // ✅ Utilise la traduction pour la Région
    final String region = data.traductionsRegion.traductions[jsonKey] ?? data.regionOriginale;

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