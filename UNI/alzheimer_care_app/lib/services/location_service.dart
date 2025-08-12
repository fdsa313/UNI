import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;
  Position? _lastKnownPosition;

  /// 위치 권한 요청
  Future<bool> requestLocationPermission() async {
    try {
      // 위치 권한 상태 확인
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // 권한 요청
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        // 권한이 영구적으로 거부됨
        return false;
      }
      
      return true;
    } catch (e) {
      print('❌ 위치 권한 요청 오류: $e');
      return false;
    }
  }

  /// 현재 위치 가져오기
  Future<Position?> getCurrentLocation() async {
    try {
      // 권한 확인
      if (!await requestLocationPermission()) {
        print('❌ 위치 권한이 없습니다.');
        return null;
      }

      // GPS 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ 위치 서비스가 비활성화되어 있습니다.');
        return null;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30), // 타임아웃을 30초로 증가
      );

      _lastKnownPosition = position;
      print('✅ 현재 위치 가져오기 성공: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ 현재 위치 가져오기 오류: $e');
      return null;
    }
  }

  /// 실시간 위치 추적 시작
  Future<void> startLocationTracking({
    required Function(Position) onLocationUpdate,
    Duration interval = const Duration(seconds: 30),
  }) async {
    try {
      // 권한 확인
      if (!await requestLocationPermission()) {
        print('❌ 위치 권한이 없습니다.');
        return;
      }

      // 기존 스트림 정리
      await stopLocationTracking();

      // 위치 추적 시작
      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // 10미터마다 업데이트
          timeLimit: Duration(seconds: interval.inSeconds),
        ),
      ).listen(
        (Position position) {
          _lastKnownPosition = position;
          onLocationUpdate(position);
          print('📍 위치 업데이트: ${position.latitude}, ${position.longitude}');
        },
        onError: (error) {
          print('❌ 위치 추적 오류: $error');
        },
      );

      print('✅ 위치 추적 시작됨');
    } catch (e) {
      print('❌ 위치 추적 시작 오류: $e');
    }
  }

  /// 위치 추적 중지
  Future<void> stopLocationTracking() async {
    try {
      await _positionStream?.cancel();
      _positionStream = null;
      print('✅ 위치 추적 중지됨');
    } catch (e) {
      print('❌ 위치 추적 중지 오류: $e');
    }
  }

  /// 좌표를 주소로 변환
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];
        
        // 도로명 주소 (가장 상세한 정보)
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          addressParts.add('도로: ${place.thoroughfare}');
        }
        
        // 건물명 또는 상세주소
        if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
          addressParts.add('건물: ${place.subThoroughfare}');
        }
        
        // 도로명
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add('도로명: ${place.street}');
        }
        
        // 동/읍/면
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add('${place.subLocality}');
        }
        
        // 시/군/구
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add('${place.locality}');
        }
        
        // 시/도
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add('${place.administrativeArea}');
        }
        
        if (addressParts.isNotEmpty) {
          return addressParts.join('\n');
        }
      }
      
      // 주소를 찾을 수 없는 경우 좌표로 대체
      return '위도: ${latitude.toStringAsFixed(6)}°\n경도: ${longitude.toStringAsFixed(6)}°';
    } catch (e) {
      print('❌ 주소 변환 오류: $e');
      // 오류 발생 시 좌표로 대체
      return '위도: ${latitude.toStringAsFixed(6)}°\n경도: ${longitude.toStringAsFixed(6)}°';
    }
  }

  /// 상세 주소 정보 가져오기 (건물명, 도로명 등)
  Future<Map<String, String>> getDetailedAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        Map<String, String> addressInfo = {};
        
        // 건물명
        if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
          addressInfo['건물명'] = place.subThoroughfare!;
        }
        
        // 도로명
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          addressInfo['도로명'] = place.thoroughfare!;
        }
        
        // 상세주소
        if (place.street != null && place.street!.isNotEmpty) {
          addressInfo['상세주소'] = place.street!;
        }
        
        // 동/읍/면
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressInfo['동/읍/면'] = place.subLocality!;
        }
        
        // 시/군/구
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressInfo['시/군/구'] = place.locality!;
        }
        
        // 시/도
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressInfo['시/도'] = place.administrativeArea!;
        }
        
        // 우편번호
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressInfo['우편번호'] = place.postalCode!;
        }
        
        // 국가
        if (place.country != null && place.country!.isNotEmpty) {
          addressInfo['국가'] = place.country!;
        }
        
        return addressInfo;
      }
      
      return {};
    } catch (e) {
      print('❌ 상세 주소 변환 오류: $e');
      return {};
    }
  }

  /// 마지막으로 알려진 위치 가져오기
  Position? getLastKnownPosition() {
    return _lastKnownPosition;
  }

  /// 두 위치 간의 거리 계산 (미터)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// 위치 정확도 확인
  bool isLocationAccurate(Position position) {
    // 정확도가 20미터 이하인 경우 정확하다고 판단
    return position.accuracy <= 20;
  }
}
