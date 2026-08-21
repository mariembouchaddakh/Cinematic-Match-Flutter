# Correction de l'erreur CONFIGURATION_NOT_FOUND

L'erreur `CONFIGURATION_NOT_FOUND` signifie que Firebase Authentication n'a pas les clés OAuth nécessaires pour reCAPTCHA.

## Solution : Ajouter les empreintes SHA dans Firebase Console

### Étape 1 : Obtenir les empreintes SHA-1 et SHA-256

✅ **Déjà fait !** Voici vos empreintes :

- **SHA-1** : `C7:62:54:87:8D:D3:D3:63:50:F9:F5:91:B6:9D:C0:39:63:25:D8:C7`
- **SHA-256** : `32:91:68:75:39:DE:E0:78:85:1A:01:59:70:AA:67:CE:08:B6:93:B6:C1:81:41:B8:9A:A8:26:C3:FB:3E:95:41`

### Étape 2 : Ajouter les empreintes dans Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet (`project-73978`)
3. Cliquez sur l'icône ⚙️ (Paramètres du projet)
4. Allez dans l'onglet **Vos applications**
5. Trouvez votre application Android (`com.example.projet`)
6. Cliquez sur l'application
7. Cliquez sur **Ajouter une empreinte**
8. Collez cette empreinte SHA-1 :
   ```
   C7:62:54:87:8D:D3:D3:63:50:F9:F5:91:B6:9D:C0:39:63:25:D8:C7
   ```
9. Cliquez sur **Ajouter une empreinte** à nouveau
10. Collez cette empreinte SHA-256 :
    ```
    32:91:68:75:39:DE:E0:78:85:1A:01:59:70:AA:67:CE:08:B6:93:B6:C1:81:41:B8:9A:A8:26:C3:FB:3E:95:41
    ```
11. Cliquez sur **Enregistrer**

### Étape 3 : Télécharger le nouveau google-services.json

1. Toujours dans la page de votre application Android
2. Cliquez sur **Télécharger google-services.json**
3. Remplacez le fichier `android/app/google-services.json` par le nouveau fichier

### Étape 4 : Vérifier que Authentication est activé

1. Dans Firebase Console, allez dans **Authentication**
2. Allez dans l'onglet **Sign-in method**
3. Vérifiez que **Email/Password** est activé
4. Si ce n'est pas le cas, activez-le et cliquez sur **Enregistrer**

### Étape 5 : Reconstruire l'application

```bash
flutter clean
flutter pub get
flutter run -d emulator-5554
```

## Solution alternative : Désactiver reCAPTCHA (pour le développement)

Si vous voulez tester rapidement sans configurer les empreintes SHA, vous pouvez désactiver reCAPTCHA dans Firebase Console :

1. Allez dans **Authentication** > **Settings**
2. Dans la section **Authorized domains**, vérifiez que votre domaine est autorisé
3. Dans **Sign-in method** > **Email/Password**, vous pouvez configurer les paramètres de sécurité

**Note** : Cette solution n'est recommandée que pour le développement. Pour la production, configurez correctement les empreintes SHA.

## Vérification

Après avoir fait ces étapes, essayez de vous inscrire à nouveau. L'erreur `CONFIGURATION_NOT_FOUND` devrait disparaître.

