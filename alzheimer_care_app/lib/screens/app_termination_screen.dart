import 'package:flutter/material.dart';
import 'dart:async';

class AppTerminationScreen extends StatefulWidget {
  const AppTerminationScreen({super.key});

  @override
  State<AppTerminationScreen> createState() => _AppTerminationScreenState();
}

class _AppTerminationScreenState extends State<AppTerminationScreen> {
  int _countdown = 15;
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
        _progress = (15 - _countdown) / 15;
      });

      if (_countdown <= 0) {
        timer.cancel();
        // 앱 종료 로직 (실제로는 SystemNavigator.pop() 등을 사용)
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 가족 영상 재생 카드
              Container(
                width: 300,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 가족 아이콘
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB74D),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.family_restroom,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 메시지
                    const Text(
                      '가족 영상 재생 중...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '사랑하는 가족들과 함께한',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                    const Text(
                      '소중한 시간들을 보여드립니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 카운트다운 메시지
              Text(
                '$_countdown초 후 앱이 종료됩니다',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFE65100),
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 진행 바
              Container(
                width: 300,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
