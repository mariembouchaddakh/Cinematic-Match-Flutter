/// Écran de connexion de l'application
/// 
/// Fonctionnalités :
/// - Formulaire de connexion (email + mot de passe)
/// - Validation des champs
/// - Authentification Firebase Auth
/// - Gestion des erreurs avec messages spécifiques
/// - Navigation vers l'écran d'inscription
/// - Navigation vers l'écran d'accueil après connexion réussie
/// 
/// Processus de connexion :
/// 1. Validation des champs (email non vide, mot de passe non vide)
/// 2. Appel Firebase Auth : signInWithEmailAndPassword()
/// 3. Gestion des erreurs (user-not-found, wrong-password, etc.)
/// 4. Navigation vers HomeScreen si succès
/// 
/// Gestion des erreurs :
/// - Email invalide
/// - Mot de passe incorrect
/// - Utilisateur non trouvé
/// - Compte désactivé
/// - Erreurs réseau
/// - Erreurs Firebase internes (PigeonUserDetails) - ignorées

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  /// Contrôleur pour le champ email
  final _emailController = TextEditingController();
  
  /// Contrôleur pour le champ mot de passe
  final _passwordController = TextEditingController();

  
  /// Indicateur de chargement (affiche un spinner pendant la connexion)
  bool _isLoading = false;

  /// Message à afficher à l'utilisateur (erreur ou succès)
  String _message = '';


  /// Fonction principale de connexion
  /// 
  /// Processus :
  /// 1. Valide les champs (email et mot de passe non vides)
  /// 2. Affiche un indicateur de chargement
  /// 3. Appelle Firebase Auth pour authentifier l'utilisateur
  /// 4. Gère les erreurs avec des messages spécifiques
  /// 5. Navigue vers HomeScreen en cas de succès
  /// 
  /// Gestion des erreurs :
  /// - Affiche un message d'erreur spécifique selon le type d'erreur
  /// - Ignore les erreurs Firebase internes (PigeonUserDetails)
  void _login() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Veuillez entrer votre email';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _message = 'Email invalide';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _message = 'Veuillez entrer votre mot de passe';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    debugPrint('Tentative de connexion avec: $email');
    
    try {
    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: _passwordController.text,
    ).then((userCredential) {
        debugPrint('Connexion réussie pour: ${userCredential.user?.email}');
        Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
            try {
        Navigator.pushReplacementNamed(context, '/home');
            } catch (navError) {
              debugPrint('Erreur lors de la navigation: $navError');
              try {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              } catch (e) {
                debugPrint('Erreur lors de la navigation alternative: $e');
              }
            }
          }
        });
    }).catchError((error) {
        final errorString = error.toString().toLowerCase();
        if (errorString.contains('pigeonuserdetails') || 
            errorString.contains('list<object?>') ||
            (errorString.contains('type') && errorString.contains('subtype'))) {
          debugPrint('Erreur Firebase interne ignorée (non bloquante): $error');
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                try {
                  Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  debugPrint('Erreur navigation après erreur Firebase: $e');
                }
              }
            });
          }
          return;
        }
        
        _handleLoginError(error);
      });
    } catch (e) {
      _handleLoginError(e);
    }
  }
  
  void _handleLoginError(dynamic error) {
    debugPrint('Erreur de connexion complète: $error');
    debugPrint('Type d\'erreur: ${error.runtimeType}');
    
      setState(() {
        _isLoading = false;
        String errorMessage = 'Erreur lors de la connexion';
        
      final errorString = error.toString().toLowerCase();
      final errorCode = error is FirebaseAuthException ? error.code : '';
      
      debugPrint('Code d\'erreur Firebase: $errorCode');
      debugPrint('Message d\'erreur: ${error.toString()}');
      
      if (errorCode == 'user-not-found' || errorString.contains('user-not-found')) {
        errorMessage = 'Aucun compte trouvé avec cet email.\n\n'
            'Vérifiez votre email ou créez un nouveau compte.\n\n'
            'Note: Si vous venez de vous inscrire, le compte pourrait ne pas avoir été créé correctement à cause d\'une erreur de configuration Firebase.';
      } else if (errorCode == 'wrong-password' || 
                 errorString.contains('wrong-password') ||
                 errorString.contains('incorrect') || 
                 errorString.contains('malformed') ||
                 errorString.contains('expired')) {
        errorMessage = 'Mot de passe incorrect.\n\nVérifiez votre mot de passe.';
      } else if (errorCode == 'invalid-email' || errorString.contains('invalid-email')) {
          errorMessage = 'Email invalide';
      } else if (errorCode == 'user-disabled' || errorString.contains('user-disabled')) {
        errorMessage = 'Ce compte a été désactivé par un administrateur';
      } else if (errorCode == 'too-many-requests' || errorString.contains('too-many-requests')) {
          errorMessage = 'Trop de tentatives. Réessayez plus tard';
      } else if (errorCode == 'network-request-failed' || errorString.contains('network-request-failed')) {
        errorMessage = 'Erreur de connexion réseau.\nVérifiez votre connexion internet';
      } else if (errorCode == 'invalid-credential' || errorString.contains('invalid-credential')) {
        errorMessage = 'Identifiants invalides.\n\n'
            'Vérifiez votre email et mot de passe.\n\n'
            'Si vous venez de vous inscrire, attendez quelques secondes et réessayez.';
      } else if (errorString.contains('configuration_not_found') || 
                 errorString.contains('configuration not found')) {
        errorMessage = 'Configuration Firebase manquante.\n\n'
            'Solution : Ajoutez les empreintes SHA dans Firebase Console.\n'
            'Voir le fichier FIX_FIREBASE_AUTH.md pour les instructions.\n\n'
            'SHA-1: C7:62:54:87:8D:D3:D3:63:50:F9:F5:91:B6:9D:C0:39:63:25:D8:C7\n'
            'SHA-256: 32:91:68:75:39:DE:E0:78:85:1A:01:59:70:AA:67:CE:08:B6:93:B6:C1:81:41:B8:9A:A8:26:C3:FB:3E:95:41';
      } else {
        errorMessage = 'Erreur de connexion:\n\n${error.toString()}\n\n'
            'Code: $errorCode\n\n'
            'Vérifiez vos identifiants ou consultez les logs pour plus de détails.';
        }
        
        _message = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🎬 LoginScreen - build() appelé');
    try {
      debugPrint('🎬 LoginScreen - Création du Scaffold...');
      
      debugPrint('🎬 LoginScreen - Retour du Scaffold');
      
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              const SizedBox(height: 40),
            const Icon(
              Icons.movie,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 40),
            const Text(
              'Movie App',
                textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Se connecter'),
              ),
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                _message,
                    textAlign: TextAlign.center,
                style: TextStyle(
                  color: _message.contains('réussie') ? Colors.green : Colors.red,
                      fontSize: 14,
                    ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                );
              },
              child: const Text('Pas de compte ? S\'inscrire'),
            ),
              const SizedBox(height: 32),
          ],
        ),
      ),
    );
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur dans LoginScreen.build(): $e');
      debugPrint('Stack trace: $stackTrace');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur dans LoginScreen: $e'),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}