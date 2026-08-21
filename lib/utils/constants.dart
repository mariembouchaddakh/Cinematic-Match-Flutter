/// Fichier de constantes de l'application
/// 
/// Ce fichier centralise toutes les constantes utilisées dans l'application :
/// - Messages d'erreur et de succès
/// - Paramètres de validation
/// - Configuration des APIs externes
/// 
/// Avantages :
/// - Facilite la maintenance (modification en un seul endroit)
/// - Améliore la lisibilité du code
/// - Évite les erreurs de typo
/// - Permet de changer facilement les messages sans chercher dans tout le code

/// Classe AppConstants : Contient toutes les constantes de l'application
/// 
/// Cette classe est une classe statique (tous les membres sont static)
/// car elle ne contient que des constantes qui ne changent jamais.
/// 
/// Utilisation :
/// ```dart
/// AppConstants.errorNetwork 
/// ```
class AppConstants {
  
  /// Message d'erreur générique pour les problèmes de réseau
  /// 
  /// Ce message est affiché quand une opération échoue à cause d'un problème
  /// de connexion réseau (pas d'internet, timeout, etc.).
  /// 
  /// Utilisé dans :
  /// - Les écrans de connexion/inscription
  /// - Les appels API (TMDb, Firestore)
  /// 
  /// Type : String (constante, ne change jamais)
  static const String errorNetwork = 'Erreur de connexion réseau';
  
  /// Message d'erreur générique pour les erreurs inconnues
  /// 
  /// Ce message est affiché quand une erreur inattendue se produit
  /// et qu'on ne peut pas identifier le type exact d'erreur.
  /// 
  /// Utilisé comme fallback quand aucun autre message d'erreur spécifique
  /// ne correspond à l'erreur rencontrée.
  /// 
  /// Type : String (constante, ne change jamais)
  static const String errorUnknown = 'Une erreur est survenue';
  
  
  /// Message de succès affiché après une connexion réussie
  /// 
  /// Ce message est affiché quand un utilisateur se connecte avec succès
  /// à l'application.
  /// 
  /// Utilisé dans :
  /// - LoginScreen après une connexion réussie
  /// 
  /// Type : String (constante, ne change jamais)
  static const String successLogin = 'Connexion réussie !';
  
  /// Message de succès affiché après une inscription réussie
  /// 
  /// Ce message est affiché quand un nouvel utilisateur s'inscrit avec succès
  /// dans l'application.
  /// 
  /// Utilisé dans :
  /// - SignUpScreen après une inscription réussie
  /// 
  /// Type : String (constante, ne change jamais)
  static const String successSignup = 'Inscription réussie !';
  
  
  /// Longueur minimale requise pour un mot de passe
  /// 
  /// Cette constante définit le nombre minimum de caractères requis
  /// pour qu'un mot de passe soit considéré comme valide.
  /// 
  /// Utilisée lors de :
  /// - L'inscription (validation du mot de passe)
  /// - La validation des formulaires
  /// 
  /// Valeur actuelle : 6 caractères (minimum recommandé par Firebase)
  /// 
  /// Type : int (constante, ne change jamais)
  static const int minPasswordLength = 6;
  
  
  /// Nom de l'application affiché dans l'interface
  /// 
  /// Ce nom est utilisé dans :
  /// - Le titre de l'application (AppBar)
  /// - Les messages et notifications
  /// - La documentation
  /// 
  /// Type : String (constante, ne change jamais)
  static const String appName = 'Movie App';
  
  
  /// Clé API pour The Movie Database (TMDb)
  /// 
  /// Cette clé est nécessaire pour accéder à l'API TMDb et récupérer
  /// les informations sur les films (titre, description, affiche, etc.).
  /// 
  /// Pour obtenir une clé API gratuite :
  /// 1. Créer un compte sur https://www.themoviedb.org/
  /// 2. Aller dans Paramètres > API
  /// 3. Demander une clé API (type Developer - gratuite)
  /// 4. Copier la clé et remplacer 'YOUR_TMDB_API_KEY' ci-dessous
  /// 
  /// Documentation officielle : https://www.themoviedb.org/documentation/api
  /// 
  /// ⚠️ IMPORTANT : 
  /// - Remplacez cette clé par votre propre clé API avant de commiter sur GitHub
  /// - Ne partagez jamais votre clé API publiquement
  /// - Pour obtenir une clé gratuite : https://www.themoviedb.org/settings/api
  /// 
  /// Type : String (constante, doit être remplacée par votre clé)
  /// 
  /// ⚠️ IMPORTANT : Pour utiliser votre clé API locale, modifiez directement cette ligne
  /// ou utilisez le fichier constants.local.dart et remplacez cette valeur.
  static const String tmdbApiKey = '163d0ee76e9574fd92df6be7c89948b2';
  
  /// URL de base de l'API TMDb
  /// 
  /// Cette URL est utilisée comme point de départ pour tous les appels
  /// à l'API TMDb. Les endpoints spécifiques sont ajoutés à cette URL.
  /// 
  /// Exemple d'utilisation :
  /// - ${tmdbBaseUrl}/movie/popular?api_key=${tmdbApiKey}
  /// 
  /// Version de l'API : v3 (actuelle)
  /// 
  /// Type : String (constante, ne change jamais)
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  
  /// URL de base pour les images TMDb
  /// 
  /// Cette URL est utilisée pour construire les URLs complètes des affiches
  /// de films. Le chemin de l'image (poster_path) est ajouté à cette URL.
  /// 
  /// Format de l'URL complète :
  /// ${tmdbImageBaseUrl}${poster_path}
  /// 
  /// Exemple :
  /// https://image.tmdb.org/t/p/w500/poster_path.jpg
  /// 
  /// Taille d'image : w500 (largeur 500px, qualité optimale pour l'affichage)
  /// 
  /// Type : String (constante, ne change jamais)
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  
  
  /// Clé API pour RapidAPI (alternative à TMDb)
  /// 
  /// Cette clé est utilisée pour accéder à l'API MovieDB de RapidAPI
  /// si TMDb n'est pas configuré ou en cas d'erreur.
  /// 
  /// Non utilisée actuellement, mais disponible si vous préférez
  /// utiliser l'API MovieDB de RapidAPI au lieu de TMDb.
  /// 
  /// Pour obtenir une clé RapidAPI :
  /// 1. Créer un compte sur https://rapidapi.com/
  /// 2. S'abonner à l'API "Movie Database" (ou similaire)
  /// 3. Copier la clé API
  /// 4. Remplacer 'YOUR_RAPIDAPI_KEY' ci-dessous
  /// 
  /// ⚠️ IMPORTANT : 
  /// - Remplacez cette clé par votre propre clé API si vous l'utilisez
  /// - Ne partagez jamais votre clé API publiquement
  /// 
  /// Type : String (constante, doit être remplacée si utilisée)
  static const String rapidApiKey = 'YOUR_RAPIDAPI_KEY';
  
  /// Host de l'API RapidAPI
  /// 
  /// Ce host est utilisé dans les en-têtes HTTP lors des appels à l'API RapidAPI.
  /// Il identifie l'API spécifique à utiliser sur la plateforme RapidAPI.
  /// 
  /// Utilisé dans :
  /// - Les en-têtes HTTP (X-RapidAPI-Host)
  /// 
  /// Type : String (constante, ne change jamais)
  static const String rapidApiHost = 'moviesdatabase.p.rapidapi.com';
  
  /// URL de base de l'API RapidAPI
  /// 
  /// Cette URL est utilisée comme point de départ pour tous les appels
  /// à l'API RapidAPI Movie Database.
  /// 
  /// Non utilisée actuellement (TMDb est prioritaire), mais disponible
  /// comme fallback si TMDb n'est pas configuré.
  /// 
  /// Type : String (constante, ne change jamais)
  static const String rapidApiBaseUrl = 'https://moviesdatabase.p.rapidapi.com';
}
