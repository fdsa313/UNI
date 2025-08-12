import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class MapViewScreen extends StatefulWidget {
  final Position? initialPosition;
  
  const MapViewScreen({super.key, this.initialPosition});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  
  Position? _currentPosition;
  String? _currentAddress;
  Map<String, String> _detailedAddress = {};
  bool _isLoading = false;
  bool _isTracking = false;
  List<Marker> _markers = [];
  
  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    if (_isTracking) {
      _locationService.stopLocationTracking();
    }
    super.dispose();
  }

  /// 지도 초기화
  Future<void> _initializeMap() async {
    if (widget.initialPosition != null) {
      _currentPosition = widget.initialPosition;
      _addMarker(_currentPosition!);
      _getAddressForPosition(_currentPosition!);
    } else {
      await _findCurrentLocation();
    }
  }

  /// 현재 위치 찾기
  Future<void> _findCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position? position = await _locationService.getCurrentLocation();
      
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
        
        _addMarker(position);
        await _getAddressForPosition(position);
        
        // 지도 중심을 현재 위치로 이동
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치를 찾을 수 없습니다. GPS를 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('위치 찾기 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 실시간 위치 추적 시작/중지
  Future<void> _toggleLocationTracking() async {
    if (_isTracking) {
      await _locationService.stopLocationTracking();
      setState(() {
        _isTracking = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('위치 추적이 중지되었습니다.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      await _locationService.startLocationTracking(
        onLocationUpdate: (Position position) {
          setState(() {
            _currentPosition = position;
          });
          
          _addMarker(position);
          _getAddressForPosition(position);
          
          // 지도 중심을 새로운 위치로 부드럽게 이동
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15.0,
          );
        },
        interval: const Duration(seconds: 30),
      );
      
      setState(() {
        _isTracking = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('실시간 위치 추적이 시작되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// 마커 추가
  void _addMarker(Position position) {
    final marker = Marker(
      point: LatLng(position.latitude, position.longitude),
      width: 80,
      height: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 24,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '환자',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ),
        ],
      ),
    );

    setState(() {
      _markers = [marker];
    });
  }

  /// 위치에 대한 주소 가져오기
  Future<void> _getAddressForPosition(Position position) async {
    try {
      String? address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      Map<String, String> detailedAddress = await _locationService.getDetailedAddress(
        position.latitude,
        position.longitude,
      );
      
      if (mounted) {
        setState(() {
          _currentAddress = address;
          _detailedAddress = detailedAddress;
        });
      }
    } catch (e) {
      print('주소 변환 오류: $e');
    }
  }

  /// 내 위치로 이동
  void _moveToMyLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환자 위치 지도'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _moveToMyLocation,
            tooltip: '내 위치로 이동',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 지도
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(37.5665, 126.9780), // 서울 시청 (기본값)
              initialZoom: 15.0,
              minZoom: 5.0,
              maxZoom: 18.0,
              onMapReady: () {
                if (_currentPosition != null) {
                  _mapController.move(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    15.0,
                  );
                }
              },
            ),
            children: [
              // OpenStreetMap 타일 레이어
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.alzheimer_care_app',
                maxZoom: 19,
              ),
              
              // 마커 레이어
              MarkerLayer(markers: _markers),
            ],
          ),
          
          // 위치 정보 오버레이
          if (_currentPosition != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '현재 위치',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                        const Spacer(),
                        if (_isTracking)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '추적 중',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 좌표 정보
                    Text(
                      '위도: ${_currentPosition!.latitude.toStringAsFixed(6)}°',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '경도: ${_currentPosition!.longitude.toStringAsFixed(6)}°',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '정확도: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    
                    // 주소 정보
                    if (_currentAddress != null) ...[
                      const SizedBox(height: 8),
                      const Divider(),
                      Text(
                        _currentAddress!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                    
                    // 상세 주소 정보
                    if (_detailedAddress.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  '${entry.key}:',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          
          // 하단 컨트롤 버튼들
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // 현재 위치 찾기 버튼
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _findCurrentLocation,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.location_searching),
                    label: Text(_isLoading ? '찾는 중...' : '위치 찾기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 실시간 추적 버튼
                ElevatedButton.icon(
                  onPressed: _toggleLocationTracking,
                  icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                  label: Text(_isTracking ? '중지' : '추적'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTracking ? Colors.red[600] : Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 로딩 인디케이터
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
