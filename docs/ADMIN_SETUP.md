# Configuration d'un compte administrateur

Pour créer un compte administrateur dans l'application, suivez ces étapes :

## Méthode 1 : Via la console Firebase

1. Connectez-vous à votre compte dans l'application
2. Ouvrez la [Console Firebase](https://console.firebase.google.com/)
3. Sélectionnez votre projet
4. Allez dans **Firestore Database**
5. Trouvez la collection `users`
6. Localisez votre document utilisateur (recherchez par email)
7. Cliquez sur le document pour l'éditer
8. Modifiez le champ `role` :
   - Changez la valeur de `user` à `admin`
9. Sauvegardez les modifications

## Méthode 2 : Via le code (pour les développeurs)

Si vous avez accès au code, vous pouvez créer un script temporaire dans `main.dart` :

```dart
// Code temporaire à ajouter dans main() après l'initialisation Firebase
final firestore = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

// Connectez-vous d'abord avec votre compte
await auth.signInWithEmailAndPassword(
  email: 'votre-email@example.com',
  password: 'votre-mot-de-passe',
);

// Puis modifiez le rôle
await firestore.collection('users').doc(auth.currentUser!.uid).update({
  'role': 'admin',
});
```

**Important** : Supprimez ce code après utilisation pour des raisons de sécurité.

## Vérification

Après avoir modifié le rôle :
1. Déconnectez-vous de l'application
2. Reconnectez-vous
3. L'onglet "Admin" devrait maintenant apparaître dans l'interface

## Permissions administrateur

Les administrateurs peuvent :
- ✅ Ajouter des films à la base de données
- ✅ Désactiver des utilisateurs (sans les supprimer)
- ✅ Activer des utilisateurs précédemment désactivés
- ✅ Voir tous les utilisateurs de l'application

## Sécurité

- Ne partagez jamais les identifiants d'un compte administrateur
- Utilisez des mots de passe forts pour les comptes admin
- Limitez le nombre de comptes administrateurs

