import 'package:flutter/material.dart';
import '../services/medication_service.dart'; // MedicationService로 변경
import 'package:flutter/services.dart';

class MedicationScreen extends StatefulWidget {
  final String? userName;
  
  const MedicationScreen({super.key, this.userName});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> with WidgetsBindingObserver {
  Map<String, dynamic> _medicationStatus = {
    'morning': false,
    'lunch': false,
    'evening': false,
    'note': null,
  };

  List<Map<String, dynamic>> _medications = [
    {
      'name': '아스피린',
      'dosage': '100mg',
      'time': '아침',
      'taken': false,
    },
    {
      'name': '혈압약',
      'dosage': '5mg',
      'time': '점심',
      'taken': false,
    },
    {
      'name': '당뇨약',
      'dosage': '500mg',
      'time': '저녁',
      'taken': false,
    },
  ];

  bool _isLoading = false;

  // 사용자 이름을 가져오는 함수
  String get _userName {
    return widget.userName ?? '돌쇠님';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTodayMedicationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 포그라운드로 돌아올 때 최신 복용 상태 로드
    if (state == AppLifecycleState.resumed) {
      _loadTodayMedicationStatus();
    }
  }

  // 화면이 포커스를 받을 때마다 상태 로드
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTodayMedicationStatus();
  }

  // 오늘 날짜의 약물 복용 상태 로드
  Future<void> _loadTodayMedicationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 날짜를 YYYY-MM-DD 형식으로 변환
      final now = DateTime.now();
      final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      
      // MedicationService로 변경
      final medicationData = await MedicationService.getMedicationStatus(_userName, today);
      
      if (medicationData != null) {
        setState(() {
          _medicationStatus['morning'] = medicationData['morning'] ?? false;
          _medicationStatus['lunch'] = medicationData['lunch'] ?? false;
          _medicationStatus['evening'] = medicationData['evening'] ?? false;
          _medicationStatus['note'] = medicationData['note'];
          
          // 약물별 상태도 업데이트
          _updateMedicationStatus();
        });
      }
    } catch (e) {
      print('약물 복용 상태 로드 오류: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 약물별 상태 업데이트
  void _updateMedicationStatus() {
    for (int i = 0; i < _medications.length; i++) {
      final time = _medications[i]['time'];
      if (time == '아침') {
        _medications[i]['taken'] = _medicationStatus['morning'] ?? false;
      } else if (time == '점심') {
        _medications[i]['taken'] = _medicationStatus['lunch'] ?? false;
      } else if (time == '저녁') {
        _medications[i]['taken'] = _medicationStatus['evening'] ?? false;
      }
    }
  }

  void _onMedicationTaken(int index) async {
    try {
      final medication = _medications[index];
      final time = medication['time'];
      
      // API로 복용 기록 저장
      final success = await MedicationService.saveMedicationLog(_userName, time);
      
      if (success) {
        setState(() {
          _medications[index]['taken'] = true;
          
          // 시간대별 상태도 업데이트
          if (time == '아침') {
            _medicationStatus['morning'] = true;
          } else if (time == '점심') {
            _medicationStatus['lunch'] = true;
          } else if (time == '저녁') {
            _medicationStatus['evening'] = true;
          }
        });
        
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medication['name']} 복용 완료!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('복용 기록 저장에 실패했습니다.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('복용 기록 저장 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('복용 기록 저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onMedicationTakenByTime(String time) async {
    try {
      // API로 복용 기록 저장
      final success = await MedicationService.saveMedicationLog(_userName, time);
      
      if (success) {
        setState(() {
          _medicationStatus[time] = true;
          
          // 해당 시간대의 모든 약을 복용 완료로 표시
          for (int i = 0; i < _medications.length; i++) {
            if (_medications[i]['time'] == time) {
              _medications[i]['taken'] = true;
            }
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$time 복용 완료!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('복용 기록 저장에 실패했습니다.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('복용 기록 저장 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('복용 기록 저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약 복용'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFFE65100),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 홈으로 돌아가기
            Navigator.of(context).pop({
              'updated': true,
              'medicationStatus': _medicationStatus,
            });
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E1),
              Color(0xFFF5F5DC),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 헤더
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '안녕하세요, ${_userName}님!',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '오늘의 약 복용을 확인해보세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 복용 시간별 요약
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '복용 시간별 요약',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // 가입일 이전 데이터 안내 메시지
                        if (_medicationStatus['note'] == '가입일 이전')
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '가입일 이전 날짜입니다. 복용 데이터가 없습니다.',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        if (_medicationStatus['note'] != '가입일 이전') ...[
                          _buildTimeSummary('아침', '08:00', 'morning'),
                          const SizedBox(height: 8),
                          _buildTimeSummary('점심', '12:00', 'lunch'),
                          const SizedBox(height: 8),
                          _buildTimeSummary('저녁', '18:00', 'evening'),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 약 목록
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '약 목록',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _medications.length,
                          itemBuilder: (context, index) {
                            final medication = _medications[index];
                            return _buildMedicationItem(medication, index);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSummary(String time, String timeString, String key) {
    final isTaken = _medicationStatus[key] ?? false;
    final medicationsInTime = _medications.where((m) => m['time'] == time).toList();
    final takenCount = medicationsInTime.where((m) => m['taken']).length;
    final totalCount = medicationsInTime.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTaken ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTaken ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTaken ? Icons.check_circle : Icons.schedule,
            color: isTaken ? Colors.green : const Color(0xFFFFB74D),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$time ($timeString)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isTaken ? Colors.green : Colors.black87,
                  ),
                ),
                Text(
                  '$takenCount/$totalCount 복용 완료',
                  style: TextStyle(
                    fontSize: 12,
                    color: isTaken ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (!isTaken && totalCount > 0)
            ElevatedButton(
              onPressed: () => _onMedicationTakenByTime(time),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('복용'),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Map<String, dynamic> medication, int index) {
    final isTaken = medication['taken'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTaken ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTaken ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTaken ? Icons.check_circle : Icons.medication,
            color: isTaken ? Colors.green : const Color(0xFFFFB74D),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isTaken ? Colors.green : Colors.black87,
                  ),
                ),
                Text(
                  '${medication['dosage']} - ${medication['time']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isTaken ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (!isTaken)
            ElevatedButton(
              onPressed: () => _onMedicationTaken(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('복용'),
            ),
        ],
      ),
    );
  }
}
