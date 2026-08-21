/// Modèle de données représentant un utilisateur de l'application
/// 
/// Cette classe encapsule toutes les informations d'un utilisateur :
/// - Informations personnelles (nom, prénom, âge, email)
/// - Photo de profil
/// - Rôle et statut (admin/user, actif/désactivé)
/// - Liste des films favoris
/// 
/// Utilisée pour :
/// - Stocker les utilisateurs dans Firestore
/// - Gérer l'authentification et les permissions
/// - Afficher les profils utilisateurs

/// Classe AppUser : Modèle de données pour un utilisateur
/// 
/// Cette classe est immuable (tous les champs sont final) pour garantir
/// l'intégrité des données. Pour modifier un utilisateur, utiliser copyWith().
class AppUser {
  /// Identifiant unique de l'utilisateur (UID Firebase Auth)
  /// 
  /// Cet ID correspond à l'UID généré par Firebase Authentication lors de l'inscription.
  /// Il est utilisé comme ID du document dans Firestore (collection "users").
  /// 
  /// Type : String (non nullable, toujours présent)
  final String id;
  
  /// Adresse email de l'utilisateur
  /// 
  /// Email utilisé pour l'authentification et la communication.
  /// Doit être unique dans la base de données.
  /// 
  /// Type : String (non nullable, toujours présent)
  final String email;
  
  /// Prénom de l'utilisateur
  /// 
  /// Prénom affiché dans l'interface utilisateur.
  /// Utilisé pour l'affichage du profil et les messages personnalisés.
  /// 
  /// Type : String (non nullable, peut être vide "")
  final String firstName;
  
  /// Nom de famille de l'utilisateur
  /// 
  /// Nom de famille affiché dans l'interface utilisateur.
  /// Utilisé avec firstName pour former le nom complet.
  /// 
  /// Type : String (non nullable, peut être vide "")
  final String lastName;
  
  /// Âge de l'utilisateur (0 si non spécifié)
  /// 
  /// Âge en années. Si non spécifié, vaut 0.
  /// Utilisé pour le matching et l'affichage du profil.
  /// 
  /// Type : int (non nullable, 0 par défaut si non spécifié)
  final int age;
  
  /// URL de la photo de profil (null si aucune photo)
  /// 
  /// URL complète de l'image stockée dans Firebase Storage.
  /// Si null, l'interface affiche une initiale ou une icône par défaut.
  /// 
  /// Type : String? (nullable, optionnel)
  final String? photoUrl;
  
  /// Rôle de l'utilisateur : 'admin' ou 'user'
  /// 
  /// Détermine les permissions dans l'application :
  /// - 'admin' : Accès à l'interface d'administration
  /// - 'user' : Utilisateur standard (par défaut)
  /// 
  /// Type : String (non nullable, 'user' par défaut)
  final String role;
  
  /// Statut actif/désactivé de l'utilisateur
  /// 
  /// Un utilisateur désactivé (isActive = false) ne peut plus se connecter.
  /// Utilisé par les administrateurs pour gérer les comptes.
  /// 
  /// Type : bool (non nullable, true par défaut)
  final bool isActive;
  
  /// Liste des IDs des films favoris de l'utilisateur
  /// 
  /// Liste des identifiants (String) des films ajoutés aux favoris.
  /// Utilisée pour :
  /// - Afficher la liste des favoris
  /// - Calculer le matching avec d'autres utilisateurs
  /// 
  /// Type : List<String> (non nullable, liste vide par défaut)
  final List<String> favoriteMovies;

  /// Constructeur du modèle AppUser
  /// 
  /// Crée une nouvelle instance AppUser avec les paramètres fournis.
  /// 
  /// Paramètres :
  /// - [id] : UID Firebase Auth (requis, non nullable)
  /// - [email] : Email de l'utilisateur (requis, non nullable)
  /// - [firstName] : Prénom (requis, non nullable, peut être vide)
  /// - [lastName] : Nom (requis, non nullable, peut être vide)
  /// - [age] : Âge (requis, non nullable, peut être 0)
  /// - [photoUrl] : URL de la photo (optionnel, nullable)
  /// - [role] : Rôle par défaut 'user' (optionnel, 'user' si non fourni)
  /// - [isActive] : Statut actif par défaut true (optionnel, true si non fourni)
  /// - [favoriteMovies] : Liste des favoris (optionnel, [] si non fourni)
  /// 
  /// Initialisation de favoriteMovies :
  /// Si favoriteMovies est null, utilise une liste vide [].
  /// Sinon, utilise la liste fournie.
  AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.age,
    this.photoUrl,
    this.role = 'user',
    this.isActive = true,
    List<String>? favoriteMovies,
  }) : favoriteMovies = favoriteMovies ?? [];

  /// Factory constructor : Crée une instance AppUser à partir d'un JSON Firestore
  /// 
  /// Cette méthode désérialise les données JSON depuis Firestore en créant
  /// une instance AppUser. Elle gère de manière sécurisée :
  /// - Les conversions de types (age peut être int ou String)
  /// - Les valeurs nulles ou manquantes (utilise des valeurs par défaut)
  /// - Les erreurs de parsing (favoriteMovies peut être de différents types)
  /// 
  /// Paramètres :
  /// - [json] : Map<String, dynamic> contenant les données Firestore
  /// - [id] : String ID du document Firestore (UID utilisateur)
  /// 
  /// Retourne : Une instance AppUser avec des valeurs par défaut si des champs sont absents
  /// 
  /// Gestion des erreurs :
  /// - Si favoriteMovies ne peut pas être parsé, utilise une liste vide
  /// - Si age n'est pas un int, essaie de le convertir depuis String
  /// - Si isActive n'est pas un bool, essaie de le convertir depuis String
  factory AppUser.fromJson(Map<String, dynamic> json, String id) {
    
    List<String> favoriteMoviesList = [];
    
    if (json['favoriteMovies'] != null) {
      try {
        final favoriteMoviesData = json['favoriteMovies'];
        
        if (favoriteMoviesData is List) {
          favoriteMoviesList = favoriteMoviesData
              .map((item) => item?.toString() ?? '')
              .where((item) => item.isNotEmpty)
              .toList();
        }
      } catch (e) {
        print('Erreur lors de la conversion de favoriteMovies: $e');
        favoriteMoviesList = [];
      }
    }

    
    int userAge = 0;
    
    if (json['age'] != null) {
      if (json['age'] is int) {
        userAge = json['age'];
      } else if (json['age'] is String) {
        userAge = int.tryParse(json['age']) ?? 0;
      }
    }

    
    bool userIsActive = true;
    
    if (json['isActive'] != null) {
      if (json['isActive'] is bool) {
        userIsActive = json['isActive'];
      } else if (json['isActive'] is String) {
        userIsActive = json['isActive'].toLowerCase() == 'true';
      }
    }

    return AppUser(
      id: id,
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      age: userAge,
      photoUrl: json['photoUrl']?.toString(),
      role: json['role']?.toString() ?? 'user',
      isActive: userIsActive,
      favoriteMovies: favoriteMoviesList,
    );
  }

  /// Méthode toJson : Convertit une instance AppUser en JSON pour Firestore
  /// 
  /// Cette méthode sérialise l'instance AppUser en Map<String, dynamic>
  /// pour pouvoir l'enregistrer dans Firestore.
  /// 
  /// Utilisée pour :
  /// - Sauvegarder un utilisateur dans Firestore (createOrUpdateUser)
  /// - Mettre à jour les données utilisateur (update)
  /// 
  /// Retourne : Un Map<String, dynamic> avec tous les champs de l'utilisateur
  /// 
  /// Note : L'ID n'est pas inclus car c'est l'ID du document Firestore lui-même
  /// (pas un champ du document)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'photoUrl': photoUrl,
      'role': role,
      'isActive': isActive,
      'favoriteMovies': favoriteMovies,
    };
  }

  /// Getter isAdmin : Vérifie si l'utilisateur est administrateur
  /// 
  /// Cette méthode retourne true si le rôle de l'utilisateur est 'admin',
  /// false sinon.
  /// 
  /// Utilisée pour :
  /// - Afficher/masquer les fonctionnalités admin dans l'interface
  /// - Vérifier les permissions avant certaines actions
  /// 
  /// Retourne : bool (true si admin, false sinon)
  bool get isAdmin => role == 'admin';

  /// Getter fullName : Retourne le nom complet de l'utilisateur
  /// 
  /// Cette méthode combine firstName et lastName pour former le nom complet.
  /// 
  /// Format : "Prénom Nom"
  /// 
  /// Utilisée pour :
  /// - L'affichage dans l'interface utilisateur
  /// - Les messages personnalisés
  /// 
  /// Retourne : String (nom complet)
  String get fullName => '$firstName $lastName';

  /// Méthode copyWith : Crée une copie de l'utilisateur avec des modifications optionnelles
  /// 
  /// Cette méthode permet de créer une nouvelle instance AppUser
  /// en modifiant seulement certains champs, sans toucher aux autres.
  /// 
  /// Pattern : Immutability (immuabilité)
  /// Au lieu de modifier l'instance existante, on crée une nouvelle instance
  /// avec les modifications souhaitées.
  /// 
  /// Exemple d'utilisation :
  /// ```dart
  /// final updatedUser = user.copyWith(age: 26, role: 'admin');
  /// ```
  /// 
  /// Paramètres :
  /// Tous les paramètres sont optionnels (nullable).
  /// Si un paramètre est null, la valeur originale est conservée.
  /// Si un paramètre est fourni, la nouvelle valeur est utilisée.
  /// 
  /// Retourne : Une nouvelle instance AppUser avec les modifications appliquées
  AppUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    int? age,
    String? photoUrl,
    String? role,
    bool? isActive,
    List<String>? favoriteMovies,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
    );
  }
}
