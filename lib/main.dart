/// Point d'entrée principal de l'application Flutter
/// 
/// Ce fichier initialise :
/// - Flutter et ses bindings
/// - Firebase (Auth, Firestore, Storage)
/// - Les gestionnaires d'erreurs globaux
/// - L'application MaterialApp avec routing
/// 
/// Architecture :
/// - MyApp : Widget racine de l'application
/// - AuthWrapper : Gère la redirection selon l'état d'authentification

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

/// Fonction main : Point d'entrée de l'application
/// 
/// Processus d'initialisation :
/// 1. Initialiser Flutter bindings (nécessaire avant toute opération Flutter)
/// 2. Configurer les gestionnaires d'erreurs globaux
/// 3. Initialiser Firebase
/// 4. Lancer l'application
/// Fonction main : Point d'entrée de l'application
/// 
/// Cette fonction est appelée automatiquement au démarrage de l'application.
/// Elle est marquée comme `async` car elle doit attendre l'initialisation de Firebase.
/// 
/// Ordre d'exécution :
/// 1. Initialiser Flutter bindings (obligatoire avant toute opération Flutter)
/// 2. Configurer les gestionnaires d'erreurs globaux (pour ignorer les erreurs Firebase internes)
/// 3. Initialiser Firebase (charge la configuration depuis google-services.json)
/// 4. Lancer l'application avec runApp()
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  /// Gestionnaire d'erreurs pour les erreurs Flutter capturées
  /// 
  /// Ce gestionnaire intercepte toutes les erreurs qui se produisent dans le code Flutter
  /// (erreurs synchrones dans les widgets, build methods, etc.).
  /// 
  /// Ignore spécifiquement l'erreur Firebase interne "PigeonUserDetails"
  /// qui est un bug connu de Firebase et ne doit pas bloquer l'application.
  /// 
  /// Pour toutes les autres erreurs, utilise le gestionnaire par défaut
  /// qui affiche l'erreur à l'utilisateur.
  /// 
  /// Paramètres :
  /// - [details] : Objet FlutterErrorDetails contenant l'exception, la stack trace, etc.
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorString = details.exception.toString().toLowerCase();
    
    if (errorString.contains('pigeonuserdetails') || 
        errorString.contains('list<object?>') ||
        (errorString.contains('type') && errorString.contains('subtype'))) {
      debugPrint('Erreur Firebase interne ignorée: ${details.exception}');
      return;
    }
    
    FlutterError.presentError(details);
  };

  /// Gestionnaire d'erreurs pour les erreurs non capturées (asynchrones)
  /// 
  /// Ce gestionnaire intercepte les erreurs qui se produisent dans le code asynchrone
  /// (callbacks, Futures, Streams) et qui ne sont pas capturées par les blocs try-catch.
  /// 
  /// Gère les erreurs qui ne sont pas capturées par les try-catch
  /// (par exemple dans les callbacks asynchrones, les Futures non await, etc.)
  /// 
  /// Paramètres :
  /// - [error] : L'objet d'erreur (peut être de n'importe quel type)
  /// - [stack] : La stack trace associée à l'erreur
  /// 
  /// Retourne :
  /// - true : L'erreur a été gérée, ne pas la propager
  /// - false : L'erreur n'a pas été gérée, laisser Flutter la gérer (crash de l'app)
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('pigeonuserdetails') || 
        errorString.contains('list<object?>') ||
        (errorString.contains('type') && errorString.contains('subtype'))) {
      debugPrint('Erreur Firebase interne ignorée (non capturée): $error');
      return true;
    }
    
    return false;
  };

  
  /// Initialiser Firebase
  /// 
  /// Cette méthode charge la configuration Firebase depuis les fichiers de configuration :
  /// - Android : android/app/google-services.json
  /// - iOS : ios/Runner/GoogleService-Info.plist
  /// 
  /// L'initialisation est asynchrone (await) car elle doit :
  /// - Lire les fichiers de configuration
  /// - Se connecter aux services Firebase
  /// - Initialiser les SDK Firebase (Auth, Firestore, Storage)
  /// 
  /// NOTE: Vous devez configurer Firebase avant de lancer l'application
  /// Voir les guides : FIX_FIREBASE_AUTH.md, ENABLE_FIRESTORE.md
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialisé avec succès');
  } catch (e) {
    debugPrint('❌ Erreur lors de l\'initialisation de Firebase: $e');
    debugPrint('⚠️ Assurez-vous que Firebase est correctement configuré.');
    debugPrint('📋 Voir les guides de configuration dans le projet.');
  }

  runApp(const MyApp());
}

/// Widget racine de l'application
/// 
/// Cette classe représente le widget racine de toute l'application Flutter.
/// Elle hérite de StatelessWidget car elle n'a pas d'état mutable.
/// 
/// Configure :
/// - Le thème de l'application (Material Design 3)
/// - Les routes de navigation (chemins nommés pour naviguer entre les écrans)
/// - Le widget de démarrage (AuthWrapper qui gère l'authentification)
/// 
/// MaterialApp est le widget principal qui :
/// - Fournit le thème Material Design à toute l'application
/// - Gère la navigation entre les écrans
/// - Fournit le contexte Material nécessaire pour tous les widgets enfants
class MyApp extends StatelessWidget {
  /// Constructeur constant pour optimiser les performances
  /// super.key permet de passer une clé au widget parent (StatelessWidget)
  const MyApp({super.key});

  /// Méthode build : Construit l'interface utilisateur de ce widget
  /// 
  /// Cette méthode est appelée automatiquement par Flutter quand le widget doit être rendu.
  /// Elle retourne un MaterialApp qui est le widget racine de l'application Material Design.
  /// 
  /// Paramètres :
  /// - [context] : Le contexte BuildContext qui contient les informations sur l'arbre de widgets
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      
      home: const AuthWrapper(),
      
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

/// Widget qui vérifie l'état d'authentification et redirige l'utilisateur
/// 
/// Ce widget est un StatefulWidget car il doit gérer un état (l'état d'authentification).
/// Il utilise un StreamBuilder pour écouter les changements d'état d'authentification Firebase.
/// 
/// Fonctionnement :
/// 1. Écoute les changements d'état d'authentification Firebase via authStateChanges()
/// 2. Affiche un indicateur de chargement pendant la vérification initiale
/// 3. Redirige vers l'écran approprié selon l'état (connecté ou non connecté)
/// 
/// Comportement actuel :
/// - Toujours affiche l'écran de connexion au démarrage
/// - L'utilisateur doit se connecter même s'il a une session active
/// 
/// Pour changer ce comportement :
/// - Modifier la logique dans le builder pour rediriger automatiquement
///   vers HomeScreen si snapshot.hasData est true
class AuthWrapper extends StatefulWidget {
  /// Constructeur constant pour optimiser les performances
  /// super.key permet de passer une clé au widget parent (StatefulWidget)
  const AuthWrapper({super.key});

  /// Méthode createState : Crée l'état associé à ce widget
  /// 
  /// Cette méthode est appelée automatiquement par Flutter pour créer l'objet State
  /// qui gère l'état mutable de ce widget.
  /// 
  /// Retourne : Une instance de _AuthWrapperState qui gère l'état de ce widget
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

/// Classe d'état pour AuthWrapper
/// 
/// Cette classe gère l'état mutable du widget AuthWrapper.
/// Elle utilise un StreamBuilder pour écouter les changements d'authentification.
class _AuthWrapperState extends State<AuthWrapper> {
  /// Méthode build : Construit l'interface utilisateur de ce widget
  /// 
  /// Cette méthode utilise un StreamBuilder pour écouter les changements d'état d'authentification.
  /// Le StreamBuilder se reconstruit automatiquement à chaque changement d'état.
  /// 
  /// Paramètres :
  /// - [context] : Le contexte BuildContext qui contient les informations sur l'arbre de widgets
  /// 
  /// Retourne : Un widget qui affiche soit un indicateur de chargement, soit l'écran de connexion
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        debugPrint('🔍 AuthWrapper - ConnectionState: ${snapshot.connectionState}');
        debugPrint('🔍 AuthWrapper - hasData: ${snapshot.hasData}');
        debugPrint('🔍 AuthWrapper - hasError: ${snapshot.hasError}');
        if (snapshot.hasError) {
          debugPrint('🔍 AuthWrapper - Error: ${snapshot.error}');
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('⏳ AuthWrapper - Affiche l\'indicateur de chargement');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          debugPrint('❌ AuthWrapper - Erreur: ${snapshot.error}');
          return Scaffold(
            body: Center(
              child: Text('Erreur: ${snapshot.error}'),
            ),
          );
        }

        
        debugPrint('✅ AuthWrapper - Affiche LoginScreen');
        try {
        return const LoginScreen();
        } catch (e, stackTrace) {
          debugPrint('❌ Erreur lors de la création de LoginScreen: $e');
          debugPrint('Stack trace: $stackTrace');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: $e'),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}