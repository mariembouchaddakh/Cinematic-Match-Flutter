/// Écran d'administration de l'application
/// 
/// Accessible uniquement aux utilisateurs avec role = "admin" dans Firestore
/// 
/// Fonctionnalités :
/// - Ajouter des films manuellement à la base de données
/// - Gérer les utilisateurs (voir tous les utilisateurs)
/// - Activer/Désactiver des utilisateurs
/// 
/// Structure :
/// - Utilise un TabBar avec 2 onglets :
///   1. Ajouter un film : Formulaire pour ajouter un nouveau film
///   2. Gérer les utilisateurs : Liste de tous les utilisateurs avec actions
/// 
/// Actions disponibles :
/// - Ajouter un film : Crée un document dans la collection "movies"
/// - Activer/Désactiver : Modifie le champ isActive d'un utilisateur
/// 
/// Note : Un utilisateur désactivé ne peut plus se connecter à l'application

import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../models/user.dart';
import '../services/movie_service.dart';
import '../services/firestore_service.dart';

/// Widget StatefulWidget pour l'écran d'administration
/// 
/// Ce widget est un StatefulWidget car il doit gérer un état (liste des utilisateurs, onglets).
/// Il est accessible uniquement aux administrateurs (vérifié dans HomeScreen).
class AdminScreen extends StatefulWidget {
  /// Service pour gérer les films (récupération, ajout, etc.)
  /// 
  /// Ce service est passé en paramètre depuis HomeScreen pour éviter de créer
  /// plusieurs instances du même service (pattern Singleton).
  final MovieService movieService;
  
  /// Service pour gérer les données Firestore (utilisateurs, films, etc.)
  /// 
  /// Ce service est passé en paramètre depuis HomeScreen pour éviter de créer
  /// plusieurs instances du même service (pattern Singleton).
  final FirestoreService firestoreService;
  
  /// Callback appelé quand un film est ajouté (pour rafraîchir la liste)
  /// 
  /// Cette fonction est appelée après l'ajout réussi d'un film pour mettre à jour
  /// la liste des films dans HomeScreen sans avoir à recharger toute l'application.
  final VoidCallback onMoviesUpdated;

  /// Constructeur constant pour optimiser les performances
  /// 
  /// Paramètres :
  /// - super.key : Clé du widget parent (StatefulWidget)
  /// - required this.movieService : Service de gestion des films (obligatoire)
  /// - required this.firestoreService : Service Firestore (obligatoire)
  /// - required this.onMoviesUpdated : Callback de mise à jour (obligatoire)
  const AdminScreen({
    super.key,
    required this.movieService,
    required this.firestoreService,
    required this.onMoviesUpdated,
  });

  /// Méthode createState : Crée l'état associé à ce widget
  /// 
  /// Cette méthode est appelée automatiquement par Flutter pour créer l'objet State
  /// qui gère l'état mutable de ce widget.
  /// 
  /// Retourne : Une instance de _AdminScreenState qui gère l'état de ce widget
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

/// Classe d'état pour AdminScreen
/// 
/// Cette classe gère l'état mutable du widget AdminScreen.
/// Elle hérite de State<AdminScreen> et implémente SingleTickerProviderStateMixin
/// pour utiliser un TabController (nécessaire pour les onglets).
/// 
/// SingleTickerProviderStateMixin : Fournit un Ticker pour animer le TabController
class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  /// Contrôleur pour gérer les onglets (Ajouter un film, Gérer les utilisateurs)
  /// 
  /// Ce contrôleur gère la navigation entre les différents onglets.
  /// Il est initialisé avec 2 onglets dans initState().
  /// 
  /// late : Initialisé dans initState(), pas à la déclaration
  late TabController _tabController;
  
  /// Liste de tous les utilisateurs de l'application
  /// 
  /// Cette liste est remplie lors du chargement initial depuis Firestore.
  /// Elle contient tous les utilisateurs (admin et user).
  /// 
  /// Initialisée à une liste vide [] au démarrage
  List<AppUser> _users = [];
  
  /// Indicateur de chargement pour la liste des utilisateurs
  /// 
  /// true : Les utilisateurs sont en cours de chargement (afficher un spinner)
  /// false : Les utilisateurs sont chargés (afficher la liste)
  /// 
  /// Initialisé à false car on charge les utilisateurs dans initState()
  bool _isLoadingUsers = false;

  /// Méthode initState : Appelée une seule fois lors de la création du widget
  /// 
  /// Cette méthode est appelée automatiquement par Flutter après la création du widget.
  /// Elle est utilisée pour initialiser les données et les services.
  /// 
  /// Ordre d'exécution :
  /// 1. Appeler super.initState() (obligatoire)
  /// 2. Initialiser le TabController avec 2 onglets
  /// 3. Charger la liste des utilisateurs
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);
    
    _loadUsers();
  }

  /// Méthode asynchrone pour charger tous les utilisateurs depuis Firestore
  /// 
  /// Cette méthode :
  /// 1. Affiche un indicateur de chargement
  /// 2. Récupère tous les utilisateurs depuis Firestore
  /// 3. Met à jour la liste _users
  /// 4. Gère les erreurs avec un message SnackBar
  /// 
  /// Retourne : Future<void> (méthode asynchrone)
  Future<void> _loadUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final users = await widget.firestoreService.getAllUsers();
      
      setState(() {
        _users = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des utilisateurs: $e')),
        );
      }
    }
  }

  /// Méthode asynchrone pour afficher le dialogue d'ajout de film
  /// 
  /// Cette méthode :
  /// 1. Crée un dialogue avec un formulaire
  /// 2. Permet de saisir les informations du film
  /// 3. Valide les données (titre requis)
  /// 4. Crée le film dans Firestore
  /// 5. Appelle le callback onMoviesUpdated pour rafraîchir la liste
  /// 
  /// Retourne : Future<void> (méthode asynchrone)
  Future<void> _showAddMovieDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();
    final ratingController = TextEditingController();
    final yearController = TextEditingController();
    final genreController = TextEditingController();
    final directorController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un film'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ratingController,
                decoration: const InputDecoration(
                  labelText: 'Note (0-10)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(
                  labelText: 'Année',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: genreController,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: directorController,
                decoration: const InputDecoration(
                  labelText: 'Réalisateur',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le titre est requis')),
                );
                return;
              }

              final movie = Movie(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descriptionController.text,
                imageUrl: imageUrlController.text.isEmpty
                    ? 'https://via.placeholder.com/500x750?text=No+Image'
                    : imageUrlController.text,
                rating: double.tryParse(ratingController.text) ?? 0.0,
                year: int.tryParse(yearController.text) ?? 0,
                genre: genreController.text.isEmpty ? 'Non spécifié' : genreController.text,
                director: directorController.text.isEmpty ? 'Non spécifié' : directorController.text,
              );

              try {
                await widget.firestoreService.addMovie(movie);
                
                if (mounted) {
                  Navigator.pop(context);
                  
                  widget.onMoviesUpdated();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Film ajouté avec succès')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  /// Méthode asynchrone pour activer/désactiver un utilisateur
  /// 
  /// Cette méthode :
  /// 1. Vérifie si l'utilisateur est actif ou non
  /// 2. Appelle disableUser() ou enableUser() selon l'état
  /// 3. Affiche un message de confirmation
  /// 4. Recharge la liste des utilisateurs
  /// 5. Gère les erreurs avec un message SnackBar
  /// 
  /// Paramètres :
  /// - [user] : L'utilisateur à activer/désactiver
  /// 
  /// Retourne : Future<void> (méthode asynchrone)
  Future<void> _toggleUserStatus(AppUser user) async {
    try {
      if (user.isActive) {
        await widget.firestoreService.disableUser(user.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.firstName} ${user.lastName} a été désactivé')),
          );
        }
      } else {
        await widget.firestoreService.enableUser(user.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${user.firstName} ${user.lastName} a été activé')),
          );
        }
      }
      _loadUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  /// Méthode build : Construit l'interface utilisateur de ce widget
  /// 
  /// Cette méthode est appelée automatiquement par Flutter quand le widget doit être rendu.
  /// Elle retourne un Column contenant un TabBar et un TabBarView.
  /// 
  /// Paramètres :
  /// - [context] : Le contexte BuildContext qui contient les informations sur l'arbre de widgets
  /// 
  /// Retourne : Un widget Column avec TabBar et TabBarView
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle), text: 'Ajouter un film'),
            Tab(icon: Icon(Icons.people), text: 'Gérer les utilisateurs'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.movie_creation,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ajouter un nouveau film',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _showAddMovieDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un film'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _isLoadingUsers
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? const Center(
                          child: Text('Aucun utilisateur trouvé'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
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
                                        )
                                      : null,
                                ),
                                title: Text('${user.firstName} ${user.lastName}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.email),
                                    Text(
                                      user.age > 0 
                                          ? 'Âge: ${user.age} ans'
                                          : 'Âge: Non spécifié',
                                    ),
                                    Text('Rôle: ${user.role}'),
                                    Text(
                                      user.isActive ? 'Actif' : 'Désactivé',
                                      style: TextStyle(
                                        color: user.isActive ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    user.isActive ? Icons.block : Icons.check_circle,
                                    color: user.isActive ? Colors.red : Colors.green,
                                  ),
                                  onPressed: () => _toggleUserStatus(user),
                                  tooltip: user.isActive
                                      ? 'Désactiver l\'utilisateur'
                                      : 'Activer l\'utilisateur',
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ],
    );
  }

  /// Méthode dispose : Appelée quand le widget est détruit
  /// 
  /// Cette méthode est appelée automatiquement par Flutter quand le widget est retiré
  /// de l'arbre de widgets. Elle est utilisée pour libérer les ressources.
  /// 
  /// Actions :
  /// 1. Libérer le TabController (évite les fuites mémoire)
  /// 2. Appeler super.dispose() (obligatoire)
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
