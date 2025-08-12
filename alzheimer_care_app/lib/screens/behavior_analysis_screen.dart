import 'package:flutter/material.dart';
import '../services/behavior_analysis_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class BehaviorAnalysisScreen extends StatefulWidget {
  const BehaviorAnalysisScreen({super.key});

  @override
  State<BehaviorAnalysisScreen> createState() => _BehaviorAnalysisScreenState();
}

class _BehaviorAnalysisScreenState extends State<BehaviorAnalysisScreen> {
  final BehaviorAnalysisService _behaviorAnalysisService = BehaviorAnalysisService();
  final LocationService _locationService = LocationService();
  
  Map<String, dynamic>? _behaviorPattern;
  List<Map<String, dynamic>> _dangerAlerts = [];
  bool _isLoading = false;
  Position? _currentPosition;
  bool _isLocationSafe = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startLocationMonitoring();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 행동 패턴 데이터 로드
      final pattern = await _behaviorAnalysisService.getBehaviorPattern();
      final alerts = await _behaviorAnalysisService.getDangerAlerts();
      
      setState(() {
        _behaviorPattern = pattern;
        _dangerAlerts = alerts;
      });
    } catch (e) {
      print('데이터 로드 오류: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startLocationMonitoring() async {
    try {
      await _locationService.startLocationTracking(
        onLocationUpdate: (Position position) async {
          setState(() {
            _currentPosition = position;
          });
          
          // 위치 안전성 확인
          final isSafe = await _behaviorAnalysisService.isLocationSafe(position);
          setState(() {
            _isLocationSafe = isSafe;
          });
          
          if (!isSafe) {
            _showDangerAlert();
          }
        },
        interval: const Duration(seconds: 30),
      );
    } catch (e) {
      print('위치 모니터링 시작 오류: $e');
    }
  }

  void _showDangerAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('🚨 위험 위치 감지!'),
          ],
        ),
        content: const Text(
          '환자가 평소 행동 반경을 벗어났습니다.\n즉시 확인이 필요합니다.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 행동 패턴 분석'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentLocationCard(),
                    const SizedBox(height: 16),
                    _buildBehaviorPatternCard(),
                    const SizedBox(height: 16),
                    _buildDangerAlertsCard(),
                    const SizedBox(height: 16),
                    _buildDataManagementCard(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCurrentLocationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isLocationSafe ? Icons.check_circle : Icons.warning,
                  color: _isLocationSafe ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '현재 위치 상태',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentPosition != null) ...[
              Text('위도: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
              Text('경도: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
              Text('정확도: ${_currentPosition!.accuracy.toStringAsFixed(1)}m'),
              Text('시간: ${_currentPosition!.timestamp.toString().substring(0, 19)}'),
            ] else ...[
              const Text('위치 정보 없음'),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isLocationSafe ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isLocationSafe ? '✅ 안전한 위치' : '🚨 위험한 위치',
                style: TextStyle(
                  color: _isLocationSafe ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorPatternCard() {
    if (_behaviorPattern == null) {
      return Card(
        elevation: 4,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📊 행동 패턴 분석',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('아직 충분한 데이터가 수집되지 않았습니다.\n1주일간의 위치 데이터가 필요합니다.'),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 행동 패턴 분석',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('중심점: ${_behaviorPattern!['centerLatitude'].toStringAsFixed(6)}, ${_behaviorPattern!['centerLongitude'].toStringAsFixed(6)}'),
            Text('행동 반경: ${_behaviorPattern!['behaviorRadius'].toStringAsFixed(0)}m'),
            Text('신뢰도: ${(_behaviorPattern!['confidenceLevel'] * 100).toStringAsFixed(0)}%'),
            Text('데이터 포인트: ${_behaviorPattern!['dataPoints']}개'),
            Text('마지막 업데이트: ${DateTime.fromMillisecondsSinceEpoch(_behaviorPattern!['lastUpdated']).toString().substring(0, 19)}'),
            
            const SizedBox(height: 12),
            const Text(
              '⏰ 시간대별 활동 패턴',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildTimePatternChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePatternChart() {
    if (_behaviorPattern == null || _behaviorPattern!['timePatterns'] == null) {
      return const Text('시간대별 데이터 없음');
    }

    final timePatterns = _behaviorPattern!['timePatterns'] as Map<String, dynamic>;
    
    return Column(
      children: [
        _buildTimeSlotRow('🌅 아침 (06:00-12:00)', timePatterns['morning']?['count'] ?? 0),
        _buildTimeSlotRow('☀️ 오후 (12:00-18:00)', timePatterns['afternoon']?['count'] ?? 0),
        _buildTimeSlotRow('🌆 저녁 (18:00-22:00)', timePatterns['evening']?['count'] ?? 0),
        _buildTimeSlotRow('🌙 밤 (22:00-06:00)', timePatterns['night']?['count'] ?? 0),
      ],
    );
  }

  Widget _buildTimeSlotRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: count / 100, // 최대값을 100으로 가정
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text('$count회'),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerAlertsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                Text(
                  '🚨 위험 알림 기록 (${_dangerAlerts.length}개)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_dangerAlerts.isEmpty)
              const Text('아직 위험 알림이 없습니다.')
            else
              ..._dangerAlerts.take(5).map((alert) => _buildAlertItem(alert)),
            if (_dangerAlerts.length > 5)
              TextButton(
                onPressed: () {
                  // 전체 알림 보기 화면으로 이동
                },
                child: Text('전체 ${_dangerAlerts.length}개 보기'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(alert['timestamp']);
    final distance = alert['distance'];
    final safetyRadius = alert['safetyRadius'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red[600], size: 16),
              const SizedBox(width: 4),
              Text(
                timestamp.toString().substring(0, 19),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('거리: ${distance.toStringAsFixed(0)}m (안전 반경: ${safetyRadius.toStringAsFixed(0)}m)'),
          Text('주소: ${alert['address']}'),
        ],
      ),
    );
  }

  Widget _buildDataManagementCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚙️ 데이터 관리',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _behaviorAnalysisService.clearAllData();
                      _loadData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('모든 데이터가 초기화되었습니다.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('데이터 초기화'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('데이터 새로고침'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _behaviorAnalysisService.generateTestData();
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🧪 테스트 데이터가 생성되었습니다!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.science),
                label: const Text('🧪 테스트 데이터 생성'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '💡 팁: 1주일간의 위치 데이터를 수집하면 정확한 행동 패턴을 분석할 수 있습니다.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationService.stopLocationTracking();
    super.dispose();
  }
}
