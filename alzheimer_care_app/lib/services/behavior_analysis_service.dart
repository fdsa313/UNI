import 'dart:math' as math;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class BehaviorAnalysisService {
  static final BehaviorAnalysisService _instance = BehaviorAnalysisService._internal();
  factory BehaviorAnalysisService() => _instance;
  BehaviorAnalysisService._internal();

  static const String _locationDataKey = 'location_history';
  static const String _behaviorPatternKey = 'behavior_pattern';
  static const String _safetyZoneKey = 'safety_zone';
  
  // 안전 반경 (미터 단위)
  static const double _safetyRadiusMeters = 2000.0; // 2km
  
  /// 위치 데이터 저장
  Future<void> saveLocationData(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': position.timestamp.millisecondsSinceEpoch,
        'accuracy': position.accuracy,
      };
      
      // 기존 데이터 가져오기
      List<String> existingData = prefs.getStringList(_locationDataKey) ?? [];
      
      // 새 데이터 추가 (최근 7일간의 데이터만 유지)
      existingData.add(jsonEncode(locationData));
      
      // 7일 이전 데이터 제거
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      existingData = existingData.where((data) {
        final location = jsonDecode(data);
        final timestamp = DateTime.fromMillisecondsSinceEpoch(location['timestamp']);
        return timestamp.isAfter(sevenDaysAgo);
      }).toList();
      
      // 최대 1000개 데이터 포인트로 제한
      if (existingData.length > 1000) {
        existingData = existingData.sublist(existingData.length - 1000);
      }
      
      await prefs.setStringList(_locationDataKey, existingData);
      print('📍 위치 데이터 저장 완료: ${existingData.length}개 포인트');
      
      // 행동 패턴 분석 및 업데이트
      await _analyzeBehaviorPattern();
      
    } catch (e) {
      print('❌ 위치 데이터 저장 오류: $e');
    }
  }
  
  /// 행동 패턴 분석
  Future<void> _analyzeBehaviorPattern() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationData = prefs.getStringList(_locationDataKey) ?? [];
      
      if (locationData.length < 10) {
        print('⚠️ 분석을 위한 충분한 데이터가 없습니다. (${locationData.length}개)');
        return;
      }
      
      // 위치 데이터 파싱
      final locations = locationData.map((data) {
        final location = jsonDecode(data);
        return {
          'latitude': location['latitude'] as double,
          'longitude': location['longitude'] as double,
          'timestamp': location['timestamp'] as int,
        };
      }).toList();
      
      // 중심점 계산 (평균 위치)
      double centerLat = 0.0;
      double centerLng = 0.0;
      
      for (var location in locations) {
        centerLat += (location['latitude'] as num).toDouble();
        centerLng += (location['longitude'] as num).toDouble();
      }
      
      centerLat /= locations.length;
      centerLng /= locations.length;
      
      // 행동 반경 계산 (95% 신뢰구간)
      List<double> distances = [];
      for (var location in locations) {
        final distance = _calculateDistance(
          centerLat, centerLng,
          (location['latitude'] as num).toDouble(), 
          (location['longitude'] as num).toDouble()
        );
        distances.add(distance);
      }
      
      // 거리 정렬 후 95% 신뢰구간 계산
      distances.sort();
      final confidenceIndex = (distances.length * 0.95).floor();
      final behaviorRadius = distances[confidenceIndex];
      
      // 시간대별 행동 패턴 분석
      final timePatterns = _analyzeTimePatterns(locations);
      
      // 행동 패턴 저장
      final behaviorPattern = {
        'centerLatitude': centerLat,
        'centerLongitude': centerLng,
        'behaviorRadius': behaviorRadius,
        'confidenceLevel': 0.95,
        'dataPoints': locations.length,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
        'timePatterns': timePatterns,
      };
      
      await prefs.setString(_behaviorPatternKey, jsonEncode(behaviorPattern));
      print('🧠 행동 패턴 분석 완료: 반경 ${behaviorRadius.toStringAsFixed(0)}m');
      
    } catch (e) {
      print('❌ 행동 패턴 분석 오류: $e');
    }
  }
  
  /// 시간대별 행동 패턴 분석
  Map<String, dynamic> _analyzeTimePatterns(List<Map<String, dynamic>> locations) {
    final timeSlots = {
      'morning': {'count': 0, 'totalDistance': 0.0},      // 06:00-12:00
      'afternoon': {'count': 0, 'totalDistance': 0.0},    // 12:00-18:00
      'evening': {'count': 0, 'totalDistance': 0.0},      // 18:00-22:00
      'night': {'count': 0, 'totalDistance': 0.0},        // 22:00-06:00
    };
    
    for (var location in locations) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(location['timestamp']);
      final hour = timestamp.hour;
      
      String timeSlot;
      if (hour >= 6 && hour < 12) {
        timeSlot = 'morning';
      } else if (hour >= 12 && hour < 18) {
        timeSlot = 'afternoon';
      } else if (hour >= 18 && hour < 22) {
        timeSlot = 'evening';
      } else {
        timeSlot = 'night';
      }
      
      final currentCount = timeSlots[timeSlot]!['count'] as int;
      timeSlots[timeSlot]!['count'] = currentCount + 1;
    }
    
    return timeSlots;
  }
  
  /// 현재 위치가 안전 반경 내에 있는지 확인
  Future<bool> isLocationSafe(Position currentPosition) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final behaviorPatternStr = prefs.getString(_behaviorPatternKey);
      
      if (behaviorPatternStr == null) {
        print('⚠️ 행동 패턴 데이터가 없습니다. 기본 안전 반경 사용');
        return true; // 데이터가 없으면 기본적으로 안전하다고 가정
      }
      
      final behaviorPattern = jsonDecode(behaviorPatternStr);
      final centerLat = behaviorPattern['centerLatitude'];
      final centerLng = behaviorPattern['centerLongitude'];
      final behaviorRadius = behaviorPattern['behaviorRadius'];
      
      // 현재 위치와 행동 반경 중심점 간의 거리 계산
      final distance = _calculateDistance(
        centerLat, centerLng,
        currentPosition.latitude, currentPosition.longitude
      );
      
      // 안전 반경과 행동 반경 중 더 큰 값 사용
      final safetyRadius = math.max(_safetyRadiusMeters, behaviorRadius);
      
      final isSafe = distance <= safetyRadius;
      
      if (!isSafe) {
        print('🚨 위험 위치 감지! 거리: ${distance.toStringAsFixed(0)}m, 안전 반경: ${safetyRadius.toStringAsFixed(0)}m');
        await _triggerDangerAlert(currentPosition, distance, safetyRadius);
      }
      
      return isSafe;
      
    } catch (e) {
      print('❌ 위치 안전성 확인 오류: $e');
      return true; // 오류 발생 시 기본적으로 안전하다고 가정
    }
  }
  
  /// 위험 알림 트리거
  Future<void> _triggerDangerAlert(Position position, double distance, double safetyRadius) async {
    try {
      // 위험 알림 데이터 저장
      final prefs = await SharedPreferences.getInstance();
      final alertData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'distance': distance,
        'safetyRadius': safetyRadius,
        'address': await _getAddressFromCoordinates(position),
      };
      
      final existingAlerts = prefs.getStringList('danger_alerts') ?? [];
      existingAlerts.add(jsonEncode(alertData));
      
      // 최근 100개 알림만 유지
      if (existingAlerts.length > 100) {
        existingAlerts.removeRange(0, existingAlerts.length - 100);
      }
      
      await prefs.setStringList('danger_alerts', existingAlerts);
      
      // 여기에 실제 알림 로직 추가 (푸시 알림, SMS, 이메일 등)
      print('🚨 위험 알림 저장 완료: ${existingAlerts.length}개');
      
    } catch (e) {
      print('❌ 위험 알림 저장 오류: $e');
    }
  }
  
  /// 좌표를 주소로 변환
  Future<String> _getAddressFromCoordinates(Position position) async {
    try {
      // 실제 구현에서는 geocoding 패키지 사용
      return '위도: ${position.latitude.toStringAsFixed(6)}, 경도: ${position.longitude.toStringAsFixed(6)}';
    } catch (e) {
      return '위치 정보 없음';
    }
  }
  
  /// 두 지점 간의 거리 계산 (미터 단위)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // 지구 반지름 (미터)
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
              math.sin(dLng / 2) * math.sin(dLng / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  /// 도를 라디안으로 변환
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
  
  /// 행동 패턴 데이터 가져오기
  Future<Map<String, dynamic>?> getBehaviorPattern() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final behaviorPatternStr = prefs.getString(_behaviorPatternKey);
      
      if (behaviorPatternStr != null) {
        return jsonDecode(behaviorPatternStr);
      }
      
      return null;
    } catch (e) {
      print('❌ 행동 패턴 데이터 가져오기 오류: $e');
      return null;
    }
  }
  
  /// 위험 알림 기록 가져오기
  Future<List<Map<String, dynamic>>> getDangerAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alerts = prefs.getStringList('danger_alerts') ?? [];
      
      return alerts.map((alert) => Map<String, dynamic>.from(jsonDecode(alert))).toList();
    } catch (e) {
      print('❌ 위험 알림 기록 가져오기 오류: $e');
      return [];
    }
  }
  
  /// 데이터 초기화 (테스트용)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_locationDataKey);
      await prefs.remove(_behaviorPatternKey);
      await prefs.remove('danger_alerts');
      print('🗑️ 모든 행동 분석 데이터가 초기화되었습니다.');
    } catch (e) {
      print('❌ 데이터 초기화 오류: $e');
    }
  }

  /// 테스트용 예시 데이터 생성
  Future<void> generateTestData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 숭실대학교 한경직 기념관을 중심으로 한 예시 위치 데이터
      final centerLat = 37.4965;
      final centerLng = 126.9570;
      final now = DateTime.now();
      
      List<String> testLocations = [];
      
      // 7일간의 다양한 시간대별 위치 데이터 생성
      for (int day = 6; day >= 0; day--) {
        final date = now.subtract(Duration(days: day));
        
        // 하루에 8-12개의 위치 데이터 생성
        final dailyPoints = 8 + (day % 5); // 8-12개
        
        for (int i = 0; i < dailyPoints; i++) {
          final hour = 6 + (i * 18 / dailyPoints).floor(); // 06:00 ~ 23:00
          final minute = (i * 60 / dailyPoints) % 60;
          
          // 중심점에서 랜덤하게 떨어진 위치 생성 (0-1500m 범위)
          final distance = (i * 1500 / dailyPoints).toDouble();
          final angle = (i * 2 * math.pi / dailyPoints);
          
          final offsetLat = distance * math.cos(angle) / 111000; // 위도 1도 ≈ 111km
          final offsetLng = distance * math.sin(angle) / (111000 * math.cos(centerLat * math.pi / 180));
          
          final testLat = centerLat + offsetLat;
          final testLng = centerLng + offsetLng;
          
          final timestamp = date.add(Duration(hours: hour, minutes: minute.toInt()));
          
          final locationData = {
            'latitude': testLat,
            'longitude': testLng,
            'timestamp': timestamp.millisecondsSinceEpoch,
            'accuracy': 5.0 + (i % 3) * 2.0, // 5-9m 정확도
          };
          
          testLocations.add(jsonEncode(locationData));
        }
      }
      
      // 테스트 데이터 저장
      await prefs.setStringList(_locationDataKey, testLocations);
      print('🧪 테스트 데이터 생성 완료: ${testLocations.length}개 위치 포인트');
      
      // 행동 패턴 분석 실행
      await _analyzeBehaviorPattern();
      
      // 테스트용 위험 알림도 생성
      await _generateTestAlerts();
      
    } catch (e) {
      print('❌ 테스트 데이터 생성 오류: $e');
    }
  }

  /// 테스트용 위험 알림 생성
  Future<void> _generateTestAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 숭실대학교에서 멀리 떨어진 위치들 (위험 위치)
      final dangerLocations = [
        {'lat': 37.5165, 'lng': 126.9570, 'distance': 2200, 'time': '오전 8시'},
        {'lat': 37.4765, 'lng': 126.9370, 'distance': 2500, 'time': '오후 2시'},
        {'lat': 37.4965, 'lng': 126.9770, 'distance': 1800, 'time': '저녁 7시'},
      ];
      
      List<String> testAlerts = [];
      
      for (int i = 0; i < dangerLocations.length; i++) {
        final location = dangerLocations[i];
        final alertTime = DateTime.now().subtract(Duration(days: i + 1, hours: i * 6));
        
        final alertData = {
          'timestamp': alertTime.millisecondsSinceEpoch,
          'latitude': location['lat'],
          'longitude': location['lng'],
          'distance': location['distance'],
          'safetyRadius': 2000,
          'address': '${location['time']} - 테스트 위험 위치',
        };
        
        testAlerts.add(jsonEncode(alertData));
      }
      
      await prefs.setStringList('danger_alerts', testAlerts);
      print('🚨 테스트 위험 알림 생성 완료: ${testAlerts.length}개');
      
    } catch (e) {
      print('❌ 테스트 위험 알림 생성 오류: $e');
    }
  }
}
