import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // 로컬에서 사용자 정보 가져오기
  static Future<Map<String, String>?> _getLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('supabase_user_id');
      final userEmail = prefs.getString('supabase_user_email');
      
      if (userId != null && userEmail != null) {
        return {
          'id': userId,
          'email': userEmail,
        };
      }
      return null;
    } catch (e) {
      print('❌ 로컬 사용자 데이터 가져오기 오류: $e');
      return null;
    }
  }

  // 보호자 비밀번호 설정
  static Future<bool> setCaregiverPassword(String password) async {
    try {
      print('=== 보호자 비밀번호 설정 시작 ===');
      print('비밀번호 길이: ${password.length}');
      
      // 먼저 Supabase Auth에서 현재 사용자 확인
      var user = _supabase.auth.currentUser;
      print('Supabase Auth 사용자: ${user?.id}');
      
      // Supabase Auth에 사용자가 없으면 로컬 데이터 사용
      if (user == null) {
        print('Supabase Auth에 사용자가 없음, 로컬 데이터 확인 중...');
        final localUser = await _getLocalUserData();
        if (localUser != null) {
          print('✅ 로컬 사용자 데이터 발견: ${localUser['email']}');
          // 로컬 사용자 ID를 사용하여 계속 진행
          user = _createMockUser(localUser['id']!, localUser['email']!);
        } else {
          print('❌ 로컬 사용자 데이터도 없음');
          return false;
        }
      }
      
      final userId = user!.id;
      print('✅ 사용자 ID: $userId');

      // 비밀번호를 해시화 (실제로는 더 안전한 방법 사용)
      final passwordHash = password; // 간단한 예시
      print('비밀번호 해시: $passwordHash');

      // 먼저 Supabase에 저장 시도 (영구 저장)
      print('Supabase에 보호자 비밀번호 저장 시도 중...');
      bool supabaseSuccess = false;
      
      try {
        // users 테이블에 직접 저장 시도
        final response = await _supabase
            .from('users')
            .update({
              'caregiver_password': passwordHash,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);

        print('✅ Supabase에 보호자 비밀번호 저장 성공: $response');
        supabaseSuccess = true;
      } catch (e) {
        print('❌ Supabase 저장 실패: $e');
        
        // 다른 방법 시도: insert로 새로 생성
        try {
          print('Supabase insert 방식으로 재시도...');
          final response = await _supabase
              .from('users')
              .upsert({
                'id': userId,
                'caregiver_password': passwordHash,
                'updated_at': DateTime.now().toIso8601String(),
              });

          print('✅ Supabase insert 성공: $response');
          supabaseSuccess = true;
        } catch (e2) {
          print('❌ Supabase insert도 실패: $e2');
        }
      }

      // 로컬에도 백업 저장 (항상)
      final localSuccess = await _saveCaregiverPasswordLocally(userId, passwordHash);
      
      if (localSuccess) {
        print('✅ 로컬 백업 저장 성공');
      }

      return supabaseSuccess || localSuccess;
    } catch (e, stackTrace) {
      print('❌ 보호자 비밀번호 설정 오류: $e');
      print('스택 트레이스: $stackTrace');
      return false;
    }
  }

  // 로컬에 보호자 비밀번호 저장 (영구 저장)
  static Future<bool> _saveCaregiverPasswordLocally(String userId, String passwordHash) async {
    try {
      // SharedPreferences 사용
      final prefs = await SharedPreferences.getInstance();
      final key = 'caregiver_password_$userId';
      await prefs.setString(key, passwordHash);
      
      print('✅ SharedPreferences 영구 저장 성공: $key');
      return true;
    } catch (e) {
      print('❌ 로컬 비밀번호 저장 오류: $e');
      return false;
    }
  }

  // 로컬에서 보호자 비밀번호 가져오기 (영구 저장)
  static Future<String?> _getCaregiverPasswordLocally(String userId) async {
    try {
      // SharedPreferences 사용
      final prefs = await SharedPreferences.getInstance();
      final key = 'caregiver_password_$userId';
      final password = prefs.getString(key);
      
      if (password != null) {
        print('✅ SharedPreferences에서 비밀번호 로드 성공: $key');
      } else {
        print('❌ SharedPreferences에 저장된 비밀번호 없음: $key');
      }
      
      return password;
    } catch (e) {
      print('❌ 로컬 비밀번호 가져오기 오류: $e');
      return null;
    }
  }

  // 모든 사용자의 보호자 비밀번호 확인 (디버깅용)
  static Future<void> _debugLocalPasswords() async {
    try {
      print('=== 로컬 저장된 보호자 비밀번호 키들 ===');
      
      // SharedPreferences 사용
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final passwordKeys = keys.where((key) => key.startsWith('caregiver_password_')).toList();
      
      for (final key in passwordKeys) {
        final hasPassword = prefs.getString(key) != null;
        print('SharedPreferences - $key: ${hasPassword ? "저장됨" : "없음"}');
      }
    } catch (e) {
      print('❌ 디버그 정보 가져오기 오류: $e');
    }
  }

  // Mock 사용자 생성 (로컬 데이터 사용 시)
  static User _createMockUser(String id, String email) {
    return User(
      id: id,
      email: email,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
    );
  }

  // 보호자 비밀번호 확인
  static Future<bool> verifyCaregiverPassword(String password) async {
    try {
      print('=== 보호자 비밀번호 확인 시작 ===');
      
      // 먼저 Supabase Auth에서 현재 사용자 확인
      var user = _supabase.auth.currentUser;
      print('Supabase Auth 사용자: ${user?.id}');
      
      // Supabase Auth에 사용자가 없으면 로컬 데이터 사용
      if (user == null) {
        print('Supabase Auth에 사용자가 없음, 로컬 데이터 확인 중...');
        final localUser = await _getLocalUserData();
        if (localUser != null) {
          print('✅ 로컬 사용자 데이터 발견: ${localUser['email']}');
          user = _createMockUser(localUser['id']!, localUser['email']!);
        } else {
          print('❌ 로컬 사용자 데이터도 없음');
          return false;
        }
      }
      
      final userId = user!.id;
      print('사용자 ID: $userId');

      // 먼저 Supabase에서 확인 시도
      try {
        final result = await _supabase
            .from('users')
            .select('caregiver_password')
            .eq('id', userId)
            .maybeSingle();

        print('Supabase 비밀번호 확인 결과: $result');

        if (result != null && result['caregiver_password'] != null) {
          final isValid = result['caregiver_password'] == password;
          print('Supabase 비밀번호 일치 여부: $isValid');
          return isValid;
        }
      } catch (e) {
        print('❌ Supabase 비밀번호 확인 실패, 로컬 확인으로 전환: $e');
      }

      // Supabase 실패 시 로컬에서 확인
      print('로컬에서 보호자 비밀번호 확인 중...');
      final localPassword = await _getCaregiverPasswordLocally(userId);
      if (localPassword != null) {
        final isValid = localPassword == password;
        print('로컬 비밀번호 일치 여부: $isValid');
        return isValid;
      }

      print('❌ 저장된 보호자 비밀번호가 없음');
      return false;
    } catch (e) {
      print('❌ 보호자 비밀번호 확인 오류: $e');
      return false;
    }
  }

  // 보호자 비밀번호 존재 여부 확인
  static Future<bool> hasCaregiverPassword() async {
    try {
      print('=== 보호자 비밀번호 존재 여부 확인 ===');
      
      // 먼저 Supabase Auth에서 현재 사용자 확인
      var user = _supabase.auth.currentUser;
      print('Supabase Auth 사용자: ${user?.id}');
      
      // Supabase Auth에 사용자가 없으면 로컬 데이터 사용
      if (user == null) {
        print('Supabase Auth에 사용자가 없음, 로컬 데이터 확인 중...');
        final localUser = await _getLocalUserData();
        if (localUser != null) {
          print('✅ 로컬 사용자 데이터 발견: ${localUser['email']}');
          user = _createMockUser(localUser['id']!, localUser['email']!);
        } else {
          print('❌ 로컬 사용자 데이터도 없음');
          return false;
        }
      }
      
      final userId = user!.id;
      print('사용자 ID: $userId');

      // 먼저 Supabase에서 확인 시도
      try {
        final result = await _supabase
            .from('users')
            .select('caregiver_password')
            .eq('id', userId)
            .maybeSingle();

        print('Supabase 비밀번호 확인 결과: $result');

        if (result != null && result['caregiver_password'] != null) {
          print('✅ Supabase에서 보호자 비밀번호 발견');
          return true;
        }
      } catch (e) {
        print('❌ Supabase 확인 실패, 로컬 확인으로 전환: $e');
      }

      // Supabase 실패 시 로컬에서 확인
      print('로컬에서 보호자 비밀번호 확인 중...');
      final localPassword = await _getCaregiverPasswordLocally(userId);
      if (localPassword != null) {
        print('✅ 로컬에 보호자 비밀번호 존재');
        return true;
      }

      print('❌ 저장된 보호자 비밀번호가 없음');
      return false;
    } catch (e) {
      print('❌ 보호자 비밀번호 존재 여부 확인 오류: $e');
      return false;
    }
  }

  // 보호자 비밀번호 삭제
  static Future<bool> deleteCaregiverPassword() async {
    try {
      print('=== 보호자 비밀번호 삭제 시작 ===');
      
      // 먼저 Supabase Auth에서 현재 사용자 확인
      var user = _supabase.auth.currentUser;
      print('Supabase Auth 사용자: ${user?.id}');
      
      // Supabase Auth에 사용자가 없으면 로컬 데이터 사용
      if (user == null) {
        print('Supabase Auth에 사용자가 없음, 로컬 데이터 확인 중...');
        final localUser = await _getLocalUserData();
        if (localUser != null) {
          print('✅ 로컬 사용자 데이터 발견: ${localUser['email']}');
          user = _createMockUser(localUser['id']!, localUser['email']!);
        } else {
          print('❌ 로컬 사용자 데이터도 없음');
          return false;
        }
      }
      
      final userId = user!.id;
      print('사용자 ID: $userId');

      // 먼저 Supabase에서 삭제 시도
      try {
        final response = await _supabase
            .from('users')
            .update({
              'caregiver_password': null,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', userId);

        print('✅ Supabase에서 보호자 비밀번호 삭제 완료: $response');
      } catch (e) {
        print('❌ Supabase 삭제 실패, 로컬 삭제로 전환: $e');
      }

      // 로컬에서도 삭제
      try {
        final prefs = await SharedPreferences.getInstance();
        final key = 'caregiver_password_$userId';
        await prefs.remove(key);
        print('✅ SharedPreferences에서 보호자 비밀번호 삭제 완료');
      } catch (e) {
        print('❌ 로컬 삭제 실패: $e');
      }

      return true;
    } catch (e) {
      print('❌ 보호자 비밀번호 삭제 오류: $e');
      return false;
    }
  }

  // Supabase 연결 상태 확인
  static bool isConnected() {
    try {
      final client = Supabase.instance.client;
      return client != null;
    } catch (e) {
      print('❌ Supabase 클라이언트 연결 오류: $e');
      return false;
    }
  }

  // 현재 사용자 정보 가져오기
  static Future<User?> getCurrentUser() async {
    try {
      var user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        // 로컬 데이터에서 사용자 정보 가져오기
        final localUser = await _getLocalUserData();
        if (localUser != null) {
          return _createMockUser(localUser['id']!, localUser['email']!);
        }
      }
      return user;
    } catch (e) {
      print('❌ 현재 사용자 정보 가져오기 오류: $e');
      return null;
    }
  }
}
