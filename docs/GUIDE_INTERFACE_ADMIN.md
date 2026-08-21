# Guide de l'Interface Admin 🎬

## Vue d'ensemble

L'interface admin est accessible uniquement aux utilisateurs ayant le rôle **"admin"** dans Firebase. Elle permet de gérer les films et les utilisateurs de l'application.

---

## 📍 Comment accéder à l'interface admin ?

1. **Connectez-vous** avec un compte qui a le rôle `admin` dans Firebase
2. Dans l'écran d'accueil (HomeScreen), vous verrez un **onglet "Admin"** dans la barre d'onglets en haut
3. Cliquez sur cet onglet pour accéder à l'interface admin

> **Note :** Si vous ne voyez pas l'onglet Admin, votre compte n'a pas le rôle admin. Voir la section "Comment devenir admin ?" ci-dessous.

---

## 🎯 Fonctionnalités de l'interface admin

L'interface admin est divisée en **2 onglets** :

### 1️⃣ Onglet "Ajouter un film" 🎬

Cet onglet permet d'ajouter manuellement des films à la base de données Firestore.

#### Interface
- **Icône** : Grande icône de film (🎬) au centre
- **Titre** : "Ajouter un nouveau film"
- **Bouton** : "Ajouter un film" (avec icône +)

#### Comment ajouter un film ?

1. Cliquez sur le bouton **"Ajouter un film"**
2. Un formulaire s'ouvre avec les champs suivants :

   | Champ | Description | Obligatoire | Exemple |
   |-------|-------------|-------------|---------|
   | **Titre** | Nom du film | ✅ Oui | "Inception" |
   | **Description** | Résumé du film | ❌ Non | "Un voleur qui entre dans les rêves..." |
   | **URL de l'image** | Lien vers l'affiche | ❌ Non | "https://example.com/poster.jpg" |
   | **Note** | Note sur 10 | ❌ Non | "8.5" |
   | **Année** | Année de sortie | ❌ Non | "2010" |
   | **Genre** | Genre(s) du film | ❌ Non | "Action, Thriller" |
   | **Réalisateur** | Nom du réalisateur | ❌ Non | "Christopher Nolan" |

3. Remplissez au minimum le **Titre** (obligatoire)
4. Cliquez sur **"Ajouter"** pour sauvegarder
5. Le film est immédiatement ajouté à Firestore et apparaîtra dans la liste des films

#### Comportement
- ✅ Le film est sauvegardé dans Firestore (collection `movies`)
- ✅ Le film apparaît immédiatement dans la liste des films de tous les utilisateurs
- ✅ Si vous ne remplissez pas l'URL de l'image, une image placeholder est utilisée
- ✅ Les champs optionnels non remplis prennent des valeurs par défaut ("Non spécifié")

---

### 2️⃣ Onglet "Gérer les utilisateurs" 👥

Cet onglet permet de voir tous les utilisateurs et de les activer/désactiver.

#### Interface
- **Liste** : Affiche tous les utilisateurs enregistrés dans Firestore
- **Carte utilisateur** : Chaque utilisateur est affiché dans une carte avec :
  - Photo de profil (ou initiale si pas de photo)
  - Nom complet (prénom + nom)
  - Email
  - Âge
  - Rôle (user ou admin)
  - Statut (Actif ou Désactivé)
  - Bouton d'action (activer/désactiver)

#### Informations affichées pour chaque utilisateur

```
┌─────────────────────────────────────┐
│  [Photo]  Prénom Nom                 │
│           email@example.com          │
│           Âge: 25 ans                │
│           Rôle: user                 │
│           Statut: Actif (vert)      │
│                          [Bouton]    │
└─────────────────────────────────────┘
```

#### Actions disponibles

**Activer/Désactiver un utilisateur :**
- Cliquez sur le bouton à droite de chaque utilisateur
- **Icône rouge (🚫)** = Utilisateur actif → Cliquez pour **désactiver**
- **Icône verte (✅)** = Utilisateur désactivé → Cliquez pour **activer**

#### Comportement
- ✅ Un utilisateur **désactivé** ne peut plus se connecter à l'application
- ✅ Un utilisateur **activé** peut se connecter normalement
- ✅ Le statut est sauvegardé dans Firestore (champ `isActive`)
- ✅ Un message de confirmation s'affiche après chaque action
- ✅ La liste se met à jour automatiquement après chaque action

---

## 🔐 Comment devenir administrateur ?

Pour accéder à l'interface admin, votre compte doit avoir le rôle `"admin"` dans Firestore.

### Méthode 1 : Via Firebase Console (Recommandé)

#### Étape 1 : Accéder à Firestore

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet
3. Cliquez sur **Firestore Database** dans le menu de gauche
4. Cliquez sur l'onglet **Data** (si ce n'est pas déjà fait)

#### Étape 2 : Trouver votre document utilisateur

1. Dans la liste des collections, cliquez sur **`users`**
2. Vous verrez une liste de tous les utilisateurs
3. Trouvez votre document utilisateur :
   - **Option A** : Cherchez par votre **email** (le document peut avoir votre email comme ID ou dans un champ)
   - **Option B** : Cherchez par votre **UID Firebase** (l'ID unique de votre compte Firebase Auth)
     - Pour trouver votre UID : Dans l'application, regardez les logs ou utilisez Firebase Auth dans la console

#### Étape 3 : Ajouter ou modifier le champ `role`

**Si le champ `role` n'existe PAS :**

1. Cliquez sur votre document utilisateur pour l'ouvrir
2. Cliquez sur **"Add field"** (Ajouter un champ) ou sur le bouton **"+"**
3. Dans le champ **Field**, tapez : `role`
4. Dans le champ **Type**, sélectionnez : **string**
5. Dans le champ **Value**, tapez : `admin`
6. Cliquez sur **"Update"** ou **"Save"**

**Si le champ `role` existe déjà :**

1. Cliquez sur votre document utilisateur pour l'ouvrir
2. Trouvez le champ **`role`** dans la liste
3. Cliquez sur la valeur actuelle (probablement `"user"`)
4. Modifiez la valeur en : `admin`
5. Cliquez sur **"Update"** ou **"Save"**

#### Étape 4 : Vérifier

Votre document devrait maintenant avoir :
```
role: "admin"
```

#### Étape 5 : Redémarrer l'application

1. Fermez complètement l'application
2. Relancez-la
3. Connectez-vous avec votre compte
4. L'onglet **"Admin"** devrait maintenant apparaître !

---

### Méthode 2 : Ajouter le champ via l'application (si vous avez déjà un admin)

Si vous avez déjà un compte admin, vous pouvez créer une fonction pour ajouter le champ `role` aux utilisateurs existants.

### Méthode 3 : Via le code (pour les développeurs)

Vous pouvez modifier directement dans Firestore ou créer un script pour changer le rôle.

---

## 📋 Résumé des fonctionnalités

| Fonctionnalité | Description | Où ? |
|----------------|-------------|------|
| **Ajouter un film** | Ajouter manuellement un film à la base | Onglet "Ajouter un film" |
| **Voir tous les utilisateurs** | Liste complète des utilisateurs | Onglet "Gérer les utilisateurs" |
| **Désactiver un utilisateur** | Empêcher un utilisateur de se connecter | Onglet "Gérer les utilisateurs" |
| **Activer un utilisateur** | Réactiver un utilisateur désactivé | Onglet "Gérer les utilisateurs" |

---

## ⚠️ Notes importantes

1. **Sécurité** : L'interface admin n'est visible que pour les utilisateurs avec le rôle `admin`
2. **Permissions** : Assurez-vous que les règles de sécurité Firestore autorisent les admins à :
   - Ajouter des films (`movies` collection)
   - Lire tous les utilisateurs (`users` collection)
   - Modifier le statut des utilisateurs (`isActive` field)
3. **Validation** : Le titre du film est obligatoire, les autres champs sont optionnels
4. **Images** : Utilisez des URLs valides pour les images, sinon un placeholder sera utilisé

---

## 🎨 Exemple d'utilisation

### Scénario 1 : Ajouter un nouveau film

1. Ouvrez l'onglet Admin
2. Cliquez sur "Ajouter un film"
3. Remplissez :
   - Titre : "The Matrix"
   - Description : "Un programmeur découvre la réalité..."
   - URL de l'image : "https://example.com/matrix.jpg"
   - Note : "9.0"
   - Année : "1999"
   - Genre : "Science-Fiction, Action"
   - Réalisateur : "Lana et Lilly Wachowski"
4. Cliquez sur "Ajouter"
5. ✅ Le film apparaît maintenant dans la liste des films !

### Scénario 2 : Désactiver un utilisateur

1. Ouvrez l'onglet "Gérer les utilisateurs"
2. Trouvez l'utilisateur à désactiver
3. Cliquez sur le bouton rouge (🚫) à droite
4. ✅ L'utilisateur est maintenant désactivé et ne peut plus se connecter

---

## 🔧 Dépannage

### Problème : Je ne vois pas l'onglet Admin

**Solution :**
- Vérifiez que votre compte a le rôle `admin` dans Firestore
- Déconnectez-vous et reconnectez-vous
- Redémarrez l'application

### Problème : Je ne peux pas ajouter de film

**Solution :**
- Vérifiez que le titre est rempli (obligatoire)
- Vérifiez votre connexion Internet
- Vérifiez les règles de sécurité Firestore

### Problème : Je ne vois pas les utilisateurs

**Solution :**
- Vérifiez que Firestore est activé dans Firebase
- Vérifiez que des utilisateurs existent dans la collection `users`
- Vérifiez les règles de sécurité Firestore

---

## 📚 Code technique

L'interface admin est implémentée dans :
- **Fichier** : `lib/screens/admin_screen.dart`
- **Service** : `lib/services/firestore_service.dart` (méthodes admin)

Les méthodes utilisées :
- `addMovie()` : Ajouter un film
- `getAllUsers()` : Récupérer tous les utilisateurs
- `disableUser()` : Désactiver un utilisateur
- `enableUser()` : Activer un utilisateur

---

**Bon usage de l'interface admin ! 🎬👥**

