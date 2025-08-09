import 'package:flutter/material.dart';

class MedicationScreen extends StatefulWidget {
  final String? userName;
  
  const MedicationScreen({super.key, this.userName});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  Map<String, bool> _medicationStatus = {
    'morning': false,
    'lunch': false,
    'evening': false,
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

  // 사용자 이름을 가져오는 함수
  String get _userName {
    return widget.userName ?? '돌쇠님';
  }

  void _onMedicationTaken(int index) {
    setState(() {
      _medications[index]['taken'] = true;
    });
    
    // 성공 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_medications[index]['name']} 복용 완료!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMedicationTakenByTime(String time) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약 복용'),
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
                      _buildTimeSummary('아침', '08:00', 'morning'),
                      const SizedBox(height: 8),
                      _buildTimeSummary('점심', '12:00', 'lunch'),
                      const SizedBox(height: 8),
                      _buildTimeSummary('저녁', '18:00', 'evening'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 약 목록
                Expanded(
                  child: Container(
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
                          '약 목록',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE65100),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _medications.length,
                            itemBuilder: (context, index) {
                              final medication = _medications[index];
                              return _buildMedicationItem(medication, index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // 약 복용 탭
        selectedItemColor: const Color(0xFFFFB74D),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index != 2) {
            Navigator.of(context).pushReplacementNamed('/home', arguments: _userName);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: '퀴즈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: '약 복용',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
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
