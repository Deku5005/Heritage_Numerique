import 'package:flutter/material.dart';
import 'HomeDashboardScreen.dart';
import 'AppDrawer.dart';
import 'package:heritage_numerique/Service/FamilyMemberService.dart';
import 'package:heritage_numerique/model/family_member_model.dart';
import 'package:heritage_numerique/model/family_model.dart';

// --- THÈME BLANC + DORÉ MODERNE ---
const Color _mainAccentColor = Color(0xFFD4A017);
const Color _backgroundColor = Color(0xFFFFFFFF);
const Color _cardTextColor = Color(0xFF1A1A1A);
const Color _searchBackground = Color(0xFFF5F5F5);

class FamilyMembersScreen extends StatefulWidget {
  final int familleId;
  const FamilyMembersScreen({super.key, required this.familleId});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen>
    with TickerProviderStateMixin {
  final FamilyMemberService _memberService = FamilyMemberService();
  late Future<List<FamilyMemberModel>> _membersData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Contrôleurs pour invitation
  final _inviteNomCompletController = TextEditingController();
  final _inviteEmailController = TextEditingController();
  final _inviteTelephoneController = TextEditingController();
  final _inviteLienParenteController = TextEditingController();

  // Contrôleurs pour ajout manuel
  final _manualNomController = TextEditingController();
  final _manualPrenomController = TextEditingController();
  final _manualEmailController = TextEditingController();
  final _manualTelephoneController = TextEditingController();
  final _manualEthnieController = TextEditingController();
  final _manualLienParenteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  @override
  void dispose() {
    _inviteNomCompletController.dispose();
    _inviteEmailController.dispose();
    _inviteTelephoneController.dispose();
    _inviteLienParenteController.dispose();
    _manualNomController.dispose();
    _manualPrenomController.dispose();
    _manualEmailController.dispose();
    _manualTelephoneController.dispose();
    _manualEthnieController.dispose();
    _manualLienParenteController.dispose();
    super.dispose();
  }

  void _loadFamilyMembers() {
    if (mounted) {
      setState(() {
        _membersData = _memberService.fetchFamilyMembers(familleId: widget.familleId);
      });
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
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
      drawer: AppDrawer(familyId: widget.familleId), // Icône menu automatique
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildPageTitle()),
          SliverToBoxAdapter(child: _buildActionSection()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            sliver: _buildMembersGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      floating: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 100, bottom: 16),
        title: const Text(
          'Héritage Numérique',
          style: TextStyle(
            color: _cardTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membres de la famille',
            style: TextStyle(
              color: _cardTextColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Gérer les membres et leurs contributions',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _searchBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un membre...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: _mainAccentColor),
                ),
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            text: 'Ajouter',
            icon: Icons.add,
            onPressed: () => _showAddManualDialog(context),
          ),
          const SizedBox(width: 10),
          _buildActionButton(
            text: 'Inviter',
            icon: Icons.person_add,
            isPrimary: true,
            onPressed: () => _showInviteMemberDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    bool isPrimary = false,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? _mainAccentColor : _searchBackground,
          foregroundColor: isPrimary ? Colors.white : _cardTextColor,
          padding: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isPrimary ? 4 : 0,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18),
            const SizedBox(height: 2),
            Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersGrid() {
    return FutureBuilder<List<FamilyMemberModel>>(
      future: _membersData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator(color: _mainAccentColor)),
          );
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                "Erreur: ${snapshot.error.toString().replaceAll('Exception: ', '')}",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text(
                "Aucun membre trouvé.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          );
        }

        final members = snapshot.data!;
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9, // Corrige overflow
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final member = members[index];
              return _buildMemberCard(member, index);
            },
            childCount: members.length,
          ),
        );
      },
    );
  }

  Widget _buildMemberCard(FamilyMemberModel member, int index) {
    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final animation = CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic);

    Future.delayed(Duration(milliseconds: 100 * index), () {
      if (mounted) animationController.forward();
    });

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(animation),
        child: GestureDetector(
          onTap: () => _showMemberDetailDialog(context, member.id),
          child: Card(
            elevation: 6,
            shadowColor: Colors.black.withOpacity(0.9),
            color: Colors.white, // BLANC PUR
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Cercle profil
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [_mainAccentColor, _mainAccentColor.withOpacity(0.7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _mainAccentColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      // Nom
                      Text(
                        '${member.prenom} ${member.nom}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _cardTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Rôle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(member.roleFamille),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          member.roleFamille ?? 'Rôle inconnu',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _cardTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bouton changer rôle
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                    child: FloatingActionButton(
                      mini: true,
                      heroTag: 'role_${member.id}',
                      backgroundColor: _mainAccentColor,
                      elevation: 4,
                      onPressed: () => _showChangeRoleDialog(context, member),
                      child: const Icon(Icons.security, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String? role) {
    if (role == null) return Colors.grey.shade200;
    final r = role.toUpperCase();
    if (r.contains('ADMIN')) return Colors.green.shade100;
    if (r.contains('EDITEUR')) return Colors.blue.shade100;
    if (r.contains('LECTEUR')) return Colors.orange.shade100;
    return Colors.grey.shade200;
  }

  // === CHAMPS DIALOGUE MODERNISÉS ===
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 15, color: _cardTextColor),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: _mainAccentColor, size: 22),
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 15),
          filled: true,
          fillColor: _searchBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _mainAccentColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  // === AJOUT MANUEL ===
  void _showAddManualDialog(BuildContext context) {
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
      builder: (context) => StatefulBuilder(
        builder: (context, setStateLocal) {
          bool isLoading = false;
          final formKey = GlobalKey<FormState>();

          Future<void> submitManualAdd() async {
            if (formKey.currentState!.validate()) {
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
                  _loadFamilyMembers();
                  _showSnackbar("Membre ajouté avec succès.");
                }
              } catch (e) {
                _showSnackbar("Erreur : ${e.toString()}", isError: true);
                setStateLocal(() => isLoading = false);
              }
            }
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Ajouter un membre', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    Expanded(child: _buildDialogTextField(controller: _manualPrenomController, label: 'Prénom', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Requis' : null)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDialogTextField(controller: _manualNomController, label: 'Nom', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Requis' : null)),
                  ]),
                  _buildDialogTextField(controller: _manualEmailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Requis' : null),
                  _buildDialogTextField(controller: _manualTelephoneController, label: 'Téléphone', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Requis' : null),
                  _buildDialogTextField(controller: _manualEthnieController, label: 'Ethnie', icon: Icons.flag_outlined, validator: (v) => v!.isEmpty ? 'Requis' : null),
                  _buildDialogTextField(controller: _manualLienParenteController, label: 'Lien de Parenté', icon: Icons.group_outlined, validator: (v) => v!.isEmpty ? 'Requis' : null),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: _searchBackground, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: const InputDecoration(labelText: 'Rôle', border: InputBorder.none),
                      items: allowedRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) => setStateLocal(() => selectedRole = v!),
                    ),
                  ),
                ]),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: isLoading ? null : submitManualAdd,
                style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Ajouter'),
              ),
            ],
          );
        },
      ),
    );
  }

  // === INVITATION ===
  void _showInviteMemberDialog(BuildContext context) {
    _inviteNomCompletController.clear();
    _inviteEmailController.clear();
    _inviteTelephoneController.clear();
    _inviteLienParenteController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateLocal) {
          bool isLoading = false;
          final formKey = GlobalKey<FormState>();

          Future<void> submitInvitation() async {
            if (formKey.currentState!.validate()) {
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
                  _showSnackbar("Invitation envoyée !");
                }
              } catch (e) {
                _showSnackbar("Erreur : ${e.toString()}", isError: true);
                setStateLocal(() => isLoading = false);
              }
            }
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Inviter un membre', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _buildDialogTextField(controller: _inviteNomCompletController, label: 'Nom complet', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Requis' : null),
                  _buildDialogTextField(controller: _inviteEmailController, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Requis' : null),
                  _buildDialogTextField(controller: _inviteTelephoneController, label: 'Téléphone', icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Requis' : null),
                  _buildDialogTextField(controller: _inviteLienParenteController, label: 'Lien de Parenté', icon: Icons.group_outlined, validator: (v) => v!.isEmpty ? 'Requis' : null),
                ]),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: isLoading ? null : submitInvitation,
                style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Envoyer'),
              ),
            ],
          );
        },
      ),
    );
  }

  // === CHANGER RÔLE ===
  void _showChangeRoleDialog(BuildContext context, FamilyMemberModel member) {
    final initialRole = member.roleFamille?.toUpperCase() ?? 'LECTEUR';
    const allowedRoles = ['LECTEUR', 'EDITEUR', 'ADMIN'];
    String selectedRole = allowedRoles.contains(initialRole) ? initialRole : 'LECTEUR';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateLocal) {
          bool isLoading = false;

          Future<void> submitRoleChange() async {
            if (selectedRole == initialRole) {
              _showSnackbar("Choisissez un rôle différent.", isError: true);
              return;
            }
            if (initialRole == 'ADMIN') {
              _showSnackbar("Impossible de modifier l'admin.", isError: true);
              return;
            }
            setStateLocal(() => isLoading = true);
            try {
              await _memberService.updateMemberRole(
                familleId: widget.familleId,
                membreId: member.id,
                nouveauRole: selectedRole,
              );
              if (mounted) {
                Navigator.pop(context);
                _loadFamilyMembers();
                _showSnackbar("Rôle mis à jour !");
              }
            } catch (e) {
              _showSnackbar("Erreur : ${e.toString()}", isError: true);
              setStateLocal(() => isLoading = false);
            }
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Changer le rôle'),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Membre : ${member.prenom} ${member.nom}', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: _searchBackground, borderRadius: BorderRadius.circular(12)),
                child: DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Nouveau rôle', border: InputBorder.none),
                  items: allowedRoles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setStateLocal(() => selectedRole = v!),
                ),
              ),
            ]),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
              ElevatedButton(
                onPressed: isLoading ? null : submitRoleChange,
                style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Confirmer'),
              ),
            ],
          );
        },
      ),
    );
  }

  // === DÉTAILS MEMBRE ===
  void _showMemberDetailDialog(BuildContext context, int membreId) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: FutureBuilder<FamilyMemberModel>(
          future: _memberService.fetchMemberDetail(membreId: membreId),
          builder: (context, snapshot) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Détails du membre', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _cardTextColor)),
                  const Divider(height: 20),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator(color: _mainAccentColor))
                  else if (snapshot.hasError)
                    Center(child: Text("Erreur: ${snapshot.error}", style: const TextStyle(color: Colors.red)))
                  else if (snapshot.hasData)
                      _buildMemberDetailContent(snapshot.data!),
                  const SizedBox(height: 20),
                  Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer', style: TextStyle(color: _mainAccentColor)))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMemberDetailContent(FamilyMemberModel member) {
    final date = member.dateAjout.year > 1 ? member.dateAjout : DateTime.now();
    final formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildDetailRow('Nom complet', '${member.prenom} ${member.nom}'),
      _buildDetailRow('Email', member.email),
      _buildDetailRow('Téléphone', member.telephone ?? 'Non spécifié'),
      _buildDetailRow('Lien de Parenté', member.lienParente ?? 'N/A'),
      _buildDetailRow('Ethnie', member.ethnie ?? 'N/A'),
      _buildDetailRow('Rôle', member.roleFamille ?? 'Inconnu'),
      _buildDetailRow('Statut', member.statut ?? 'Inconnu'),
      _buildDetailRow('Date d\'ajout', formattedDate),
    ]);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text('$label :', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black54))),
        ],
      ),
    );
  }
}