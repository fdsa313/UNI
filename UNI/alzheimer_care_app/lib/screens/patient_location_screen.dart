import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/location_service.dart';
import 'map_view_screen.dart';

class PatientLocationScreen extends StatefulWidget {
  const PatientLocationScreen({super.key});

  @override
  State<PatientLocationScreen> createState() => _PatientLocationScreenState();
}

class _PatientLocationScreenState extends State<PatientLocationScreen> {
  final LocationService _locationService = LocationService();
  
  Position? _currentPosition;
  String? _currentAddress;
  Map<String, String> _detailedAddress = {};
  bool _isLoading = false;
  bool _isTracking = false;
  String _statusMessage = '위치 찾기를 시작하려면 버튼을 누르세요.';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _locationService.stopLocationTracking();
    super.dispose();
  }

  /// 위치 권한 확인
  Future<void> _checkLocationPermission() async {
    bool hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission) {
      setState(() {
        _statusMessage = '위치 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      });
    }
  }

  /// 현재 위치 찾기
  Future<void> _findCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '현재 위치를 찾는 중...';
    });

    try {
      Position? position = await _locationService.getCurrentLocation();
      
              if (position != null) {
          String? address = await _locationService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );
          
          Map<String, String> detailedAddress = await _locationService.getDetailedAddress(
            position.latitude,
            position.longitude,
          );

          setState(() {
            _currentPosition = position;
            _currentAddress = address;
            _detailedAddress = detailedAddress;
            _statusMessage = '✅ 위치를 찾았습니다! (${position.accuracy.toStringAsFixed(1)}m 정확도)';
          });
        } else {
        setState(() {
          _statusMessage = '위치를 찾을 수 없습니다. GPS를 확인해주세요.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '위치 찾기 중 오류가 발생했습니다: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 실시간 위치 추적 시작/중지
  Future<void> _toggleLocationTracking() async {
    if (_isTracking) {
      await _locationService.stopLocationTracking();
      setState(() {
        _isTracking = false;
        _statusMessage = '위치 추적이 중지되었습니다.';
      });
    } else {
      await _locationService.startLocationTracking(
        onLocationUpdate: (Position position) {
          setState(() {
            _currentPosition = position;
            _statusMessage = '실시간 위치 추적 중...';
          });
          
          // 주소 업데이트
          _locationService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          ).then((address) async {
            if (mounted) {
              Map<String, String> detailedAddress = await _locationService.getDetailedAddress(
                position.latitude,
                position.longitude,
              );
              
              setState(() {
                _currentAddress = address;
                _detailedAddress = detailedAddress;
              });
            }
          });
        },
        interval: const Duration(seconds: 30),
      );
      
      setState(() {
        _isTracking = true;
        _statusMessage = '실시간 위치 추적이 시작되었습니다.';
      });
    }
  }

  /// 지도 앱에서 위치 열기
  Future<void> _openInMaps() async {
    if (_currentPosition != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}';
      
      try {
        // url_launcher 패키지가 필요합니다
        // await launchUrl(Uri.parse(url));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('지도 앱에서 위치를 열려면 url_launcher 패키지가 필요합니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('지도 앱 열기 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 앱 내 지도 화면 열기
  void _openMapView() {
    if (_currentPosition != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MapViewScreen(initialPosition: _currentPosition),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 현재 위치를 찾아주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환자 위치 찾기'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상태 메시지
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _statusMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 위치 찾기 버튼
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _findCurrentLocation,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.location_searching),
              label: Text(_isLoading ? '위치 찾는 중...' : '현재 위치 찾기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 실시간 추적 버튼
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _toggleLocationTracking,
              icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
              label: Text(_isTracking ? '위치 추적 중지' : '실시간 위치 추적'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTracking ? Colors.red[600] : Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 위치 정보 표시
            if (_currentPosition != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📍 현재 위치 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 좌표 정보
                    _buildInfoRow('위도', '${_currentPosition!.latitude.toStringAsFixed(6)}°'),
                    _buildInfoRow('경도', '${_currentPosition!.longitude.toStringAsFixed(6)}°'),
                    _buildInfoRow('정확도', '${_currentPosition!.accuracy.toStringAsFixed(1)}m'),
                    
                    // 시간 정보
                    _buildInfoRow('시간', '${_currentPosition!.timestamp?.toLocal().toString().substring(0, 19)}'),
                    
                    if (_currentPosition!.speed > 0) ...[
                      _buildInfoRow('속도', '${_currentPosition!.speed.toStringAsFixed(1)}m/s'),
                    ],
                    
                    if (_currentPosition!.altitude != 0) ...[
                      _buildInfoRow('고도', '${_currentPosition!.altitude.toStringAsFixed(1)}m'),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    // 주소 정보
                    if (_currentAddress != null) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      _buildInfoRow('주소', _currentAddress!),
                    ],
                    
                    // 상세 주소 정보
                    if (_detailedAddress.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        '📍 상세 위치 정보',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._detailedAddress.entries.map((entry) => 
                        _buildInfoRow(entry.key, entry.value)
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // 지도에서 열기 버튼들
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openInMaps,
                            icon: const Icon(Icons.map),
                            label: const Text('외부 지도'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[600],
                              side: BorderSide(color: Colors.blue[600]!),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openMapView,
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('앱 내 지도'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            const Spacer(),
            
            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '위치 정확도를 높이려면 GPS가 활성화되어 있어야 합니다.',
                      style: TextStyle(fontSize: 14, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
