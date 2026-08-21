/// Écran de matching (correspondance) entre utilisateurs
/// 
/// Fonctionnalités :
/// - Affiche les utilisateurs avec des goûts similaires (>75% de correspondance)
/// - Calcule le taux de correspondance basé sur les films favoris communs
/// - Affiche le nombre de films en commun
/// 
/// Algorithme de matching :
/// - Utilise la similarité de Jaccard pour calculer le taux de correspondance
/// - Formule : (intersection des favoris) / (union des favoris) * 100
/// - Filtre les utilisateurs avec >75% de correspondance
/// - Trie par taux décroissant
/// 
/// Affichage :
/// - Liste des utilisateurs correspondants
/// - Photo de profil (ou initiale)
/// - Nom, email, âge
/// - Taux de correspondance en pourcentage
/// - Nombre de films en commun

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

class MatchingScreen extends StatefulWidget {
  /// ID de l'utilisateur actuel (pour calculer le matching)
  final String userId;
  
  /// Service Firestore pour récupérer les utilisateurs et calculer le matching
  final FirestoreService firestoreService;

  const MatchingScreen({
    super.key,
    required this.userId,
    required this.firestoreService,
  });

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userId.isNotEmpty) {
      _loadMatches();
    }
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔄 Chargement des correspondances pour: ${widget.userId}');
      final matches = await widget.firestoreService.findMatchingUsers(widget.userId);
      debugPrint('✅ ${matches.length} correspondances trouvées');
      
      if (mounted) {
        setState(() {
          _matches = matches;
          _isLoading = false;
        });
        
        if (matches.isEmpty) {
          debugPrint('⚠️ Aucune correspondance trouvée. Vérifiez que:');
          debugPrint('   1. Vous avez ajouté des films aux favoris');
          debugPrint('   2. D\'autres utilisateurs ont des favoris');
          debugPrint('   3. Il y a au moins 75% de correspondance');
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des correspondances: $e');
      debugPrint('❌ Type d\'erreur: ${e.runtimeType}');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('permission') || errorString.contains('denied')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur de permission. Vérifiez les règles Firestore.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              action: SnackBarAction(
                label: 'Réessayer',
                onPressed: _loadMatches,
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.userId.isEmpty) {
      return const Center(
        child: Text('Vous devez être connecté pour voir les correspondances'),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune correspondance trouvée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des films à vos favoris pour trouver des utilisateurs avec des goûts similaires !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadMatches,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Utilisateurs avec 75% ou plus de correspondance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadMatches,
                tooltip: 'Actualiser',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _matches.length,
            itemBuilder: (context, index) {
              final match = _matches[index];
              final user = match['user'] as AppUser;
              final matchRate = match['matchRate'] as double;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: user.photoUrl != null
                                ? NetworkImage(user.photoUrl!)
                                : null,
                            child: user.photoUrl == null
                                ? Text(
                                    user.firstName.isNotEmpty
                                        ? user.firstName[0].toUpperCase()
                                        : user.email.isNotEmpty
                                            ? user.email[0].toUpperCase()
                                            : 'U',
                                    style: const TextStyle(fontSize: 24),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${user.firstName} ${user.lastName}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.age > 0 
                                      ? '${user.age} ans' 
                                      : 'Âge non spécifié',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getMatchColor(matchRate),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${matchRate.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<String>>(
                        future: _getCommonMovies(widget.userId, user.id),
                        builder: (context, snapshot) {
                          final commonCount = snapshot.data?.length ?? 0;
                          return Row(
                            children: [
                              Icon(
                                Icons.movie,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$commonCount film${commonCount > 1 ? 's' : ''} en commun',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getMatchColor(double matchRate) {
    if (matchRate >= 90) return Colors.green;
    if (matchRate >= 80) return Colors.lightGreen;
    return Colors.orange;
  }

  Future<List<String>> _getCommonMovies(String userId1, String userId2) async {
    try {
      final user1 = await widget.firestoreService.getUserById(userId1);
      final user2 = await widget.firestoreService.getUserById(userId2);
      
      if (user1 == null || user2 == null) return [];
      
      final set1 = user1.favoriteMovies.toSet();
      final set2 = user2.favoriteMovies.toSet();
      return set1.intersection(set2).toList();
    } catch (e) {
      return [];
    }
  }
}

