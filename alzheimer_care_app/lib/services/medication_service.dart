import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MedicationService {
  static const String _medicationKey = 'medication_records';
  
  // 약물 복용 기록 저장
  static Future<bool> saveMedicationRecord(String patientName, String time, DateTime takenAt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 기존 기록 가져오기
      final existingData = prefs.getString(_medicationKey);
      Map<String, dynamic> allRecords = {};
      
      if (existingData != null) {
        allRecords = Map<String, dynamic>.from(jsonDecode(existingData));
      }
      
      // 환자별 기록 가져오기
      List<Map<String, dynamic>> patientRecords = [];
      if (allRecords.containsKey(patientName)) {
        patientRecords = List<Map<String, dynamic>>.from(allRecords[patientName]);
      }
      
      // 오늘 날짜 문자열 (YYYY-MM-DD)
      final today = takenAt.toIso8601String().substring(0, 10);
      
      // 오늘 기록 찾기
      Map<String, dynamic>? todayRecord;
      int todayIndex = -1;
      
      for (int i = 0; i < patientRecords.length; i++) {
        if (patientRecords[i]['date'] == today) {
          todayRecord = Map<String, dynamic>.from(patientRecords[i]);
          todayIndex = i;
          break;
        }
      }
      
      if (todayRecord != null) {
        // 오늘 기록이 있으면 해당 시간 업데이트
        todayRecord[time] = true;
        todayRecord['updated_at'] = takenAt.toIso8601String();
        
        if (todayIndex >= 0) {
          patientRecords[todayIndex] = todayRecord;
        }
      } else {
        // 오늘 기록이 없으면 새로 생성
        todayRecord = {
          'date': today,
          '아침': time == '아침',
          '점심': time == '점심',
          '저녁': time == '저녁',
          'created_at': takenAt.toIso8601String(),
          'updated_at': takenAt.toIso8601String(),
        };
        patientRecords.add(todayRecord);
      }
      
      // 환자 기록 업데이트
      allRecords[patientName] = patientRecords;
      
      // SharedPreferences에 저장
      await prefs.setString(_medicationKey, jsonEncode(allRecords));
      
      print('✅ 약물 복용 기록 저장 성공: $patientName - $time - $today');
      return true;
    } catch (e) {
      print('❌ 약물 복용 기록 저장 실패: $e');
      return false;
    }
  }
  
  // 약물 복용 상태 조회
  static Future<Map<String, dynamic>?> getMedicationStatus(String patientName, String date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 저장된 기록 가져오기
      final existingData = prefs.getString(_medicationKey);
      if (existingData == null) return null;
      
      Map<String, dynamic> allRecords = Map<String, dynamic>.from(jsonDecode(existingData));
      
      // 환자별 기록 가져오기
      if (!allRecords.containsKey(patientName)) return null;
      
      List<Map<String, dynamic>> patientRecords = List<Map<String, dynamic>>.from(allRecords[patientName]);
      
      // 해당 날짜의 기록 찾기
      for (var record in patientRecords) {
        if (record['date'] == date) {
          return {
            'morning': record['아침'] ?? false,
            'lunch': record['점심'] ?? false,
            'evening': record['저녁'] ?? false,
            'date': record['date'],
            'created_at': record['created_at'],
            'updated_at': record['updated_at'],
          };
        }
      }
      
      return null;
    } catch (e) {
      print('❌ 약물 복용 상태 조회 실패: $e');
      return null;
    }
  }
  
  // 환자의 모든 복용 기록 가져오기
  static Future<List<Map<String, dynamic>>> getAllMedicationRecords(String patientName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 저장된 기록 가져오기
      final existingData = prefs.getString(_medicationKey);
      if (existingData == null) return [];
      
      Map<String, dynamic> allRecords = Map<String, dynamic>.from(jsonDecode(existingData));
      
      // 환자별 기록 가져오기
      if (!allRecords.containsKey(patientName)) return [];
      
      List<Map<String, dynamic>> patientRecords = List<Map<String, dynamic>>.from(allRecords[patientName]);
      
      // 날짜순으로 정렬 (최신순)
      patientRecords.sort((a, b) => b['date'].compareTo(a['date']));
      
      return patientRecords;
    } catch (e) {
      print('❌ 모든 복용 기록 조회 실패: $e');
      return [];
    }
  }
  
  // 복용 기록 삭제 (테스트용)
  static Future<void> clearAllRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_medicationKey);
      print('✅ 모든 복용 기록 삭제 완료');
    } catch (e) {
      print('❌ 복용 기록 삭제 실패: $e');
    }
  }

  // saveMedicationLog 메서드 추가 (API 호환성을 위해)
  static Future<bool> saveMedicationLog(String patientName, String time) async {
    try {
      // 한국어 시간을 영어 키로 변환
      String timeKey = '';
      if (time == 'morning') {
        timeKey = '아침';
      } else if (time == 'lunch') {
        timeKey = '점심';
      } else if (time == 'evening') {
        timeKey = '저녁';
      }
      
      // saveMedicationRecord 호출
      return await saveMedicationRecord(patientName, timeKey, DateTime.now());
    } catch (e) {
      print('❌ saveMedicationLog 실패: $e');
      return false;
    }
  }
}
