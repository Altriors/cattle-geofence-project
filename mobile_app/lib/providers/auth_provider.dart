import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    AuthService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<String?> signIn(String email, String password) async {
    _setLoading(true);
    final error = await AuthService.signIn(email, password);
    _setLoading(false);
    return error;
  }

  Future<String?> signUp(String email, String password, String name) async {
    _setLoading(true);
    final error = await AuthService.signUp(email, password, name);
    _setLoading(false);
    return error;
  }

  Future<void> signOut() async {
    await AuthService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}