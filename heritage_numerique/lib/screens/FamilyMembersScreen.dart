import 'package:flutter/material.dart';
// NOTE: Assurez-vous que les chemins d'importation sont corrects pour votre structure de fichiers.
import 'HomeDashboardScreen.dart'; // Assurez-vous que ce chemin est correct
import 'AppDrawer.dart'; // Assurez-vous que ce chemin est correct

import 'package:heritage_numerique/Service/FamilyMemberService.dart';
import 'package:heritage_numerique/model/family_member_model.dart';
import 'package:heritage_numerique/model/family_model.dart'; // Importé pour la réponse updateRole

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);

class FamilyMembersScreen extends StatefulWidget {
  final int familleId;

  const FamilyMembersScreen({super.key, required this.familleId});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final FamilyMemberService _memberService = FamilyMemberService();
  late Future<List<FamilyMemberModel>> _membersData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  // Fonction de chargement des membres
  void _loadFamilyMembers() {
    final int id = widget.familleId;
    setState(() {
      _membersData = _memberService.fetchFamilyMembers(familleId: id);
    });
  }

  // 💡 Fonction utilitaire pour afficher les messages (succès ou erreur)
  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      // FIX 1: L'AppDrawer est activé.
      drawer: AppDrawer(familyId: widget.familleId),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomHeader(),
            const SizedBox(height: 20),
            _buildPageTitle(),
            const SizedBox(height: 20),
            _buildActionSection(),
            const SizedBox(height: 20),
            _buildMembersTable(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Fonctions de construction de l'UI (inchangées)
  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              // FIX 2: La logique d'ouverture du tiroir est activée.
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membres de la famille',
            style: TextStyle(
              color: _cardTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Gérer les membres de votre famille et leurs contributions',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _searchBackground,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher membre...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: _mainAccentColor),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              text: 'Ajouter manuellement',
              isPrimary: false,
              onPressed: (context) => _showAddManualDialog(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              text: 'Inviter un membre',
              isPrimary: true,
              onPressed: (context) => _showInviteMemberDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isPrimary,
    required Function(BuildContext) onPressed,
  }) {
    return Builder(
        builder: (context) {
          return ElevatedButton.icon(
            onPressed: () => onPressed(context),
            icon: Icon(
              isPrimary ? Icons.person_add : Icons.add,
              color: isPrimary ? Colors.white : _cardTextColor,
              size: 16,
            ),
            label: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isPrimary ? Colors.white : _cardTextColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? _mainAccentColor : _searchBackground,
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: isPrimary ? BorderSide.none : const BorderSide(color: Colors.transparent),
              ),
            ),
          );
        }
    );
  }

  Widget _buildMembersTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<FamilyMemberModel>>(
        future: _membersData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Erreur de chargement: ${snapshot.error.toString().replaceAll('Exception: ', '')}",
                    style: const TextStyle(color: Colors.red)
                )
            );
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final members = snapshot.data!;

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                children: [
                  // Ligne d'en-tête (pas de modèle de membre passé)
                  _buildTableRow(
                    isHeader: true,
                    data: {'membre': 'Membre', 'role': 'Rôle', 'lien': 'Lien', 'date': 'Date ajout', 'statut': 'Statut', 'action': 'Action'},
                  ),
                  ...members.map((member) {
                    return _buildMemberRow(member);
                  }).toList(),
                ],
              ),
            );
          }

          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Aucun membre trouvé pour cette famille.", style: TextStyle(color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberRow(FamilyMemberModel member) {
    // 💡 NOTE: L'InkWell de la ligne entière ouvre les détails du membre.
    // L'IconButton dans la cellule "Action" ouvrira le changement de rôle.
    final DateTime date = member.dateAjout.year > 1 ? member.dateAjout : DateTime.now();
    final String formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    final String lienParent = member.lienParente ?? 'N/A';

    return InkWell(
      // Tap sur la ligne pour afficher les détails
      onTap: () => _showMemberDetailDialog(context, member.id),
      child: _buildTableRow(
        isHeader: false,
        data: {
          'membre': '${member.prenom} ${member.nom}',
          // FIX: Utiliser l'opérateur ?? pour gérer le cas où roleFamille est null
          'role': member.roleFamille ?? 'Rôle inconnu',
          'lien': lienParent,
          'date': formattedDate,
          // FIX: Gérer le statut qui peut être null
          'statut': member.statut ?? 'Statut inconnu',
          'action': '...', // Texte générique pour l'action
        },
        member: member, // ✅ Passage du membre pour l'action
      ),
    );
  }

  // Signature de la méthode mise à jour pour accepter un membre optionnel
  Widget _buildTableRow({required bool isHeader, required Map<String, String> data, FamilyMemberModel? member}) {
    Color getColorForRole(String role) {
      if (role.toUpperCase().contains('ADMIN')) return Colors.lightGreen.shade100;
      if (role.toUpperCase().contains('EDITEUR')) return Colors.green.shade100;
      if (role.toUpperCase().contains('LECTEUR')) return Colors.orange.shade100;
      return Colors.transparent;
    }

    Color getColorForStatus(String status) {
      if (status.toUpperCase() == 'ACCEPTE') return Colors.green.shade50;
      if (status.toUpperCase() == 'EN ATTENTE') return Colors.orange.shade50;
      return Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade100 : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildTableCell(data['membre']!, isHeader: isHeader)),
          // data['role']! est maintenant garanti d'être une String grâce au fix dans _buildMemberRow
          Expanded(flex: 2, child: Center(child: _buildRoleChip(data['role']!, isHeader, getColorForRole(data['role']!)))),
          Expanded(flex: 1, child: _buildTableCell(data['lien']!, isHeader: isHeader)),
          Expanded(flex: 2, child: _buildTableCell(data['date']!, isHeader: isHeader)),
          // data['statut']! est maintenant garanti d'être une String
          Expanded(flex: 2, child: Center(child: _buildStatusChip(data['statut']!, isHeader, getColorForStatus(data['statut']!)))),
          // ✅ Passage du membre à la cellule d'action
          Expanded(flex: 1, child: Center(child: _buildTableCell(data['action']!, isHeader: isHeader, isAction: true, member: member))),
        ],
      ),
    );
  }

  // Signature de la méthode mise à jour pour accepter un membre optionnel
  Widget _buildTableCell(String text, {required bool isHeader, bool isAction = false, FamilyMemberModel? member}) {
    // ✅ Logique pour le bouton d'action (rôle change)
    if (isAction && !isHeader && member != null) {
      return IconButton(
        icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
        onPressed: () => _showChangeRoleDialog(context, member), // Appel au nouveau dialogue
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: 'Changer le rôle',
      );
    }

    // Logique pour les cellules d'en-tête et de données standard
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        fontSize: isHeader ? 12 : 10,
        color: isHeader ? _cardTextColor : Colors.black,
      ),
    );
  }

  // === DÉFINITION DES WIDGETS MANQUANTS ===

  // Définition de _buildRoleChip
  Widget _buildRoleChip(String text, bool isHeader, Color color) {
    if (isHeader) return _buildTableCell(text, isHeader: true);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 8, color: _cardTextColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Définition de _buildStatusChip
  Widget _buildStatusChip(String text, bool isHeader, Color color) {
    if (isHeader) return _buildTableCell(text, isHeader: true);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 8, color: _cardTextColor.withOpacity(0.8), fontWeight: FontWeight.w600),
      ),
    );
  }

  // =======================================================
  // ---  LOGIQUE : Changer le rôle d'un membre ---
  // =======================================================

  void _showChangeRoleDialog(BuildContext context, FamilyMemberModel member) {

    // FIX SÉCURITÉ : S'assurer que le rôle est non-null pour l'initialisation et la comparaison.
    final String initialRole = member.roleFamille?.toUpperCase() ?? 'LECTEUR';

    const List<String> allowedRoles = ['LECTEUR', 'EDITEUR', 'ADMIN'];

    // Assigner le rôle actuel s'il est dans la liste autorisée, sinon 'LECTEUR' par défaut
    String? selectedRole = allowedRoles.contains(initialRole)
        ? initialRole
        : 'LECTEUR';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            bool isLoading = false;
            FamilyMemberModel currentMember = member;

            // Assurer une valeur par défaut sûre pour la comparaison et l'affichage.
            final String currentMemberRoleUpper = currentMember.roleFamille?.toUpperCase() ?? 'LECTEUR';
            final String currentMemberRoleDisplay = currentMember.roleFamille ?? 'Rôle inconnu';

            // Fonction de soumission (Appel API PUT)
            Future<void> submitRoleChange() async {
              if (selectedRole == null || selectedRole == currentMemberRoleUpper) {
                _showSnackbar("Veuillez sélectionner un nouveau rôle différent.", isError: true);
                return;
              }

              if (currentMemberRoleUpper == 'ADMIN') {
                _showSnackbar("Impossible de modifier le rôle de l'administrateur de cette famille directement via cette interface.", isError: true);
                return;
              }

              setStateLocal(() => isLoading = true);

              try {
                // Le service retourne FamilyModel, nous vérifions juste le succès
                await _memberService.updateMemberRole(
                  familleId: widget.familleId,
                  membreId: currentMember.id,
                  nouveauRole: selectedRole!,
                );

                if (mounted) {
                  Navigator.of(context).pop();
                  _showSnackbar("Rôle de ${currentMember.prenom} mis à jour en '$selectedRole' avec succès.");
                  _loadFamilyMembers(); // Recharger la liste pour afficher le nouveau rôle
                }

              } catch (e) {
                _showSnackbar("Erreur lors du changement de rôle: ${e.toString().replaceAll('Exception: ', '')}", isError: true);
                setStateLocal(() => isLoading = false);
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: const Text(
                'Changer le rôle du membre',
                style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Membre : ${currentMember.prenom} ${currentMember.nom}',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rôle actuel : $currentMemberRoleDisplay', // Utiliser la version non-null
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown pour le Nouveau Rôle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: _searchBackground,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Nouveau Rôle',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      isExpanded: true,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      icon: const Icon(Icons.arrow_drop_down, color: _mainAccentColor),
                      onChanged: (newValue) {
                        setStateLocal(() {
                          selectedRole = newValue;
                        });
                      },
                      items: allowedRoles.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : submitRoleChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainAccentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 15, height: 15,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Confirmer', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ... _showMemberDetailDialog, _buildMemberDetailContent, _buildDetailRow ...

  void _showMemberDetailDialog(BuildContext context, int membreId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: _backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: FutureBuilder<FamilyMemberModel>(
            future: _memberService.fetchMemberDetail(membreId: membreId),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails du membre',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _cardTextColor),
                    ),
                    const Divider(height: 20, color: Colors.grey),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: CircularProgressIndicator(color: _mainAccentColor),
                        ),
                      )
                    else if (snapshot.hasError)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            "Erreur: ${snapshot.error.toString().replaceAll('Exception: ', '')}",
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (snapshot.hasData)
                        _buildMemberDetailContent(snapshot.data!),

                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fermer', style: TextStyle(color: _mainAccentColor, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMemberDetailContent(FamilyMemberModel member) {
    final DateTime date = member.dateAjout.year > 1 ? member.dateAjout : DateTime.now();
    final String formattedDateAjout = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    final String telephone = member.telephone?.isNotEmpty == true ? member.telephone! : 'Non spécifié';

    final String lienParente = member.lienParente ?? 'N/A';
    final String ethnie = member.ethnie ?? 'N/A';

    // FIX SÉCURITÉ : Gérer le rôle null ici aussi pour l'affichage détaillé
    final String roleFamille = member.roleFamille ?? 'Rôle inconnu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Nom complet', '${member.prenom} ${member.nom}'),
        _buildDetailRow('Lien de parenté', lienParente),
        _buildDetailRow('Ethnie', ethnie),
        _buildDetailRow('Rôle familial', roleFamille),
        _buildDetailRow('Statut', member.statut ?? 'Statut inconnu'),
        const SizedBox(height: 10),
        _buildDetailRow('Téléphone', telephone),
        _buildDetailRow('Email', member.email ?? 'Non spécifié'),
        _buildDetailRow('Date d\'ajout', formattedDateAjout),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }


  // =======================================================
  // ---  LOGIQUE MISE À JOUR : Ajout Membre Manuel ---
  // =======================================================

  void _showAddManualDialog(BuildContext context) {
    // 💡 1. Contrôleurs pour les 6 champs de texte requis
    final prenomController = TextEditingController();
    final nomController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final ethnieController = TextEditingController();
    final lienParenteController = TextEditingController();

    // 💡 2. État pour le Rôle Familial (Dropdown)
    String? selectedRole = 'LECTEUR'; // Valeur par défaut
    // Note: Utilisation des rôles 'EDITEUR' et 'CONTRIBUTEUR' pour la saisie manuelle
    const List<String> roleOptions = ['LECTEUR', 'EDITEUR', 'ADMIN'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 💡 3. Utilisation de StatefulBuilder pour gérer l'état local (loading et dropdown)
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            bool isLoading = false;

            // 💡 4. Fonction de soumission (Appel API)
            Future<void> submit() async {
              if (prenomController.text.isEmpty ||
                  nomController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  ethnieController.text.isEmpty ||
                  lienParenteController.text.isEmpty ||
                  selectedRole == null) {
                _showSnackbar("Veuillez remplir tous les champs obligatoires.", isError: true);
                return;
              }

              setStateLocal(() => isLoading = true);

              try {
                // Appel à la NOUVELLE méthode avec les 8 paramètres
                await _memberService.addFamilyMemberManual(
                  idFamille: widget.familleId,
                  nom: nomController.text,
                  prenom: prenomController.text,
                  email: emailController.text,
                  telephone: phoneController.text,
                  ethnie: ethnieController.text,
                  lienParente: lienParenteController.text,
                  roleFamille: selectedRole!,
                );

                if (mounted) {
                  Navigator.of(context).pop(); // Fermer le dialogue
                  _showSnackbar("Membre ajouté manuellement avec succès.");
                  _loadFamilyMembers(); // Recharger la liste
                }

              } catch (e) {
                _showSnackbar("Erreur lors de l'ajout: ${e.toString().replaceAll('Exception: ', '')}", isError: true);
                setStateLocal(() => isLoading = false);
              }
            }

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ajouter un membre manuellement',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
                          ),
                          Text(
                            'Remplissez tous les détails requis pour l\'ajout.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // NOUVEAUX CHAMPS
                      _buildInputField('Prénom', prenomController, hint: 'Ex: Niakale'),
                      _buildInputField('Nom', nomController, hint: 'Ex: Diakité'),
                      _buildInputField('Email', emailController, hint: 'Ex: email@exemple.com', keyboardType: TextInputType.emailAddress),
                      _buildInputField('Téléphone', phoneController, hint: 'Ex: +223 78787878', keyboardType: TextInputType.phone),
                      _buildInputField('Ethnie', ethnieController, hint: 'Ex: Bambara, Peul'),
                      _buildInputField('Lien de parenté', lienParenteController, hint: 'Ex: Oncle, Tante, Cousin'),

                      // Dropdown pour le Rôle Familial
                      _buildRoleDropdown(
                        selectedRole: selectedRole,
                        options: roleOptions,
                        onChanged: (String? newValue) {
                          setStateLocal(() {
                            selectedRole = newValue;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                            child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _mainAccentColor,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                width: 15, height: 15,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                                  : const Text('Ajouter le membre', style: TextStyle(color: Colors.white, fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =======================================================
  // --- LOGIQUE : Inviter un membre (à compléter) ---
  // =======================================================

  void _showInviteMemberDialog(BuildContext context) {
    // Dans une application réelle, ceci contiendrait la logique d'envoi d'invitations par e-mail ou lien.
    // Pour l'instant, c'est un simple message d'information.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Inviter un membre'),
          content: const Text(
            "La fonctionnalité d'invitation par lien ou email sera bientôt disponible. Veuillez utiliser l'ajout manuel pour l'instant.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }


  // --- WIDGET MANQUANT : Champ de saisie réutilisable ---
  Widget _buildInputField(String label, TextEditingController controller, {String? hint, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              fillColor: _searchBackground,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // --- WIDGET MANQUANT : Dropdown pour le Rôle ---
  Widget _buildRoleDropdown({
    required String? selectedRole,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rôle Familial', style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _searchBackground,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              isExpanded: true,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              icon: const Icon(Icons.arrow_drop_down, color: _mainAccentColor),
              onChanged: onChanged,
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
