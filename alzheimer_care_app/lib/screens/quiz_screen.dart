import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final String? userName;
  
  const QuizScreen({super.key, this.userName});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  int _score = 0;
  bool _quizCompleted = false;
  List<Map<String, dynamic>> _answers = [];
  DateTime? _quizStartTime;

  // 사용자 이름을 가져오는 함수
  String get _userName {
    return widget.userName ?? '돌쇠님';
  }

  @override
  void initState() {
    super.initState();
    _quizStartTime = DateTime.now();
  }

  // 퀴즈 문제들
  final List<Map<String, dynamic>> _questions = [
    {
      'question': '오늘은 무슨 요일인가요?',
      'options': ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
      'correctAnswer': '금요일', // 예시 답안
    },
    {
      'question': '지금은 몇 시인가요?',
      'options': ['아침', '점심', '저녁', '밤'],
      'correctAnswer': '점심', // 예시 답안
    },
    {
      'question': '오늘 날씨는 어떤가요?',
      'options': ['맑음', '흐림', '비', '눈'],
      'correctAnswer': '맑음', // 예시 답안
    },
    {
      'question': '지금 계절은 무엇인가요?',
      'options': ['봄', '여름', '가을', '겨울'],
      'correctAnswer': '여름', // 예시 답안
    },
    {
      'question': '오늘은 몇 월인가요?',
      'options': ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
      'correctAnswer': '8월', // 예시 답안
    },
  ];

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() async {
    if (_selectedAnswer == null) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswer == currentQuestion['correctAnswer'];
    
    if (isCorrect) {
      _score++;
    }

    // 답안 기록
    _answers.add({
      'question': currentQuestion['question'],
      'selectedAnswer': _selectedAnswer,
      'correctAnswer': currentQuestion['correctAnswer'],
      'isCorrect': isCorrect,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      // 퀴즈 완료 - 결과 저장
      await _saveQuizResult();
      
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  // 퀴즈 결과 저장
  Future<void> _saveQuizResult() async {
    try {
      final endTime = DateTime.now();
      final duration = endTime.difference(_quizStartTime!).inMinutes;
      
      final success = await ApiService.saveQuizResult(
        _userName,
        _score,
        _questions.length,
        duration,
        _answers,
      );
      
      if (success) {
        print('퀴즈 결과 저장 성공: $_score/${_questions.length}');
      } else {
        print('퀴즈 결과 저장 실패');
      }
    } catch (e) {
      print('퀴즈 결과 저장 오류: $e');
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _score = 0;
      _quizCompleted = false;
      _answers.clear();
      _quizStartTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('퀴즈'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFFE65100),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 홈으로 돌아가기
            Navigator.of(context).pop(false);
          },
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
            padding: const EdgeInsets.all(16.0),
            child: _quizCompleted ? _buildQuizResult() : _buildQuizQuestion(),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizQuestion() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      children: [
        // 진행률 표시
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
              Text(
                '문제 ${_currentQuestionIndex + 1} / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8D6E63),
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFB74D)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 문제
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
              const Icon(
                Icons.quiz,
                size: 48,
                color: Color(0xFFFFB74D),
              ),
              const SizedBox(height: 16),
              Text(
                currentQuestion['question'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 답안 옵션들
        Expanded(
          child: ListView.builder(
            itemCount: (currentQuestion['options'] as List).length,
            itemBuilder: (context, index) {
              final option = currentQuestion['options'][index];
              final isSelected = _selectedAnswer == option;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () => _selectAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? const Color(0xFFFFB74D) : Colors.white,
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFFFB74D) : Colors.grey.shade300,
                      ),
                    ),
                    elevation: isSelected ? 4 : 1,
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 답안 제출 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _selectedAnswer != null ? _submitAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB74D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '답안 제출',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizResult() {
    final percentage = (_score / _questions.length * 100).round();
    String message;
    Color messageColor;

    if (percentage >= 80) {
      message = '훌륭합니다! 인지 능력이 좋습니다!';
      messageColor = Colors.green;
    } else if (percentage >= 60) {
      message = '좋습니다! 조금 더 노력해보세요!';
      messageColor = Colors.orange;
    } else {
      message = '괜찮습니다! 천천히 다시 해보세요!';
      messageColor = Colors.red;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
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
              const Icon(
                Icons.celebration,
                size: 64,
                color: Color(0xFFFFB74D),
              ),
              const SizedBox(height: 24),
              Text(
                '퀴즈 완료!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '점수: $_score / ${_questions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFB74D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '정답률: $percentage%',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF8D6E63),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: messageColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // 홈으로 돌아가기 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // 퀴즈 완료 결과를 홈화면에 전달
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '홈으로 돌아가기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 다시 시작하기 버튼
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _restartQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB74D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '다시 시작하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
