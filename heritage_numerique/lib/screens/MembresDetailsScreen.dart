// Fichier : lib/screens/MembreDetailScreen.dart

import 'package:flutter/material.dart';
import '../model/MembreDetailsModel.dart'; // Assurez-vous d'avoir le bon import
import '../service/ArbreGenealogiqueService.dart';
import 'dart:math';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _lightGreyBackground = Color(0xFFF0F0F0);
const String _baseUrl = "http://10.0.2.2:8080";

class MembreDetailScreen extends StatefulWidget {
  final int membreId;

  const MembreDetailScreen({super.key, required this.membreId});

  @override
  State<MembreDetailScreen> createState() => _MembreDetailScreenState();
}

class _MembreDetailScreenState extends State<MembreDetailScreen> {
  List<MembreDetail> _membresDetail = [];
  bool _isLoading = true;
  String? _errorMessage;
  final ArbreGenealogiqueService _apiService = ArbreGenealogiqueService();

  @override
  void initState() {
    super.initState();
    _fetchMemberDetails();
  }

  Future<void> _fetchMemberDetails() async {
    try {
      final details = await _apiService.fetchMembreDetail(membreId: widget.membreId);
      setState(() {
        _membresDetail = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les détails du membre (ID: ${widget.membreId}). Vérifiez la connexion.';
        _isLoading = false;
        debugPrint('Erreur de chargement des détails: ${e.toString()}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tente de trouver le membre sélectionné pour le titre
    final MembreDetail? selectedMember = _membresDetail.isNotEmpty
        ? _membresDetail.firstWhere((m) => m.id == widget.membreId, orElse: () => _membresDetail.first)
        : null;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
            selectedMember != null ? 'Relations de ${selectedMember.nomComplet}' : 'Détails du Membre',
            style: const TextStyle(color: _cardTextColor, fontSize: 18, fontWeight: FontWeight.w600)
        ),
        backgroundColor: _backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: _cardTextColor),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (_membresDetail.isEmpty) {
      return const Center(child: Text("Aucun membre trouvé pour ce nœud de l'arbre."));
    }

    // CONSERVATION DE L'ORDRE DU BACKEND
    final List<MembreDetail> apiOrderedMembers = _membresDetail;

    // Récupération du nom du membre sélectionné pour les libellés
    final MembreDetail? selectedMember = apiOrderedMembers.firstWhere((m) => m.id == widget.membreId, orElse: () => apiOrderedMembers.first);
    final String selectedMemberName = selectedMember?.nomComplet ?? 'Membre sélectionné';


    return ListView.builder(
      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
      itemCount: apiOrderedMembers.length,
      itemBuilder: (context, index) {
        final membre = apiOrderedMembers[index];

        String prefixText;
        bool isSelected = (membre.id == widget.membreId);

        if (isSelected) {
          // 🔑 LOGIQUE CORRIGÉE : L'étiquette est cumulative pour le membre sélectionné
          prefixText = 'Membre sélectionné';

          if (index == 0) {
            prefixText += ' (Père)';
          } else if (index == 1) {
            prefixText += ' (Mère)';
          }

        } else if (index == 0) {
          // Si ce n'est PAS le membre sélectionné et qu'il est en 1ère position (Père)
          prefixText = 'Père de $selectedMemberName';

        } else if (index == 1) {
          // Si ce n'est PAS le membre sélectionné et qu'il est en 2ème position (Mère)
          prefixText = 'Mère de $selectedMemberName';

        } else {
          // Tous les autres membres liés
          prefixText = 'Membre lié';
        }

        return _buildCompactMemberCard(membre, prefixText, isSelected);
      },
    );
  }

  // 🔑 Widget pour construire la carte compacte (Photo + 3 infos)
  Widget _buildCompactMemberCard(MembreDetail membre, String relationLabel, bool isSelected) {
    final String fullPhotoUrl = (membre.photoUrl != null && membre.photoUrl!.isNotEmpty)
        ? '$_baseUrl/${membre.photoUrl!}'
        : '';
    final bool hasPhoto = fullPhotoUrl.isNotEmpty;

    // Déterminer la couleur de la bordure selon le rôle
    final Color borderColor = isSelected
        ? _mainAccentColor
        : Colors.grey.shade300;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: isSelected ? _lightGreyBackground : Colors.white, // Légère différence de couleur pour le sélectionné
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isSelected ? 3 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(isSelected ? 0.3 : 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Label de la relation
          Text(
            relationLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? _mainAccentColor : _cardTextColor.withOpacity(0.8),
            ),
          ),
          const Divider(color: Colors.transparent, height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 2. Image de profil
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: hasPhoto
                      ? Image.network(
                    fullPhotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey, size: 30),
                  )
                      : const Icon(Icons.person, color: Colors.grey, size: 30),
                ),
              ),
              const SizedBox(width: 15),

              // 3. Détails
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membre.nomComplet,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _cardTextColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildDetailLine(Icons.cake_outlined, membre.dateNaissance),
                    _buildDetailLine(Icons.location_on_outlined, membre.lieuNaissance),
                    _buildDetailLine(Icons.label_outline, membre.relationFamiliale, isLast: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔑 Widget utilitaire pour une ligne de détail compacte
  Widget _buildDetailLine(IconData icon, String value, {bool isLast = false}) {
    final displayValue = value.isEmpty ? 'Non spécifié' : value;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 2.0),
      child: Row(
        children: [
          Icon(icon, size: 14, color: _mainAccentColor.withOpacity(0.8)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 12,
                color: value.isEmpty ? Colors.grey.shade500 : _cardTextColor.withOpacity(0.9),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}