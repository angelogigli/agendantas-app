import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _api = ApiService();

  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkSession() async {
    try {
      // Prima prova auto-login con credenziali salvate
      final autoLoginSuccess = await _api.tryAutoLogin();

      if (autoLoginSuccess) {
        _isLoggedIn = true;
        await _loadProfile();
      } else {
        // Se auto-login fallisce, verifica sessione esistente
        final prefs = await SharedPreferences.getInstance();
        final hasSession = prefs.getBool('hasSession') ?? false;

        if (hasSession) {
          try {
            final result = await _api.checkSession();
            if (result['success'] == true) {
              _isLoggedIn = true;
              await _loadProfile();
            } else {
              await _clearSession();
            }
          } catch (e) {
            debugPrint('API check session error: $e');
            await _clearSession();
          }
        }
      }
    } catch (e) {
      debugPrint('Check session error: $e');
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final result = await _api.login(username, password);

      if (result['success'] == true) {
        _isLoggedIn = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSession', true);

        await _loadProfile();
      }

      notifyListeners();
      return result;
    } catch (e) {
      notifyListeners();
      return {'success': false, 'message': 'Errore: $e'};
    }
  }

  Future<void> _loadProfile() async {
    try {
      _currentUser = await _api.getProfile();
    } catch (e) {
      debugPrint('Load profile error: $e');
    }
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    await _clearSession();
  }

  Future<void> _clearSession() async {
    _isLoggedIn = false;
    _currentUser = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSession', false);
    } catch (e) {
      debugPrint('Clear session error: $e');
    }
  }
}
