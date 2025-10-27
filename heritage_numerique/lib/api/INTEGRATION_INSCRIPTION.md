# Configuration de l'API - Heritage Numérique

## 🚀 Intégration de l'endpoint d'inscription terminée !

### ✅ Ce qui a été fait :

1. **Modèles créés** :
   - `RegisterRequest` - Modèle pour la requête d'inscription
   - `AuthResponse` - Modèle pour la réponse d'authentification
   - `LoginRequest` - Modèle pour la connexion (prêt pour plus tard)

2. **Repository créé** :
   - `AuthRepository` - Gestion complète de l'authentification
   - Méthodes pour inscription, connexion, sauvegarde des tokens
   - Gestion automatique du stockage local

3. **Interface mise à jour** :
   - Ajout des champs : numéro de téléphone, ethnie, code d'invitation
   - Intégration complète avec l'API
   - Gestion des erreurs et du loading
   - Validation des champs

4. **Configuration** :
   - Client API avec Dio configuré
   - Intercepteurs pour les tokens d'authentification
   - Configuration centralisée dans `ApiConfig`

### 🔧 Configuration requise :

**IMPORTANT** : Modifiez l'URL de base dans `lib/config/api_config.dart` :

```dart
// Pour émulateur Android
static const String baseUrl = 'http://10.0.2.2:8080/api';

// Pour appareil physique (remplacez par votre IP)
static const String baseUrl = 'http://192.168.1.100:8080/api';

// Pour production
static const String baseUrl = 'https://votre-domaine.com/api';
```

### 📱 Comment tester :

1. **Installez les dépendances** :
   ```bash
   flutter pub get
   ```

2. **Générez le code JSON** :
   ```bash
   flutter packages pub run build_runner build
   ```

3. **Configurez l'URL** dans `lib/config/api_config.dart`

4. **Lancez l'application** et testez l'inscription

### 🎯 Fonctionnalités de l'inscription :

- ✅ Validation des champs (email, téléphone, mot de passe)
- ✅ Code d'invitation optionnel
- ✅ Gestion des erreurs API
- ✅ Sauvegarde automatique du token
- ✅ Interface utilisateur responsive
- ✅ Indicateur de chargement
- ✅ Messages de succès/erreur

### 📋 Champs du formulaire :

1. **Prénom** (requis)
2. **Nom** (requis)
3. **Email** (requis, validation format)
4. **Numéro de téléphone** (requis, min 8 chiffres)
5. **Ethnie** (requis)
6. **Code d'invitation** (optionnel)
7. **Mot de passe** (requis, min 6 caractères)
8. **Confirmation mot de passe** (requis)

### 🔄 Prochaines étapes :

Donnez-moi le prochain endpoint que vous souhaitez intégrer ! Par exemple :
- Connexion (`/auth/login`)
- Profil utilisateur (`/users/profile`)
- Contes (`/contes`)
- Artisanat (`/artisanat`)
- etc.

### 🐛 Dépannage :

Si vous avez des erreurs :
1. Vérifiez que votre API Spring Boot est démarrée
2. Vérifiez l'URL dans `ApiConfig`
3. Vérifiez les logs dans la console Flutter
4. Assurez-vous que CORS est configuré sur votre API

L'intégration est prête ! Testez l'inscription et donnez-moi le prochain endpoint ! 🎉
