# Comment ajouter le rôle admin dans Firestore 🔐

## Problème

Vous ne trouvez pas le champ `role` dans votre document utilisateur dans Firestore. C'est normal si :
- Vous vous êtes inscrit avant que le champ `role` soit ajouté au code
- Le document utilisateur n'a pas été créé correctement lors de l'inscription

## Solution : Ajouter le champ manuellement

### 📋 Guide pas à pas

#### 1. Ouvrir Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Connectez-vous avec votre compte Google
3. Sélectionnez votre projet Firebase

#### 2. Accéder à Firestore

1. Dans le menu de gauche, cliquez sur **"Firestore Database"**
2. Cliquez sur l'onglet **"Data"** (si ce n'est pas déjà sélectionné)

#### 3. Trouver votre document utilisateur

1. Dans la liste des collections, vous devriez voir **`users`**
2. Cliquez sur **`users`** pour voir tous les utilisateurs
3. Trouvez votre document :
   - **Par email** : Cherchez un document qui contient votre email dans les champs
   - **Par UID** : Le document peut avoir votre UID Firebase comme ID du document
     - Pour trouver votre UID : Regardez l'ID du document (c'est souvent l'UID Firebase Auth)

#### 4. Ouvrir votre document

Cliquez sur votre document pour l'ouvrir et voir tous ses champs.

#### 5. Ajouter le champ `role`

**Si le champ `role` n'existe PAS :**

1. Cliquez sur le bouton **"Add field"** ou **"+"** (en haut à droite ou en bas de la liste des champs)
2. Un formulaire s'ouvre :
   - **Field name** : Tapez `role`
   - **Type** : Sélectionnez **string**
   - **Value** : Tapez `admin`
3. Cliquez sur **"Update"** ou **"Save"**

**Si le champ `role` existe déjà avec la valeur `"user"` :**

1. Cliquez sur la valeur `"user"` du champ `role`
2. Modifiez-la en `admin`
3. Cliquez sur **"Update"** ou **"Save"**

#### 6. Structure finale du document

Votre document devrait ressembler à ceci :

```
Document ID: [votre-uid]
Fields:
  - email: "votre@email.com" (string)
  - firstName: "Votre Prénom" (string)
  - lastName: "Votre Nom" (string)
  - age: 25 (number)
  - photoUrl: "https://..." (string) [optionnel]
  - role: "admin" (string) ← NOUVEAU CHAMP
  - isActive: true (boolean)
  - favoriteMovies: [] (array) [optionnel]
```

#### 7. Redémarrer l'application

1. **Fermez complètement** l'application Flutter
2. **Relancez-la** avec `flutter run`
3. **Connectez-vous** avec votre compte
4. L'onglet **"Admin"** devrait maintenant apparaître dans la barre d'onglets !

---

## 🎯 Vérification rapide

Pour vérifier que ça fonctionne :

1. Dans l'application, connectez-vous
2. Regardez la barre d'onglets en haut de l'écran d'accueil
3. Vous devriez voir un onglet **"Admin"** (en plus de Films, Favoris, Matching)

Si vous ne voyez toujours pas l'onglet Admin :
- Vérifiez que le champ `role` est bien `"admin"` (pas `admin` sans guillemets)
- Vérifiez que vous êtes connecté avec le bon compte
- Redémarrez complètement l'application

---

## 📸 Aide visuelle

### Dans Firebase Console :

```
Firebase Console
├── Firestore Database
    └── Data
        └── Collections
            └── users
                └── [votre-document-id]
                    ├── email: "votre@email.com"
                    ├── firstName: "Prénom"
                    ├── lastName: "Nom"
                    ├── age: 25
                    ├── role: "admin" ← AJOUTEZ ICI
                    └── isActive: true
```

### Bouton "Add field" :

Dans l'interface Firestore, vous verrez un bouton **"Add field"** ou **"+"** qui permet d'ajouter un nouveau champ au document.

---

## ⚠️ Notes importantes

1. **Type de champ** : Le champ `role` doit être de type **string** (texte)
2. **Valeur** : La valeur doit être exactement `"admin"` (en minuscules)
3. **Guillemets** : Dans Firestore, les strings sont automatiquement entre guillemets, vous n'avez pas besoin de les taper
4. **Sensibilité à la casse** : `"admin"` fonctionne, mais `"Admin"` ou `"ADMIN"` ne fonctionneront pas

---

## 🔧 Alternative : Créer un script

Si vous avez beaucoup d'utilisateurs à modifier, vous pouvez créer un script. Mais pour un seul utilisateur, la méthode manuelle est plus simple.

---

## ✅ Résumé

1. Firebase Console → Firestore Database → Collection `users`
2. Trouvez votre document
3. Ajoutez le champ `role` avec la valeur `admin` (type: string)
4. Sauvegardez
5. Redémarrez l'application
6. L'onglet Admin devrait apparaître !

**Besoin d'aide ?** Vérifiez que vous avez bien suivi toutes les étapes et que le champ est bien de type string avec la valeur exacte `admin`.

