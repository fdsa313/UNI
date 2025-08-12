import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EmergencyCallScreen extends StatefulWidget {
  const EmergencyCallScreen({super.key});

  @override
  State<EmergencyCallScreen> createState() => _EmergencyCallScreenState();
}

class _EmergencyCallScreenState extends State<EmergencyCallScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  List<Map<String, String>> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
      // 기본 긴급 연락처
      _emergencyContacts = [
        {'name': '119', 'phone': '119'},
        {'name': '경찰서', 'phone': '112'},
      ];
    }
  }

  void _makeCall(BuildContext context, String contact, String number) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$contact에게 전화'),
          content: Text('$number로 전화를 걸까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$contact에게 전화를 걸고 있습니다...'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('전화'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isWideScreen = screenWidth > 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('긴급 전화'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFFE65100),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8E1),
              Color(0xFFFFF3E0),
              Color(0xFFFFF0E6),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFB74D),
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideScreen ? 40 : 16,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      // 헤더 섹션
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '긴급 전화',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFE65100),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '안녕하세요, ${_userData?['name'] ?? '사용자'}님',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: const Color(0xFF8D6E63),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '긴급 상황이신가요? 누구에게 전화하시겠습니까?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8D6E63),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 연락처 목록 (스크롤 가능)
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                '긴급 연락처',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE65100),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // 스크롤 가능한 연락처 목록
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      // 기본 연락처들
                                      _buildCallOption(
                                        context,
                                        '보호자',
                                        _userData?['caregiverPhone'] ?? '010-0000-0000',
                                        () => _makeCall(context, '보호자', _userData?['caregiverPhone'] ?? '010-0000-0000'),
                                        isSmallScreen,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildCallOption(
                                        context,
                                        '응급실',
                                        '119',
                                        () => _makeCall(context, '응급실', '119'),
                                        isSmallScreen,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildCallOption(
                                        context,
                                        '담당의사',
                                        _userData?['doctorPhone'] ?? '010-0000-0000',
                                        () => _makeCall(context, '담당의사', _userData?['doctorPhone'] ?? '010-0000-0000'),
                                        isSmallScreen,
                                      ),
                                      
                                      // 사용자 정의 긴급 연락처들
                                      ..._emergencyContacts.map((contact) => Column(
                                        children: [
                                          const SizedBox(height: 8),
                                          _buildCallOption(
                                            context,
                                            contact['name'] ?? '긴급연락처',
                                            contact['phone'] ?? '000-0000-0000',
                                            () => _makeCall(context, contact['name'] ?? '긴급연락처', contact['phone'] ?? '000-0000-0000'),
                                            isSmallScreen,
                                          ),
                                        ],
                                      )).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 취소 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black87,
                            padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCallOption(
    BuildContext context,
    String contact,
    String number,
    VoidCallback onTap,
    bool isSmallScreen,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 4 : 8,
        ),
        leading: Container(
          width: isSmallScreen ? 32 : 40,
          height: isSmallScreen ? 32 : 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB74D),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          ),
          child: Icon(
            Icons.phone,
            color: Colors.white,
            size: isSmallScreen ? 16 : 20,
          ),
        ),
        title: Text(
          contact,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFE65100),
          ),
        ),
        subtitle: Text(
          number,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: const Color(0xFF8D6E63),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
