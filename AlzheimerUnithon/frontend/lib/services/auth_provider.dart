import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _user != null;

  // 토큰 저장
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    _token = token;
  }

  // 토큰 로드
  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  // 토큰 삭제
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
  }

  // 초기화
  Future<void> initialize() async {
    await _loadToken();
    if (_token != null) {
      await _loadCurrentUser();
    }
  }

  // 현재 사용자 정보 로드
  Future<void> _loadCurrentUser() async {
    if (_token == null) return;

    final result = await ApiService.getCurrentUser(_token!);
    if (result['success']) {
      _user = User.fromJson(result['data']['user']);
      notifyListeners();
    } else {
      await logout();
    }
  }

  // 로그인
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        _user = User.fromJson(result['data']['user']);
        await _saveToken(result['data']['token']);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': '로그인 중 오류가 발생했습니다.',
      };
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.register(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );

      if (result['success']) {
        _user = User.fromJson(result['data']['user']);
        await _saveToken(result['data']['token']);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': '회원가입 중 오류가 발생했습니다.',
      };
    }
  }

  // 로그아웃
  Future<void> logout() async {
    if (_token != null) {
      await ApiService.logout(_token!);
    }
    
    _user = null;
    await _removeToken();
    notifyListeners();
  }
}
