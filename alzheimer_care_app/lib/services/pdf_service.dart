import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

class PDFService {
  /// AI 분석 결과를 PDF로 생성
  Future<String> generateAnalysisPDF({
    required String patientName,
    required String aiReport,
    required Map<String, dynamic> progressData,
    required String reportType, // 'ai', 'smart', 'chat'
  }) async {
    try {
      // PDF 문서 생성
      final PdfDocument document = PdfDocument();
      
      // 페이지 추가
      final PdfPage page = document.pages.add();
      final PdfGraphics graphics = page.graphics;
      
      // 폰트 설정
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
      final PdfFont subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
      final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
      final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
      final PdfFont smallFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
      
      // 색상 설정
      final PdfColor primaryColor = PdfColor(255, 183, 77); // #FFB74D
      final PdfColor secondaryColor = PdfColor(230, 81, 0); // #E65100
      final PdfColor textColor = PdfColor(33, 33, 33);
      
      // 현재 위치
      double yPosition = 50;
      
      // 헤더 (환자 정보)
      _drawHeader(graphics, patientName, reportType, titleFont, primaryColor, secondaryColor);
      yPosition = 120;
      
      // 요약 정보 박스
      yPosition = _drawSummaryBox(graphics, progressData, headerFont, bodyFont, primaryColor, yPosition);
      yPosition += 30;
      
      // AI 분석 보고서
      yPosition = _drawAIReport(graphics, aiReport, headerFont, bodyFont, textColor, yPosition);
      yPosition += 30;
      
      // 상세 데이터
      yPosition = _drawDetailedData(graphics, progressData, headerFont, bodyFont, smallFont, yPosition);
      yPosition += 30;
      
      // 푸터
      _drawFooter(graphics, page, smallFont, yPosition);
      
      // PDF 저장
      final String fileName = '${patientName}_AI분석보고서_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String filePath = await _savePDF(document, fileName);
      
      // 문서 해제
      document.dispose();
      
      return filePath;
    } catch (e) {
      print('❌ PDF 생성 오류: $e');
      rethrow;
    }
  }
  
  /// 헤더 그리기
  void _drawHeader(PdfGraphics graphics, String patientName, String reportType, 
                   PdfFont titleFont, PdfColor primaryColor, PdfColor secondaryColor) {
    // 배경 박스
    final PdfBrush backgroundBrush = PdfSolidBrush(primaryColor);
    graphics.drawRectangle(
      brush: backgroundBrush,
      bounds: Rect.fromLTWH(0, 0, 595, 80)
    );
    
    // 제목
    final String title = '$patientName님의 AI 분석 보고서';
    final PdfStringFormat titleFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    
    graphics.drawString(
      title,
      titleFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(0, 20, 595, 40),
      format: titleFormat,
    );
    
    // 부제목
    final String subtitle = '생성일: ${DateTime.now().toString().substring(0, 19)}';
    final PdfFont subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    graphics.drawString(
      subtitle,
      subtitleFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(0, 60, 595, 20),
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );
  }
  
  /// 요약 정보 박스 그리기
  double _drawSummaryBox(PdfGraphics graphics, Map<String, dynamic> progressData, 
                         PdfFont headerFont, PdfFont bodyFont, PdfColor primaryColor, double yPosition) {
    // 요약 박스 배경
    final PdfBrush boxBrush = PdfSolidBrush(PdfColor(255, 248, 225));
    graphics.drawRectangle(
      brush: boxBrush,
      bounds: Rect.fromLTWH(30, yPosition, 535, 80),
    );
    
    // 테두리
    final PdfPen borderPen = PdfPen(primaryColor, width: 2);
    graphics.drawRectangle(
      pen: borderPen,
      bounds: Rect.fromLTWH(30, yPosition, 535, 80),
    );
    
    // 요약 정보
    final String summaryTitle = '📊 주요 지표 요약';
    graphics.drawString(
      summaryTitle,
      headerFont,
      brush: PdfSolidBrush(PdfColor(230, 81, 0)),
      bounds: Rect.fromLTWH(50, yPosition + 10, 200, 20),
    );
    
    // 인지 점수
    final cognitiveScore = progressData['cognitive_score'] ?? 0.0;
    graphics.drawString(
      '인지 점수: ${cognitiveScore.round()}점',
      bodyFont,
      brush: PdfSolidBrush(PdfColor(33, 33, 33)),
      bounds: Rect.fromLTWH(50, yPosition + 35, 150, 15),
    );
    
    // 퀴즈 평균
    final quizResults = progressData['quiz_results'] ?? [];
    final avgQuizScore = _calculateAverageQuizScore(quizResults);
    graphics.drawString(
      '퀴즈 평균: ${avgQuizScore}%',
      bodyFont,
      brush: PdfSolidBrush(PdfColor(33, 33, 33)),
      bounds: Rect.fromLTWH(250, yPosition + 35, 150, 15),
    );
    
    // 약물 준수율
    final medicationCompliance = progressData['medication_compliance'] ?? 0.0;
    graphics.drawString(
      '약물 준수율: ${medicationCompliance.round()}%',
      bodyFont,
      brush: PdfSolidBrush(PdfColor(33, 33, 33)),
      bounds: Rect.fromLTWH(450, yPosition + 35, 150, 15),
    );
    
    return yPosition + 90;
  }
  
  /// AI 보고서 그리기
  double _drawAIReport(PdfGraphics graphics, String aiReport, 
                      PdfFont headerFont, PdfFont bodyFont, PdfColor textColor, double yPosition) {
    // 섹션 제목
    graphics.drawString(
      '🤖 AI 분석 보고서',
      headerFont,
      brush: PdfSolidBrush(textColor),
      bounds: Rect.fromLTWH(30, yPosition, 200, 20),
    );
    
    yPosition += 25;
    
    // AI 보고서 내용을 줄 단위로 분할하여 그리기
    final List<String> lines = _splitTextIntoLines(aiReport, 80);
    final PdfBrush textBrush = PdfSolidBrush(textColor);
    
    for (String line in lines) {
      if (yPosition > 750) { // 페이지 끝에 가까우면 새 페이지
        break;
      }
      
      graphics.drawString(
        line,
        bodyFont,
        brush: textBrush,
        bounds: Rect.fromLTWH(30, yPosition, 535, 15),
      );
      
      yPosition += 18;
    }
    
    return yPosition;
  }
  
  /// 상세 데이터 그리기
  double _drawDetailedData(PdfGraphics graphics, Map<String, dynamic> progressData,
                          PdfFont headerFont, PdfFont bodyFont, PdfFont smallFont, double yPosition) {
    // 섹션 제목
    graphics.drawString(
      '📈 상세 데이터 분석',
      headerFont,
      brush: PdfSolidBrush(PdfColor(33, 33, 33)),
      bounds: Rect.fromLTWH(30, yPosition, 200, 20),
    );
    
    yPosition += 25;
    
    // 퀴즈 결과 테이블
    final quizResults = progressData['quiz_results'] ?? [];
    if (quizResults.isNotEmpty) {
      yPosition = _drawQuizResultsTable(graphics, quizResults, headerFont, bodyFont, yPosition);
      yPosition += 20;
    }
    
    // 기분 트렌드
    final moodTrend = progressData['mood_trend'] ?? [];
    if (moodTrend.isNotEmpty) {
      yPosition = _drawMoodTrendTable(graphics, moodTrend, headerFont, bodyFont, yPosition);
      yPosition += 20;
    }
    
    return yPosition;
  }
  
  /// 퀴즈 결과 테이블 그리기
  double _drawQuizResultsTable(PdfGraphics graphics, List quizResults, 
                              PdfFont headerFont, PdfFont bodyFont, double yPosition) {
    // 테이블 헤더
    final PdfBrush headerBrush = PdfSolidBrush(PdfColor(255, 183, 77));
    graphics.drawRectangle(
      brush: headerBrush,
      bounds: Rect.fromLTWH(30, yPosition, 535, 25),
    );
    
    // 헤더 텍스트
    graphics.drawString(
      '날짜',
      headerFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(40, yPosition + 5, 100, 15),
    );
    
    graphics.drawString(
      '점수',
      headerFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(150, yPosition + 5, 100, 15),
    );
    
    graphics.drawString(
      '소요시간',
      headerFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(270, yPosition + 5, 100, 15),
    );
    
    graphics.drawString(
      '정답률',
      headerFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(390, yPosition + 5, 100, 15),
    );
    
    yPosition += 25;
    
    // 테이블 데이터
    for (var quiz in quizResults.take(10)) { // 최근 10개만 표시
      final date = quiz['date'] ?? 'N/A';
      final score = (quiz['score'] ?? 0) as int;
      final total = (quiz['total'] ?? 1) as int;
      final time = quiz['time'] ?? 'N/A';
      final percentage = ((score / total) * 100).round();
      
      graphics.drawString(
        date,
        bodyFont,
        brush: PdfSolidBrush(PdfColor(33, 33, 33)),
        bounds: Rect.fromLTWH(40, yPosition + 5, 100, 15),
      );
      
      graphics.drawString(
        '$score/$total',
        bodyFont,
        brush: PdfSolidBrush(PdfColor(33, 33, 33)),
        bounds: Rect.fromLTWH(150, yPosition + 5, 100, 15),
      );
      
      graphics.drawString(
        time,
        bodyFont,
        brush: PdfSolidBrush(PdfColor(33, 33, 33)),
        bounds: Rect.fromLTWH(270, yPosition + 5, 100, 15),
      );
      
      graphics.drawString(
        '$percentage%',
        bodyFont,
        brush: PdfSolidBrush(PdfColor(33, 33, 33)),
        bounds: Rect.fromLTWH(390, yPosition + 5, 100, 15),
      );
      
      yPosition += 20;
    }
    
    return yPosition;
  }
  
  /// 기분 트렌드 테이블 그리기
  double _drawMoodTrendTable(PdfGraphics graphics, List moodTrend, 
                            PdfFont headerFont, PdfFont bodyFont, double yPosition) {
    // 테이블 헤더
    final PdfBrush headerBrush = PdfSolidBrush(PdfColor(255, 183, 77));
    graphics.drawRectangle(
      brush: headerBrush,
      bounds: Rect.fromLTWH(30, yPosition, 535, 25),
    );
    
    // 헤더 텍스트
    graphics.drawString(
      '날짜',
      headerFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(40, yPosition + 5, 100, 15),
    );
    
    graphics.drawString(
      '기분',
      headerFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(150, yPosition + 5, 100, 15),
    );
    
    graphics.drawString(
      '점수',
      headerFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(270, yPosition + 5, 100, 15),
    );
    
    graphics.drawString(
      '평가',
      headerFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(390, yPosition + 5, 100, 15),
    );
    
    yPosition += 25;
    
    // 테이블 데이터
    for (var mood in moodTrend.take(10)) { // 최근 10개만 표시
      final date = mood['date'] ?? 'N/A';
      final moodText = mood['mood'] ?? 'N/A';
      final score = mood['score'] ?? 0;
      final evaluation = _getMoodEvaluation(score);
      
      graphics.drawString(
        date,
        bodyFont,
        brush: PdfSolidBrush(PdfColor(33, 33, 33)),
        bounds: Rect.fromLTWH(40, yPosition + 5, 100, 15),
      );
      
      graphics.drawString(
        moodText,
        bodyFont,
        brush: PdfSolidBrush(PdfColor(33, 33, 33)),
        bounds: Rect.fromLTWH(150, yPosition + 5, 100, 15),
      );
      
      graphics.drawString(
        '$score/5',
        bodyFont,
        brush: PdfSolidBrush(PdfColor(33, 33, 33)),
        bounds: Rect.fromLTWH(270, yPosition + 5, 100, 15),
      );
      
      graphics.drawString(
        evaluation,
        bodyFont,
        brush: PdfSolidBrush(PdfColor(33, 33, 33)),
        bounds: Rect.fromLTWH(390, yPosition + 5, 100, 15),
      );
      
      yPosition += 20;
    }
    
    return yPosition;
  }
  
  /// 푸터 그리기
  void _drawFooter(PdfGraphics graphics, PdfPage page, PdfFont smallFont, double yPosition) {
    final String footerText = '본 보고서는 AI 분석을 통해 자동 생성되었습니다. 의료진과 상담하시기 바랍니다.';
    
    graphics.drawString(
      footerText,
      smallFont,
      brush: PdfSolidBrush(PdfColor(128, 128, 128)),
      bounds: Rect.fromLTWH(30, yPosition, 535, 15),
    );
    
    // 페이지 번호
    final String pageNumber = '페이지 1';
    graphics.drawString(
      pageNumber,
      smallFont,
      brush: PdfSolidBrush(PdfColor(128, 128, 128)),
      bounds: Rect.fromLTWH(500, yPosition, 65, 15),
    );
  }
  
  /// PDF 저장
  Future<String> _savePDF(PdfDocument document, String fileName) async {
    try {
      // 웹 환경에서는 권한 요청 없이 바로 다운로드
      if (kIsWeb) {
        // 웹에서는 PDF 생성만 하고 다운로드를 위한 옵션 제공
        print('✅ 웹 PDF 생성 완료: $fileName');
        print('💡 웹에서는 PDF가 생성되었습니다.');
        print('📥 다운로드 방법:');
        print('   1. 모바일 앱 사용 (권장)');
        print('   2. 클립보드에 복사 후 붙여넣기');
        print('   3. 브라우저 개발자 도구에서 확인');
        
        // 웹에서 클립보드에 PDF 데이터 복사 시도
        try {
          await _copyPDFToClipboard(document, fileName);
          print('✅ PDF가 클립보드에 복사되었습니다!');
        } catch (e) {
          print('⚠️ 클립보드 복사 실패: $e');
        }
        
        return 'web_generated_$fileName';
      } else {
        // 모바일 환경에서만 권한 요청
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('저장소 접근 권한이 필요합니다.');
        }
        
        // 문서를 바이트로 변환
        final List<int> bytes = await document.save();
        
        // 저장 경로 설정
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String filePath = '${appDocDir.path}/$fileName';
        
        // 파일 저장
        final File file = File(filePath);
        await file.writeAsBytes(bytes);
        
        print('✅ 모바일 PDF 저장 완료: $filePath');
        return filePath;
      }
    } catch (e) {
      print('❌ PDF 저장 실패: $e');
      rethrow;
    }
  }

  /// 웹에서 PDF를 클립보드에 복사
  Future<void> _copyPDFToClipboard(PdfDocument document, String fileName) async {
    try {
      // PDF를 바이트로 변환
      final List<int> bytes = await document.save();
      
      // Base64로 인코딩
      final String base64Data = base64Encode(bytes);
      
      // 클립보드에 복사할 데이터 준비
      final String clipboardData = '''
📄 AI 분석 보고서 PDF 데이터

파일명: $fileName
생성일: ${DateTime.now().toString().substring(0, 19)}
크기: ${(bytes.length / 1024).toStringAsFixed(1)} KB

Base64 데이터:
$base64Data

사용법:
1. 이 데이터를 텍스트 파일로 저장
2. 파일 확장자를 .pdf로 변경
3. PDF 뷰어로 열기

또는:
1. 온라인 Base64 to PDF 변환기 사용
2. 위 Base64 데이터를 붙여넣기
3. PDF 다운로드
''';
      
      // 클립보드에 복사
      await Clipboard.setData(ClipboardData(text: clipboardData));
      
      print('✅ PDF 데이터가 클립보드에 복사되었습니다!');
      print('💡 이제 원하는 곳에 붙여넣기(Ctrl+V)할 수 있습니다.');
      
    } catch (e) {
      print('❌ 클립보드 복사 실패: $e');
      rethrow;
    }
  }
  
  /// 텍스트를 줄 단위로 분할
  List<String> _splitTextIntoLines(String text, int maxCharsPerLine) {
    final List<String> lines = [];
    final List<String> words = text.split(' ');
    String currentLine = '';
    
    for (String word in words) {
      if ((currentLine + word).length <= maxCharsPerLine) {
        currentLine += (currentLine.isEmpty ? '' : ' ') + word;
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
        }
        currentLine = word;
      }
    }
    
    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }
    
    return lines;
  }
  
  /// 평균 퀴즈 점수 계산
  int _calculateAverageQuizScore(List quizResults) {
    if (quizResults.isEmpty) return 0;
    
    int totalScore = 0;
    int totalQuestions = 0;
    
    for (var quiz in quizResults) {
      totalScore += (quiz['score'] ?? 0) as int;
      totalQuestions += (quiz['total'] ?? 1) as int;
    }
    
    if (totalQuestions == 0) return 0;
    return ((totalScore / totalQuestions) * 100).round();
  }
  
  /// 기분 평가 텍스트 반환
  String _getMoodEvaluation(int score) {
    if (score >= 4) return '매우 좋음';
    if (score >= 3) return '좋음';
    if (score >= 2) return '보통';
    return '나쁨';
  }
}
