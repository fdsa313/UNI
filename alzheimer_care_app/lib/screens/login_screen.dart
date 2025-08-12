import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 실제 API 호출
        final result = await ApiService.login(
          _emailController.text,
          _passwordController.text,
        );
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          if (result['success']) {
            // 로그인 성공
            final userData = result['data']['user'];
            final userName = userData['name'] ?? '사용자';
            
            // 홈 화면으로 이동하면서 사용자 이름 전달
            Navigator.of(context).pushReplacementNamed('/home', arguments: userName);
          } else {
            // 로그인 실패
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? '로그인에 실패했습니다.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('네트워크 오류가 발생했습니다.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 600;
    final isWideScreen = screenWidth > 600;
    
    return Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideScreen ? 40 : 24,
                    vertical: isSmallScreen ? 16 : 24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 로고 및 앱 제목
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
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
                              Container(
                                width: isSmallScreen ? 60 : 80,
                                height: isSmallScreen ? 60 : 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB74D),
                                  borderRadius: BorderRadius.circular(isSmallScreen ? 15 : 20),
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: isSmallScreen ? 30 : 40,
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              Text(
                                '하이머딩거',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE65100),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '사랑하는 가족을 위한 케어 앱',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 12 : 14,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 24 : 32),
                        
                        // 로그인 폼
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '로그인',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE65100),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isSmallScreen ? 20 : 24),
                              
                              // 이메일 입력 필드
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: '이메일',
                                  hintText: 'example@email.com',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFFFB74D), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: isSmallScreen ? 12 : 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '이메일을 입력해주세요';
                                  }
                                  return null;
                                },
                              ),
                              
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              
                              // 비밀번호 입력 필드
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: '비밀번호',
                                  hintText: '비밀번호를 입력하세요',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                      color: const Color(0xFF9CA3AF),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Color(0xFFFFB74D), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: isSmallScreen ? 12 : 16,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '비밀번호를 입력해주세요';
                                  }
                                  return null;
                                },
                              ),
                              
                              SizedBox(height: isSmallScreen ? 20 : 24),
                              
                              // 로그인 버튼
                              ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFB74D),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: isSmallScreen ? 16 : 20,
                                        height: isSmallScreen ? 16 : 20,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        '로그인',
                                        style: TextStyle(
                                          fontSize: isSmallScreen ? 14 : 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              
                              // 회원가입 링크
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '계정이 없으신가요? ',
                                    style: TextStyle(
                                      color: const Color(0xFF6B7280),
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/signup');
                                    },
                                    child: Text(
                                      '회원가입',
                                      style: TextStyle(
                                        color: const Color(0xFFE65100),
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}
