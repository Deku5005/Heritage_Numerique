# Structure API - Heritage Numérique

Cette structure fournit une base solide pour intégrer votre API Spring Boot avec votre application Flutter.

## Structure des dossiers

```
lib/
├── api/
│   ├── api_client.dart      # Client HTTP centralisé avec Dio
│   └── api_response.dart    # Classes pour gérer les réponses API
├── models/
│   └── base_model.dart      # Modèles de base et utilitaires
├── repositories/
│   └── base_repository.dart # Repository de base avec méthodes CRUD
├── services/
│   └── api_service.dart     # Service de configuration API
└── examples/
    └── example_integration.dart # Exemple d'utilisation
```

## Configuration

### 1. URL de base
Modifiez l'URL de base dans `lib/api/api_client.dart` :
```dart
static const String baseUrl = 'http://votre-serveur:8080/api';
```

### 2. Initialisation
Dans votre `main.dart`, initialisez l'API :
```dart
import 'package:heritage_numerique/services/api_service.dart';

void main() {
  ApiService().initialize();
  runApp(MyApp());
}
```

## Utilisation

### 1. Créer un modèle
```dart
@JsonSerializable()
class MonModele extends BaseModel {
  final int id;
  final String nom;
  
  MonModele({required this.id, required this.nom});
  
  factory MonModele.fromJson(Map<String, dynamic> json) => _$MonModeleFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MonModeleToJson(this);
}
```

### 2. Créer un repository
```dart
class MonRepository extends BaseRepository {
  Future<ApiResponse<List<MonModele>>> getAll() async {
    return await get<List<MonModele>>(
      '/mon-endpoint',
      fromJson: (data) => (data as List)
          .map((item) => MonModele.fromJson(item))
          .toList(),
    );
  }
}
```

### 3. Utiliser dans un widget
```dart
class MonWidget extends StatefulWidget {
  @override
  _MonWidgetState createState() => _MonWidgetState();
}

class _MonWidgetState extends State<MonWidget> {
  final MonRepository _repository = MonRepository();
  List<MonModele> _items = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    final response = await _repository.getAll();
    
    if (response.success && response.data != null) {
      setState(() {
        _items = response.data!;
        _loading = false;
      });
    } else {
      // Gérer l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Erreur inconnue')),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item.nom),
                  subtitle: Text('ID: ${item.id}'),
                );
              },
            ),
    );
  }
}
```

## Prochaines étapes

1. **Donnez-moi votre premier endpoint** avec sa documentation Swagger
2. **Je créerai le modèle et le repository** spécifiques
3. **Nous intégrerons** l'endpoint dans votre interface utilisateur

## Commandes utiles

```bash
# Installer les dépendances
flutter pub get

# Générer le code JSON (après avoir créé des modèles avec @JsonSerializable)
flutter packages pub run build_runner build

# Nettoyer et régénérer
flutter packages pub run build_runner build --delete-conflicting-outputs
```
