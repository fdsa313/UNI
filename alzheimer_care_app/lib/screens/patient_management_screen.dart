import 'package:flutter/material.dart';
import '../services/medication_service.dart'; // Added import for MedicationService

class PatientManagementScreen extends StatefulWidget {
  final String? userName;
  
  const PatientManagementScreen({super.key, this.userName});

  @override
  State<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  Map<String, dynamic>? _progressData;
  bool _isLoading = true;
  
  // 사용자 이름을 가져오는 함수
  String get _userName {
    return widget.userName ?? '돌쇠님';
  }

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // SharedPreferences에서 약물 복용 기록 가져오기
      final medicationRecords = await MedicationService.getAllMedicationRecords(_userName);
      
      if (medicationRecords.isNotEmpty) {
        // 약물 복용 기록이 있는 경우
        final patientData = _generatePatientSpecificData(_userName);
        patientData['medicationRecords'] = medicationRecords;
        
        setState(() {
          _progressData = patientData;
          _isLoading = false;
        });
        print('SharedPreferences에서 환자 데이터 로드 성공: $_userName');
      } else {
        // 약물 복용 기록이 없는 경우, 기본 데이터 생성
        print('약물 복용 기록이 없음, 기본 데이터 생성: $_userName');
        final patientData = _generatePatientSpecificData(_userName);
        
        setState(() {
          _progressData = patientData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('데이터 로드 오류, 기본 데이터 사용: $e');
      // 오류 발생 시 기본 데이터 사용
      final patientData = _generatePatientSpecificData(_userName);
      setState(() {
        _progressData = patientData;
        _isLoading = false;
      });
    }
  }

  // 환자별 개별 데이터 생성
  Map<String, dynamic> _generatePatientSpecificData(String patientName) {
    // 환자별로 다른 데이터 생성
    switch (patientName) {
      case '김철수님':
        return {
          'quizResults': [
            {'date': '2024-08-11', 'score': 4, 'total': 5, 'time': '15분'},
            {'date': '2024-08-10', 'score': 3, 'total': 5, 'time': '20분'},
            {'date': '2024-08-09', 'score': 5, 'total': 5, 'time': '12분'},
          ],
          'medicationCompliance': 85.0,
          'moodTrend': [
            {'date': '2024-08-11', 'mood': '좋음', 'score': 4},
            {'date': '2024-08-10', 'mood': '보통', 'score': 3},
            {'date': '2024-08-09', 'mood': '좋음', 'score': 4},
          ],
          'cognitiveScore': 75.0,
          'recommendations': [
            '정기적인 퀴즈 참여로 인지 능력 향상',
            '약물 복용 시간 준수 필요',
            '긍정적인 기분 유지가 중요',
          ],
          'medicationHistory': [
            {'date': '2024-08-11', 'morning': true, 'lunch': true, 'evening': false},
            {'date': '2024-08-10', 'morning': true, 'lunch': true, 'evening': true},
            {'date': '2024-08-09', 'morning': false, 'lunch': true, 'evening': true},
            {'date': '2024-08-08', 'morning': true, 'lunch': false, 'evening': true},
            {'date': '2024-08-07', 'morning': true, 'lunch': true, 'evening': true},
          ],
        };
      
      case '돌쇠님':
        return {
          'quizResults': [
            {'date': '2024-08-11', 'score': 2, 'total': 5, 'time': '25분'},
            {'date': '2024-08-10', 'score': 1, 'total': 5, 'time': '30분'},
            {'date': '2024-08-09', 'score': 3, 'total': 5, 'time': '28분'},
          ],
          'medicationCompliance': 65.0,
          'moodTrend': [
            {'date': '2024-08-11', 'mood': '보통', 'score': 3},
            {'date': '2024-08-10', 'mood': '나쁨', 'score': 2},
            {'date': '2024-08-09', 'mood': '보통', 'score': 3},
          ],
          'cognitiveScore': 45.0,
          'recommendations': [
            '더 자주 퀴즈에 참여하여 인지 능력 향상 필요',
            '약물 복용을 더욱 철저히 관리해야 함',
            '기분 개선을 위한 활동과 관심이 필요',
          ],
          'medicationHistory': [
            {'date': '2024-08-11', 'morning': false, 'lunch': true, 'evening': false},
            {'date': '2024-08-10', 'morning': true, 'lunch': false, 'evening': true},
            {'date': '2024-08-09', 'morning': false, 'lunch': true, 'evening': false},
            {'date': '2024-08-08', 'morning': true, 'lunch': true, 'evening': false},
            {'date': '2024-08-07', 'morning': false, 'lunch': false, 'evening': true},
          ],
        };
      
      case '박영희님':
        return {
          'quizResults': [
            {'date': '2024-08-11', 'score': 5, 'total': 5, 'time': '10분'},
            {'date': '2024-08-10', 'score': 4, 'total': 5, 'time': '12분'},
            {'date': '2024-08-09', 'score': 5, 'total': 5, 'time': '11분'},
          ],
          'medicationCompliance': 95.0,
          'moodTrend': [
            {'date': '2024-08-11', 'mood': '매우 좋음', 'score': 5},
            {'date': '2024-08-10', 'mood': '좋음', 'score': 4},
            {'date': '2024-08-09', 'mood': '매우 좋음', 'score': 5},
          ],
          'cognitiveScore': 88.0,
          'recommendations': [
            '현재 상태를 잘 유지하고 있습니다',
            '정기적인 운동과 사회적 활동 권장',
            '인지 훈련을 지속하여 더욱 향상시키세요',
          ],
          'medicationHistory': [
            {'date': '2024-08-11', 'morning': true, 'lunch': true, 'evening': true},
            {'date': '2024-08-10', 'morning': true, 'lunch': true, 'evening': true},
            {'date': '2024-08-09', 'morning': true, 'lunch': true, 'evening': true},
            {'date': '2024-08-08', 'morning': true, 'lunch': true, 'evening': true},
            {'date': '2024-08-07', 'morning': true, 'lunch': true, 'evening': true},
          ],
        };
      
      default:
        // 기본 데이터 (새로운 환자)
        return {
          'quizResults': [
            {'date': '2024-08-11', 'score': 0, 'total': 5, 'time': '0분'},
            {'date': '2024-08-10', 'score': 0, 'total': 5, 'time': '0분'},
            {'date': '2024-08-09', 'score': 0, 'total': 5, 'time': '0분'},
          ],
          'medicationCompliance': 0.0,
          'moodTrend': [
            {'date': '2024-08-11', 'mood': '기록 없음', 'score': 0},
            {'date': '2024-08-10', 'mood': '기록 없음', 'score': 0},
            {'date': '2024-08-09', 'mood': '기록 없음', 'score': 0},
          ],
          'cognitiveScore': 0.0,
          'recommendations': [
            '첫 퀴즈 참여를 권장합니다',
            '약물 복용 기록을 시작해주세요',
            '기분 상태를 기록해주세요',
          ],
          'medicationHistory': [
            {'date': '2024-08-11', 'morning': false, 'lunch': false, 'evening': false},
            {'date': '2024-08-10', 'morning': false, 'lunch': false, 'evening': false},
            {'date': '2024-08-09', 'morning': false, 'lunch': false, 'evening': false},
            {'date': '2024-08-08', 'morning': false, 'lunch': false, 'evening': false},
            {'date': '2024-08-07', 'morning': false, 'lunch': false, 'evening': false},
          ],
        };
    }
  }

  // 평균 퀴즈 정답률 계산
  int _calculateAverageQuizScore() {
    if (_progressData == null || 
        _progressData!['quizResults'] == null || 
        (_progressData!['quizResults'] as List).isEmpty) return 0;
    
    int totalScore = 0;
    int totalQuestions = 0;
    
    for (var quiz in _progressData!['quizResults'] as List) {
      totalScore += (quiz['score'] ?? 0) as int;
      totalQuestions += (quiz['total'] ?? 0) as int;
    }
    
    if (totalQuestions == 0) return 0;
    
    int result = ((totalScore / totalQuestions) * 100).round();
    return result;
  }

  // 약물 복용 준수율 계산 (최근 7일)
  double _calculateMedicationCompliance() {
    if (_progressData == null || 
        _progressData!['medicationHistory'] == null || 
        (_progressData!['medicationHistory'] as List).isEmpty) return 0.0;
    
    final history = _progressData!['medicationHistory'] as List;
    int totalDoses = 0;
    int takenDoses = 0;
    
    for (var day in history) {
      if (day['morning'] == true) takenDoses++;
      if (day['lunch'] == true) takenDoses++;
      if (day['evening'] == true) takenDoses++;
      totalDoses += 3;
    }
    
    if (totalDoses == 0) return 0.0;
    return (takenDoses / totalDoses) * 100;
  }

  // 평균 기분 점수 계산
  double _calculateAverageMoodScore() {
    if (_progressData == null || 
        _progressData!['moodTrend'] == null || 
        (_progressData!['moodTrend'] as List).isEmpty) return 0.0;
    
    final moodTrend = _progressData!['moodTrend'] as List;
    int totalScore = 0;
    
    for (var mood in moodTrend) {
      totalScore += (mood['score'] ?? 0) as int;
    }
    
    if (moodTrend.isEmpty) return 0.0;
    return totalScore / moodTrend.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환자 관리'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFFE65100),
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 환자 정보 헤더
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: const Color(0xFFFFB74D),
                                child: Text(
                                  _userName.isNotEmpty ? _userName.substring(0, 1) : '?',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _userName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '환자 정보 관리',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8D6E63),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 진행상황 요약 카드들
                        const Text(
                          '진행상황 요약',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_progressData != null) ...[
                          _buildProgressCard(
                            '퀴즈 성과',
                            Icons.quiz,
                            '${(_progressData!['quizResults'] as List?)?.length ?? 0}회 참여',
                            '평균 정답률: ${_calculateAverageQuizScore()}%',
                            Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          _buildProgressCard(
                            '약물 복용',
                            Icons.medication,
                            '복용 준수율',
                            '${_calculateMedicationCompliance().round()}%',
                            Colors.green,
                          ),
                          const SizedBox(height: 16),
                          _buildProgressCard(
                            '기분 상태',
                            Icons.sentiment_satisfied,
                            '평균 기분 점수',
                            '${_calculateAverageMoodScore().toStringAsFixed(1)}/5점',
                            Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          _buildProgressCard(
                            '인지 능력',
                            Icons.psychology,
                            '종합 인지 점수',
                            '${(_progressData!['cognitiveScore'] ?? 0.0).round()}/100점',
                            Colors.purple,
                          ),
                        ],

                        const SizedBox(height: 24),

                        // 복용 기록
                        const Text(
                          '복용 기록',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: const Color(0xFFE65100),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    '최근 7일 복용 현황',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              // 복용 기록 테이블
                              if (_progressData != null && _progressData!['medicationHistory'] != null) ...[
                                _buildMedicationHistoryTable(),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 권장사항
                        if (_progressData != null && _progressData!['recommendations'] != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI 권장사항',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...((_progressData!['recommendations'] as List?) ?? []).map((rec) => 
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.lightbulb_outline,
                                          color: Color(0xFFFFB74D),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            rec.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF8D6E63),
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ).toList(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, IconData icon, String subtitle, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8D6E63),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationHistoryTable() {
    final history = _progressData!['medicationHistory'] as List?;
    if (history == null || history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          '복용 기록이 없습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF8D6E63),
          ),
        ),
      );
    }
    
    return Column(
      children: [
        // 테이블 헤더
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '날짜',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '아침',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '점심',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '저녁',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 테이블 데이터
        ...history.map((day) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    (day['date'] ?? '').toString(),
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (day['morning'] == true) ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(
                    (day['morning'] == true) ? Icons.check : Icons.close,
                    color: (day['morning'] == true) ? Colors.green : Colors.red,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (day['lunch'] == true) ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(
                    (day['lunch'] == true) ? Icons.check : Icons.close,
                    color: (day['lunch'] == true) ? Colors.green : Colors.red,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (day['evening'] == true) ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Icon(
                    (day['evening'] == true) ? Icons.check : Icons.close,
                    color: (day['evening'] == true) ? Colors.green : Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}
