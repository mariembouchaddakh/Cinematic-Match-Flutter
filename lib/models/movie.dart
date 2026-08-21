/// Modèle de données représentant un film dans l'application
/// 
/// Cette classe encapsule toutes les informations d'un film :
/// - Identifiant unique
/// - Informations de base (titre, description)
/// - Métadonnées (note, année, genre, réalisateur)
/// - URL de l'affiche
/// 
/// Utilisée pour :
/// - Stocker les films depuis Firestore
/// - Parser les données de l'API TMDb
/// - Afficher les films dans l'interface

/// Classe Movie : Modèle de données pour un film
/// 
/// Cette classe est immuable (tous les champs sont final) pour garantir
/// l'intégrité des données. Pour modifier un film, créer une nouvelle instance.
class Movie {
  /// Identifiant unique du film (peut être un ID TMDb ou un ID Firestore)
  /// 
  /// Cet ID peut provenir de différentes sources :
  /// - ID TMDb : Si le film vient de l'API The Movie Database
  /// - ID Firestore : Si le film a été ajouté manuellement par un admin
  /// - Timestamp : Si le film a été créé dans l'application
  /// 
  /// Type : String (non nullable, toujours présent)
  final String id;
  
  /// Titre du film
  /// 
  /// Titre complet du film tel qu'affiché dans l'interface.
  /// Utilisé pour la recherche et l'affichage.
  /// 
  /// Type : String (non nullable, toujours présent)
  final String title;
  
  /// Description/résumé du film
  /// 
  /// Synopsis ou résumé du film.
  /// Utilisé pour l'affichage dans la liste et la page de détails.
  /// 
  /// Type : String (non nullable, peut être vide "")
  final String description;
  
  /// URL de l'affiche du film
  /// 
  /// URL complète de l'image de l'affiche du film.
  /// Peut provenir de TMDb, d'une URL externe, ou d'un placeholder.
  /// 
  /// Type : String (non nullable, toujours présent)
  final String imageUrl;
  
  /// Note du film sur 10 (peut être 0 si non spécifiée)
  /// 
  /// Note moyenne du film, généralement sur une échelle de 0 à 10.
  /// Utilisée pour l'affichage et le tri des films.
  /// 
  /// Type : double (non nullable, 0.0 par défaut)
  final double rating;
  
  /// Année de sortie du film
  /// 
  /// Année de sortie du film en salle.
  /// Utilisée pour l'affichage et le filtrage.
  /// 
  /// Type : int (non nullable, 0 par défaut)
  final int year;
  
  /// Genre(s) du film (ex: "Action, Thriller")
  /// 
  /// Liste des genres séparés par des virgules.
  /// Peut contenir un ou plusieurs genres.
  /// 
  /// Type : String (non nullable, peut être vide "")
  final String genre;
  
  /// Nom du réalisateur
  /// 
  /// Nom du réalisateur principal du film.
  /// Utilisé pour l'affichage dans la page de détails.
  /// 
  /// Type : String (non nullable, peut être "Non spécifié")
  final String director;

  /// Constructeur du modèle Movie
  /// 
  /// Crée une nouvelle instance Movie avec tous les paramètres requis.
  /// 
  /// Tous les paramètres sont requis (required) pour garantir l'intégrité des données.
  /// Aucun paramètre n'a de valeur par défaut pour éviter les films incomplets.
  /// 
  /// Paramètres :
  /// - [id] : Identifiant unique (requis, non nullable)
  /// - [title] : Titre du film (requis, non nullable)
  /// - [description] : Description (requis, non nullable)
  /// - [imageUrl] : URL de l'affiche (requis, non nullable)
  /// - [rating] : Note sur 10 (requis, non nullable)
  /// - [year] : Année de sortie (requis, non nullable)
  /// - [genre] : Genre(s) (requis, non nullable)
  /// - [director] : Réalisateur (requis, non nullable)
  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.year,
    required this.genre,
    required this.director,
  });

  /// Factory constructor : Crée une instance Movie à partir d'un JSON (Firestore ou API)
  /// 
  /// Cette méthode désérialise les données JSON en créant une instance Movie.
  /// Elle est utilisée pour :
  /// - Désérialiser les données depuis Firestore (getMoviesFromFirestore)
  /// - Parser les réponses de l'API TMDb (_parseMovieFromTMDB)
  /// 
  /// Utilise des valeurs par défaut si certains champs sont absents
  /// pour éviter les erreurs de parsing et garantir qu'une instance Movie
  /// est toujours créée, même avec des données incomplètes.
  /// 
  /// Paramètres :
  /// - [json] : Map<String, dynamic> contenant les données JSON
  /// 
  /// Retourne : Une instance Movie avec des valeurs par défaut si des champs sont absents
  /// 
  /// Valeurs par défaut :
  /// - id : '' (chaîne vide)
  /// - title : '' (chaîne vide)
  /// - description : '' (chaîne vide)
  /// - imageUrl : '' (chaîne vide)
  /// - rating : 0.0 (zéro)
  /// - year : 0 (zéro)
  /// - genre : '' (chaîne vide)
  /// - director : '' (chaîne vide)
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      year: json['year'] ?? 0,
      genre: json['genre'] ?? '',
      director: json['director'] ?? '',
    );
  }

  /// Méthode toJson : Convertit une instance Movie en JSON pour Firestore
  /// 
  /// Cette méthode sérialise l'instance Movie en Map<String, dynamic>
  /// pour pouvoir l'enregistrer dans Firestore ou l'envoyer à une API.
  /// 
  /// Utilisée pour :
  /// - Sauvegarder un film dans Firestore (addMovie)
  /// - Envoyer des données à l'API (si nécessaire)
  /// 
  /// Retourne : Un Map<String, dynamic> avec tous les champs du film
  /// 
  /// Note : Tous les champs sont inclus, y compris l'ID (contrairement à AppUser.toJson)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'rating': rating,
      'year': year,
      'genre': genre,
      'director': director,
    };
  }
}
