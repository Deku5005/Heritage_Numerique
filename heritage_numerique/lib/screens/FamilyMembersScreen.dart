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

  // ✅ CONTRÔLEURS ET CLÉ POUR LA LOGIQUE D'INVITATION
  final GlobalKey<FormState> _inviteFormKey = GlobalKey<FormState>();
  final TextEditingController _inviteNomCompletController = TextEditingController();
  final TextEditingController _inviteEmailController = TextEditingController();
  final TextEditingController _inviteTelephoneController = TextEditingController();
  final TextEditingController _inviteLienParenteController = TextEditingController();

  // ✅ CONTRÔLEURS ET CLÉ POUR L'AJOUT MANUEL
  final GlobalKey<FormState> _manualFormKey = GlobalKey<FormState>();
  final TextEditingController _manualNomController = TextEditingController();
  final TextEditingController _manualPrenomController = TextEditingController();
  final TextEditingController _manualEmailController = TextEditingController();
  final TextEditingController _manualTelephoneController = TextEditingController();
  final TextEditingController _manualEthnieController = TextEditingController();
  final TextEditingController _manualLienParenteController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  @override
  void dispose() {
    // --- Nettoyage des contrôleurs d'invitation ---
    _inviteNomCompletController.dispose();
    _inviteEmailController.dispose();
    _inviteTelephoneController.dispose();
    _inviteLienParenteController.dispose();

    // --- Nettoyage des contrôleurs d'ajout manuel ---
    _manualNomController.dispose();
    _manualPrenomController.dispose();
    _manualEmailController.dispose();
    _manualTelephoneController.dispose();
    _manualEthnieController.dispose();
    _manualLienParenteController.dispose();

    super.dispose();
  }

  // Fonction de chargement des membres
  void _loadFamilyMembers() {
    final int id = widget.familleId;
    // Vérification pour s'assurer que setState est appelé uniquement si le widget est monté
    if (mounted) {
      setState(() {
        _membersData = _memberService.fetchFamilyMembers(familleId: id);
      });
    }
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
    final DateTime date = member.dateAjout.year > 1 ? member.dateAjout : DateTime.now();
    final String formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    final String lienParent = member.lienParente ?? 'N/A';

    return InkWell(
      onTap: () => _showMemberDetailDialog(context, member.id),
      child: _buildTableRow(
        isHeader: false,
        data: {
          'membre': '${member.prenom} ${member.nom}',
          'role': member.roleFamille ?? 'Rôle inconnu',
          'lien': lienParent,
          'date': formattedDate,
          'statut': member.statut ?? 'Statut inconnu',
          'action': '...',
        },
        member: member,
      ),
    );
  }

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
          Expanded(flex: 2, child: Center(child: _buildRoleChip(data['role']!, isHeader, getColorForRole(data['role']!)))),
          Expanded(flex: 1, child: _buildTableCell(data['lien']!, isHeader: isHeader)),
          Expanded(flex: 2, child: _buildTableCell(data['date']!, isHeader: isHeader)),
          Expanded(flex: 2, child: Center(child: _buildStatusChip(data['statut']!, isHeader, getColorForStatus(data['statut']!)))),
          Expanded(flex: 1, child: Center(child: _buildTableCell(data['action']!, isHeader: isHeader, isAction: true, member: member))),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {required bool isHeader, bool isAction = false, FamilyMemberModel? member}) {
    if (isAction && !isHeader && member != null) {
      return IconButton(
        icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
        onPressed: () => _showChangeRoleDialog(context, member),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: 'Changer le rôle',
      );
    }

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

  // === DÉFINITION DES WIDGETS CHIP ===

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

  // Widget utilitaire pour les champs de texte dans le dialogue
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _mainAccentColor, size: 20),
          labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          fillColor: _searchBackground,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(color: _mainAccentColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          errorStyle: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }


  // =======================================================
  // ---  LOGIQUE : Ajouter un membre manuellement ---
  // =======================================================

  void _showAddManualDialog(BuildContext context) {
    // Réinitialiser les champs à l'ouverture du dialogue
    _manualNomController.clear();
    _manualPrenomController.clear();
    _manualEmailController.clear();
    _manualTelephoneController.clear();
    _manualEthnieController.clear();
    _manualLienParenteController.clear();

    const List<String> allowedRoles = ['LECTEUR', 'EDITEUR'];
    String selectedRole = 'LECTEUR';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            bool isLoading = false;

            Future<void> submitManualAdd() async {
              if (_manualFormKey.currentState!.validate()) {
                setStateLocal(() => isLoading = true);

                try {
                  await _memberService.addFamilyMemberManual(
                    idFamille: widget.familleId,
                    nom: _manualNomController.text.trim(),
                    prenom: _manualPrenomController.text.trim(),
                    email: _manualEmailController.text.trim(),
                    telephone: _manualTelephoneController.text.trim(),
                    ethnie: _manualEthnieController.text.trim(),
                    lienParente: _manualLienParenteController.text.trim(),
                    roleFamille: selectedRole,
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                    _loadFamilyMembers(); // Recharger après fermeture du dialogue
                    _showSnackbar("Membre ajouté manuellement avec succès.");
                  }

                } catch (e) {
                  _showSnackbar("Erreur lors de l'ajout manuel : ${e.toString().replaceAll('Exception: ', '')}", isError: true);
                  setStateLocal(() => isLoading = false);
                }
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: const Text(
                'Ajouter un membre manuellement',
                style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 18),
              ),
              content: Form(
                key: _manualFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildDialogTextField(
                            controller: _manualPrenomController,
                            label: 'Prénom',
                            icon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'Requis.' : null,
                          )),
                          const SizedBox(width: 10),
                          Expanded(child: _buildDialogTextField(
                            controller: _manualNomController,
                            label: 'Nom',
                            icon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'Requis.' : null,
                          )),
                        ],
                      ),
                      _buildDialogTextField(
                        controller: _manualEmailController,
                        label: 'Email (Doit être unique)',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.isEmpty) return 'L\'email est requis.';
                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRegex.hasMatch(v)) return 'Format invalide.';
                          return null;
                        },
                      ),
                      _buildDialogTextField(
                        controller: _manualTelephoneController,
                        label: 'Téléphone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Requis.' : null,
                      ),
                      _buildDialogTextField(
                        controller: _manualEthnieController,
                        label: 'Ethnie',
                        icon: Icons.flag_outlined,
                        validator: (v) => v!.isEmpty ? 'Requis.' : null,
                      ),
                      _buildDialogTextField(
                        controller: _manualLienParenteController,
                        label: 'Lien de Parenté (Ex: Père, Sœur)',
                        icon: Icons.group_outlined,
                        validator: (v) => v!.isEmpty ? 'Requis.' : null,
                      ),
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
                            labelText: 'Rôle',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                            icon: Icon(Icons.security, color: _mainAccentColor, size: 20),
                          ),
                          isExpanded: true,
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                          icon: const Icon(Icons.arrow_drop_down, color: _mainAccentColor),
                          onChanged: (newValue) {
                            setStateLocal(() {
                              selectedRole = newValue!;
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
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : submitManualAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainAccentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 15, height: 15,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Ajouter', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  // =======================================================
  // ---  LOGIQUE : Inviter un membre ---
  // =======================================================

  void _showInviteMemberDialog(BuildContext context) {
    // Réinitialiser les champs à l'ouverture du dialogue
    _inviteNomCompletController.clear();
    _inviteEmailController.clear();
    _inviteTelephoneController.clear();
    _inviteLienParenteController.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            bool isLoading = false;

            Future<void> submitInvitation() async {
              if (_inviteFormKey.currentState!.validate()) {
                setStateLocal(() => isLoading = true);

                try {
                  await _memberService.inviteFamilyMember(
                    familleId: widget.familleId,
                    nomComplet: _inviteNomCompletController.text.trim(),
                    email: _inviteEmailController.text.trim(),
                    telephone: _inviteTelephoneController.text.trim(),
                    lienParent: _inviteLienParenteController.text.trim(),
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                    _showSnackbar("Invitation envoyée avec succès à ${_inviteEmailController.text.trim()}.");
                  }

                } catch (e) {
                  _showSnackbar("Erreur lors de l'envoi de l'invitation: ${e.toString().replaceAll('Exception: ', '')}", isError: true);
                  setStateLocal(() => isLoading = false);
                }
              }
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: const Text(
                'Inviter un membre',
                style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 18),
              ),
              content: Form(
                key: _inviteFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDialogTextField(
                        controller: _inviteNomCompletController,
                        label: 'Nom Complet',
                        icon: Icons.person_outline,
                        validator: (v) => v!.isEmpty ? 'Le nom complet est requis.' : null,
                      ),
                      _buildDialogTextField(
                        controller: _inviteEmailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v!.isEmpty) return 'L\'email est requis.';
                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRegex.hasMatch(v)) return 'Format d\'email invalide.';
                          return null;
                        },
                      ),
                      _buildDialogTextField(
                        controller: _inviteTelephoneController,
                        label: 'Téléphone',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Le téléphone est requis.' : null,
                      ),
                      _buildDialogTextField(
                        controller: _inviteLienParenteController,
                        label: 'Lien de Parenté (Ex: Père, Sœur)',
                        icon: Icons.group_outlined,
                        validator: (v) => v!.isEmpty ? 'Le lien de parenté est requis.' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : submitInvitation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainAccentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 15, height: 15,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text('Envoyer l\'invitation', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  // =======================================================
  // ---  LOGIQUE : Changer le rôle d'un membre (CORRECTION DU CRASH POST-SUCCÈS) ---
  // =======================================================

  void _showChangeRoleDialog(BuildContext context, FamilyMemberModel member) {

    // 1. Initialisation sécurisée
    final String initialRole = member.roleFamille?.toUpperCase() ?? 'LECTEUR';
    const List<String> allowedRoles = ['LECTEUR', 'EDITEUR', 'ADMIN'];

    // ✅ CORRECTION : selectedRole est String non-nullable
    String selectedRole = (allowedRoles.contains(initialRole) ? initialRole : 'LECTEUR').toUpperCase();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            bool isLoading = false;
            FamilyMemberModel currentMember = member;

            final String currentMemberRoleUpper = currentMember.roleFamille?.toUpperCase() ?? 'LECTEUR';
            final String currentMemberRoleDisplay = currentMember.roleFamille ?? 'Rôle inconnu';

            // Fonction de soumission (Appel API PUT)
            Future<void> submitRoleChange() async {

              if (selectedRole == currentMemberRoleUpper) {
                _showSnackbar("Veuillez sélectionner un nouveau rôle différent.", isError: true);
                return;
              }

              if (currentMemberRoleUpper == 'ADMIN') {
                _showSnackbar("Impossible de modifier le rôle de l'administrateur de cette famille directement via cette interface.", isError: true);
                return;
              }

              setStateLocal(() => isLoading = true);

              try {
                await _memberService.updateMemberRole(
                  familleId: widget.familleId,
                  membreId: currentMember.id,
                  nouveauRole: selectedRole,
                );

                // 💡 CORRECTION DU CRASH : Fermer le dialogue avant de mettre à jour le state de l'écran
                if (mounted) {
                  Navigator.of(context).pop(); // Fermeture immédiate du dialogue
                  _loadFamilyMembers(); // Rechargement de la liste sur l'écran principal
                  _showSnackbar("Rôle de ${currentMember.prenom} mis à jour en '$selectedRole' avec succès.");
                }

              } catch (e) {
                // En cas d'erreur, uniquement mettre à jour l'état local du dialogue pour réactiver le bouton
                setStateLocal(() => isLoading = false);
                _showSnackbar("Erreur lors du changement de rôle: ${e.toString().replaceAll('Exception: ', '')}", isError: true);
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
                    'Rôle actuel : $currentMemberRoleDisplay',
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
                          selectedRole = newValue!;
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

  // --- LOGIQUE : Afficher les détails d'un membre ---

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

    final String roleFamille = member.roleFamille ?? 'Rôle inconnu';
    final String statut = member.statut ?? 'Statut inconnu';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Nom complet', '${member.prenom} ${member.nom}'),
        _buildDetailRow('Email', member.email),
        _buildDetailRow('Téléphone', telephone),
        const SizedBox(height: 10),
        _buildDetailRow('Lien de Parenté', lienParente),
        _buildDetailRow('Ethnie', ethnie),
        const SizedBox(height: 10),
        _buildDetailRow('Rôle', roleFamille),
        _buildDetailRow('Statut', statut),
        _buildDetailRow('Date d\'ajout', formattedDateAjout),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}