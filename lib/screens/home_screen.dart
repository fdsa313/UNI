import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _isProtectorMode = false;
  bool _isProtectorPasswordSet = false; // 보호자 비밀번호 설정 여부
  final TextEditingController _protectorPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _protectorPassword = ""; // 실제로는 보안된 방식으로 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E1),
      appBar: AppBar(
        title: Text(
          '복약 관리',
          style: TextStyle(
            color: Color(0xFF8D6E63),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 보호자 모드 전환 버튼
          Container(
            margin: EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showProtectorModeDialog,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isProtectorMode 
                      ? Color(0xFFFF9800).withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isProtectorMode 
                        ? Color(0xFFFF9800)
                        : Color(0xFFD7CCC8),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isProtectorMode ? Icons.shield : Icons.shield_outlined,
                      color: _isProtectorMode 
                          ? Color(0xFFFF9800)
                          : Color(0xFF8D6E63),
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _isProtectorMode ? '보호자' : '환자',
                      style: TextStyle(
                        color: _isProtectorMode 
                            ? Color(0xFFFF9800)
                            : Color(0xFF8D6E63),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildWelcomeCard(),
              SizedBox(height: 24),
              _buildQuickActions(),
              SizedBox(height: 24),
              _buildTodayMedicines(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF5F5DC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8D6E63).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _isProtectorMode ? Icons.shield : Icons.medical_services,
            size: 48,
            color: Color(0xFFFF9800),
          ),
          SizedBox(height: 16),
          Text(
            _isProtectorMode ? '보호자 모드' : '환자 모드',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 8),
          Text(
            _isProtectorMode 
                ? '환자의 복약을 관리하고 모니터링하세요'
                : '오늘도 건강한 복용을 시작해보세요',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFA1887F),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF8D6E63).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '빠른 액션',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D6E63),
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.medication,
                  title: '복용 체크',
                  onTap: () {
                    // 복용 체크 기능
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add,
                  title: '약물 추가',
                  onTap: () {
                    // 약물 추가 기능
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.schedule,
                  title: '알림 설정',
                  onTap: () {
                    // 알림 설정 기능
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.history,
                  title: '복용 기록',
                  onTap: () {
                    // 복용 기록 기능
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFF5F5DC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xFFD7CCC8)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Color(0xFFFF9800),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF8D6E63),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMedicines() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8D6E63).withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 복용',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8D6E63),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 64,
                      color: Color(0xFFA1887F),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '등록된 약물이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFA1887F),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '약물을 추가해보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA1887F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProtectorModeDialog() {
    if (_isProtectorMode) {
      // 보호자 모드에서 환자 모드로 전환
      setState(() {
        _isProtectorMode = false;
      });
      _showModeChangeSnackBar('환자 모드로 전환되었습니다');
    } else {
      // 환자 모드에서 보호자 모드로 전환
      if (!_isProtectorPasswordSet) {
        // 처음 보호자 모드 설정
        _showProtectorPasswordSetupDialog();
      } else {
        // 기존 비밀번호로 보호자 모드 진입
        _showProtectorPasswordDialog();
      }
    }
  }

  void _showProtectorPasswordSetupDialog() {
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.shield, color: Color(0xFFFF9800)),
              SizedBox(width: 8),
              Text(
                '보호자 모드 설정',
                style: TextStyle(
                  color: Color(0xFF8D6E63),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '보호자 모드를 사용하려면\n4자리 비밀번호를 설정해주세요',
                style: TextStyle(
                  color: Color(0xFF8D6E63),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5DC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFFD7CCC8)),
                ),
                child: TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8D6E63),
                  ),
                  decoration: InputDecoration(
                    hintText: '새 비밀번호 (4자리)',
                    hintStyle: TextStyle(color: Color(0xFFA1887F)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    counterText: "",
                  ),
                ),
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5DC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFFD7CCC8)),
                ),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8D6E63),
                  ),
                  decoration: InputDecoration(
                    hintText: '비밀번호 확인 (4자리)',
                    hintStyle: TextStyle(color: Color(0xFFA1887F)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    counterText: "",
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(color: Color(0xFFA1887F)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _setupProtectorPassword();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '설정',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _setupProtectorPassword() {
    if (_newPasswordController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('4자리 비밀번호를 입력해주세요'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('비밀번호가 일치하지 않습니다'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 보호자 비밀번호 설정
    _protectorPassword = _newPasswordController.text;
    _isProtectorPasswordSet = true;
    _isProtectorMode = true;

    Navigator.of(context).pop();
    _showModeChangeSnackBar('보호자 모드가 설정되었습니다');
  }

  void _showProtectorPasswordDialog() {
    _protectorPasswordController.clear();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.shield, color: Color(0xFFFF9800)),
              SizedBox(width: 8),
              Text(
                '보호자 모드',
                style: TextStyle(
                  color: Color(0xFF8D6E63),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '보호자 모드로 전환하려면\n비밀번호를 입력해주세요',
                style: TextStyle(
                  color: Color(0xFF8D6E63),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5DC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFFD7CCC8)),
                ),
                child: TextField(
                  controller: _protectorPasswordController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8D6E63),
                  ),
                  decoration: InputDecoration(
                    hintText: '비밀번호 입력',
                    hintStyle: TextStyle(color: Color(0xFFA1887F)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    counterText: "",
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '취소',
                style: TextStyle(color: Color(0xFFA1887F)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _checkProtectorPassword();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9800),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '확인',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _checkProtectorPassword() {
    if (_protectorPasswordController.text == _protectorPassword) {
      Navigator.of(context).pop();
      setState(() {
        _isProtectorMode = true;
      });
      _showModeChangeSnackBar('보호자 모드로 전환되었습니다');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('비밀번호가 올바르지 않습니다'),
              ),
            ],
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showModeChangeSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isProtectorMode ? Icons.shield : Icons.medical_services,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Color(0xFFFF9800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _protectorPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
