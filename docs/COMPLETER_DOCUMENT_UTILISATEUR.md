# Comment compléter votre document utilisateur dans Firestore 📝

## Problème

Votre document utilisateur dans Firestore ne contient que le champ `favoriteMovies`. Il manque tous les autres champs nécessaires (email, firstName, lastName, age, role, isActive, etc.).

## Solution : Ajouter tous les champs manquants

### 📋 Champs à ajouter

Votre document doit contenir les champs suivants :

| Champ | Type | Valeur | Description |
|-------|------|--------|-------------|
| `email` | string | Votre email | L'email avec lequel vous vous êtes inscrit |
| `firstName` | string | Votre prénom | Votre prénom |
| `lastName` | string | Votre nom | Votre nom de famille |
| `age` | number | Votre âge | Votre âge (ex: 25) |
| `role` | string | `admin` | Pour devenir admin, sinon `user` |
| `isActive` | boolean | `true` | Pour activer le compte |
| `favoriteMovies` | array | `[]` | Déjà présent, gardez-le |
| `photoUrl` | string | (optionnel) | URL de votre photo de profil |

---

## 🎯 Guide pas à pas

### Étape 1 : Ouvrir votre document

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Firestore Database → Data
3. Collection `users`
4. Cliquez sur votre document (celui qui contient `favoriteMovies`)

### Étape 2 : Ajouter les champs un par un

Pour chaque champ ci-dessous, cliquez sur **"Add field"** ou **"+"** et ajoutez :

#### 1. Champ `email` (string)

- **Field name** : `email`
- **Type** : `string`
- **Value** : Votre adresse email (ex: `marie@gmail.com`)
- Cliquez sur **"Update"**

#### 2. Champ `firstName` (string)

- **Field name** : `firstName`
- **Type** : `string`
- **Value** : Votre prénom (ex: `Marie`)
- Cliquez sur **"Update"**

#### 3. Champ `lastName` (string)

- **Field name** : `lastName`
- **Type** : `string`
- **Value** : Votre nom (ex: `Dupont`)
- Cliquez sur **"Update"**

#### 4. Champ `age` (number)

- **Field name** : `age`
- **Type** : `number` (pas string !)
- **Value** : Votre âge (ex: `25` - sans guillemets)
- Cliquez sur **"Update"**

#### 5. Champ `role` (string)

- **Field name** : `role`
- **Type** : `string`
- **Value** : `admin` (pour devenir admin) ou `user` (pour un utilisateur normal)
- Cliquez sur **"Update"**

#### 6. Champ `isActive` (boolean)

- **Field name** : `isActive`
- **Type** : `boolean` (pas string !)
- **Value** : `true` (cochez la case ou sélectionnez true)
- Cliquez sur **"Update"**

#### 7. Champ `photoUrl` (string) - Optionnel

- **Field name** : `photoUrl`
- **Type** : `string`
- **Value** : URL de votre photo (ou laissez vide si vous n'avez pas de photo)
- Cliquez sur **"Update"**

---

## ✅ Structure finale du document

Votre document devrait ressembler à ceci :

```
Document ID: [votre-uid-firebase]
Fields:
  - email: "votre@email.com" (string)
  - firstName: "Marie" (string)
  - lastName: "Dupont" (string)
  - age: 25 (number)
  - role: "admin" (string) ← Pour devenir admin
  - isActive: true (boolean)
  - favoriteMovies: [] (array) ← Déjà présent
  - photoUrl: "https://..." (string) [optionnel]
```

---

## 🎯 Exemple concret

Si vous vous appelez **Marie Bouchaddakh**, avez **25 ans**, et votre email est **marie@gmail.com** :

```
email: "marie@gmail.com" (string)
firstName: "Marie" (string)
lastName: "Bouchaddakh" (string)
age: 25 (number)
role: "admin" (string)
isActive: true (boolean)
favoriteMovies: [] (array)
```

---

## ⚠️ Points importants

1. **Types de champs** :
   - `email`, `firstName`, `lastName`, `role`, `photoUrl` → Type **string**
   - `age` → Type **number** (pas string !)
   - `isActive` → Type **boolean** (pas string !)
   - `favoriteMovies` → Type **array** (déjà présent)

2. **Valeurs** :
   - Pour `role` : `admin` ou `user` (en minuscules, sans guillemets dans l'interface)
   - Pour `isActive` : `true` ou `false` (boolean, pas de guillemets)
   - Pour `age` : Un nombre (ex: `25`, pas `"25"`)

3. **Ordre** : L'ordre des champs n'a pas d'importance

---

## 🔄 Après avoir ajouté tous les champs

1. **Fermez complètement** l'application Flutter
2. **Relancez-la** avec `flutter run`
3. **Connectez-vous** avec votre compte
4. Si vous avez mis `role: "admin"`, l'onglet **"Admin"** devrait apparaître !

---

## 🆘 Si vous avez des problèmes

### Problème : Je ne trouve pas le bouton "Add field"

**Solution** : 
- Cliquez sur votre document pour l'ouvrir
- Le bouton peut être en haut à droite ou en bas de la liste des champs
- Parfois, il faut cliquer sur un bouton **"+"** ou **"Add field"**

### Problème : Je ne peux pas changer le type

**Solution** :
- Dans Firestore, vous devez d'abord choisir le type avant d'entrer la valeur
- Si vous avez déjà créé le champ avec le mauvais type, supprimez-le et recréez-le

### Problème : Le champ `age` ne fonctionne pas

**Solution** :
- Assurez-vous que le type est **number** (pas string)
- Entrez juste le nombre (ex: `25`) sans guillemets
- Si vous voyez `"25"` avec des guillemets, c'est une string, pas un number

---

## 📝 Résumé rapide

1. Ouvrez votre document dans Firestore
2. Ajoutez ces champs :
   - `email` (string) : Votre email
   - `firstName` (string) : Votre prénom
   - `lastName` (string) : Votre nom
   - `age` (number) : Votre âge
   - `role` (string) : `admin` ou `user`
   - `isActive` (boolean) : `true`
3. Gardez `favoriteMovies` (déjà présent)
4. Redémarrez l'application
5. Connectez-vous
6. ✅ C'est fait !

**Besoin d'aide ?** Vérifiez que tous les types de champs sont corrects (string, number, boolean) et que les valeurs sont correctes.

