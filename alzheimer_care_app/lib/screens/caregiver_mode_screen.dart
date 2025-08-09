import 'package:flutter/material.dart';

class CaregiverModeScreen extends StatelessWidget {
  final String? userName; // 사용자 이름을 받을 수 있도록 추가
  
  const CaregiverModeScreen({super.key, this.userName});

  // 사용자 이름을 가져오는 함수
  String get _userName {
    return userName ?? '돌쇠님'; // 기본값은 '돌쇠님'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('보호자 모드'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFFE65100),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
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
                              '보호자 모드',
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
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB74D),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 20,
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

                const SizedBox(height: 16),

                // 보호자 모드 제목
                const Text(
                  '보호자 모드',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB74D),
                  ),
                ),

                const SizedBox(height: 24),

                // 관리 옵션들
                Expanded(
                  child: ListView(
                    children: [
                      _buildOptionItem(
                        context,
                        Icons.medication,
                        '약물 설정',
                        '복용 시간, 약물 정보 관리',
                        () => Navigator.of(context).pushNamed('/medication-settings'),
                      ),
                      _buildOptionItem(
                        context,
                        Icons.quiz,
                        '퀴즈 설정',
                        '환자가 풀 퀴즈 선택',
                        () => Navigator.of(context).pushNamed('/quiz-settings'),
                      ),
                      _buildOptionItem(
                        context,
                        Icons.person_add,
                        '환자 관리',
                        '환자 정보, 상태 관리',
                        () {},
                      ),
                      _buildOptionItem(
                        context,
                        Icons.history,
                        '복용 기록',
                        '약 복용 이력 확인',
                        () {},
                      ),
                      _buildOptionItem(
                        context,
                        Icons.bar_chart,
                        '진행 상황',
                        '퀴즈 결과, 활동 분석',
                        () {},
                      ),
                      _buildOptionItem(
                        context,
                        Icons.emergency,
                        '긴급 연락처',
                        '응급 상황 연락처 관리',
                        () {},
                      ),
                      _buildOptionItem(
                        context,
                        Icons.settings,
                        '앱 설정',
                        '앱 정보, 알림 설정',
                        () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB74D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE65100),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8D6E63),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFFFFB74D),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
