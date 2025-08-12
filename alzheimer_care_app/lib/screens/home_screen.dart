import 'package:flutter/material.dart';
import 'caregiver_mode_screen.dart';
import 'emergency_call_screen.dart';
import 'quiz_screen.dart';
import 'medication_screen.dart';
import 'settings_screen.dart';
import '../services/api_service.dart';
import '../services/medication_service.dart';

import 'dart:async';

class HomeScreen extends StatefulWidget {
  final String? userName; // 사용자 이름을 받을 수 있도록 추가
  
  const HomeScreen({super.key, this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedMood = '';
  Map<String, bool> _medicationStatus = {
    'morning': false,
    'lunch': false,
    'evening': false,
  };
  
  // 타이머 관련 변수들
  Timer? _timer;
  String _nextMedicationTime = '';
  String _remainingTime = '';

  // 사용자 이름을 가져오는 함수 (실제로는 데이터베이스에서 가져옴)
  String get _userName {
    return widget.userName ?? '돌쇠님'; // 기본값은 '돌쇠님'
  }

  @override
  void initState() {
    super.initState();
    _loadTodayMedicationStatus();
    _updateNextMedicationTime();
    _startTimer();
  }

  // 화면이 포커스를 받을 때마다 상태 로드
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTodayMedicationStatus();
  }

  // 오늘 날짜의 약물 복용 상태 로드
  Future<void> _loadTodayMedicationStatus() async {
    try {
      final today = DateTime.now().toString().substring(0, 10);
      final medicationData = await MedicationService.getMedicationStatus(_userName, today);
      
      if (medicationData != null) {
        setState(() {
          _medicationStatus['morning'] = medicationData['morning'] ?? false;
          _medicationStatus['lunch'] = medicationData['lunch'] ?? false;
          _medicationStatus['evening'] = medicationData['evening'] ?? false;
        });
        
        // 다음 복용 시간 업데이트
        _updateNextMedicationTime();
      }
    } catch (e) {
      print('약물 복용 상태 로드 오류: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 다음 복용 시간 계산
  void _updateNextMedicationTime() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    
    // 복용 시간들 (실제로는 설정에서 가져와야 함)
    final morningTime = const TimeOfDay(hour: 8, minute: 0);
    final lunchTime = const TimeOfDay(hour: 12, minute: 0);
    final eveningTime = const TimeOfDay(hour: 18, minute: 0);
    
    TimeOfDay nextTime;
    String timeKey;
    
    if (currentTime.hour < morningTime.hour || 
        (currentTime.hour == morningTime.hour && currentTime.minute < morningTime.minute)) {
      nextTime = morningTime;
      timeKey = 'morning';
    } else if (currentTime.hour < lunchTime.hour || 
               (currentTime.hour == lunchTime.hour && currentTime.minute < lunchTime.minute)) {
      nextTime = lunchTime;
      timeKey = 'lunch';
    } else if (currentTime.hour < eveningTime.hour || 
               (currentTime.hour == eveningTime.hour && currentTime.minute < eveningTime.minute)) {
      nextTime = eveningTime;
      timeKey = 'evening';
    } else {
      // 오늘의 모든 복용이 완료된 경우, 내일 아침으로 설정
      nextTime = morningTime;
      timeKey = 'morning';
    }
    
    // 이미 복용한 경우 다음 시간으로
    if (_medicationStatus[timeKey] == true) {
      if (timeKey == 'morning') {
        nextTime = lunchTime;
        timeKey = 'lunch';
      } else if (timeKey == 'lunch') {
        nextTime = eveningTime;
        timeKey = 'evening';
      } else {
        nextTime = morningTime;
        timeKey = 'morning';
      }
    }
    
    _nextMedicationTime = '${nextTime.hour.toString().padLeft(2, '0')}:${nextTime.minute.toString().padLeft(2, '0')}';
    _calculateRemainingTime(nextTime);
  }

  // 남은 시간 계산
  void _calculateRemainingTime(TimeOfDay nextTime) {
    final now = DateTime.now();
    final nextDateTime = DateTime(now.year, now.month, now.day, nextTime.hour, nextTime.minute);
    
    // 다음 복용 시간이 오늘인지 내일인지 확인
    DateTime targetDateTime;
    if (nextDateTime.isBefore(now)) {
      // 오늘 시간이 지났으면 내일로 설정
      targetDateTime = nextDateTime.add(const Duration(days: 1));
    } else {
      targetDateTime = nextDateTime;
    }
    
    final difference = targetDateTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    if (hours > 0) {
      _remainingTime = '${hours}시간 ${minutes}분';
    } else {
      _remainingTime = '${minutes}분';
    }
    
    setState(() {});
  }

  // 타이머 시작
  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateNextMedicationTime();
    });
  }

  // 복용 완료 처리
  void _onMedicationTaken(String time) async {
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
      
      // SharedPreferences로 복용 기록 저장
      final success = await MedicationService.saveMedicationRecord(_userName, timeKey, DateTime.now());
      
      if (success) {
        setState(() {
          _medicationStatus[time] = true;
        });
        
        // 다음 복용 시간 업데이트
        _updateNextMedicationTime();
        
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$timeKey 복용이 기록되었습니다!'),
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

  // 기분 선택 처리
  void _onMoodSelected(String mood) async {
    try {
      // API로 기분 기록 저장
      final success = await ApiService.saveMood(_userName, mood);
      
      if (success) {
        setState(() {
          _selectedMood = mood;
        });
        
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오늘의 기분이 기록되었습니다: $mood'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기분 기록 저장에 실패했습니다.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('기분 기록 저장 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('기분 기록 저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCaregiverModeDialog() {
    // 비밀번호 화면으로 이동
    Navigator.of(context).pushNamed('/caregiver', arguments: _userName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '안녕하세요, ${_userName}님!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '환자 모드',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _showCaregiverModeDialog,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB74D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB74D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 긴급 전화 버튼
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/emergency-call');
                },
                icon: const Icon(Icons.emergency, color: Colors.white),
                label: const Text(
                  '긴급 전화',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 메인 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // 다음 복용 시간
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5DC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB74D),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '다음 복용 시간',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _medicationStatus.values.every((taken) => taken)
                                      ? '오늘의 복용이 완료되었습니다!'
                                      : '${_nextMedicationTime}까지 ${_remainingTime} 남았습니다',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF8D6E63),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 오늘의 복용 상태
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5DC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '오늘의 복용 상태',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildMedicationItem('아침 복용', '08:00', 'morning'),
                          const SizedBox(height: 8),
                          _buildMedicationItem('점심 복용', '12:00', 'lunch'),
                          const SizedBox(height: 8),
                          _buildMedicationItem('저녁 복용', '18:00', 'evening'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 오늘의 기분
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5DC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFB74D)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '오늘의 기분',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMoodButton('😊', '좋음'),
                              _buildMoodButton('😐', '보통'),
                              _buildMoodButton('😞', '나쁨'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 주요 기능 버튼들
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => QuizScreen(userName: _userName),
                                ),
                              );
                            },
                            icon: const Icon(Icons.quiz),
                            label: const Text('퀴즈'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB74D),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MedicationScreen(userName: _userName),
                                ),
                              );
                            },
                            icon: const Icon(Icons.medication),
                            label: const Text('약 복용'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE65100),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 설정 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SettingsScreen(userName: _userName),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings),
                        label: const Text('설정'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D6E63),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem(String title, String time, String key) {
    final isTaken = _medicationStatus[key] ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isTaken ? Icons.check_circle : Icons.medication,
            color: isTaken ? Colors.green : const Color(0xFFFFB74D),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$title ($time)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isTaken ? FontWeight.bold : FontWeight.normal,
                color: isTaken ? Colors.green : Colors.black87,
              ),
            ),
          ),
          if (!isTaken)
            ElevatedButton(
              onPressed: () => _onMedicationTaken(key),
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

  Widget _buildMoodButton(String emoji, String label) {
    final isSelected = _selectedMood == label;
    return GestureDetector(
      onTap: () => _onMoodSelected(label),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB74D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFB74D) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
