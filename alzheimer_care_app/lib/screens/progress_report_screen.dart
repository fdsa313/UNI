import 'package:flutter/material.dart';
import '../services/smart_analysis_service.dart';
import '../services/medication_service.dart'; // 약물 복용 기록 서비스 추가
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

  // 진행상황 데이터 로드
  Future<void> _loadProgressData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 사용자 이름을 직접 사용 (widget.userName)
      final patientName = _userName;
      print('환자 진행상황 조회 시도: $patientName');
      
      // SharedPreferences에서 약물 복용 기록 가져오기
      final medicationRecords = await MedicationService.getAllMedicationRecords(patientName);
      
      print('약물 복용 기록: $medicationRecords');
      
      if (medicationRecords.isNotEmpty) {
        print('약물 복용 기록 로드 성공');
        
        // 약물 복용 기록만으로 진행상황 데이터 구성
        final enhancedProgressData = {
          'medicationRecords': medicationRecords,
          'quiz_results': [], // 빈 배열로 초기화
          'medication_compliance': _calculateMedicationCompliance(medicationRecords),
          'mood_trend': [], // 빈 배열로 초기화
          'cognitive_score': 0.0, // 기본값
        };
        
        setState(() {
          _progressData = enhancedProgressData;
        });
        
        // 자동 AI 보고서 생성 비활성화 (사용자가 버튼을 눌러야 생성)
        print('진행상황 데이터 로드 완료. AI 보고서는 수동으로 생성하세요.');
      } else {
        print('약물 복용 기록이 없습니다. 기본 데이터로 초기화');
        _initializeDefaultData();
      }
    } catch (e) {
      print('진행상황 데이터 로드 오류: $e');
      _initializeDefaultData();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 약물 복용률 계산
  double _calculateMedicationCompliance(List<Map<String, dynamic>> medicationRecords) {
    if (medicationRecords.isEmpty) return 0.0;
    
    print('🔍 복용률 계산 시작: ${medicationRecords.length}개 기록');
    
    // 최근 7일간의 복용 기록 계산
    final recentRecords = medicationRecords.take(7).toList();
    int totalDoses = 0;
    int takenDoses = 0;

    for (var record in recentRecords) {
      print('📅 기록 분석: ${record['date']}');
      print('  - 아침: ${record['아침']}');
      print('  - 점심: ${record['점심']}');
      print('  - 저녁: ${record['저녁']}');
      
      // SharedPreferences에 저장된 한국어 키 사용
      if (record['아침'] == true) takenDoses++;
      if (record['점심'] == true) takenDoses++;
      if (record['저녁'] == true) takenDoses++;
      totalDoses += 3;
    }

    final compliance = totalDoses > 0 ? (takenDoses / totalDoses * 100) : 0.0;
    print('📊 복용률 계산 결과: $takenDoses/$totalDoses = ${compliance.toStringAsFixed(1)}%');
    
    return compliance;
  }

  // 기본 데이터 초기화
  void _initializeDefaultData() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final dayBeforeYesterday = today.subtract(const Duration(days: 2));
    
    _progressData = {
      'quizResults': [
        {
          'date': today.toString().substring(0, 10),
          'score': 0,
          'total': 5,
          'time': 0,
        },
        {
          'date': yesterday.toString().substring(0, 10),
          'score': 0,
          'total': 5,
          'time': 0,
        },
        {
          'date': dayBeforeYesterday.toString().substring(0, 10),
          'score': 0,
          'total': 5,
          'time': 0,
        },
      ],
      'medicationCompliance': 0,
      'moodTrend': [
        {
          'date': today.toString().substring(0, 10),
          'mood': '기록 없음',
          'score': 0,
        },
        {
          'date': yesterday.toString().substring(0, 10),
          'mood': '기록 없음',
          'score': 0,
        },
        {
          'date': dayBeforeYesterday.toString().substring(0, 10),
          'mood': '기록 없음',
          'score': 0,
        },
      ],
      'cognitiveScore': 0,
      'recommendations': [
        '첫 퀴즈 참여를 권장합니다',
        '약물 복용 기록을 시작해주세요',
        '기분 상태를 기록해주세요',
      ],
    };
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
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
      print('DEBUG: 스마트 분석 서비스 호출 시작');
      
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
      
      // 스마트 분석 서비스에서 기대하는 형식으로 데이터 변환
      final smartData = {
        'quizResults': _progressData!['quiz_results'] ?? [],
        'medicationCompliance': _progressData!['medication_compliance'] ?? 0.0,
        'moodTrend': _progressData!['mood_trend'] ?? [],
        'cognitiveScore': _progressData!['cognitive_score'] ?? 0.0,
        'medicationRecords': _progressData!['medicationRecords'] ?? [],
      };
      
      print('DEBUG: 스마트 분석 서비스 호출 데이터: $_progressData');
      print('DEBUG: 스마트 분석 서비스 변환된 데이터: $smartData');
      
      // 스마트 분석 서비스를 통해 AI 보고서 생성
      final smartReport = await _smartAnalysisService.generateSmartMedicalReport(
        patientName: _userName,
        progressData: smartData,
      );
      
      print('DEBUG: 스마트 분석 서비스 응답 받음: ${smartReport.length}자');
      return smartReport;
      
    } catch (e) {
      print('ERROR: 스마트 분석 서비스 호출 실패: $e');
      print('DEBUG: 기본 보고서 생성');
      
      // 서비스 호출 실패 시 기본 보고서 생성
      final basicReport = _generateBasicReport();
      
      print('DEBUG: 기본 보고서 생성: ${basicReport.length}자');
      return basicReport;
    }
  }

  // 기본 보고서 생성
  String _generateBasicReport() {
    final medicationRecords = _progressData?['medicationRecords'] ?? [];
    final compliance = _progressData?['medication_compliance'] ?? 0.0;
    
    String report = '${_userName}님의 건강 보고서\n\n';
    
    if (medicationRecords.isNotEmpty) {
      report += '💊 약물 복용 현황:\n';
      report += '• 복용 준수율: ${compliance.toStringAsFixed(1)}%\n';
      report += '• 최근 복용 기록: ${medicationRecords.length}일\n\n';
      
      // 최근 3일간의 복용 기록
      final recentRecords = medicationRecords.take(3).toList();
      for (var record in recentRecords) {
        final date = record['date'] ?? '알 수 없음';
        final morning = record['morning'] == true ? '✅' : '❌';
        final lunch = record['점심'] == true ? '✅' : '❌';
        final evening = record['저녁'] == true ? '✅' : '❌';
        
        report += '$date: 아침$morning 점심$lunch 저녁$evening\n';
      }
    } else {
      report += '💊 약물 복용 기록이 없습니다.\n';
    }
    
    report += '\n📊 권장사항:\n';
    if (compliance >= 80) {
      report += '• 훌륭합니다! 현재 복용률을 유지하세요.\n';
    } else if (compliance >= 60) {
      report += '• 복용률이 양호합니다. 더 높은 준수율을 위해 노력하세요.\n';
    } else {
      report += '• 복용률이 낮습니다. 정기적인 복용을 권장합니다.\n';
    }
    
    return report;
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
      // 간단한 응답 생성 (SmartAnalysisService에는 generateChatResponse가 없음)
      String response = '죄송합니다. 현재 채팅 기능이 제한되어 있습니다.\n\n';
      response += '대신 AI 보고서를 생성하여 건강 상태를 확인해보세요.';
      
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

                        // 진행 상황 요약
                        _buildProgressSummary(),

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

  Widget _buildProgressSummary() {
    if (_progressData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('진행 상황 데이터를 불러오는 중...'),
        ),
      );
    }

    final medicationRecords = _progressData!['medicationRecords'] ?? [];
    final quizResults = _progressData!['quiz_results'] ?? [];
    final cognitiveScore = _progressData!['cognitive_score'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 진행 상황 요약',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFFE65100),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 복용 기록 요약
            _buildMedicationSummary(medicationRecords),
            const SizedBox(height: 16),
            
            // 퀴즈 결과 요약
            _buildQuizSummary(quizResults),
            const SizedBox(height: 16),
            
            // 인지 점수
            _buildCognitiveScore(cognitiveScore),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationSummary(List<dynamic> medicationRecords) {
    if (medicationRecords.isEmpty) {
      return _buildSummaryItem(
        '💊 약물 복용 기록',
        '아직 복용 기록이 없습니다.',
        Colors.grey,
      );
    }

    // 최근 7일간의 복용 기록 계산
    final recentRecords = medicationRecords.take(7).toList();
    int totalDoses = 0;
    int takenDoses = 0;

    for (var record in recentRecords) {
      if (record['morning'] == true) takenDoses++;
      if (record['lunch'] == true) takenDoses++;
      if (record['evening'] == true) takenDoses++;
      totalDoses += 3;
    }

    final complianceRate = totalDoses > 0 ? (takenDoses / totalDoses * 100).round() : 0;

    return _buildSummaryItem(
      '💊 약물 복용 기록 (최근 7일)',
      '복용률: $complianceRate% ($takenDoses/$totalDoses)',
      complianceRate >= 80 ? Colors.green : complianceRate >= 60 ? Colors.orange : Colors.red,
    );
  }

  Widget _buildQuizSummary(List<dynamic> quizResults) {
    if (quizResults.isEmpty) {
      return _buildSummaryItem(
        '🧠 퀴즈 결과',
        '아직 퀴즈 기록이 없습니다.',
        Colors.grey,
      );
    }

    final recentQuizzes = quizResults.take(5).toList();
    double averageScore = 0;
    if (recentQuizzes.isNotEmpty) {
      final scores = recentQuizzes.map((q) => q['score'] ?? 0.0).toList();
      averageScore = scores.reduce((a, b) => a + b) / scores.length;
    }

    return _buildSummaryItem(
      '🧠 퀴즈 결과 (최근 5회)',
      '평균 점수: ${averageScore.toStringAsFixed(1)}점',
      averageScore >= 7 ? Colors.green : averageScore >= 5 ? Colors.orange : Colors.red,
    );
  }

  Widget _buildCognitiveScore(double score) {
    String status;
    Color color;
    
    if (score >= 8) {
      status = '매우 좋음';
      color = Colors.green;
    } else if (score >= 6) {
      status = '좋음';
      color = Colors.blue;
    } else if (score >= 4) {
      status = '보통';
      color = Colors.orange;
    } else {
      status = '주의 필요';
      color = Colors.red;
    }

    return _buildSummaryItem(
      '🧠 인지 기능 점수',
      '$score점 ($status)',
      color,
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
