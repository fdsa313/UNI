import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF8E1), // 따뜻한 크림색
              Color(0xFFFFF3E0), // 연한 오렌지 크림
              Color(0xFFFFE0B2), // 베이지 오렌지
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 60),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildLogo(),
                    ),
                    SizedBox(height: 40),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildTitle(),
                      ),
                    ),
                    SizedBox(height: 60),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildLoginForm(),
                      ),
                    ),
                    SizedBox(height: 30),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildSignUpLink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF9800), // 따뜻한 오렌지
            Color(0xFFFF8A65), // 연한 오렌지
            Color(0xFFFF7043), // 진한 오렌지
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF9800).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.medical_services,
        size: 70,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          '복약 관리',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8D6E63), // 따뜻한 갈색
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '가족과 함께하는 건강한 복용',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFFA1887F), // 연한 갈색
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF9800), Color(0xFFFF8A65)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(24),
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
        children: [
          Text(
            '로그인',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8D6E63), // 따뜻한 갈색
            ),
          ),
          SizedBox(height: 30),
          _buildEmailField(),
          SizedBox(height: 20),
          _buildPasswordField(),
          SizedBox(height: 30),
          _buildLoginButton(),
          SizedBox(height: 20),
          _buildForgotPassword(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5F5DC), // 베이지색 배경
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFD7CCC8)), // 연한 갈색 테두리
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 16, color: Color(0xFF8D6E63)),
        decoration: InputDecoration(
          labelText: '이메일',
          labelStyle: TextStyle(color: Color(0xFFA1887F)),
          prefixIcon: Icon(Icons.email, color: Color(0xFFFF9800)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: _validateEmail,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF5F5DC), // 베이지색 배경
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFD7CCC8)), // 연한 갈색 테두리
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(fontSize: 16, color: Color(0xFF8D6E63)),
        decoration: InputDecoration(
          labelText: '비밀번호',
          labelStyle: TextStyle(color: Color(0xFFA1887F)),
          prefixIcon: Icon(Icons.lock, color: Color(0xFFFF9800)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: Color(0xFFA1887F),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: _validatePassword,
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF8A65)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF9800).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
          '로그인',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {
        // 비밀번호 찾기 기능
      },
      child: Text(
        '비밀번호를 잊으셨나요?',
        style: TextStyle(
          color: Color(0xFFFF9800),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFD7CCC8).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '계정이 없으신가요? ',
            style: TextStyle(
              color: Color(0xFF8D6E63),
              fontSize: 16,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => SignUpScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
              );
            },
            child: Text(
              '회원가입',
              style: TextStyle(
                color: Color(0xFFFF9800),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '올바른 이메일 형식을 입력해주세요';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    if (value.length < 6) {
      return '비밀번호는 6자 이상이어야 합니다';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 실제 HTTP 요청 (테스트용 더미 데이터 사용)
      final result = await ApiService.loginTest(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        // 로그인 성공 시 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.toString().replaceAll('Exception: ', ''),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFFFF5722),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
