import 'package:dio/dio.dart';
import 'dart:convert';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  // 실행 시 --dart-define=OPENAI_API_KEY=... 로 주입
  static const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');
  
  final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    headers: {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    },
  ));

  /// ChatGPT API를 호출하여 환자 데이터 기반 AI 보고서 생성
  Future<String> generateMedicalReport({
    required String patientName,
    required Map<String, dynamic> progressData,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY 가 설정되지 않았습니다. flutter run 시 --dart-define=OPENAI_API_KEY=... 로 전달하세요.');
    }
    try {
      // 환자 데이터를 분석하여 프롬프트 생성
      final prompt = _buildMedicalPrompt(patientName, progressData);
      
      final response = await _dio.post('/chat/completions', data: {
        // 경량 최신 모델 권장. 필요 시 원래 gpt-4 로 변경 가능
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': '''당신은 알츠하이머 치매 전문 의사입니다. 
환자의 데이터를 분석하여 전문적이고 의학적으로 정확한 보고서를 한국어로 작성해주세요.

보고서는 다음 형식을 따라주세요:
1. 인지기능 평가 (MMSE-DS 기준)
2. 인지기능 7가지 영역 분석
3. 약물 복용 현황
4. 기분 상태 및 행동심리증상 (BPSD) 평가
5. 의학적 권장사항
6. 비약물적 중재 권장
7. 향후 목표 및 주의사항

의학적 용어를 사용하고, 전문적이면서도 이해하기 쉽게 작성해주세요.'''
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': 1500,
        'temperature': 0.7,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('OpenAI API 오류: $e');
      // API 호출 실패 시 기본 템플릿 반환
      return _generateFallbackReport(patientName, progressData);
    }
  }

  /// 실시간 채팅 응답 생성
  Future<String> generateChatResponse({
    required String userMessage,
    required String patientName,
    required Map<String, dynamic> progressData,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY 가 설정되지 않았습니다.');
    }
    
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': 'gpt-4o-mini',
        'messages': [
          {
            'role': 'system',
            'content': '''당신은 알츠하이머 치매 환자와 보호자를 돕는 친근하고 전문적인 의료 상담사입니다.

환자 정보:
- 이름: $patientName
- 퀴즈 평균 정답률: ${_calculateAverageQuizScore(progressData['quizResults'] as List)}%
- 약물 복용 준수율: ${(progressData['medicationCompliance'] ?? 0).round()}%
- 인지 점수: ${(progressData['cognitiveScore'] ?? 0).round()}/100점

당신의 역할:
1. 환자와 보호자의 질문에 친근하고 이해하기 쉽게 답변
2. 의학적 조언과 일상생활 가이드 제공
3. 치매 예방과 관리에 대한 실용적인 팁 제시
4. 항상 따뜻하고 격려하는 톤 유지
5. 한국어로 자연스럽게 대화

답변은 간결하고 실용적이어야 하며, 필요시 환자 데이터를 참고하여 개인화된 조언을 제공하세요.'''
          },
          {
            'role': 'user',
            'content': userMessage,
          }
        ],
        'max_tokens': 500,
        'temperature': 0.8,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final content = data['choices'][0]['message']['content'];
        return content;
      } else {
        throw Exception('API 호출 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('OpenAI 채팅 API 오류: $e');
      return '죄송합니다. 응답을 생성하는 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  /// 의학적 프롬프트 생성
  String _buildMedicalPrompt(String patientName, Map<String, dynamic> progressData) {
    final quizResults = progressData['quizResults'] as List;
    final medicationCompliance = progressData['medicationCompliance'];
    final moodTrend = progressData['moodTrend'] as List;
    final cognitiveScore = progressData['cognitiveScore'];
    
    final averageQuizScore = _calculateAverageQuizScore(quizResults);
    final averageMoodScore = _calculateAverageMoodScore(moodTrend);
    
    return '''
환자명: $patientName

퀴즈 성과 데이터:
- 참여 횟수: ${quizResults.length}회
- 평균 정답률: $averageQuizScore%
- 최근 퀴즈 결과: ${quizResults.map((q) => '${q['date']}: ${q['score']}/${q['total']}').join(', ')}

약물 복용 현황:
- 복용 준수율: ${medicationCompliance.round()}%

기분 상태:
- 평균 기분 점수: $averageMoodScore/5점
- 기분 변화: ${moodTrend.map((m) => '${m['date']}: ${m['mood']}').join(', ')}

인지 능력:
- 종합 인지 점수: ${cognitiveScore.round()}/100점

위 데이터를 바탕으로 전문적인 의학 보고서를 작성해주세요.
치매 환자의 인지 기능, 약물 복용, 기분 상태를 종합적으로 분석하고,
의학적 관점에서 개선 방안과 권장사항을 제시해주세요.''';
  }

  /// 평균 퀴즈 정답률 계산
  int _calculateAverageQuizScore(List quizResults) {
    if (quizResults.isEmpty) return 0;
    
    int totalScore = 0;
    int totalQuestions = 0;
    
    for (var quiz in quizResults) {
      totalScore += quiz['score'] as int;
      totalQuestions += quiz['total'] as int;
    }
    
    if (totalQuestions == 0) return 0;
    return ((totalScore / totalQuestions) * 100).round();
  }

  /// 평균 기분 점수 계산
  double _calculateAverageMoodScore(List moodTrend) {
    if (moodTrend.isEmpty) return 0.0;
    
    int totalScore = 0;
    for (var mood in moodTrend) {
      totalScore += mood['score'] as int;
    }
    
    return (totalScore / moodTrend.length).toDouble();
  }

  /// API 호출 실패 시 기본 보고서 생성
  String _generateFallbackReport(String patientName, Map<String, dynamic> progressData) {
    final averageQuizScore = _calculateAverageQuizScore(progressData['quizResults']);
    
    return '''
환자 ${patientName}님의 치매 진행상황 전문 의학 보고서 (기본 템플릿)
- 인지 점수: ${progressData['cognitiveScore'].round()}점 / 100점
- 퀴즈 평균 정답률: $averageQuizScore%
- 약물 복용 준수율: ${progressData['medicationCompliance'].round()}%
- 기분 상태 평균: ${_calculateAverageMoodScore(progressData['moodTrend'])} / 5점

권장사항: 정기적인 인지 훈련, 복용 시간 준수, 긍정적 상호작용 유지.''';
  }
}
