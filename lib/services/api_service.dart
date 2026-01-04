import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  // Base URL del server
  static const String baseUrl = 'https://agenda.antasonlus.org/new/handlers/';
  static const String avatarUrl = 'https://agenda.antasonlus.org/new/avatar/';
  static const String photoUrl = 'https://agenda.antasonlus.org/new/photo/';

  // Ottiene URL foto: prima prova avatar/, poi photo/nomeclown.jpg
  static String getPhotoUrl(String? foto, String? nomeclown) {
    if (foto != null && foto.isNotEmpty) {
      return '$avatarUrl$foto';
    }
    if (nomeclown != null && nomeclown.isNotEmpty) {
      return '$photoUrl$nomeclown.jpg';
    }
    return '';
  }

  // Cookie di sessione
  String? _sessionCookie;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Headers comuni
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    if (_sessionCookie != null) {
      headers['Cookie'] = _sessionCookie!;
    }
    return headers;
  }

  // Estrai e salva cookie dalla risposta
  void _extractCookies(http.Response response) {
    final cookies = response.headers['set-cookie'];
    if (cookies != null) {
      _sessionCookie = cookies.split(';').first;
    }
  }

  // Salva credenziali per login automatico
  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_username', username);
    await prefs.setString('saved_password', password);
  }

  // Cancella credenziali salvate
  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
  }

  // Tenta login automatico con credenziali salvate
  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('saved_username');
      final password = prefs.getString('saved_password');

      if (username != null && password != null) {
        final result = await login(username, password, saveCredentials: false);
        return result['success'] == true;
      }
    } catch (e) {
      debugPrint('Auto login error: $e');
    }
    return false;
  }

  // Chiamata API generica POST
  Future<Map<String, dynamic>> _post(String handler, String action, [Map<String, String>? data]) async {
    try {
      final uri = Uri.parse('$baseUrl$handler?action=$action');
      final response = await http.post(
        uri,
        headers: _headers,
        body: data,
      );

      _extractCookies(response);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Errore HTTP: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  // Chiamata API generica GET
  Future<Map<String, dynamic>> _get(String handler, String action, [Map<String, String>? params]) async {
    try {
      var url = '$baseUrl$handler?action=$action';
      if (params != null) {
        params.forEach((key, value) {
          url += '&$key=$value';
        });
      }

      final uri = Uri.parse(url);
      final response = await http.get(uri, headers: _headers);

      _extractCookies(response);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Errore HTTP: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Errore di connessione: $e'};
    }
  }

  // ==================== AUTH ====================

  Future<Map<String, dynamic>> login(String username, String password, {bool saveCredentials = true}) async {
    final result = await _post('Auth.ashx', 'login', {
      'username': username,
      'password': password,
    });

    // Salva credenziali se login riuscito
    if (result['success'] == true && saveCredentials) {
      await _saveCredentials(username, password);
    }

    return result;
  }

  Future<Map<String, dynamic>> logout() async {
    final result = await _post('Auth.ashx', 'logout');
    _sessionCookie = null;
    await _clearCredentials();
    return result;
  }

  Future<Map<String, dynamic>> checkSession() async {
    return await _get('Auth.ashx', 'check');
  }

  // ==================== ACTIVITIES ====================

  Future<Map<String, dynamic>> getUpcomingActivities() async {
    return await _get('Activities.ashx', 'upcoming');
  }

  Future<DashboardStats?> getStats() async {
    final result = await _get('Activities.ashx', 'stats');
    if (result['success'] == true) {
      return DashboardStats.fromJson(result);
    }
    return null;
  }

  Future<Map<String, dynamic>> getServices(int year) async {
    return await _get('Activities.ashx', 'services', {'year': year.toString()});
  }

  Future<Map<String, dynamic>> getWorkshops(int year) async {
    return await _get('Activities.ashx', 'workshops', {'year': year.toString()});
  }

  Future<Map<String, dynamic>> getActivityDetail(int id) async {
    return await _get('Activities.ashx', 'detail', {'id': id.toString()});
  }

  // ==================== BOOKINGS ====================

  Future<Map<String, dynamic>> createBooking(int activityId) async {
    return await _post('Bookings.ashx', 'create', {
      'activityId': activityId.toString(),
    });
  }

  Future<Map<String, dynamic>> deleteBooking(int activityId) async {
    return await _post('Bookings.ashx', 'delete', {
      'activityId': activityId.toString(),
    });
  }

  // ==================== MESSAGES ====================

  Future<List<Message>> getInbox() async {
    final result = await _get('Messages.ashx', 'inbox');
    if (result['success'] == true && result['items'] != null) {
      return (result['items'] as List)
          .map((m) => Message.fromJson(m))
          .toList();
    }
    return [];
  }

  Future<List<Message>> getSentMessages() async {
    final result = await _get('Messages.ashx', 'sent');
    if (result['success'] == true && result['items'] != null) {
      return (result['items'] as List)
          .map((m) => Message.fromJson(m))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> sendMessage(String toId, String message) async {
    return await _post('Messages.ashx', 'send', {
      'toId': toId,
      'message': message,
    });
  }

  Future<Map<String, dynamic>> markAsRead(int messageId) async {
    return await _post('Messages.ashx', 'read', {
      'messageId': messageId.toString(),
    });
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    return await _post('Messages.ashx', 'markallread');
  }

  Future<int> getUnreadCount() async {
    final result = await _get('Messages.ashx', 'count');
    if (result['success'] == true) {
      return result['count'] ?? 0;
    }
    return 0;
  }

  Future<List<Contact>> getContacts() async {
    final result = await _get('Messages.ashx', 'contacts');
    if (result['success'] == true && result['items'] != null) {
      return (result['items'] as List)
          .map((c) => Contact.fromJson(c))
          .toList();
    }
    return [];
  }

  // ==================== PROFILE ====================

  Future<User?> getProfile() async {
    final result = await _get('Profile.ashx', 'get');
    if (result['success'] == true && result['profile'] != null) {
      return User.fromJson(result['profile']);
    }
    return null;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, String> data) async {
    return await _post('Profile.ashx', 'update', data);
  }

  Future<Map<String, dynamic>> changePassword(String oldPassword, String newPassword) async {
    return await _post('Profile.ashx', 'password', {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  Future<Map<String, dynamic>> acceptRules() async {
    return await _post('Profile.ashx', 'acceptrules');
  }

  // ==================== STATS ====================

  Future<Map<String, dynamic>> getPersonalStats() async {
    return await _get('Stats.ashx', 'personal');
  }

  Future<Map<String, dynamic>> getYearlyStats(int year) async {
    return await _get('Stats.ashx', 'yearly', {'year': year.toString()});
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    return await _get('Stats.ashx', 'global');
  }

  Future<Map<String, dynamic>> getGlobalYearlyStats(int year) async {
    return await _get('Stats.ashx', 'globalyearly', {'year': year.toString()});
  }

  // ==================== NOTIFICATIONS ====================

  Future<Map<String, dynamic>> getNotifications() async {
    return await _get('Notifications.ashx', 'get');
  }
}
