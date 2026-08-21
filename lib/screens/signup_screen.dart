/// Écran d'inscription de l'application
/// 
/// Fonctionnalités :
/// - Formulaire d'inscription complet (nom, prénom, âge, email, mot de passe, photo)
/// - Validation de tous les champs
/// - Sélection/téléchargement de photo de profil
/// - Création du compte Firebase Auth
/// - Upload de la photo vers Firebase Storage
/// - Création du profil utilisateur dans Firestore
/// - Navigation vers l'écran de connexion après inscription
/// 
/// Processus d'inscription :
/// 1. Validation de tous les champs (non vides, formats valides)
/// 2. Vérification que les mots de passe correspondent
/// 3. Vérification de la longueur minimale du mot de passe (6 caractères)
/// 4. Création du compte Firebase Auth : createUserWithEmailAndPassword()
/// 5. Upload de la photo (si fournie) vers Firebase Storage
/// 6. Création du profil utilisateur dans Firestore
/// 7. Navigation vers LoginScreen
/// 
/// Gestion des erreurs :
/// - Email déjà utilisé
/// - Email invalide
/// - Mot de passe trop faible
/// - Erreurs réseau
/// - Erreurs Firebase (permissions, etc.)
/// 
/// Note : L'inscription continue même si l'upload de la photo échoue

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_screen.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  
  /// Contrôleur pour le champ email
  final _emailController = TextEditingController();
  
  /// Contrôleur pour le champ mot de passe
  final _passwordController = TextEditingController();
  
  /// Contrôleur pour la confirmation du mot de passe
  final _confirmPasswordController = TextEditingController();
  
  /// Contrôleur pour le champ prénom
  final _firstNameController = TextEditingController();
  
  /// Contrôleur pour le champ nom
  final _lastNameController = TextEditingController();
  
  /// Contrôleur pour le champ âge
  final _ageController = TextEditingController();

  
  /// Indicateur de chargement (affiche un spinner pendant l'inscription)
  bool _isLoading = false;

  /// Message à afficher à l'utilisateur (erreur ou succès)
  String _message = '';

  
  /// Fichier image sélectionné pour la photo de profil
  File? _profileImage;
  
  /// Instance ImagePicker pour sélectionner/télécharger des images
  final ImagePicker _picker = ImagePicker();
  
  /// Service Firestore pour créer le profil utilisateur
  final FirestoreService _firestoreService = FirestoreService();


  /// Sélectionne une image depuis la galerie
  /// 
  /// Utilise ImagePicker pour ouvrir la galerie et sélectionner une image
  /// L'image est redimensionnée automatiquement (max 800x800) pour optimiser
  /// la taille du fichier avant l'upload
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erreur lors de la sélection de l\'image: $e';
      });
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erreur lors de la prise de photo: $e';
      });
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner une photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Appareil photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _signUp() async {
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

    final firstName = _firstNameController.text.trim();
    if (firstName.isEmpty) {
      setState(() {
        _message = 'Veuillez entrer votre prénom';
      });
      return;
    }

    final lastName = _lastNameController.text.trim();
    if (lastName.isEmpty) {
      setState(() {
        _message = 'Veuillez entrer votre nom';
      });
      return;
    }

    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      setState(() {
        _message = 'Veuillez entrer votre âge';
      });
      return;
    }

    final age = int.tryParse(ageText);
    if (age == null || age < 1 || age > 150) {
      setState(() {
        _message = 'Âge invalide';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _message = 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _message = 'Le mot de passe doit contenir au moins 6 caractères';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      ).then((userCredential) async {
        final user = userCredential.user;
        if (user == null) {
          throw Exception('Erreur lors de la création du compte');
        }

        debugPrint('✅ Compte Firebase Auth créé: ${user.uid}');

        String? photoUrl;
        if (_profileImage != null) {
          try {
            photoUrl = await _firestoreService.uploadProfilePhoto(user.uid, _profileImage!);
            if (photoUrl == null) {
              debugPrint('Avertissement: L\'upload de la photo a échoué, mais le compte sera créé sans photo');
            }
          } catch (e) {
            debugPrint('Erreur lors de l\'upload de la photo: $e');
          }
        }

        final appUser = AppUser(
          id: user.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          age: age,
          photoUrl: photoUrl,
          role: 'user',
          isActive: true,
        );

        try {
          await _firestoreService.createOrUpdateUser(appUser);
          debugPrint('✅ Profil Firestore créé avec succès');
        } catch (e) {
          debugPrint('Erreur lors de la création du profil Firestore: $e');
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
            _message = 'Inscription réussie !';
          });
          
          debugPrint('✅ Navigation vers l\'écran de connexion...');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          });
        }
      }).catchError((error) {
        final errorString = error.toString().toLowerCase();
        if (errorString.contains('pigeonuserdetails') || 
            errorString.contains('list<object?>') ||
            (errorString.contains('type') && errorString.contains('subtype'))) {
          debugPrint('⚠️ Erreur Firebase interne ignorée (non bloquante): $error');
          
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && mounted) {
            debugPrint('✅ L\'utilisateur a été créé malgré l\'erreur: ${currentUser.email}');
            setState(() {
              _isLoading = false;
              _message = 'Inscription réussie !';
            });
            
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            });
            return;
          }
        }
        
        _handleSignUpError(error);
      });
    } catch (error) {
      _handleSignUpError(error);
    }
  }
  
  void _handleSignUpError(dynamic error) {
    setState(() {
      _isLoading = false;
      String errorMessage = 'Erreur lors de l\'inscription';
      
      final errorString = error.toString().toLowerCase();
      
      debugPrint('❌ Erreur d\'inscription: $error');
      
      if (errorString.contains('email-already-in-use') || errorString.contains('email déjà utilisé')) {
        errorMessage = 'Cet email est déjà utilisé';
      } else if (errorString.contains('invalid-email') || errorString.contains('email invalide')) {
        errorMessage = 'Email invalide';
      } else if (errorString.contains('weak-password') || errorString.contains('mot de passe trop faible')) {
        errorMessage = 'Mot de passe trop faible (minimum 6 caractères)';
      } else if (errorString.contains('network-request-failed') || errorString.contains('réseau')) {
        errorMessage = 'Erreur de connexion réseau. Vérifiez votre connexion internet';
      } else if (errorString.contains('operation-not-allowed')) {
        errorMessage = 'L\'inscription par email n\'est pas activée dans Firebase';
      } else if (errorString.contains('permission-denied') || errorString.contains('permission refusée')) {
        errorMessage = 'Permission refusée. Vérifiez la configuration Firestore';
      } else if (errorString.contains('unavailable')) {
        errorMessage = 'Service temporairement indisponible. Réessayez plus tard';
      } else if (errorString.contains('configuration_not_found') || errorString.contains('configuration not found')) {
        errorMessage = 'Configuration Firebase manquante.\n\n'
            'Solution : Ajoutez les empreintes SHA dans Firebase Console.\n'
            'Voir le fichier FIX_FIREBASE_AUTH.md pour les instructions.\n\n'
            'SHA-1: C7:62:54:87:8D:D3:D3:63:50:F9:F5:91:B6:9D:C0:39:63:25:D8:C7\n'
            'SHA-256: 32:91:68:75:39:DE:E0:78:85:1A:01:59:70:AA:67:CE:08:B6:93:B6:C1:81:41:B8:9A:A8:26:C3:FB:3E:95:41';
      } else {
        errorMessage = 'Erreur: ${error.toString()}';
        debugPrint('Erreur d\'inscription complète: $error');
      }
      
      _message = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.person_add,
              size: 80,
              color: Colors.blue,
            ),
                  const SizedBox(height: 20),
            const Text(
              'Créer un compte',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _showImagePickerDialog,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _showImagePickerDialog,
                    child: const Text('Ajouter une photo de profil'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Âge',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('S\'inscrire'),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Déjà un compte ? Se connecter'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }
}
