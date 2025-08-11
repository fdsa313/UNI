import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:alzheimer_care_app/screens/patient_management_screen.dart';

class CaregiverModeScreen extends StatefulWidget {
  final String? userName;
  
  const CaregiverModeScreen({super.key, this.userName});

  @override
  State<CaregiverModeScreen> createState() => _CaregiverModeScreenState();
}

class _CaregiverModeScreenState extends State<CaregiverModeScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  List<Map<String, String>> _emergencyContacts = [];
  
  // 웹뷰 컨트롤러
  WebViewController? _webViewController;

  // 사용자 이름을 가져오는 함수
  String get _userName {
    return widget.userName ?? "김철수님";
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // 웹뷰 초기화
    if (kIsWeb) {
      WebViewPlatform.instance = WebWebViewPlatform();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await ApiService.getUserData();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });

      // 긴급 연락처 로드
      _loadEmergencyContacts();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadEmergencyContacts() {
    if (_userData != null && _userData!['emergencyContacts'] != null) {
      final contacts = _userData!['emergencyContacts'] as List;
      _emergencyContacts = contacts.map((contact) => Map<String, String>.from(contact)).toList();
    } else {
      // 기본 긴급 연락처 설정
      _emergencyContacts = [
        {'name': '119', 'phone': '119'},
        {'name': '경찰서', 'phone': '112'},
      ];
    }
  }

  void _showLocationFinder(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('위치 찾기'),
            backgroundColor: const Color(0xFFFFB74D),
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..loadRequest(
                Uri.parse('https://map.naver.com'),
              ),
          ),
        ),
      ),
    );
  }



  void _showEmergencyContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('긴급 연락처 관리'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _emergencyContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _emergencyContacts[index];
                      return ListTile(
                        title: Text(contact['name'] ?? ''),
                        subtitle: Text(contact['phone'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _emergencyContacts.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showAddContactDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB74D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('연락처 추가'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _saveEmergencyContacts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                foregroundColor: Colors.white,
              ),
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('긴급 연락처 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '연락처 이름',
                  hintText: '예: 이웃집 김씨',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  hintText: '010-0000-0000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  setState(() {
                    _emergencyContacts.add({
                      'name': nameController.text,
                      'phone': phoneController.text,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB74D),
                foregroundColor: Colors.white,
              ),
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveEmergencyContacts() async {
    try {
      final success = await ApiService.saveEmergencyContacts(_emergencyContacts);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('긴급 연락처가 저장되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadUserData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('저장에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장에 실패했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                        Icons.location_on,
                        '위치 찾기',
                        '네이버 지도로 위치 확인',
                        () => _showLocationFinder(context),
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
                        () => Navigator.of(context).pushNamed('/patient-management', arguments: _userName),
                      ),
                      _buildOptionItem(
                        context,
                        Icons.bar_chart,
                        '진행 상황',
                        'AI 보고서, 활동 분석',
                        () => Navigator.of(context).pushNamed('/progress-report', arguments: _userName),
                      ),
                      _buildOptionItem(
                        context,
                        Icons.emergency,
                        '긴급 연락처',
                        '응급 상황 연락처 관리 (${_emergencyContacts.length}개)',
                        () => _showEmergencyContactsDialog(context),
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