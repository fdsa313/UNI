import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 테스트용 서버 URL
  static const String baseUrl = 'http://localhost:3000/api';
  
  // 로그인 API
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('로그인 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 회원가입 API
  static Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('회원가입 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 사용자 정보 조회 API
  static Future<Map<String, dynamic>> getUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('사용자 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 약물 정보 조회 API
  static Future<List<Map<String, dynamic>>> getMedicines(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/medicines'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('약물 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 테스트용 더미 데이터 반환 (서버가 없을 때 사용)
  static Future<Map<String, dynamic>> loginTest(String email, String password) async {
    // 실제 서버 대신 시뮬레이션
    await Future.delayed(Duration(seconds: 1));
    
    if (email == 'test@test.com' && password == '123456') {
      return {
        'success': true,
        'token': 'dummy_token_12345',
        'user': {
          'id': '1',
          'email': email,
          'name': '테스트 사용자',
        }
      };
    } else {
      throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
    }
  }
}
