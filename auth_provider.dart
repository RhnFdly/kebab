import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        // Load user profile from Firestore
        final userProfile =
            await _firestoreService.getUserProfile(firebaseUser.uid);
        if (userProfile != null) {
          _user = userProfile;
        } else {
          // Create user profile if doesn't exist
          _user = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName,
            phoneNumber: firebaseUser.phoneNumber,
            photoUrl: firebaseUser.photoURL,
          );
          await _firestoreService.saveUserProfile(_user!);
        }
      } else {
        _user = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Add timeout to prevent infinite loading
      final userModel = await _authService
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Login request timed out. Please check your internet connection.');
            },
          );

      if (userModel != null) {
        // Load profile from Firestore
        final profile = await _firestoreService
            .getUserProfile(userModel.uid)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => null,
            );
        _user = profile ?? userModel;
        return true;
      }
      _errorMessage = 'Login failed: Invalid credentials';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Add timeout to prevent infinite loading
      final userModel = await _authService
          .registerWithEmailAndPassword(
            email: email,
            password: password,
            displayName: displayName,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Registration request timed out. Please check your internet connection.');
            },
          );

      if (userModel != null) {
        // Save profile to Firestore
        await _firestoreService
            .saveUserProfile(userModel)
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                throw Exception('Failed to save profile. Please try again.');
              },
            );
        _user = userModel;
        return true;
      }
      _errorMessage = 'Registration failed';
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      if (_user == null) return false;

      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (address != null) updates['address'] = address;

      await _firestoreService.updateUserProfile(_user!.uid, updates);
      
      // Update display name in Firebase Auth
      if (displayName != null) {
        await _authService.updateProfile(displayName: displayName);
      }

      // Reload user
      final updatedUser = await _firestoreService.getUserProfile(_user!.uid);
      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
