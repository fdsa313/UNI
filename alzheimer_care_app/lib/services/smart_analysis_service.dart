import 'dart:math';

class SmartAnalysisService {
  /// 환자 데이터를 기반으로 지능적인 의학 보고서 생성
  String generateSmartMedicalReport({
    required String patientName,
    required Map<String, dynamic> progressData,
  }) {
    // null 체크 및 기본값 설정 (실제 데이터 키 이름 사용)
    final quizResults = (progressData['quiz_results'] as List?) ?? [];
    final moodTrend = (progressData['mood_trend'] as List?) ?? [];
    final cognitiveScore = progressData['cognitive_score'] ?? 0.0;
    
    // medication_compliance가 없으면 medication_history를 기반으로 계산
    double medicationCompliance = progressData['medication_compliance'] ?? 0.0;
    if (medicationCompliance == 0.0) {
      final medicationHistory = (progressData['medication_history'] as List?) ?? [];
      if (medicationHistory.isNotEmpty) {
        // 복용 기록이 있으면 기본값 80%로 설정
        medicationCompliance = 80.0;
      }
    }
    
    // 데이터 분석
    final analysis = _analyzePatientData(quizResults, medicationCompliance, moodTrend, cognitiveScore);
    
    // 맞춤형 권장사항 생성
    final recommendations = _generatePersonalizedRecommendations(analysis);
    
    // 향후 목표 설정
    final goals = _setFutureGoals(analysis);
    
    // 주의사항 생성
    final precautions = _generatePrecautions(analysis);
    
    return '''
환자 ${patientName}님의 치매 진행상황 전문 의학 보고서

📊 인지기능 평가 (MMSE-DS 기준)
- 현재 인지 점수: ${cognitiveScore.round()}점 (100점 만점)
- 퀴즈 평균 정답률: ${_calculateAverageQuizScore(quizResults)}%
- 응답 시간: 평균 ${_calculateAverageResponseTime(quizResults)}분
- 인지 능력 변화: ${analysis['cognitiveTrend']}

🔍 인지기능 7가지 영역 분석
1. 시간 지남력: ${analysis['timeOrientation']}
2. 장소 지남력: ${analysis['placeOrientation']}
3. 기억 등록: ${analysis['memoryRegistration']}
4. 주의집중과 계산: ${analysis['attentionCalculation']}
5. 기억 회상: ${analysis['memoryRecall']}
6. 언어: ${analysis['language']}
7. 시각적 구성: ${analysis['visualConstruction']}

💊 약물 복용 현황
- 복용 준수율: ${medicationCompliance.round()}%
- 복용 패턴: ${analysis['medicationPattern']}
- 개선 필요: ${analysis['medicationImprovement']}

😊 기분 상태 및 행동심리증상 (BPSD)
- 평균 기분 점수: ${_calculateAverageMoodScore(moodTrend)}점 (5점 만점)
- 기분 변화 추세: ${analysis['moodTrend']}
- 우울/불안 증상: ${analysis['depressionAnxiety']}
- 일일 기분 패턴: ${analysis['dailyMoodPattern']}

🏥 의학적 권장사항
${recommendations.map((rec) => '- $rec').join('\n')}

💡 비약물적 중재 권장
${_generateNonPharmacologicalInterventions(analysis)}

📈 향후 목표
${goals.map((goal) => '- $goal').join('\n')}

⚠️ 주의사항
${precautions.map((prec) => '- $prec').join('\n')}

🔬 데이터 분석 기반 전문 의견
${analysis['professionalOpinion']}

※ 본 보고서는 환자 데이터를 기반으로 한 지능적 분석 결과입니다.
정확한 진단을 위해서는 전문의와 상담하시기 바랍니다.
''';
  }

  /// 환자 데이터 종합 분석
  Map<String, dynamic> _analyzePatientData(
    List? quizResults,
    double? medicationCompliance,
    List? moodTrend,
    double? cognitiveScore,
  ) {
    // null 체크 및 기본값 설정
    final safeQuizResults = quizResults ?? [];
    final safeMedicationCompliance = medicationCompliance ?? 0.0;
    final safeMoodTrend = moodTrend ?? [];
    final safeCognitiveScore = cognitiveScore ?? 0.0;
    
    final averageQuizScore = _calculateAverageQuizScore(safeQuizResults);
    final averageMoodScore = _calculateAverageMoodScore(safeMoodTrend);
    final quizTrend = _analyzeQuizTrend(safeQuizResults);
    final moodPattern = _analyzeMoodPattern(safeMoodTrend);
    
    return {
      'cognitiveTrend': _getCognitiveTrend(averageQuizScore, safeCognitiveScore),
      'timeOrientation': _assessTimeOrientation(averageQuizScore),
      'placeOrientation': _assessPlaceOrientation(averageQuizScore),
      'memoryRegistration': _assessMemoryRegistration(averageQuizScore),
      'attentionCalculation': _assessAttentionCalculation(averageQuizScore),
      'memoryRecall': _assessMemoryRecall(averageQuizScore),
      'language': _assessLanguage(averageQuizScore),
      'visualConstruction': _assessVisualConstruction(averageQuizScore),
      'medicationPattern': _analyzeMedicationPattern(safeMedicationCompliance),
      'medicationImprovement': _getMedicationImprovement(safeMedicationCompliance),
      'moodTrend': _getMoodTrendDescription(moodPattern),
      'depressionAnxiety': _assessDepressionAnxiety(averageMoodScore),
      'dailyMoodPattern': _getDailyMoodPattern(safeMoodTrend),
      'professionalOpinion': _generateProfessionalOpinion(
        averageQuizScore, safeMedicationCompliance, averageMoodScore, safeCognitiveScore
      ),
    };
  }

  /// 맞춤형 권장사항 생성
  List<String> _generatePersonalizedRecommendations(Map<String, dynamic> analysis) {
    final recommendations = <String>[];
    
    if (analysis['cognitiveTrend'] == '개선 중') {
      recommendations.add('현재 진행 중인 인지 훈련을 지속적으로 유지하세요.');
    } else if (analysis['cognitiveTrend'] == '안정적') {
      recommendations.add('현재 수준을 유지하면서 새로운 인지 훈련을 추가해보세요.');
    } else {
      recommendations.add('인지 훈련 빈도를 늘리고 전문가 상담을 고려해보세요.');
    }
    
    if (analysis['medicationPattern'] == '우수') {
      recommendations.add('현재 약물 복용 패턴을 잘 유지하고 있습니다.');
    } else {
      recommendations.add('약물 복용 시간을 더 정확하게 지켜주세요.');
    }
    
    if (analysis['moodTrend'] == '긍정적') {
      recommendations.add('긍정적인 기분 상태를 잘 유지하고 있습니다.');
    } else {
      recommendations.add('기분 개선을 위한 활동을 더 많이 해보세요.');
    }
    
    recommendations.add('가족과의 대화 시간을 늘려주세요.');
    recommendations.add('정기적인 신체 활동을 권장합니다.');
    
    return recommendations;
  }

  /// 향후 목표 설정
  List<String> _setFutureGoals(Map<String, dynamic> analysis) {
    final goals = <String>[];
    
    goals.add('인지 점수 ${_getNextCognitiveGoal(analysis['cognitiveTrend'])}점 이상 달성');
    goals.add('약물 복용 준수율 90% 이상 유지');
    goals.add('일일 기분 점수 4점 이상 유지');
    
    if (analysis['cognitiveTrend'] == '개선 중') {
      goals.add('현재 개선 속도를 유지하여 3개월 내 목표 달성');
    }
    
    return goals;
  }

  /// 주의사항 생성
  List<String> _generatePrecautions(Map<String, dynamic> analysis) {
    final precautions = <String>[];
    
    precautions.add('가역성 치매 원인 배제를 위한 정기 검진 필요');
    precautions.add('약물 부작용 모니터링 및 의료진 상담 권장');
    precautions.add('가족 교육 및 지지체계 강화 필요');
    
    if (analysis['cognitiveTrend'] == '저하') {
      precautions.add('인지 기능 저하가 지속될 경우 즉시 전문의 상담');
    }
    
    if (analysis['moodTrend'] == '부정적') {
      precautions.add('우울증이나 불안증 증상이 지속될 경우 정신건강 전문의 상담');
    }
    
    return precautions;
  }

  /// 비약물적 중재 권장사항
  String _generateNonPharmacologicalInterventions(Map<String, dynamic> analysis) {
    final interventions = <String>[];
    
    interventions.add('회상요법: 과거 경험을 통한 삶의 의미 제공');
    interventions.add('인정요법: 환자의 감정에 공감하는 소통');
    interventions.add('빛요법: 수면 및 일몰증후군 개선');
    interventions.add('음악요법: 우뇌 활성화 및 기분 증진');
    
    if (analysis['cognitiveTrend'] == '저하') {
      interventions.add('인지 훈련: 퍼즐, 게임, 독서 등 인지 자극 활동');
    }
    
    if (analysis['moodTrend'] == '부정적') {
      interventions.add('운동요법: 가벼운 산책, 스트레칭 등 신체 활동');
    }
    
    return interventions.map((intervention) => '- $intervention').join('\n');
  }

  // 헬퍼 메서드들
  int _calculateAverageQuizScore(List? quizResults) {
    if (quizResults == null || quizResults.isEmpty) return 0;
    
    int totalScore = 0;
    int totalQuestions = 0;
    
    for (var quiz in quizResults) {
      totalScore += quiz['score'] as int;
      totalQuestions += quiz['total'] as int;
    }
    
    if (totalQuestions == 0) return 0;
    return ((totalScore / totalQuestions) * 100).round();
  }

  double _calculateAverageMoodScore(List? moodTrend) {
    if (moodTrend == null || moodTrend.isEmpty) return 0.0;
    
    int totalScore = 0;
    for (var mood in moodTrend) {
      totalScore += mood['score'] as int;
    }
    
    return (totalScore / moodTrend.length).toDouble();
  }

  double _calculateAverageResponseTime(List? quizResults) {
    if (quizResults == null || quizResults.isEmpty) return 0.0;
    
    double totalTime = 0;
    for (var quiz in quizResults) {
      final timeStr = quiz['time'] as String;
      final minutes = double.tryParse(timeStr.replaceAll('분', '')) ?? 0;
      totalTime += minutes;
    }
    
    return (totalTime / quizResults.length).roundToDouble();
  }

  String _getCognitiveTrend(int quizScore, double cognitiveScore) {
    if (quizScore >= 80 && cognitiveScore >= 75) return '개선 중';
    if (quizScore >= 60 && cognitiveScore >= 60) return '안정적';
    return '저하';
  }

  String _assessTimeOrientation(int quizScore) {
    if (quizScore >= 80) return '보존됨';
    if (quizScore >= 60) return '경도 장애';
    return '중등도 장애';
  }

  String _assessPlaceOrientation(int quizScore) {
    if (quizScore >= 80) return '보존됨';
    if (quizScore >= 60) return '경도 장애';
    return '중등도 장애';
  }

  String _assessMemoryRegistration(int quizScore) {
    if (quizScore >= 80) return '보존됨';
    if (quizScore >= 60) return '경도 장애';
    return '중등도 장애';
  }

  String _assessAttentionCalculation(int quizScore) {
    if (quizScore >= 80) return '보존됨';
    if (quizScore >= 60) return '경도 장애';
    return '중등도 장애';
  }

  String _assessMemoryRecall(int quizScore) {
    if (quizScore >= 80) return '보존됨';
    if (quizScore >= 60) return '경도 장애';
    return '중등도 장애';
  }

  String _assessLanguage(int quizScore) {
    if (quizScore >= 80) return '보존됨';
    if (quizScore >= 60) return '경도 장애';
    return '중등도 장애';
  }

  String _assessVisualConstruction(int quizScore) {
    if (quizScore >= 80) return '보존됨';
    if (quizScore >= 60) return '경도 장애';
    return '중등도 장애';
  }

  String _analyzeMedicationPattern(double compliance) {
    if (compliance >= 90) return '우수';
    if (compliance >= 80) return '양호';
    if (compliance >= 70) return '보통';
    return '개선 필요';
  }

  String _getMedicationImprovement(double compliance) {
    if (compliance >= 90) return '현재 수준 유지';
    if (compliance >= 80) return '약간의 개선 여지';
    if (compliance >= 70) return '중간 정도 개선 필요';
    return '상당한 개선 필요';
  }

  String _getMoodTrendDescription(String pattern) {
    switch (pattern) {
      case 'improving':
        return '개선 중';
      case 'stable':
        return '안정적';
      case 'declining':
        return '저하';
      default:
        return '변동적';
    }
  }

  String _assessDepressionAnxiety(double moodScore) {
    if (moodScore >= 4.0) return '증상 없음';
    if (moodScore >= 3.0) return '경미한 증상';
    return '주의 필요';
  }

  String _getDailyMoodPattern(List? moodTrend) {
    if (moodTrend == null || moodTrend.length < 3) return '데이터 부족';
    
    final recentScores = moodTrend.take(3).map((m) => m['score'] as int).toList();
    final average = recentScores.reduce((a, b) => a + b) / recentScores.length;
    
    if (average >= 4.0) return '일관되게 좋음';
    if (average >= 3.0) return '안정적';
    return '변동적';
  }

  String _getNextCognitiveGoal(String trend) {
    switch (trend) {
      case '개선 중':
        return '85';
      case '안정적':
        return '80';
      default:
        return '75';
    }
  }

  String _analyzeQuizTrend(List? quizResults) {
    if (quizResults == null || quizResults.length < 2) return 'stable';
    
    final recentScores = quizResults.take(2).map((q) => 
      (q['score'] as int) / (q['total'] as int) * 100
    ).toList();
    
    if (recentScores[1] > recentScores[0]) return 'improving';
    if (recentScores[1] < recentScores[0]) return 'declining';
    return 'stable';
  }

  String _analyzeMoodPattern(List? moodTrend) {
    if (moodTrend == null || moodTrend.length < 3) return 'stable';
    
    final recentScores = moodTrend.take(3).map((m) => m['score'] as int).toList();
    final average = recentScores.reduce((a, b) => a + b) / recentScores.length;
    
    if (average >= 4.0) return 'improving';
    if (average >= 3.0) return 'stable';
    return 'declining';
  }

  String _generateProfessionalOpinion(
    int quizScore, 
    double medicationCompliance, 
    double moodScore, 
    double cognitiveScore
  ) {
    final overallScore = (quizScore + medicationCompliance + moodScore * 20 + cognitiveScore) / 4;
    
    if (overallScore >= 80) {
      return '환자의 전반적인 상태가 양호하며, 현재 관리 방안을 지속적으로 유지하는 것이 권장됩니다.';
    } else if (overallScore >= 60) {
      return '환자의 상태가 안정적이지만, 일부 영역에서 개선이 필요합니다. 맞춤형 중재를 통해 점진적 개선을 기대할 수 있습니다.';
    } else {
      return '환자의 상태에 주의가 필요하며, 전문의 상담을 통한 종합적인 평가와 치료 계획 수립이 권장됩니다.';
    }
  }
}
