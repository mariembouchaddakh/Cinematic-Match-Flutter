/// Service de gestion des films
/// 
/// Ce service gère la récupération des films depuis plusieurs sources :
/// 1. Firestore : Films ajoutés manuellement par les administrateurs (priorité)
/// 2. API TMDb : Films populaires récupérés depuis l'API externe
/// 3. Films de démonstration : Fallback si aucune autre source n'est disponible
/// 
/// Fonctionnalités :
/// - Combinaison intelligente des sources (évite les doublons)
/// - Recherche de films par titre
/// - Récupération d'un film par ID
/// - Parsing des données API TMDb
/// 
/// Architecture :
/// - Priorité aux films Firestore (ajoutés par admin)
/// - Complément avec les films API TMDb
/// - Fallback sur films de démonstration en cas d'erreur

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../utils/constants.dart';
import 'firestore_service.dart';

class MovieService {
  /// Service Firestore pour récupérer les films depuis la base de données
  final FirestoreService _firestoreService = FirestoreService();

  /// Récupère tous les films disponibles
  /// 
  /// Processus :
  /// 1. Récupère les films depuis Firestore (ajoutés par admin)
  /// 2. Récupère les films depuis l'API TMDb (si configurée)
  /// 3. Combine les deux listes en évitant les doublons (par ID)
  /// 4. Priorité aux films Firestore en cas de doublon
  /// 5. Retourne les films de démonstration si aucune source n'est disponible
  /// 
  /// Retourne : Liste de tous les films disponibles
  Future<List<Movie>> getMovies() async {
    try {
      print('🎬 Début du chargement des films...');
      
      final firestoreMovies = await _firestoreService.getMoviesFromFirestore();
      print('📚 ${firestoreMovies.length} films depuis Firestore');
      
      final apiMovies = await _getMoviesFromAPI();
      print('🌐 ${apiMovies.length} films depuis l\'API');
      
      final allMovies = <String, Movie>{};
      
      for (final movie in firestoreMovies) {
        allMovies[movie.id] = movie;
      }
      
      for (final movie in apiMovies) {
        if (!allMovies.containsKey(movie.id)) {
          allMovies[movie.id] = movie;
        }
      }
      
      final totalMovies = allMovies.values.toList();
      print('✅ Total: ${totalMovies.length} films chargés');
      
      if (totalMovies.isEmpty) {
        print('⚠️ Aucun film trouvé, utilisation des films de démonstration');
        return _getDemoMovies();
      }
      
      return totalMovies;
    } catch (e) {
      print('❌ Erreur lors de la récupération des films: $e');
      return _getDemoMovies();
    }
  }

  Future<List<Movie>> _getMoviesFromAPI() async {
    if (AppConstants.tmdbApiKey != 'YOUR_TMDB_API_KEY' && 
        AppConstants.tmdbApiKey.isNotEmpty) {
      print('🔑 Clé API TMDb détectée, tentative de récupération...');
      return await _getMoviesFromTMDB();
    }
    
    if (AppConstants.rapidApiKey != 'YOUR_RAPIDAPI_KEY' && 
        AppConstants.rapidApiKey.isNotEmpty) {
      print('🔑 Clé API RapidAPI détectée, tentative de récupération...');
      return await _getMoviesFromRapidAPI();
    }
    
    print('⚠️ Aucune clé API configurée.');
    print('⚠️ Clé TMDb actuelle: ${AppConstants.tmdbApiKey.substring(0, AppConstants.tmdbApiKey.length > 20 ? 20 : AppConstants.tmdbApiKey.length)}...');
    print('⚠️ Pour obtenir une clé API gratuite: https://www.themoviedb.org/settings/api');
    print('⚠️ Utilisation des films de démonstration.');
    return [];
  }

  Future<List<Movie>> _getMoviesFromTMDB() async {
    try {
      final List<Movie> allMovies = [];
      
      const int maxPages = 5;
      print('📡 Récupération de $maxPages pages de films depuis TMDb...');
      
      for (int page = 1; page <= maxPages; page++) {
        try {
          final url = Uri.parse('${AppConstants.tmdbBaseUrl}/movie/popular?api_key=${AppConstants.tmdbApiKey}&language=fr-FR&page=$page');
          print('📡 Page $page/$maxPages...');
          
          final response = await http.get(url);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final results = data['results'] as List?;
            
            if (results != null && results.isNotEmpty) {
              final movies = results
                  .map((json) => _parseMovieFromTMDB(json))
                  .where((movie) => movie != null)
                  .cast<Movie>()
                  .toList();
              
              allMovies.addAll(movies);
              print('✅ Page $page: ${movies.length} films ajoutés (Total: ${allMovies.length})');
            } else {
              print('⚠️ Page $page: Aucun résultat');
              break;
            }
          } else {
            print('❌ Erreur TMDb page $page - Status: ${response.statusCode}');
            print('❌ Réponse: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
            if (response.statusCode == 401) {
              print('❌ Clé API invalide ou expirée');
              print('❌ Vérifiez votre clé API dans lib/utils/constants.dart');
              print('❌ Obtenez une clé gratuite: https://www.themoviedb.org/settings/api');
              break;
            } else if (response.statusCode == 404) {
              print('❌ Endpoint non trouvé. Vérifiez l\'URL de l\'API.');
              break;
            }
          }
          
          if (page < maxPages) {
            await Future.delayed(const Duration(milliseconds: 200));
          }
        } catch (e) {
          print('❌ Erreur lors de la récupération de la page $page: $e');
        }
      }
      
      print('✅ Total: ${allMovies.length} films récupérés depuis TMDb');
      return allMovies;
    } catch (e) {
      print('❌ Erreur lors de l\'appel TMDb: $e');
    }
    
    return [];
  }

  Future<List<Movie>> _getMoviesFromRapidAPI() async {
    try {
      final url = Uri.parse('${AppConstants.rapidApiBaseUrl}/titles/random?list=most_pop_movies&limit=20');
      print('📡 Appel API RapidAPI: $url');
      
      final response = await http.get(
        url,
        headers: {
          'X-RapidAPI-Key': AppConstants.rapidApiKey,
          'X-RapidAPI-Host': AppConstants.rapidApiHost,
        },
      );

      print('📡 Réponse RapidAPI - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;
        
        if (results != null && results.isNotEmpty) {
          print('✅ ${results.length} films trouvés dans RapidAPI');
          final movies = results
              .map((json) => _parseMovieFromAPI(json))
              .where((movie) => movie != null)
              .cast<Movie>()
              .toList();
          print('✅ ${movies.length} films parsés avec succès');
          return movies;
        }
      } else {
        print('❌ Erreur RapidAPI - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'appel RapidAPI: $e');
    }
    
    return [];
  }

  Movie? _parseMovieFromTMDB(Map<String, dynamic> json) {
    try {
      final id = json['id']?.toString() ?? '';
      final title = json['title']?.toString() ?? 'Titre inconnu';
      final overview = json['overview']?.toString() ?? 'Description non disponible';
      final posterPath = json['poster_path']?.toString();
      final imageUrl = posterPath != null && posterPath.isNotEmpty
          ? '${AppConstants.tmdbImageBaseUrl}$posterPath'
          : 'https://via.placeholder.com/500x750?text=No+Image';
      final rating = (json['vote_average'] as num?)?.toDouble() ?? 0.0;
      final year = json['release_date']?.toString().split('-').first ?? '0';
      final yearInt = int.tryParse(year) ?? 0;
      
      final genreIds = json['genre_ids'] as List?;
      String genre = 'Non spécifié';
      if (genreIds != null && genreIds.isNotEmpty) {
        final genreMap = {
          28: 'Action', 12: 'Aventure', 16: 'Animation', 35: 'Comédie',
          80: 'Crime', 99: 'Documentaire', 18: 'Drame', 10751: 'Famille',
          14: 'Fantastique', 36: 'Histoire', 27: 'Horreur', 10402: 'Musique',
          9648: 'Mystère', 10749: 'Romance', 878: 'Science-Fiction',
          10770: 'Téléfilm', 53: 'Thriller', 10752: 'Guerre', 37: 'Western'
        };
        final genres = genreIds
            .map((id) => genreMap[id as int] ?? '')
            .where((g) => g.isNotEmpty)
            .toList();
        if (genres.isNotEmpty) {
          genre = genres.join(', ');
        }
      }
      
      return Movie(
        id: id,
        title: title,
        description: overview,
        imageUrl: imageUrl,
        rating: rating,
        year: yearInt,
        genre: genre,
        director: 'Non spécifié',
      );
    } catch (e) {
      print('Erreur lors du parsing du film TMDb: $e');
      return null;
    }
  }

  Movie? _parseMovieFromAPI(Map<String, dynamic> json) {
    try {
      final titleText = json['titleText'] as Map<String, dynamic>?;
      final primaryImage = json['primaryImage'] as Map<String, dynamic>?;
      final releaseYear = json['releaseYear'] as Map<String, dynamic>?;
      
      final id = json['id']?.toString() ?? '';
      final title = titleText?['text']?.toString() ?? 'Titre inconnu';
      final imageUrl = primaryImage?['url']?.toString() ?? '';
      final year = releaseYear?['year'] as int? ?? 0;
      
      return Movie(
        id: id,
        title: title,
        description: json['plot']?['plotText']?['plainText']?.toString() ?? 
                    'Description non disponible',
        imageUrl: imageUrl.isNotEmpty ? imageUrl : 
                 'https://via.placeholder.com/500x750?text=No+Image',
        rating: (json['ratingsSummary']?['aggregateRating'] as num?)?.toDouble() ?? 0.0,
        year: year,
        genre: _extractGenres(json),
        director: _extractDirector(json),
      );
    } catch (e) {
      print('Erreur lors du parsing du film: $e');
      return null;
    }
  }

  String _extractGenres(Map<String, dynamic> json) {
    try {
      final genres = json['genres'] as Map<String, dynamic>?;
      final genreList = genres?['genres'] as List?;
      if (genreList != null && genreList.isNotEmpty) {
        return genreList
            .map((g) => g['text']?.toString() ?? '')
            .where((g) => g.isNotEmpty)
            .join(', ');
      }
    } catch (e) {
      print('Erreur lors de l\'extraction des genres: $e');
    }
    return 'Non spécifié';
  }

  String _extractDirector(Map<String, dynamic> json) {
    try {
      final directors = json['directors'] as List?;
      if (directors != null && directors.isNotEmpty) {
        final director = directors.first as Map<String, dynamic>?;
        final credits = director?['credits'] as List?;
        if (credits != null && credits.isNotEmpty) {
          final person = credits.first as Map<String, dynamic>?;
          final name = person?['name']?['nameText']?['text']?.toString();
          if (name != null) return name;
        }
      }
    } catch (e) {
      print('Erreur lors de l\'extraction du réalisateur: $e');
    }
    return 'Non spécifié';
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) {
      return getMovies();
    }

    try {
      final allMovies = await getMovies();
      return allMovies
          .where((movie) =>
              movie.title.toLowerCase().contains(query.toLowerCase()) ||
              movie.description.toLowerCase().contains(query.toLowerCase()) ||
              movie.genre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }

  Future<Movie?> getMovieById(String id) async {
    try {
      final movie = await _firestoreService.getMovieByIdFromFirestore(id);
      if (movie != null) return movie;
      
      final allMovies = await getMovies();
      try {
        return allMovies.firstWhere((movie) => movie.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du film: $e');
      return null;
    }
  }

  List<Movie> _getDemoMovies() {
    return [
    Movie(
      id: '1',
      title: 'Inception',
      description: 'Un voleur expérimenté dans l\'art de l\'extraction, Dom Cobb, se voit proposer une dernière mission qui pourrait lui permettre de retrouver sa vie d\'avant. Mais cette fois, il ne s\'agit pas d\'un vol, mais d\'une implantation : il doit faire l\'inverse.',
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=500',
      rating: 8.8,
      year: 2010,
      genre: 'Science-Fiction, Action',
      director: 'Christopher Nolan',
    ),
    Movie(
      id: '2',
      title: 'The Dark Knight',
      description: 'Batman accepte l\'un de ses plus grands défis psychologiques et moraux de sa capacité à lutter contre l\'injustice. Avec l\'aide du lieutenant Jim Gordon et du procureur Harvey Dent, Batman entreprend de démanteler les dernières organisations criminelles qui infestent les rues de Gotham.',
      imageUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=500',
      rating: 9.0,
      year: 2008,
      genre: 'Action, Thriller',
      director: 'Christopher Nolan',
    ),
    Movie(
      id: '3',
      title: 'Pulp Fiction',
      description: 'L\'odyssée sanglante et burlesque de petits malfrats dans la jungle de Hollywood à travers trois histoires qui s\'entremêlent.',
      imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=500',
      rating: 8.9,
      year: 1994,
      genre: 'Crime, Drame',
      director: 'Quentin Tarantino',
    ),
    ];
  }
}
