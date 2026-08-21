# Configuration Firebase pour Windows

## Problème

Firebase sur Windows nécessite le SDK C++ Firebase qui n'est pas automatiquement téléchargé. C'est pourquoi vous obtenez des erreurs CMake lors de la compilation pour Windows.

## Solutions

### Solution 1 : Utiliser Android/iOS (Recommandé)

Firebase est mieux supporté sur Android et iOS. Pour tester l'application :

```bash
# Sur Android (émulateur ou appareil)
flutter run -d emulator-5554

# Ou sur un appareil Android connecté
flutter run -d <device-id>

# Pour iOS (sur Mac uniquement)
flutter run -d <ios-device-id>
```

### Solution 2 : Configurer Firebase pour Windows

Si vous devez absolument utiliser Windows, suivez ces étapes :

1. **Télécharger le SDK Firebase C++ pour Windows** :
   - Allez sur [Firebase C++ SDK Releases](https://github.com/firebase/firebase-cpp-sdk/releases)
   - Téléchargez la dernière version
   - Extrayez-le dans un dossier (par exemple `C:\firebase_cpp_sdk`)

2. **Configurer les variables d'environnement** :
   ```bash
   # Dans PowerShell (en tant qu'administrateur)
   [System.Environment]::SetEnvironmentVariable("FIREBASE_CPP_SDK", "C:\firebase_cpp_sdk", "Machine")
   ```

3. **Modifier le CMakeLists.txt** :
   Le plugin Firebase devrait détecter automatiquement le SDK, mais si ce n'est pas le cas, vous devrez peut-être modifier les fichiers CMake.

4. **Nettoyer et reconstruire** :
   ```bash
   flutter clean
   flutter pub get
   flutter run -d windows
   ```

### Solution 3 : Utiliser Firebase uniquement sur Android/iOS

Si vous ne voulez pas configurer Windows, vous pouvez conditionner l'utilisation de Firebase :

```dart
import 'dart:io' show Platform;

// Dans votre code
if (Platform.isAndroid || Platform.isIOS) {
  await Firebase.initializeApp();
} else {
  // Mode démo ou désactiver Firebase sur Windows
  print('Firebase non disponible sur cette plateforme');
}
```

## Recommandation

Pour le développement et les tests, utilisez **Android** ou **iOS** où Firebase est entièrement supporté. Windows peut être utilisé pour le développement de l'UI, mais pour les fonctionnalités Firebase complètes, utilisez Android/iOS.

## Vérification

Pour vérifier que Firebase fonctionne correctement :

1. Lancez sur Android : `flutter run -d emulator-5554`
2. Testez l'inscription/connexion
3. Vérifiez que les données sont sauvegardées dans Firestore

## Notes

- Firebase Storage et Firestore fonctionnent mieux sur Android/iOS
- L'authentification Firebase est également mieux supportée sur mobile
- Pour une application de production, privilégiez Android/iOS

