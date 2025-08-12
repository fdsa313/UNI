import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../services/smart_analysis_service.dart';
import '../services/api_service.dart'; // Added import for ApiService
import '../services/pdf_service.dart'; // PDF 생성 서비스 추가
import 'dart:io';
import 'package:flutter/services.dart';

// 채팅 메시지 모델 클래스
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ProgressReportScreen extends StatefulWidget {
  final String? userName;
  
  const ProgressReportScreen({super.key, this.userName});

  @override
  State<ProgressReportScreen> createState() => _ProgressReportScreenState();
}

class _ProgressReportScreenState extends State<ProgressReportScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _progressData;
  String? _aiReport;
  final OpenAIService _openAIService = OpenAIService();
  final SmartAnalysisService _smartAnalysisService = SmartAnalysisService();
  final PDFService _pdfService = PDFService(); // PDF 서비스 추가
  
  // 채팅 관련 상태 변수 추가
  final List<ChatMessage> _chatMessages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isChatLoading = false;
  
  // 사용자 이름을 가져오는 함수
  String get _userName {
    return widget.userName ?? '돌쇠님';
  }

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // API에서 환자별 데이터를 가져오기 시도
      final apiData = await ApiService.getPatientData(_userName);
      
      if (apiData != null) {
        // API에서 데이터를 가져온 경우
        setState(() {
          _progressData = apiData;
          _isLoading = false;
        });
        print('API에서 환자 데이터 로드 성공: $_userName');
      } else {
        // API에서 데이터를 가져올 수 없는 경우, 기본 데이터 생성
        print('API에서 데이터를 찾을 수 없음, 기본 데이터 생성: $_userName');
        final patientData = _generatePatientSpecificData(_userName);
        
        // 기본 데이터를 API에 저장
        final saveSuccess = await ApiService.savePatientData(_userName, patientData);
        if (saveSuccess) {
          print('기본 데이터 API 저장 성공: $_userName');
        } else {
          print('기본 데이터 API 저장 실패: $_userName');
        }
        
        setState(() {
          _progressData = patientData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('API 호출 오류, 기본 데이터 사용: $e');
      // API 호출 실패 시 기본 데이터 사용
      final patientData = _generatePatientSpecificData(_userName);
      setState(() {
        _progressData = patientData;
        _isLoading = false;
      });
    }
  }

  // 환자별 개별 데이터 생성
  Map<String, dynamic> _generatePatientSpecificData(String patientName) {
    // 환자별로 다른 데이터 생성
    switch (patientName) {
      case '김철수님':
        return {
          'quizResults': [
            {'date': '2024-08-11', 'score': 4, 'total': 5, 'time': '15분'},
            {'date': '2024-08-10', 'score': 3, 'total': 5, 'time': '20분'},
            {'date': '2024-08-09', 'score': 5, 'total': 5, 'time': '12분'},
          ],
          'medicationCompliance': 85.0,
          'moodTrend': [
            {'date': '2024-08-11', 'mood': '좋음', 'score': 4},
            {'date': '2024-08-10', 'mood': '보통', 'score': 3},
            {'date': '2024-08-09', 'mood': '좋음', 'score': 4},
          ],
          'cognitiveScore': 75.0,
          'recommendations': [
            '정기적인 퀴즈 참여로 인지 능력 향상',
            '약물 복용 시간 준수 필요',
            '긍정적인 기분 유지가 중요',
          ],
        };
      
      case '돌쇠님':
        return {
          'quizResults': [
            {'date': '2024-08-11', 'score': 2, 'total': 5, 'time': '25분'},
            {'date': '2024-08-10', 'score': 1, 'total': 5, 'time': '30분'},
            {'date': '2024-08-09', 'score': 3, 'total': 5, 'time': '28분'},
          ],
          'medicationCompliance': 65.0,
          'moodTrend': [
            {'date': '2024-08-11', 'mood': '보통', 'score': 3},
            {'date': '2024-08-10', 'mood': '나쁨', 'score': 2},
            {'date': '2024-08-09', 'mood': '보통', 'score': 3},
          ],
          'cognitiveScore': 45.0,
          'recommendations': [
            '더 자주 퀴즈에 참여하여 인지 능력 향상 필요',
            '약물 복용을 더욱 철저히 관리해야 함',
            '기분 개선을 위한 활동과 관심이 필요',
          ],
        };
      
      case '박영희님':
        return {
          'quizResults': [
            {'date': '2024-08-11', 'score': 5, 'total': 5, 'time': '10분'},
            {'date': '2024-08-10', 'score': 4, 'total': 5, 'time': '12분'},
            {'date': '2024-08-09', 'score': 5, 'total': 5, 'time': '11분'},
          ],
          'medicationCompliance': 95.0,
          'moodTrend': [
            {'date': '2024-08-11', 'mood': '매우 좋음', 'score': 5},
            {'date': '2024-08-10', 'mood': '좋음', 'score': 4},
            {'date': '2024-08-09', 'mood': '매우 좋음', 'score': 5},
          ],
          'cognitiveScore': 88.0,
          'recommendations': [
            '현재 상태를 잘 유지하고 있습니다',
            '정기적인 운동과 사회적 활동 권장',
            '인지 훈련을 지속하여 더욱 향상시키세요',
          ],
        };
      
      default:
        // 기본 데이터 (새로운 환자)
        return {
          'quizResults': [
            {'date': '2024-08-11', 'score': 0, 'total': 5, 'time': '0분'},
            {'date': '2024-08-10', 'score': 0, 'total': 5, 'time': '0분'},
            {'date': '2024-08-09', 'score': 0, 'total': 5, 'time': '0분'},
          ],
          'medicationCompliance': 0.0,
          'moodTrend': [
            {'date': '2024-08-11', 'mood': '기록 없음', 'score': 0},
            {'date': '2024-08-10', 'mood': '기록 없음', 'score': 0},
            {'date': '2024-08-09', 'mood': '기록 없음', 'score': 0},
          ],
          'cognitiveScore': 0.0,
          'recommendations': [
            '첫 퀴즈 참여를 권장합니다',
            '약물 복용 기록을 시작해주세요',
            '기분 상태를 기록해주세요',
          ],
        };
    }
  }

  Future<void> _generateAIReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('DEBUG: AI 보고서 생성 시작');
      
      // _progressData가 null인지 확인
      if (_progressData == null) {
        print('DEBUG: _progressData가 null입니다. 기본 데이터로 초기화합니다.');
        _progressData = {
          'quizResults': [],
          'medicationCompliance': 0.0,
          'moodTrend': [],
          'cognitiveScore': 0.0,
        };
      }
      
      print('DEBUG: _progressData 상태: $_progressData');
      
      // ChatGPT API 호출
      print('DEBUG: ChatGPT API 호출 시작');
      final aiReport = await _callChatGPT();
      print('DEBUG: ChatGPT 응답 받음: ${aiReport.length}자');
      
      setState(() {
        _aiReport = aiReport;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI 보고서가 생성되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e, stackTrace) {
      print('ERROR: 보고서 생성 실패: $e');
      print('ERROR: 스택 트레이스: $stackTrace');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('보고서 생성에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _callChatGPT() async {
    try {
      print('DEBUG: OpenAI API 호출 시작');
      
      // _progressData가 null인지 확인
      if (_progressData == null) {
        print('DEBUG: _progressData가 null입니다. 기본 데이터로 초기화합니다.');
        _progressData = {
          'quizResults': [],
          'medicationCompliance': 0.0,
          'moodTrend': [],
          'cognitiveScore': 0.0,
        };
      }
      
      // OpenAI API에서 기대하는 형식으로 데이터 변환
      final openAIData = {
        'quizResults': _progressData!['quiz_results'] ?? [],
        'medicationCompliance': _progressData!['medication_compliance'] ?? 0.0,
        'moodTrend': _progressData!['mood_trend'] ?? [],
        'cognitiveScore': _progressData!['cognitive_score'] ?? 0.0,
      };
      
      print('DEBUG: OpenAI API 호출 데이터: $_progressData');
      print('DEBUG: OpenAI API 변환된 데이터: $openAIData');
      
      // OpenAI API를 통해 AI 보고서 생성
      final aiReport = await _openAIService.generateMedicalReport(
        patientName: _userName,
        progressData: openAIData,
      );
      
      print('DEBUG: OpenAI API 응답 받음: ${aiReport.length}자');
      return aiReport;
      
    } catch (e) {
      print('ERROR: OpenAI API 호출 실패: $e');
      print('DEBUG: 스마트 분석 서비스로 대체');
      
      // API 호출 실패 시 스마트 분석 서비스 사용
      final smartReport = _smartAnalysisService.generateSmartMedicalReport(
        patientName: _userName,
        progressData: _progressData ?? {
          'quiz_results': [],
          'medication_compliance': 0.0,
          'mood_trend': [],
          'cognitive_score': 0.0,
        },
      );
      
      print('DEBUG: 스마트 분석 보고서 생성: ${smartReport.length}자');
      return smartReport;
    }
  }

  // 채팅 메시지 보내기
  Future<void> _sendChatMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // 사용자 메시지 추가
    setState(() {
      _chatMessages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isChatLoading = true;
    });
    
    _messageController.clear();
    
    // 스크롤을 맨 아래로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      // GPT API 호출 전에 데이터 형식 변환
      final openAIData = {
        'quizResults': _progressData!['quiz_results'] ?? [],
        'medicationCompliance': _progressData!['medication_compliance'] ?? 0.0,
        'moodTrend': _progressData!['mood_trend'] ?? [],
        'cognitiveScore': _progressData!['cognitive_score'] ?? 0.0,
      };
      
      // GPT API 호출하여 응답 생성
      final response = await _openAIService.generateChatResponse(
        userMessage: message,
        patientName: _userName,
        progressData: openAIData,
      );

      // AI 응답 추가
      setState(() {
        _chatMessages.add(ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isChatLoading = false;
      });
      
      // AI 응답 후에도 스크롤을 맨 아래로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('ERROR: 채팅 응답 생성 실패: $e');
      
      // 에러 메시지 추가
      setState(() {
        _chatMessages.add(ChatMessage(
          text: '죄송합니다. 응답을 생성하는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isChatLoading = false;
      });
      
      // 에러 메시지 후에도 스크롤을 맨 아래로 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  // 평균 퀴즈 정답률 계산
  int _calculateAverageQuizScore() {
    if (_progressData == null || _progressData!['quizResults'].isEmpty) return 0;
    
    int totalScore = 0;
    int totalQuestions = 0;
    
    for (var quiz in _progressData!['quizResults']) {
      totalScore += quiz['score'] as int;
      totalQuestions += quiz['total'] as int;
    }
    
    if (totalQuestions == 0) return 0;
    return ((totalScore / totalQuestions) * 100).round();
  }

  // PDF 생성 메서드
  Future<void> _generatePDF() async {
    if (_aiReport == null || _aiReport!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 AI 분석 보고서를 생성해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // PDF 생성
      final String filePath = await _pdfService.generateAnalysisPDF(
        patientName: _userName,
        aiReport: _aiReport!,
        progressData: _progressData ?? {},
        reportType: 'ai',
      );

      setState(() {
        _isLoading = false;
      });

      // 성공 메시지
      if (mounted) {
        if (filePath.startsWith('web_generated')) {
          // 웹 환경: 클립보드 복사 안내
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('PDF가 생성되었습니다! 클립보드에 복사되었습니다.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: '사용법 보기',
                onPressed: () {
                  _showWebPDFUsageDialog(context);
                },
              ),
            ),
          );
        } else {
          // 모바일 환경: 파일 열기 옵션
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF가 생성되었습니다: ${filePath.split('/').last}'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: '파일 열기',
                onPressed: () {
                  _openPDFFile(filePath);
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF 생성 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // PDF 파일 열기
  void _openPDFFile(String filePath) {
    // 플랫폼별 파일 열기 로직
    // 웹에서는 다운로드, 모바일에서는 파일 뷰어
    print('PDF 파일 경로: $filePath');
    // TODO: 플랫폼별 파일 열기 구현
  }

  // 웹 환경에서 PDF 사용법 다이얼로그 표시
  void _showWebPDFUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('PDF 사용법'),
          content: const Text(
            '웹 환경에서는 PDF 파일을 직접 다운로드하여 사용할 수 있습니다.\n'
            '클립보드에 복사된 PDF는 브라우저의 기본 다운로드 메뉴를 통해 접근할 수 있습니다.\n'
            '파일을 다운로드하여 원하는 위치에 저장하고 열어보세요.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // AI 보고서 텍스트를 클립보드에 복사하는 메서드
  Future<void> _copyReportToClipboard() async {
    if (_aiReport == null || _aiReport!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI 보고서가 없습니다.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: _aiReport!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI 보고서가 클립보드에 복사되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI 보고서 복사에 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('진행상황 AI 보고서'),
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
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 헤더
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.analytics,
                                size: 48,
                                color: Color(0xFFFFB74D),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_userName}님의 진행상황',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE65100),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'AI가 분석한 맞춤형 보고서를 확인하세요',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF8D6E63),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // AI 보고서 생성 버튼
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _generateAIReport,
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text(
                              'AI 보고서 생성',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFB74D),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // AI 보고서 표시
                        if (_aiReport != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'AI 분석 보고서',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // 텍스트 복사 버튼
                                        ElevatedButton.icon(
                                          onPressed: () => _copyReportToClipboard(),
                                          icon: const Icon(Icons.copy),
                                          label: const Text('복사'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF4CAF50),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // PDF 생성 버튼
                                        ElevatedButton.icon(
                                          onPressed: _generatePDF,
                                          icon: const Icon(Icons.picture_as_pdf),
                                          label: const Text('PDF'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFE65100),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _aiReport!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF8D6E63),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // 실시간 AI 상담 채팅
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    color: const Color(0xFFE65100),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    '실시간 AI 상담',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE65100),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'AI 의료 상담사와 실시간으로 대화하세요. 치매 관리, 일상생활, 의학적 질문 등 무엇이든 물어보세요.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8D6E63),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // 채팅 메시지 목록
                              if (_chatMessages.isNotEmpty) ...[
                                Container(
                                  height: 300,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    controller: _chatScrollController,
                                    padding: const EdgeInsets.all(12),
                                    itemCount: _chatMessages.length,
                                    itemBuilder: (context, index) {
                                      final message = _chatMessages[index];
                                      return _buildChatMessage(message);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // 로딩 인디케이터
                              if (_isChatLoading) ...[
                                Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'AI가 응답을 생성하고 있습니다...',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF1976D2),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                              
                              // 메시지 입력 필드
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      decoration: InputDecoration(
                                        hintText: '질문이나 궁금한 점을 입력하세요...',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFFF5F5F5),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      maxLines: 1,
                                      onSubmitted: (_) => _sendChatMessage(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE65100),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: IconButton(
                                      onPressed: _sendChatMessage,
                                      icon: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 진행상황 요약
                        if (_progressData != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: const Color(0xFFE65100),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      '진행상황 요약',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE65100),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '상세한 진행상황과 환자 관리 정보는 "환자 관리" 메뉴에서 확인할 수 있습니다.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF8D6E63),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed('/patient-management', arguments: _userName);
                                    },
                                    icon: const Icon(Icons.person),
                                    label: const Text('환자 관리로 이동'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE65100),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isUser ? const Color(0xFFE65100) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: message.isUser ? Colors.white70 : Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
