import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'caregiver_mode_screen.dart';
import '../services/supabase_service.dart';

class CaregiverPasswordScreen extends StatefulWidget {
  final String? userName;
  
  const CaregiverPasswordScreen({super.key, this.userName});

  @override
  State<CaregiverPasswordScreen> createState() => _CaregiverPasswordScreenState();
}

class _CaregiverPasswordScreenState extends State<CaregiverPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  
  bool _isPasswordSet = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureCurrentPassword = true;
  bool _isLoading = false;
  bool _isCheckingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkPasswordStatus();
  }

  Future<void> _checkPasswordStatus() async {
    setState(() {
      _isCheckingStatus = true;
    });
    
    try {
      final hasPassword = await SupabaseService.hasCaregiverPassword();
      print('DEBUG: _checkPasswordStatus - Supabase에 비밀번호 존재: $hasPassword'); // 디버그 로그
      
      if (mounted) {
        setState(() {
          _isPasswordSet = hasPassword;
          _isCheckingStatus = false;
        });
      }
    } catch (e) {
      print('❌ 비밀번호 상태 확인 오류: $e');
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('비밀번호 상태 확인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setPassword() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 일치하지 않습니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호는 최소 4자 이상이어야 합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('=== 비밀번호 설정 시도 ===');
      print('비밀번호: ${_passwordController.text}');
      print('비밀번호 길이: ${_passwordController.text.length}');
      
      // Supabase 연결 상태 확인
      if (!SupabaseService.isConnected()) {
        print('❌ Supabase 연결 실패');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('서버 연결에 실패했습니다. 인터넷 연결을 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // 현재 사용자 확인
      final currentUser = await SupabaseService.getCurrentUser();
      if (currentUser == null) {
        print('❌ 로그인된 사용자가 없음');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 상태가 아닙니다. 다시 로그인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      print('✅ Supabase 클라이언트 상태: 연결됨');
      print('✅ 현재 사용자: ${currentUser.email}');
      
      // Supabase에 비밀번호 저장
      final success = await SupabaseService.setCaregiverPassword(_passwordController.text);
      
      print('SupabaseService 결과: $success');
      
      if (success) {
        print('✅ 비밀번호 설정 성공!');
        setState(() {
          _isPasswordSet = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 성공적으로 설정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );

        // 비밀번호 입력 필드 초기화
        _passwordController.clear();
        _confirmPasswordController.clear();
      } else {
        print('❌ 비밀번호 설정 실패!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호 설정에 실패했습니다. 잠시 후 다시 시도해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ 비밀번호 설정 오류: $e');
      print('스택 트레이스: $stackTrace');
      
      String errorMessage = '알 수 없는 오류가 발생했습니다.';
      if (e.toString().contains('network')) {
        errorMessage = '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.';
      } else if (e.toString().contains('table')) {
        errorMessage = '데이터베이스 오류가 발생했습니다. 관리자에게 문의해주세요.';
      } else if (e.toString().contains('auth')) {
        errorMessage = '인증 오류가 발생했습니다. 다시 로그인해주세요.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('=== 비밀번호 확인 시작 ===');
      
      // Supabase 연결 상태 확인
      if (!SupabaseService.isConnected()) {
        print('❌ Supabase 연결 실패');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('서버 연결에 실패했습니다. 인터넷 연결을 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // 현재 사용자 확인
      final currentUser = await SupabaseService.getCurrentUser();
      if (currentUser == null) {
        print('❌ 로그인된 사용자가 없음');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 상태가 아닙니다. 다시 로그인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      print('✅ 현재 사용자: ${currentUser.email}');
      
      final isValid = await SupabaseService.verifyCaregiverPassword(_currentPasswordController.text);
      print('비밀번호 확인 결과: $isValid');
      
      if (isValid) {
        print('✅ 비밀번호 확인 성공!');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => CaregiverModeScreen(userName: widget.userName),
          ),
        );
      } else {
        print('❌ 비밀번호 확인 실패');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호가 올바르지 않습니다. 다시 확인해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
        _currentPasswordController.clear();
      }
    } catch (e) {
      print('❌ 비밀번호 확인 중 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호 확인 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    // 현재 비밀번호 확인 다이얼로그 표시
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('비밀번호 초기화'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '비밀번호를 초기화하려면\n현재 비밀번호를 입력해주세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '현재 비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  print('=== 비밀번호 초기화 시작 ===');
                  
                  // Supabase 연결 상태 확인
                  if (!SupabaseService.isConnected()) {
                    print('❌ Supabase 연결 실패');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('서버 연결에 실패했습니다. 인터넷 연결을 확인해주세요.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  // 현재 사용자 확인
                  final currentUser = await SupabaseService.getCurrentUser();
                  if (currentUser == null) {
                    print('❌ 로그인된 사용자가 없음');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('로그인 상태가 아닙니다. 다시 로그인해주세요.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  
                  print('✅ 현재 사용자: ${currentUser.email}');
                  
                  final isValid = await SupabaseService.verifyCaregiverPassword(confirmPasswordController.text);
                  print('비밀번호 확인 결과: $isValid');
                  
                  if (isValid) {
                    print('✅ 비밀번호 확인 성공, 초기화 진행');
                    // 비밀번호가 맞으면 초기화
                    final success = await SupabaseService.deleteCaregiverPassword();
                    if (success) {
                      print('✅ 비밀번호 초기화 성공');
                      Navigator.of(context).pop();
                      
                      setState(() {
                        _isPasswordSet = false;
                      });
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('비밀번호가 성공적으로 초기화되었습니다.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else {
                      print('❌ 비밀번호 초기화 실패');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('비밀번호 초기화에 실패했습니다. 잠시 후 다시 시도해주세요.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    print('❌ 비밀번호 확인 실패');
                    // 비밀번호가 틀리면 오류 메시지
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('비밀번호가 올바르지 않습니다. 다시 확인해주세요.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    confirmPasswordController.clear();
                  }
                } catch (e) {
                  print('❌ 비밀번호 초기화 중 오류: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('비밀번호 초기화 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('초기화'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 비밀번호가 설정되지 않은 경우 비밀번호 설정 화면 표시
    if (_isCheckingStatus) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('보호자 모드'),
          backgroundColor: const Color(0xFFFFB74D),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
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
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFFFB74D),
                  strokeWidth: 3,
                ),
                SizedBox(height: 24),
                Text(
                  '비밀번호 상태를 확인하는 중...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8D6E63),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (!_isPasswordSet) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('보호자 모드'),
          backgroundColor: const Color(0xFFFFB74D),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 아이콘
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 제목
                  const Text(
                    '보호자 모드 비밀번호 설정',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 설명
                  const Text(
                    '보호자 모드에 진입할 때 사용할\n비밀번호를 설정해주세요.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8D6E63),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // 비밀번호 설정 폼
                  Column(
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: '새 비밀번호',
                          hintText: '4자 이상 입력',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: '비밀번호 확인',
                          hintText: '다시 한 번 입력',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _setPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB74D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  '비밀번호 설정',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 비밀번호가 설정된 경우 비밀번호 확인 화면 표시
    return Scaffold(
      appBar: AppBar(
        title: const Text('보호자 모드'),
        backgroundColor: const Color(0xFFFFB74D),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB74D),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 제목
                const Text(
                  '보호자 모드 비밀번호',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // 설명
                const Text(
                  '보호자 모드에 진입하려면\n비밀번호를 입력해주세요.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8D6E63),
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // 비밀번호 확인 폼
                Column(
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        hintText: '비밀번호를 입력하세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword = !_obscureCurrentPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB74D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                '보호자 모드 진입',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        '비밀번호 초기화',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }
}
