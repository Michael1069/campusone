import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  bool _isLoading = true;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  String? get userId => _user?.uid;

  AuthProvider() {
    _init();
  }

  // Initialize and listen to auth state changes
  Future<void> _init() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Sign up with email and password
  Future<void> signup(String name, String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'username': email.split('@')[0],
        'bio': null,
        'avatarUrl': null,
        'department': null,
        'year': null,
        'interests': [],
        'skills': [],
        'followersCount': 0,
        'followingCount': 0,
        'postsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      _error = 'An unexpected error occurred';
      notifyListeners();
      rethrow;
    }
  }

  // Sign in with email and password
  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;
      
      // Check if user document exists
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        // Create user document if it doesn't exist
        final name = email.split('@')[0];
        print('📝 Creating missing user document for $email');
        await _firestore.collection('users').doc(userId).set({
          'id': userId,
          'name': name,
          'email': email,
          'username': email.split('@')[0],
          'bio': null,
          'avatarUrl': userCredential.user!.photoURL,
          'department': null,
          'year': null,
          'interests': [],
          'skills': [],
          'followersCount': 0,
          'followingCount': 0,
          'postsCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
        });
        
        // Update Firebase Auth display name
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();
        _user = _auth.currentUser;
        
        print('✅ User document created');
      } else {
        // Update last active
        await _firestore.collection('users').doc(userId).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
      }

      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      rethrow;
    } catch (e) {
      _isLoading = false;
      _error = 'An unexpected error occurred';
      notifyListeners();
      rethrow;
    }
  }

  // Sign out
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _user = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to logout';
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to send reset email';
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? department,
    String? year,
    List<String>? interests,
    List<String>? skills,
  }) async {
    try {
      if (_user == null) return false;

      _isLoading = true;
      notifyListeners();

      Map<String, dynamic> updates = {};
      
      if (name != null) {
        updates['name'] = name;
        await _user!.updateDisplayName(name);
      }
      if (bio != null) updates['bio'] = bio;
      if (department != null) updates['department'] = department;
      if (year != null) updates['year'] = year;
      if (interests != null) updates['interests'] = interests;
      if (skills != null) updates['skills'] = skills;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_user!.uid).update(updates);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
