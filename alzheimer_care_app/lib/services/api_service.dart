import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 실제 서버 URL (MCP 설정에서 연결한 서버)
  static const String baseUrl = 'http://127.0.0.1:3000/api';
  
  // 로그인 API
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('로그인 시도: $email'); // 디버그 로그
      print('API URL: $baseUrl/auth/login'); // 디버그 로그
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('응답 상태 코드: ${response.statusCode}'); // 디버그 로그
      print('응답 본문: ${response.body}'); // 디버그 로그

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // 로그인 성공 시 사용자 정보를 로컬에 저장
        if (data['success']) {
          await _saveUserData(data['data']['user']);
        }
        
        return data;
      } else {
        return {
          'success': false,
          'message': '로그인에 실패했습니다. (상태 코드: ${response.statusCode})',
        };
      }
    } catch (e) {
      print('로그인 오류: $e'); // 디버그 로그
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  // 회원가입 API
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String patientPhone,
    required String caregiverPhone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'patientPhone': patientPhone,
          'caregiverPhone': caregiverPhone,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // 회원가입 성공 시 사용자 정보를 로컬에 저장
        if (data['success']) {
          await _saveUserData(data['data']['user']);
        }
        
        return data;
      } else {
        return {
          'success': false,
          'message': '회원가입에 실패했습니다.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다.',
      };
    }
  }

  // 사용자 정보 가져오기
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 사용자 정보 저장
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData));
    } catch (e) {
      print('사용자 데이터 저장 실패: $e');
    }
  }

  // 로그아웃
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
    } catch (e) {
      print('로그아웃 실패: $e');
    }
  }

  // 약물 정보 가져오기
  static Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medications'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['medications']);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // 약물 정보 저장
  static Future<bool> saveMedication(Map<String, dynamic> medication) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medications'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(medication),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 복용 기록 저장
  static Future<bool> saveMedicationLog(String medicationId, String time) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/medication-logs'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'medicationId': medicationId,
          'time': time,
          'takenAt': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 기분 기록 저장
  static Future<bool> saveMood(String mood) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/moods'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mood': mood,
          'recordedAt': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
