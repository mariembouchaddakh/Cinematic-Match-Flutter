/// Service de gestion des données Firestore et Firebase Storage
/// 
/// Ce service centralise toutes les opérations de base de données :
/// - Gestion des utilisateurs (CRUD)
/// - Gestion des films (CRUD)
/// - Gestion des favoris (ajout/retrait)
/// - Calcul du matching entre utilisateurs
/// - Upload de photos de profil
/// 
/// Architecture :
/// - Utilise Firestore pour les données structurées
/// - Utilise Firebase Storage pour les fichiers (photos)
/// - Implémente la logique de retry pour les opérations critiques
/// - Complète automatiquement les champs manquants des utilisateurs
/// 
/// Collections Firestore :
/// - users : Documents utilisateurs (ID = UID Firebase Auth)
/// - movies : Documents films (ID = ID du film)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/movie.dart';

class FirestoreService {
  /// Instance Firestore pour accéder à la base de données
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Instance Firebase Storage pour gérer les fichiers (photos)
  final FirebaseStorage _storage = FirebaseStorage.instance;

  
  /// Nom de la collection Firestore pour les utilisateurs
  static const String usersCollection = 'users';
  
  /// Nom de la collection Firestore pour les films
  static const String moviesCollection = 'movies';


  /// Crée ou met à jour un utilisateur dans Firestore
  /// 
  /// Utilise SetOptions(merge: true) pour :
  /// - Créer le document s'il n'existe pas
  /// - Mettre à jour seulement les champs fournis s'il existe déjà
  /// 
  /// Paramètres :
  /// - [user] : Instance AppUser à sauvegarder
  /// 
  /// Utilisé lors de :
  /// - L'inscription (création du profil)
  /// - La mise à jour du profil utilisateur
  /// - La complétion automatique des champs manquants
  Future<void> createOrUpdateUser(AppUser user) async {
    await _firestore
        .collection(usersCollection)
        .doc(user.id)
        .set(user.toJson(), SetOptions(merge: true));
  }

  Future<AppUser?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final appUser = AppUser.fromJson(data, doc.id);
        
        await _ensureUserFieldsComplete(userId, appUser, data);
        
        return appUser;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  Future<void> _ensureUserFieldsComplete(String userId, AppUser appUser, Map<String, dynamic> data) async {
    try {
      final authUser = FirebaseAuth.instance.currentUser;
      bool needsUpdate = false;
      final updates = <String, dynamic>{};

      if (appUser.email.isEmpty && authUser?.email != null) {
        updates['email'] = authUser!.email!;
        needsUpdate = true;
        debugPrint('✅ Email complété automatiquement: ${authUser.email}');
      }

      if (appUser.firstName.isEmpty) {
        String firstName = 'Utilisateur';
        if (authUser?.displayName != null && authUser!.displayName!.isNotEmpty) {
          final parts = authUser.displayName!.split(' ');
          firstName = parts[0];
        } else if (authUser?.email != null) {
          final emailParts = authUser!.email!.split('@');
          firstName = emailParts[0].split('.')[0];
          firstName = firstName[0].toUpperCase() + firstName.substring(1);
        }
        updates['firstName'] = firstName;
        needsUpdate = true;
        debugPrint('✅ firstName complété automatiquement: $firstName');
      }

      if (appUser.lastName.isEmpty && authUser?.displayName != null) {
        final parts = authUser!.displayName!.split(' ');
        if (parts.length > 1) {
          updates['lastName'] = parts.sublist(1).join(' ');
          needsUpdate = true;
          debugPrint('✅ lastName complété automatiquement: ${updates['lastName']}');
        }
      }

      if (!data.containsKey('age')) {
        debugPrint('⚠️ Champ age manquant, mais non complété automatiquement (doit être rempli manuellement)');
      }

      if (appUser.role.isEmpty || !data.containsKey('role')) {
        updates['role'] = 'user';
        needsUpdate = true;
        debugPrint('✅ role complété automatiquement: user');
      }

      if (!data.containsKey('isActive')) {
        updates['isActive'] = true;
        needsUpdate = true;
        debugPrint('✅ isActive complété automatiquement: true');
      }

      if (needsUpdate) {
        await _firestore
            .collection(usersCollection)
            .doc(userId)
            .update(updates);
        debugPrint('✅ Document utilisateur complété automatiquement avec ${updates.length} champs');
      }
    } catch (e) {
      debugPrint('⚠️ Erreur lors de la complétion automatique des champs: $e');
    }
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final appUser = await getUserById(user.uid);
        
        if (appUser == null) {
          debugPrint('📝 Création d\'un profil minimal pour: ${user.uid}');
          final newUser = AppUser(
            id: user.uid,
            email: user.email ?? '',
            firstName: user.displayName?.split(' ').first ?? 
                       (user.email?.split('@').first.split('.').first ?? 'Utilisateur'),
            lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
            age: 0,
            role: 'user',
            isActive: true,
          );
          await createOrUpdateUser(newUser);
          return newUser;
        }
        
        return appUser;
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur actuel: $e');
      return null;
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    try {
      final appUser = await getCurrentUser();
      return appUser?.isAdmin ?? false;
    } catch (e) {
      print('Erreur lors de la vérification du statut admin: $e');
      return false;
    }
  }

  Future<void> disableUser(String userId) async {
    await _firestore
        .collection(usersCollection)
        .doc(userId)
        .update({'isActive': false});
  }

  Future<void> enableUser(String userId) async {
    await _firestore
        .collection(usersCollection)
        .doc(userId)
        .update({'isActive': true});
  }

  Future<List<AppUser>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(usersCollection).get();
      return snapshot.docs
          .where((doc) => doc.exists && doc.data().isNotEmpty)
          .map((doc) {
            try {
              return AppUser.fromJson(doc.data(), doc.id);
            } catch (e) {
              print('Erreur lors de la conversion de l\'utilisateur ${doc.id}: $e');
              return null;
            }
          })
          .whereType<AppUser>()
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs: $e');
      return [];
    }
  }

  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_photos/$userId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Erreur lors de l\'upload de la photo: $e');
      return null;
    }
  }


  Future<void> addFavoriteMovie(String userId, String movieId) async {
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 1);
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final userRef = _firestore.collection(usersCollection).doc(userId);
        
        final doc = await userRef.get();
        
        if (doc.exists) {
          await userRef.update({
            'favoriteMovies': FieldValue.arrayUnion([movieId]),
          });
        } else {
          await userRef.set({
            'favoriteMovies': [movieId],
          }, SetOptions(merge: true));
        }
        
        print('✅ Film $movieId ajouté aux favoris pour l\'utilisateur $userId');
        return;
      } catch (e) {
        final errorString = e.toString().toLowerCase();
        final isPermissionDenied = errorString.contains('permission_denied') || 
                                   errorString.contains('api has not been used') ||
                                   errorString.contains('is disabled');
        
        if (isPermissionDenied) {
          print('❌ ERREUR CRITIQUE: Firestore n\'est pas activé dans votre projet Firebase!');
          print('📋 Solution: Activez Firestore dans Firebase Console');
          print('🔗 Lien: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=project-73978');
          rethrow;
        }
        
        final isUnavailable = errorString.contains('unavailable') || 
                              errorString.contains('transient');
        
        if (isUnavailable && attempt < maxRetries - 1) {
          final delay = Duration(milliseconds: baseDelay.inMilliseconds * (1 << attempt));
          print('⚠️ Service indisponible, nouvelle tentative dans ${delay.inSeconds}s... (${attempt + 1}/$maxRetries)');
          await Future.delayed(delay);
          continue;
        } else {
          print('❌ Erreur lors de l\'ajout du film aux favoris: $e');
          rethrow;
        }
      }
    }
  }

  Future<void> removeFavoriteMovie(String userId, String movieId) async {
    const maxRetries = 3;
    const baseDelay = Duration(seconds: 1);
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final userRef = _firestore.collection(usersCollection).doc(userId);
        
        final doc = await userRef.get();
        
        if (doc.exists) {
          await userRef.update({
            'favoriteMovies': FieldValue.arrayRemove([movieId]),
          });
          print('✅ Film $movieId retiré des favoris pour l\'utilisateur $userId');
          return;
        } else {
          print('⚠️ Document utilisateur n\'existe pas, rien à retirer');
          return;
        }
      } catch (e) {
        final errorString = e.toString().toLowerCase();
        final isPermissionDenied = errorString.contains('permission_denied') || 
                                   errorString.contains('api has not been used') ||
                                   errorString.contains('is disabled');
        
        if (isPermissionDenied) {
          print('❌ ERREUR CRITIQUE: Firestore n\'est pas activé dans votre projet Firebase!');
          print('📋 Solution: Activez Firestore dans Firebase Console');
          print('🔗 Lien: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=project-73978');
          rethrow;
        }
        
        final isUnavailable = errorString.contains('unavailable') || 
                              errorString.contains('transient');
        
        if (isUnavailable && attempt < maxRetries - 1) {
          final delay = Duration(milliseconds: baseDelay.inMilliseconds * (1 << attempt));
          print('⚠️ Service indisponible, nouvelle tentative dans ${delay.inSeconds}s... (${attempt + 1}/$maxRetries)');
          await Future.delayed(delay);
          continue;
        } else {
          print('❌ Erreur lors du retrait du film des favoris: $e');
          rethrow;
        }
      }
    }
  }

  Future<bool> isFavoriteMovie(String userId, String movieId) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final favoriteMovies = data['favoriteMovies'] as List?;
        if (favoriteMovies != null) {
          return favoriteMovies.contains(movieId);
        }
      }
      return false;
    } catch (e) {
      print('Erreur lors de la vérification du favori: $e');
      return false;
    }
  }

  Future<List<String>> getFavoriteMovies(String userId) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final favoriteMovies = data['favoriteMovies'] as List?;
        if (favoriteMovies != null) {
          return favoriteMovies.map((e) => e.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des favoris: $e');
      return [];
    }
  }


  Future<void> addMovie(Movie movie) async {
    await _firestore
        .collection(moviesCollection)
        .doc(movie.id)
        .set(movie.toJson());
  }

  Future<List<Movie>> getMoviesFromFirestore() async {
    try {
      final snapshot = await _firestore.collection(moviesCollection).get();
      return snapshot.docs
          .map((doc) => Movie.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des films: $e');
      return [];
    }
  }

  Future<Movie?> getMovieByIdFromFirestore(String movieId) async {
    try {
      final doc = await _firestore.collection(moviesCollection).doc(movieId).get();
      if (doc.exists) {
        return Movie.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du film: $e');
      return null;
    }
  }


  double calculateMatchRate(AppUser user1, AppUser user2) {
    if (user1.favoriteMovies.isEmpty || user2.favoriteMovies.isEmpty) {
      print('   ⚠️ Un des utilisateurs n\'a pas de favoris');
      return 0.0;
    }

    final set1 = user1.favoriteMovies.toSet();
    final set2 = user2.favoriteMovies.toSet();

    final intersection = set1.intersection(set2).length;
    print('   📊 Films en commun: $intersection');
    
    final union = set1.union(set2).length;
    print('   📊 Total de films uniques: $union');

    if (union == 0) return 0.0;

    final rate = (intersection / union) * 100;
    print('   📊 Calcul: ($intersection / $union) × 100 = ${rate.toStringAsFixed(1)}%');
    return rate;
  }

  Future<List<Map<String, dynamic>>> findMatchingUsers(String userId) async {
    try {
      print('');
      print('═══════════════════════════════════════════════════════');
      print('🔍 DÉBUT DE LA RECHERCHE DE CORRESPONDANCES');
      print('═══════════════════════════════════════════════════════');
      print('📋 UID recherché: $userId');
      
      final currentUser = await getUserById(userId);
      if (currentUser == null) {
        print('❌ ERREUR: Utilisateur actuel non trouvé dans Firestore!');
        print('═══════════════════════════════════════════════════════');
        return [];
      }

      print('');
      print('👤 UTILISATEUR ACTUEL:');
      print('   Nom: ${currentUser.firstName} ${currentUser.lastName}');
      print('   Email: ${currentUser.email}');
      print('   ID: ${currentUser.id}');
      print('   Actif: ${currentUser.isActive}');
      print('   🎬 Favoris: ${currentUser.favoriteMovies.length} films');
      print('   📋 IDs des favoris: ${currentUser.favoriteMovies}');

      if (currentUser.favoriteMovies.isEmpty) {
        print('');
        print('⚠️ ATTENTION: Aucun film favori pour cet utilisateur!');
        print('   Le matching ne peut pas fonctionner sans favoris.');
        print('   Ajoutez des films aux favoris dans l\'onglet Films.');
        print('═══════════════════════════════════════════════════════');
        return [];
      }

      print('');
      print('📥 RÉCUPÉRATION DE TOUS LES UTILISATEURS...');
      final allUsers = await getAllUsers();
      print('👥 Total d\'utilisateurs dans la base: ${allUsers.length}');

      if (allUsers.isEmpty) {
        print('❌ ERREUR: Aucun utilisateur récupéré!');
        print('   Vérifiez les règles Firestore.');
        print('═══════════════════════════════════════════════════════');
        return [];
      }

      print('');
      print('🔄 COMPARAISON AVEC CHAQUE UTILISATEUR...');
      print('───────────────────────────────────────────────────────');

      final matches = <Map<String, dynamic>>[];
      int comparisonCount = 0;

      for (final user in allUsers) {
        if (user.id == userId) {
          print('⏭️ Ignoré: ${user.firstName} ${user.lastName} (utilisateur actuel)');
          continue;
        }
        
        if (!user.isActive) {
          print('⏭️ Ignoré: ${user.firstName} ${user.lastName} (compte désactivé)');
          continue;
        }

        comparisonCount++;
        print('');
        print('🔍 Comparaison #$comparisonCount avec: ${user.firstName} ${user.lastName}');
        print('   Email: ${user.email}');
        print('   Favoris: ${user.favoriteMovies.length} films');
        print('   IDs: ${user.favoriteMovies}');

        if (user.favoriteMovies.isEmpty) {
          print('   ⚠️ Cet utilisateur n\'a pas de favoris, matching impossible');
          continue;
        }

        final matchRate = calculateMatchRate(currentUser, user);
        print('   📊 Taux de correspondance: ${matchRate.toStringAsFixed(1)}%');

        if (matchRate >= 75.0) {
          print('   ✅ MATCH TROUVÉ! (${matchRate.toStringAsFixed(1)}% >= 75%)');
          matches.add({
            'user': user,
            'matchRate': matchRate,
          });
        } else if (matchRate >= 50.0) {
          print('   ⚠️ Correspondance moyenne (${matchRate.toStringAsFixed(1)}% - seuil: >=75%)');
        } else {
          print('   ❌ Correspondance faible (${matchRate.toStringAsFixed(1)}% < 75%)');
        }
      }

      matches.sort((a, b) => (b['matchRate'] as double).compareTo(a['matchRate'] as double));

      print('');
      print('───────────────────────────────────────────────────────');
      print('✨ RÉSULTAT FINAL: ${matches.length} correspondance(s) trouvée(s)');
      if (matches.isNotEmpty) {
        print('');
        print('🎯 Liste des correspondances:');
        for (var i = 0; i < matches.length; i++) {
          final match = matches[i];
          final user = match['user'] as AppUser;
          final rate = match['matchRate'] as double;
          print('   ${i + 1}. ${user.firstName} ${user.lastName} - ${rate.toStringAsFixed(1)}%');
        }
      } else {
        print('');
        print('💡 CONSEILS:');
        print('   • Ajoutez plus de films à vos favoris');
        print('   • Demandez à d\'autres utilisateurs d\'ajouter des favoris');
        print('   • Le seuil est fixé à >=75% de correspondance');
      }
      print('═══════════════════════════════════════════════════════');
      print('');
      return matches;
    } catch (e) {
      print('❌ Erreur lors de la recherche de correspondances: $e');
      return [];
    }
  }
}

