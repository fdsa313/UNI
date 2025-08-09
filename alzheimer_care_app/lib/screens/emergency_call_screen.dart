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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF8E1),
              Color(0xFFF5F5DC),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFB74D),
                ),
              )
            : Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5DC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFB74D)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '긴급 전화',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '안녕하세요, ${_userData?['name'] ?? '사용자'}님',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '긴급 상황이신가요? 누구에게 전화하시겠습니까?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8D6E63),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 전화 옵션들
                      _buildCallOption(
                        context,
                        '보호자',
                        _userData?['caregiverPhone'] ?? '010-0000-0000',
                        () => _makeCall(context, '보호자', _userData?['caregiverPhone'] ?? '010-0000-0000'),
                      ),
                      const SizedBox(height: 12),
                      // 기본 긴급 연락처
                      _buildCallOption(
                        context,
                        '응급실',
                        '119',
                        () => _makeCall(context, '응급실', '119'),
                      ),
                      const SizedBox(height: 12),
                      _buildCallOption(
                        context,
                        '담당의사',
                        _userData?['doctorPhone'] ?? '010-0000-0000',
                        () => _makeCall(context, '담당의사', _userData?['doctorPhone'] ?? '010-0000-0000'),
                      ),
                      
                      // 사용자 정의 긴급 연락처들
                      ..._emergencyContacts.map((contact) => Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildCallOption(
                            context,
                            contact['name'] ?? '긴급연락처',
                            contact['phone'] ?? '000-0000-0000',
                            () => _makeCall(context, contact['name'] ?? '긴급연락처', contact['phone'] ?? '000-0000-0000'),
                          ),
                        ],
                      )).toList(),
                
                const SizedBox(height: 24),
                
                // 취소 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16,
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
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB74D),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.phone,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          contact,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE65100),
          ),
        ),
        subtitle: Text(
          number,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8D6E63),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
