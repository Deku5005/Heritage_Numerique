import 'package:flutter/material.dart';

// Imports nécessaires pour les appels API et le stockage (doivent être présents dans votre pubspec.yaml)

// IMPORTS LOCAUX (CHEMINS MIS À JOUR)
import 'editProfil.dart'; // Importe la page de modification
import '../Service/UtilisateurService1.dart';
import '../model/utilisateur1.dart'; // Correction du chemin de l'import (de 'model/' à 'models/')
// Correction du nom de l'import
// 💡 Import de l'écran de destination principal
import '../screens/contes_screen.dart';

// --- Constantes de Style ---
const Color _primaryColor = Color(0xFF714D1D);
const Color _primaryTextColor = Color(0xFF000000);
const Color _secondaryTextColor = Color(0xFF99928F);

// =======================================================
// CONVERSION EN STATEFULWIDGET POUR GÉRER L'ÉTAT ET L'API
// =======================================================

class ProfilePage extends StatefulWidget {
  final int? familyId;
  const ProfilePage({super.key, required this.familyId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Déclaration du Future et du Service
  late final UtilisateurService1 _userService;
  late Future<Utilisateur1> _userFuture;

  @override
  void initState() {
    super.initState();
    // 1. Initialisation du service (les services de stockage sont injectés par défaut ici)
    // NOTE: S'assurer que MembreIdStorageService est correctement importé
    _userService = UtilisateurService1();

    // 2. Lancement de la récupération des données de l'utilisateur connecté
    _userFuture = _userService.getCurrentUser();
  }

  // Widget pour une ligne de détail du profil (Icône + Titre + Valeur)
  Widget _buildProfileDetail({
    required IconData icon,
    required String title,
    required String value,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 2.0),
            child: Icon(icon, color: _primaryTextColor, size: 28),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: _primaryTextColor,
                    height: 1.4,
                  ),
                ),
                Text(
                  isPassword ? '******' : value,
                  style: TextStyle(
                    fontWeight: isPassword ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 14,
                    color: isPassword ? _primaryTextColor : _secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fonction de navigation qui passe les données de l'utilisateur
  void _navigateToEditProfile(BuildContext context, Utilisateur1 user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // Utilisation correcte du paramètre nommé initialUser
        builder: (context) => EditProfilePage(initialUser: user),
      ),
    ).then((value) {
      // Recharger les données après le retour de la page de modification
      if (value == true) {
        setState(() {
          _userFuture = _userService.getCurrentUser();
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 64,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        // Permet au Scaffold de déterminer s'il doit ajouter un bouton de retour par défaut
        // Nous le gérons manuellement, donc on le désactive.
        automaticallyImplyLeading: false,

        // 💡 LOGIQUE CORRIGÉE DU BOUTON RETOUR
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primaryTextColor),
          onPressed: () {

              // 2. Navigation vers la page principale si la page actuelle est la "racine"
              // (ex: affichée via pushReplacement par BottomNavigationWidget)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ContesScreen()),
              );
            }
        ),

        // 💡 Ajustement du titre : on utilise simplement le champ 'title' sans Center
        title: const Text(
          'Héritage Numérique',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: _primaryTextColor,
          ),
        ),

        actions: const [
          SizedBox(width: 20), // Espace pour équilibrer avec le bouton de retour à gauche
        ],
      ),

      // =======================================================
      // CORPS DE LA PAGE AVEC FUTUREBUILDER
      // =======================================================
      body: FutureBuilder<Utilisateur1>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // État de chargement
            return const Center(child: CircularProgressIndicator(color: _primaryColor));
          } else if (snapshot.hasError) {
            // État d'erreur (si l'appel API échoue ou le token manque)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'Erreur de chargement des données: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _primaryTextColor),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            // Données disponibles
            final Utilisateur1 user = snapshot.data!;

            // Extraction des données avec des valeurs par défaut pour les champs nuls
            final String dynamicUserName = '${user.prenom ?? ''} ${user.nom ?? ''}'.trim();
            final String dynamicUserEmail = user.email ?? 'Non spécifié';
            final String dynamicUserPhone = user.numeroTelephone ?? 'N/A';
            final String dynamicUserEthnie = user.ethnie ?? 'Non renseignée';

            // Affichage de la structure du profil
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // --- Titre "Profil" ---
                  const Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      'Profil',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: _primaryTextColor,
                      ),
                    ),
                  ),

                  // --- Informations Utilisateur (Avatar + Noms/Email) ---
                  Column(
                    children: [
                      // Avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: _primaryColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          dynamicUserName.isNotEmpty ? dynamicUserName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Nom complet
                      Text(
                        dynamicUserName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: _primaryTextColor,
                        ),
                      ),

                      // Email
                      Text(
                        dynamicUserEmail,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: _secondaryTextColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // --- Champs de Détail du Profil ---
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Column(
                      children: [
                        _buildProfileDetail(
                          icon: Icons.person_outline,
                          title: 'Nom',
                          value: user.nom ?? 'N/A',
                        ),

                        _buildProfileDetail(
                          icon: Icons.person_outline,
                          title: 'Prénom',
                          value: user.prenom ?? 'N/A',
                        ),

                        _buildProfileDetail(
                          icon: Icons.group_outlined, // Icône pour Ethnie
                          title: 'Ethnie',
                          value: dynamicUserEthnie,
                        ),

                        _buildProfileDetail(
                          icon: Icons.phone_outlined,
                          title: 'Téléphone',
                          value: dynamicUserPhone,
                        ),

                        _buildProfileDetail(
                          icon: Icons.mail_outline,
                          title: 'Email',
                          value: dynamicUserEmail,
                        ),

                        _buildProfileDetail(
                          icon: Icons.lock_outline,
                          title: 'Changer mot d epasse',
                          value: 'placeholder',
                          isPassword: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Bouton Modifier ---
                  Center(
                    child: ElevatedButton.icon(
                      // IMPORTANT : Passer l'objet utilisateur au navigateur
                      onPressed: () => _navigateToEditProfile(context, user),
                      icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
                      label: const Text(
                        'Modifier',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shadowColor: Colors.black.withOpacity(0.25),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: const Size(150, 50),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          // État par défaut (ne devrait pas arriver si les états précédents sont bien couverts)
          return const Center(child: Text('Initialisation...'));
        },
      ),
    );
  }
}