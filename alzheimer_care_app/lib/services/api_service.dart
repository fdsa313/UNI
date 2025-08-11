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

  // 사용자 데이터 저장 (로컬)
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(userData));
  }

  // 사용자 데이터 조회 (로컬)
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // 환자 데이터 저장 API
  static Future<bool> savePatientData(String patientName, Map<String, dynamic> patientData) async {
    try {
      print('환자 데이터 저장 시도: $patientName');
      
      final response = await http.post(
        Uri.parse('$baseUrl/patients/$patientName/data'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patientData),
      );

      print('환자 데이터 저장 응답: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        print('환자 데이터 저장 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('환자 데이터 저장 오류: $e');
      return false;
    }
  }

  // 환자 데이터 조회 API
  static Future<Map<String, dynamic>?> getPatientData(String patientName) async {
    try {
      print('환자 데이터 조회 시도: $patientName');
      
      final response = await http.get(
        Uri.parse('$baseUrl/patients/$patientName/data'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('환자 데이터 조회 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        }
      } else if (response.statusCode == 404) {
        print('환자 데이터를 찾을 수 없음: $patientName');
        return null;
      } else {
        print('환자 데이터 조회 실패: ${response.statusCode}');
      }
      
      return null;
    } catch (e) {
      print('환자 데이터 조회 오류: $e');
      return null;
    }
  }

  // 퀴즈 결과 저장 API
  static Future<bool> saveQuizResult(String patientName, Map<String, dynamic> quizData) async {
    try {
      print('퀴즈 결과 저장 시도: $patientName');
      
      final response = await http.post(
        Uri.parse('$baseUrl/patients/$patientName/quiz'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(quizData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        print('퀴즈 결과 저장 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('퀴즈 결과 저장 오류: $e');
      return false;
    }
  }

  // 약물 복용 기록 저장 API
  static Future<bool> saveMedicationLog(String patientName, Map<String, dynamic> medicationData) async {
    try {
      print('약물 복용 기록 저장 시도: $patientName');
      
      final response = await http.post(
        Uri.parse('$baseUrl/patients/$patientName/medication'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(medicationData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        print('약물 복용 기록 저장 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('약물 복용 기록 저장 오류: $e');
      return false;
    }
  }

  // 약물 복용 기록 조회 API
  static Future<Map<String, dynamic>?> getMedicationLog(String patientName, String date) async {
    try {
      print('약물 복용 기록 조회 시도: $patientName, $date');
      
      final response = await http.get(
        Uri.parse('$baseUrl/patients/$patientName/medication/$date'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'];
        }
      } else if (response.statusCode == 404) {
        print('약물 복용 기록을 찾을 수 없음: $patientName, $date');
        return null;
      } else {
        print('약물 복용 기록 조회 실패: ${response.statusCode}');
      }
      
      return null;
    } catch (e) {
      print('약물 복용 기록 조회 오류: $e');
      return null;
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

  // 담당의사 번호 저장
  static Future<bool> saveDoctorPhone(String doctorPhone) async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        userData['doctorPhone'] = doctorPhone;
        await _saveUserData(userData);
        return true;
      }
      return false;
    } catch (e) {
      print('담당의사 번호 저장 실패: $e');
      return false;
    }
  }

  // 긴급 연락처 저장
  static Future<bool> saveEmergencyContacts(List<Map<String, String>> contacts) async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        userData['emergencyContacts'] = contacts;
        await _saveUserData(userData);
        return true;
      }
      return false;
    } catch (e) {
      print('긴급 연락처 저장 실패: $e');
      return false;
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
