# 🧪 Guide de Test - Intégration Inscription API

## ✅ **Statut : Prêt pour les tests !**

L'application Flutter est en cours de lancement avec l'intégration API complète.

## 🔧 **Configuration requise avant test :**

### 1. **URL de l'API** 
Modifiez dans `lib/config/api_config.dart` :

```dart
// Pour émulateur Android
static const String baseUrl = 'http://10.0.2.2:8080/api';

// Pour appareil physique (remplacez par votre IP)
static const String baseUrl = 'http://192.168.1.100:8080/api';
```

### 2. **Vérifiez que votre API Spring Boot est démarrée**
- Port : 8080 (par défaut)
- Endpoint : `/api/auth/register`
- CORS configuré pour accepter les requêtes Flutter

## 📱 **Comment tester l'inscription :**

1. **Lancez l'application** (en cours)
2. **Naviguez vers l'écran d'inscription**
3. **Remplissez le formulaire** avec :
   - Prénom : `Jean`
   - Nom : `Dupont`
   - Email : `jean.dupont@example.com`
   - Téléphone : `12345678`
   - Ethnie : `Bambara`
   - Code d'invitation : `INVITE123` (optionnel)
   - Mot de passe : `password123`
   - Confirmation : `password123`
4. **Cochez "J'accepte les conditions"**
5. **Cliquez sur "S'inscrire"**

## 🎯 **Comportements attendus :**

### ✅ **Succès :**
- Indicateur de chargement sur le bouton
- Message de succès : "Inscription réussie ! Bienvenue Jean Dupont"
- Navigation vers l'écran principal
- Token sauvegardé automatiquement

### ❌ **Erreurs possibles :**
- **Erreur de connexion** : Vérifiez l'URL de l'API
- **Erreur de validation** : Vérifiez les champs requis
- **Erreur serveur** : Vérifiez que votre API Spring Boot fonctionne

## 🔍 **Debug et logs :**

Les logs API sont affichés dans la console Flutter :
- `🚀 API Request: POST /auth/register`
- `📤 Data: {...}`
- `✅ API Response: 200 /auth/register`
- `📥 Data: {...}`

## 🐛 **Dépannage :**

### Problème : "Erreur de connexion"
**Solution :**
1. Vérifiez que votre API Spring Boot est démarrée
2. Vérifiez l'URL dans `ApiConfig`
3. Pour émulateur Android : utilisez `10.0.2.2:8080`
4. Pour appareil physique : utilisez l'IP de votre machine

### Problème : "CORS error"
**Solution :**
Configurez CORS dans votre API Spring Boot :
```java
@CrossOrigin(origins = "*")
@RestController
public class AuthController {
    // ...
}
```

### Problème : "Validation error"
**Solution :**
Vérifiez que tous les champs requis sont remplis :
- Email valide
- Téléphone (min 8 chiffres)
- Mot de passe (min 6 caractères)
- Conditions acceptées

## 🎉 **Prochaines étapes :**

Une fois l'inscription testée avec succès, donnez-moi le prochain endpoint à intégrer :
- Connexion (`/auth/login`)
- Profil utilisateur (`/users/profile`)
- Contes (`/contes`)
- Artisanat (`/artisanat`)
- etc.

**L'application est prête pour les tests !** 🚀
